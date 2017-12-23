
(* TODO:
   * finir les phis
   * fonction choose action
* *)

(* ================================ *)
(*  useful functions for los phis   *)
(* ================================ *)

(* TODO make this a parameter *)
let batch_size = 10

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

module Features = struct

  (* convenient way to compute the dot production in L *)
  let zero _ _ = 1.

  let one b ps = 1.

  (* Cleared lines times contribution of the piece to cleard lines *)
  let two b ps = 1.

  (** max nb of 'neighbors' for all empty cells  in b*)
  let three b ps =
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    float (Array.fold_left (fun accu elt ->
        max accu (nb_adjacent_empty_cell elt)
      ) 0 tab)

  (* Same as #4 but with columns *)
  let four b ps =
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
  let five b ps =
    let accu = ref 0 in
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    for i = 0 to Array.length tab -2 do
      accu := !accu + nb_full_top tab.(i) tab.(i+1)
    done;
    float !accu

  let six b ps = 18.

  (** TODO: find the diff between f5 and f7  *)
  let seven b ps = 1.

  (** nb of row with, at least, 1 hole *)
  let eight b ps =
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    let accu = ref 0 in
    for i = 0 to Array.length tab -2 do
      if nb_full_top tab.(i) tab.(i+1) > 0 then incr accu
    done;
    float !accu


  (** Array of all phis functions *)
  let phi_arr = [|zero; one; two; three; four; five; six; seven; eight|]

  (** Computes the features *)
  let compute board playspec =
    Array.map (fun f -> f board playspec) phi_arr
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

(* Create memory of transitions *)
let mem_make size =
  let (tbl : (int, transition) Hashtbl.t) = Hashtbl.create size in
  tbl


(* ================================ *)
(*  Everything about loss function  *)
(* ================================ *)

(* TODO: global var ? *)
let weights = [|0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.|]

(** weights initialization between -1 and 1 *)
let init_weights () =
  Array.iteri (fun i _ -> weights.(i) <- Random.float 2. -.1.) weights


(** gives V(\phi(board)) *)
let v_from_phis phis =
  Auxfct.dot phis weights

(** gives V(board) *)
(** useful ? not sure  *)
let v_from_board board playspec =
  let s = Features.compute board playspec in
  v_from_phis s

(** updates weights according to the gradient gard *)
let update_weights grad eta =
  Array.iteri (fun i elt -> weights.(i) <- weights.(i) -. eta *. elt) grad

(*  ===============================  *)
(*  ===============================  *)

(** Reward function *)
(* TODO: in aux function ? *)
let r x = if x >= 2 then -200.
  else if x = 1 then -100.
  else if x = 0 then 1.
  else 100. *. (float (abs x))

(* Gives reward expectancies from [state] *)
(* TODO *)
(* besoin d'une fonction de signature:
   val simulation : Board -> Tetromino -> Rotation -> transition
   val simu : Board -> Tetromino -> Action -> int
qui ne modifie pas en place le plateau*)
let get_reward_exps v state = [| |]

(* A copy paste of qmat's but they have to be specific to the agent *)
let choose_action reward_exps eps actset =
  let rnd = Random.float 1. in
  let actid = if rnd > eps then Auxfct.argmax_r reward_exps
    else let rind = Random.int (List.length actset - 1) in
      List.nth actset rind
  in
  (Game.Action.from_int actid, actid)

let update weights epsilon gamma eta ntetr batch_size =
  let board = Game.Board.make (2 * ntetr) in
  let memory = Array.make batch_size empty_trans in

  for i = 0 to ntetr - 1 do


    (* fill the memory with some transitions *)
    for i = 0 to batch_size - 1 do
      let tetromino = Game.Tetromino.make_rand () in
      let idactions = Game.Tetromino.get_actids tetromino in
      let action, act_ind = choose_action epsilon gamma idactions in
      let old_height = Game.Board.height board in
      let old_features = phi board Phis.phi_arr in
      Game.play board tetromino action;
      let new_height = Game.Board.height board in
      let new_features = phi board Phis.phi_arr in
      memory.(i) <- { s_t = old_features;
                      a_t = act_ind;
                      r_t = r (new_height - old_height);
                      s_t1= new_features}
    done; (* memory is full *)
    let grad = grad_L memory gamma weights in
    update_weights grad eta
  done

(* Returns a usable delta from a transition *)
let delta trans gamma =
  let y = trans.r_t +. gamma *. v_from_phis trans.s_t1 in
  y -. v_from_phis trans.s_t

(** compute \nabla L with respect to w for a given batch*)
let grad_w batch gamma weights =
  let card_b = float (List.length batch) in
  Array.mapi (fun index _ ->
      1. /. card_b *. (List.fold_left (fun accu elt ->
          (delta elt gamma) *.
          (gamma *. v_from_phis elt.s_t1 -. v_from_phis elt.s_t)
        )) 0. batch
    ) weights

(* Builds a batch from memory *)
let makebatch mem =
  let rec loop k =
    if k <= 1 then []
    else Hashtbl.find mem (k - 1) :: loop (k - 1)
  in
  loop batch_size

(* Updates the wieghts in place *)
let update weights state act_ind nstate reward gam par mem i =
  let eta = par in (* Only for notations *)
  if i mod batch_size = 0 then
    let batch = makebatch mem in
    let grad = grad_w batch gam weights in
    Array.iteri (fun i w -> weights.(i) <- w -. eta *. grad.(i)) weights
  else
    let rind = Random.int batch_size in
    let ps = () in
    let trans = {
      s_t =  Features.compute state ps ;
      s_t1 = Features.compute nstate ps ;
      r_t = reward ;
      a_t = act_ind } in
    Hashtbl.add mem rind trans
