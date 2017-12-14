
let phi_arr = [|(fun x -> 3.)|]

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
    let old_features = phi board phi_arr in
    Game.play board tetromino action;
    let new_height = Game.Board.height board in
    let new_features = phi board phi_arr in
    memory.(i) <- { s_t = old_features;
                    a_t = act_ind;
                    r_t = r (new_height - old_height);
                    s_t1= new_features}
  done
