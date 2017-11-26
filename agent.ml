(** Manages agent training and embodies the agent *)

(** Auxiliary functions *)
module Auxfct = struct

  (** Simple fuction giving the max of an array *)
  let flarray_max arr = Array.fold_left max min_float arr

  (** Argmax with random choice if two same max *)
  let argmax_r arr =
    let len = Array.length arr in
    let maxv = flarray_max arr in
    let rec build_maxis k =
      if k >= len then [] else
      if arr.(k) == maxv then k :: build_maxis (k+1)
      else build_maxis (k+1)
    in
    let maxis = build_maxis 0 in
    Random.self_init () ;
    List.nth maxis (Random.int (List.length maxis))

  (** One to one mapping from bool array to digit *)
  let arr2dig arr =
    Array.fold_left (fun acc elt -> (acc lsl 1) + elt) 0 arr

  (** Outputs the two last lines of the board *)
  let get_board_top board =
    let height = Game.Board.height board in
    if height >= 2 then
      Game.Board.to_arr (height - 2) height board else
      Game.Board.to_arr 0 height board

  (** One to one onto mapping from action to int *)
  let int_from_action = fun action ->
    let rotation = Game.Action.rotation action in
    let translation = Game.Action.translation action in
    translation lsl 2 + rotation
end

let action_set =
  [|{rot=North; trans = Column(0)};
    {rot=North; trans = Column(1)};
    {rot=North; trans = Column(2)};
    {rot=North; trans = Column(3)};
    {rot=North; trans = Column(4)};
    {rot=East; trans = Column(0)};
    {rot=East; trans = Column(1)};
    {rot=East; trans = Column(2)};
    {rot=East; trans = Column(3)};
    {rot=East; trans = Column(4)};
    {rot=South; trans = Column(0)};
    {rot=South; trans = Column(1)};
    {rot=South; trans = Column(2)};
    {rot=South; trans = Column(3)};
    {rot=South; trans = Column(4)};
    {rot=West; trans = Column(0)};
    {rot=West; trans = Column(1)};
    {rot=West; trans = Column(2)};
    {rot=West; trans = Column(3)};
    {rot=West; trans = Column(4)}
  |]

(** Logging shortcut, to log with adequate logger *)
let boltlog lvl msg = Bolt.Logger.log "agent" lvl msg

(** Evaluation function defining reward *)
let get_reward board = Game.Board.height board

(** Outputs state from board repr and a tetromino *)
let get_state board tetromino =
  let board_repr = Auxfct.get_board_top board
  and tetromino_repr = Game.Tetromino.to_arr tetromino in
  let board_one = Array.fold_left Array.append [| |] board_repr in
  Auxfct.arr2dig (Array.append board_one tetromino_repr)

(** gives the action coresponding to index_action *)
let map_action = fun index_action action_set -> action_set.(index_action)

(** chose an action for the current state *)
let choose_action = fun q epsilon state action_set ->
  let tirage = Random.float 1. in
  if tirage < epsilon
  then map_action (Auxfct.argmax_r q.(state)) action_set
  else map_action (Random.int (Array.length action_set)) action_set

(** Function updating Q matrix *)
let update_qmat qmat eps gam alpha action_set nturns =
  (* Initialise state *)
  let board = ref (Game.Board.make ())
  and tetromino = ref (Game.Tetromino.make_rand ()) in
  let state = ref (get_state !board !tetromino) in

  for i = 0 to nturns- 1 do
    (* Compute action *)
    let action = choose_action qmat eps !state action_set in
    (* Update board accordingly to action *)
    board := Game.play !board !tetromino action ;
    (* Compute the reward associated to the board *)
    let reward = get_reward !board in
    (* Create next state *)
    tetromino := Game.Tetromino.make_rand () ;
    let nstate = get_state !board !tetromino in
    let n_action = Auxfct.int_from_action action in
    (* Update Q matrix *)
    qmat.(!state).(n_action) <- (1. -. alpha i) *. qmat.(nstate).(n_action) +.
                              (alpha i) *.
                              (float_of_int reward +.
                               gam *. (Auxfct.flarray_max qmat.(nstate))) ;
    state := nstate
  done ;
  !board

(** Train the Q matrix with ngames of nturns each *)
let train qmat eps gam alpha ngames action_set ntetr =
  boltlog Bolt.Level.INFO
    (Printf.sprintf "Session:ngames=%d:eps=%f:gam=%f" ngames eps gam) ;
  for i = 0 to ngames do
    let new_height = Game.Board.height
        (update_qmat qmat eps gam alpha action_set ntetr) in
    Aio.log_game (Printf.sprintf "%d" new_height) ;
    Printf.printf "%d\n" new_height
  done

(** Plays a game of ntetr with qmat *)
let play qmat ntetr =
  let board = ref (Game.Board.make ())
  and tetromino = ref (Game.Tetromino.make_rand ()) in
  let  state = ref (get_state !board !tetromino) in
  for i = 0 to ntetr - 1 do
    let action = choose_action qmat 0. !state Game.Action.set in
    board := Game.play !board !tetromino action ;
    tetromino := Game.Tetromino.make_rand () ;
    state := get_state !board !tetromino ;
  done ;

  !board

let alpha = fun k ->
  1. /. (1. +. 18. *. k)
