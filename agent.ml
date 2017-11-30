(** Manages agent training and embodies the agent *)

(** Logging shortcut, to log with adequate logger *)
let boltlog lvl msg = Bolt.Logger.log "agent" lvl msg

(** Auxiliary functions *)
module Auxfct = struct

  (** Simple fuction giving the max of an array *)
  let flarray_max arr = Array.fold_left max min_float arr

  (** Argmax with random choice if two same max *)
  let argmax_r arr =
    let epscmp = 1.e-5 in (* Equality on floats isn't reliable *)
    let len = Array.length arr in
    let maxv = flarray_max arr in
    let rec build_maxis k =
      if k >= len then []
      else if arr.(k) >= maxv -. epscmp && arr.(k) <= maxv +. epscmp
      then k :: build_maxis (k+1)
      else build_maxis (k+1)
    in
    let maxis = build_maxis 0 in
    List.nth maxis (Random.int (List.length maxis))

  (** One to one mapping from bool array to digit *)
  let arr2dig arr =
    Array.fold_left (fun acc elt -> (acc lsl 1) + elt) 0 arr

  (** Outputs the two last lines of the board *)
  let get_board_top board =
    let height = Game.Board.height board in
    if height >= 2 then
      Game.Board.to_arr (height - 1) height board else
      Game.Board.to_arr 0 height board

  let arr_find arr elt =
    let rec loop k =
      if arr.(k) = elt then k else loop (k+1)
    in
    loop 0
end

(** Evaluation function defining reward
    @param ntetr a parameter to normalise reward fct, typically the number of
                 tetrominos
*)
let get_reward param board =
  1. /. ( 1. +. log (1. +. (float param /. (float (Game.Board.height board)))))

(** Outputs state from board repr and a tetromino *)
let get_state board tetromino =
  let board_repr = Auxfct.get_board_top board
  and tetromino_repr = Auxfct.arr_find Game.Tetromino.tetromino_list
      tetromino in
  let board_one = Array.fold_left Array.append [| |] board_repr in
  let dig_board = Auxfct.arr2dig board_one in
  tetromino_repr lsl (Game.Board.width * 2) + dig_board

(** gives the action coresponding to index_action *)
let map_action = fun index_action action_set -> action_set.(index_action)

(** chose an action for the current state *)
let choose_action = fun q epsilon state action_set ->
  let tirage = Random.float 1. in
  if tirage > epsilon
  then
    let action_no = Auxfct.argmax_r q.(state) in
    (action_set.(action_no), action_no)
  else
    let action_no = Random.int (Array.length action_set) in
    (action_set.(action_no), action_no)

(** Function updating Q matrix *)
let update_qmat qmat eps gam alpha ntetr ~get_reward =
  (* Initialise state *)
  let board = ref (Game.Board.make ())
  and tetromino = ref (Game.Tetromino.make_rand ()) in
  let state = ref (get_state !board !tetromino) in

  for i = 0 to ntetr - 1 do
    (* Compute action *)
    let action, act_ind = choose_action qmat eps !state Game.Action.set in
    (* Update board accordingly to action *)
    board := Game.play !board !tetromino action ;
    (* Create next state *)
    tetromino := Game.Tetromino.make_rand () ;
    let nstate = get_state !board !tetromino in
    (* Compute the reward associated to the board *)
    let reward = get_reward !board in
    (* Update Q matrix *)
    qmat.(!state).(act_ind) <- (1. -. alpha i) *. qmat.(!state).(act_ind) +.
                              (alpha i) *.
                              (reward +.
                               gam *. (Auxfct.flarray_max qmat.(nstate))) ;
    state := nstate
  done ;
  !board

(** Train the Q matrix with ngames of nturns each *)
let train qmat eps gam alpha ngames ntetr =
  boltlog Bolt.Level.INFO
    (Printf.sprintf "Session:ngames=%d:ntetr=%d:eps=%f:gam=%f"
       ngames ntetr eps gam) ;
  let get_reward_norm = get_reward ntetr in
  for i = 0 to ngames do
    let fboard = (update_qmat qmat eps gam alpha ntetr get_reward_norm) in
    let reward = get_reward_norm fboard in
    Aio.log_game (Printf.sprintf "game %d: %f" i reward) ;
    Aio.log_reward reward ;
    Printf.printf "Reward of game %d: %f\n" i (get_reward_norm fboard)
  done

(** Plays a game of ntetr with qmat TODO factorise with update_qmat *)
let play qmat ntetr =
  let board = ref (Game.Board.make ())
  and tetromino = ref (Game.Tetromino.make_rand ()) in
  let  state = ref (get_state !board !tetromino) in
  for i = 0 to ntetr - 1 do
    let action, _ = choose_action qmat 0. !state Game.Action.set in
    board := Game.play !board !tetromino action ;
    tetromino := Game.Tetromino.make_rand () ;
    state := get_state !board !tetromino ;
  done ;

  !board

let alpha = fun k ->
  1. /. (1. +. 18. *. k)
