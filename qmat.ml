(** Manages agent training and embodies the agent *)

(* Type of the Q matrix *)
type t = float array array

(* State are a line of the qmat and therefore int *)
type s = int

(* No memory for Q matrix *)
type mem = unit

(* No memory for Q matrix *)
let mem_make _ = ()

(** Number of lines used to compute a state *)
let line_per_state = 2

(** Outputs the two last lines of the board *)
let get_board_top board =
  let height = Game.Board.height board in
  if height >= 2 then
    Game.Board.to_arr (height - 1) height board else
    Game.Board.to_arr 0 height board

(** Reward function *)
let r backboard board =
  let x = Game.Board.height board - Game.Board.height backboard in
  if x >= 2 then -200.
  else if x = 1 then -100.
  else if x = 0 then 1.
  else 100. *. (float (abs x))

(** Outputs state from board repr and a tetromino *)
let get_state tetromino board =
  let board_repr = get_board_top board
  and intetr = Game.Tetromino.to_int tetromino in
  let board_one = Array.fold_left Array.append [| |] board_repr in
  let dig_board = Auxfct.arr2dig board_one in
  intetr lsl (Game.Board.width * 2) + dig_board

(* Chooses an action *)
let choose_act = fun reward_exps epsilon action_set ->
  let tirage = Random.float 1. in
  let actionid = if tirage > epsilon then Auxfct.argmax_r reward_exps
    else let rind = Random.int (List.length action_set - 1) in
      List.nth action_set rind
  in
  (Game.Action.from_int actionid, actionid)

(* The matrix is filled with neg_infinity where actions are not possible and
 * zeros else *)
let make scard =
  let tetr_per_state = Game.Board.width * line_per_state in
  let state_per_tetr = truncate (2. ** (float tetr_per_state))
  and tetr_range_st = ref 0
  and qmat = Array.make_matrix scard Game.Action.card neg_infinity in
  (* Subfunction writing zeros in the Q matrix for one tetromino *)
  let init_qmat_aux tetr =
    let actids = Game.Tetromino.get_actids tetr in
    begin
      tetr_range_st := Game.Tetromino.to_int tetr * state_per_tetr ;
      List.iter (fun id ->
          (* Each tetromino has 4096 associated stated possible *)
          for j = !tetr_range_st to !tetr_range_st + state_per_tetr - 1 do
            qmat.(j).(id) <- 0.
          done ;
        ) actids
    end
  in
  (* Loops over tetrominos and writes zeros *)
  List.iter init_qmat_aux Game.Tetromino.set ;
  qmat

let get_reward_exps qmat state = qmat.(state)

(** Function updating Q matrix, plays one game *)
let update qmat state act_ind nstate reward gam par _ i =
  let alpha = 1. /. (1. +. par *. float i) in
  qmat.(state).(act_ind) <- qmat.(state).(act_ind) +.
                            alpha *.  (
                              reward +.
                              gam *. (Auxfct.flarray_max qmat.(nstate)) -.
                              qmat.(state).(act_ind))
