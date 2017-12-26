(* TODO
   * finir les phis
   * fonction choose action
   * decide how to deal with the 'playspec' thing
*)

(* ================================ *)
(*  useful functions for los phis   *)
(* ================================ *)

(** gives the number of 'neighbors' for all empty cells in a row  *)
let nb_adjacent_empty_cell row =
  let ret = ref 0 in
  if row.(0) = 0 then incr ret;
  for i = 0 to Array.length row -1 do
    if (i = Array.length row -1 && row.(i) = 0)
    || (i <> Array.length row -1) && (row.(i) = 0 && row.(i+1) <> 0)
    || (i <> Array.length row -1) && (row.(i) <> 0 && row.(i+1) = 0)
    then
      incr ret
  done;
  !ret

(* TODO: find a better name *)
let nb_full_top  row_0 row_1 =
  let ret = ref 0 in
  for i = 0 to Array.length row_0 -1 do
    if row_0.(i) = 0 && row_1.(i) <> 0 then incr ret
  done;
  !ret

(* Module computing features. The objective here is to avoid parsing all board
 * seven times each turn. Incremental updates are thereford advised, using data
 * passed through calls *)
module Features = struct
  (* Data used by the features *)
  type data = {
    wells: (int * int) list; (* coordinates of wells *)
  }

  (* The type of a feature *)
  type feat_sig = float -> data -> Game.Board.t -> Game.Action.ps -> int

  (* convenient way to compute the dot product in L *)
  let zero _ _ _ _ = 1.

  let one prev d b ps = 18.

  let two prev d b ps = 18.

  (** max nb of 'neighbors' for all empty cells  in b*)
  let three prev d b ps =
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    float (Array.fold_left (fun accu elt ->
        max accu (nb_adjacent_empty_cell elt)
      ) 0 tab)

  (* Same as #4 but with columns *)
  let four prev d b ps =
    let ret = ref 0 in
    let h = Game.Board.height b in
    let tab = Game.Board.to_arr 0 h b in
    for c = 0 to Game.Board.width - 1 do
      let col = Array.make h 0 in
      for r = 0 to h do
        col.(r) <- tab.(r).(c)
      done;
      ret := max !ret (nb_adjacent_empty_cell col)
    done;
    float !ret


  (** the number of filled cells above holes  *)
  let five prev d b ps =
    let accu = ref 0 in
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    for i = 0 to Array.length tab -2 do
      accu := !accu + nb_full_top tab.(i) tab.(i+1)
    done;
    float !accu

  let six prev d b ps = 18.

  (** TODO find the diff between f5 and f7  *)
  let seven prev d b ps =
    if List.mem (ps.x, ps.y) d.wells || List.mem (ps.x, ps.y + 1) d.wells
    then prev +. 1.
    else prev

  (** nb of rox with, at least, 1 hole *)
  let eight prev d b ps =
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    let accu = ref 0 in
    for i = 0 to Array.length tab -2 do
      if nb_full_top tab.(i) tab.(i+1) > 0 then incr accu
    done;
    float !accu

  (** Array of all phis functions *)
  let arr = [|zero; one; two; three; four; five; six; seven; eight|]

  (** Number of features considered *)
  let card = Array.length arr

  (* Compute all features *)
  let compute b ps = Array.map (fun f -> f b ps) arr
end


(** transition between 2 states *)
type transition = {
  s_t : float array;
  a_t : int;
  r_t : float;
  s_t1: float array
}

(* TODO: find a more elegent solution *)
let empty_trans = { s_t = [||]; a_t =0; r_t =0.; s_t1=[||]}


(* ================================ *)
(*  Everything about loss function  *)
(* ================================ *)

(** weights initialization between -1 and 1 *)
let make () =
  let w = Array.make Features.card 0. in
  Array.iteri (fun i _ -> w.(i) <- Random.float 2. -.1.) w ;
  w


(** gives V(\phi(board)) *)
let v_from_feat w feat = Auxfct.dot feat w

(** compute delta for a given transition t *)
let delta w t gamma =
  t.r_t +. gamma *. (v_from_feat w t.s_t1) -. (v_from_feat w t.s_t)

(** compute loss function L for a mini-batch B *)
(** useful ? not sure  *)
let loss_f w batch gamma =
  1. /. (2. *. float(Array.length batch)) *.
  Array.fold_left (fun accu elt -> accu +. (w delta elt gamma)**2.) 0. batch

(** compute \nabla L with respect to w for a given batch*)
let grad_L w batch gamma =
  let card_b = float (Array.length batch) in
  Array.mapi (fun index _ ->
      1. /. card_b *. (Array.fold_left (fun accu elt ->
          (delta w elt gamma) *.
          (gamma *. v_from_feat w elt.s_t1 -. v_from_feat w elt.s_t)
        )) 0. batch
    ) w

(** updates weights according to the gradient grad *)
let update_weights weights grad eta =
  Array.iteri (fun i elt -> weights.(i) <- weights.(i) -. eta *. elt) grad

(*  ===============================  *)
(*  ===============================  *)

(** Reward function *)
(* TODO: in aux function ? *)
let r backboard board =
  let x = Game.Board.height board - Game.Board.height backboard in
  if x >= 2 then -200.
  else if x = 1 then -100.
  else if x = 0 then 1.
  else 100. *. (float (abs x))


(** how to chosse the next action *)
(* TODO *)
(* besoin d'une fonction de signature:
   val simulation : Board -> Tetromino -> Rotation -> transition
qui ne modifie pas en place le plateau*)
let choose_action epsilon gamma idactions = Game.Action.from_int 0, 0

let update weights epsilon gamma eta ntetr batch_size =
  let memory = Array.make batch_size empty_trans
  and board = Game.Board.make (2 * ntetr)
  and prevboard = Game.Board.make (2 * ntetr)
  in
  for i = 0 to ntetr - 1 do
    (* fill the memory with some transitions *)
    for i = 0 to batch_size - 1 do
      let tetromino = Game.Tetromino.make_rand () in
      let idactions = Game.Tetromino.get_actids tetromino in
      let action, act_ind = choose_action epsilon gamma idactions in
      let prevfeatures = Features.compute board ps in
      (* From here, prev for previous is for var not impacted by Game.play *)
      Game.play board tetromino action;
      let features = Features.compute board ps in
      memory.(i) <- { s_t = prevfeatures;
                      a_t = act_ind;
                      r_t = r prevboard board;
                      s_t1= features} ;
      (* Update everything *)
      Game.play prevboard tetromino action ;
    done; (* memory is full *)
    let grad = grad_L weights memory gamma in
    update_weights weights grad eta
  done
