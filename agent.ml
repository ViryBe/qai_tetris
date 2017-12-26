(* TODO
   * finir les phis
   * fonction choose action
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

module Phis = struct
  (* convinient way to compute the dot production in L *)
  let zero _ = 1.

  let one b = 18.

  let two b = 18.

  (** max nb of 'neighbors' for all empty cells  in b*)
  let three b =
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    float (Array.fold_left (fun accu elt ->
        max accu (nb_adjacent_empty_cell elt)
      ) 0 tab)

  (* Same as #4 but with columns *)
  let four b =
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
  let five b =
    let accu = ref 0 in
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    for i = 0 to Array.length tab -2 do
      accu := !accu + nb_full_top tab.(i) tab.(i+1)
    done;
    float !accu

  let six b = 18.

  (** TODO find the diff between f5 and f7  *)
  let seven b =
    five b

  (** nb of rox with, at least, 1 hole *)
  let eight b =
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    let accu = ref 0 in
    for i = 0 to Array.length tab -2 do
      if nb_full_top tab.(i) tab.(i+1) > 0 then incr accu
    done;
    float !accu


  (** Array of all phis functions *)
  let phi_arr = [|zero; one; two; three; four; five; six; seven; eight|]
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
let init_weights () =
  Array.iteri (fun i _ -> weights.(i) <- Random.float 2. -.1.) weights


let phi board phi_arr =
  Array.map (fun f -> f board) phi_arr


(** gives V(\phi(board)) *)
let v_from_phis phis =
  Auxfct.dot phis weights

(** gives V(board) *)
(** useful ? not sure  *)
let v_from_board board =
  let s = phi board Phis.phi_arr in
  v_from_phis s

(** compute delta for a given transition t *)
let delta t gamma =
  t.r_t +. gamma *. (v_from_phis t.s_t1) -. (v_from_phis t.s_t)

(** compute loss function L for a mini-batch B *)
(** useful ? not sure  *)
let loss_f batch gamma =
  1. /. (2. *. float(Array.length batch)) *.
  Array.fold_left (fun accu elt -> accu +. (delta elt gamma)**2.) 0. batch

(** compute \nabla L with respect to w for a given batch*)
let grad_L batch gamma weights =
  let card_b = float (Array.length batch) in
  Array.mapi (fun index _ ->
      1. /. card_b *. (Array.fold_left (fun accu elt ->
          (delta elt gamma) *.
          (gamma *. v_from_phis elt.s_t1 -. v_from_phis elt.s_t)
        )) 0. batch
    ) weights

(** updates weights according to the gradient gard *)
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
let choose_action epsilon gamma idactions =
  Game.Action

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
      let prevfeatures = phi board Phis.phi_arr in
      (* From here, prev for previous is for var not impacted by Game.play *)
      Game.play board tetromino action;
      let features = phi board Phis.phi_arr in
      memory.(i) <- { s_t = prevfeatures;
                      a_t = act_ind;
                      r_t = r prevboard board;
                      s_t1= features} ;
      (* Update everything *)
      Game.play prevboard tetromino action ;
    done; (* memory is full *)
    let grad = grad_L memory gamma weights in
    update_weights weights grad eta
  done
