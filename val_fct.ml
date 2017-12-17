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
  let phi_1 b = 4.

  let phi_2 b = 4.

  (** max nb of 'neighbors' for all empty cells  in b*)
  let phi_3 b =
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    float (Array.fold_left (fun accu elt ->
        max accu (nb_adjacent_empty_cell elt)
      ) 0 tab)

  let phi_4 b = 4.

  (** the number of filled cells above holes  *)
  let phi_5 b =
    let accu = ref 0 in
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    for i = 0 to Array.length tab -2 do
      accu := !accu + nb_full_top tab.(i) tab.(i+1)
    done;
    float (!accu)

  let phi_6 b = 4.

  (** TODO: find the diff between f5 and f7  *)
  let phi_7 b =
    phi_5 b

  (** nb of rox with, at least, 1 hole *)
  let phi_8 b =
    let tab = Game.Board.to_arr 0 (Game.Board.height b) b in
    let accu = ref 0 in
    for i = 0 to Array.length tab -2 do
      if nb_full_top tab.(i) tab.(i+1) > 0 then incr accu
    done;
    float (!accu)


  (** Array of all phis functions *)
  let phi_arr = [|phi_1; phi_2; phi_3; phi_4; phi_5; phi_6; phi_7; phi_8|]
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

let fuct_V s w =
  Auxfct.fold_left2_array (fun accu e1 e2 -> accu +.e1 *.e2 ) 0. s w

let phi board phi_arr =
  Array.map (fun f -> f board) phi_arr

(** Reward function *)
(* TODO: in aux function ? *)
let r x = if x >= 2 then -200.
  else if x = 1 then -100.
  else if x = 0 then 1.
  else 100. *. (float (abs x))


(** how to chosse the next action *)
(* TODO *)
let choose_action epsilon gamma idactions =
  Game.Action

let update weights epsilon gamma eta ntetro batch_size =
  let board = Game.Board.make (2 * ntetro) in
  let memory = Array.make ntetro empty_trans in

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
  done
