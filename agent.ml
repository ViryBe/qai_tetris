(** Manages agent training and embodies the agent *)

(** Auxiliary functions *)
module Auxfct = struct

  (** Simple fuction giving the max of an array *)
  let flarray_max arr = Array.fold_left max arr.(0) arr

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
    let line_bin = Array.map (fun elt -> if elt = 0 then 0 else 1) arr in
    Array.fold_left (fun acc elt -> (acc lsl 1) + elt) 0 line_bin

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

(** Reward function *)
let r x = if x >= 2 then -200.
  else if x = 1 then -100.
  else if x = 0 then 1.
  else 100. *. (float (abs x))

(** Outputs state from board repr and a tetromino *)
let get_state board tetromino =
  let board_repr = Auxfct.get_board_top board
  and intetr = Game.Tetromino.to_int tetromino - 1 in
  let board_one = Array.fold_left Array.append [| |] board_repr in
  let dig_board = Auxfct.arr2dig board_one in
  intetr lsl (Game.Board.width * 2) + dig_board

(** chose an action for the current state
    @return [(action, action_mo)] with action an Action.t and action_no the
            id of the action *)
let choose_action = fun q epsilon state action_set ->
  let tirage = Random.float 1. in
  let action_no = if tirage > epsilon then Auxfct.argmax_r q.(state)
    else Random.int (List.length action_set)
  in
  (Game.Action.from_int (List.nth action_set action_no), action_no)

(** Function updating Q matrix, plays one game *)
let update_qmat bheight qmat eps gam alpha ntetr =
  (* Initialise state *)
  let board = Game.Board.make bheight
  and tetromino = ref (Game.Tetromino.make_rand ()) in
  let state = ref (get_state board !tetromino)
  and height = ref (Game.Board.height board) in

  for i = 0 to ntetr - 1 do
    (* Compute action *)
    let idactions = Game.Tetromino.available_actids !tetromino in
    let action, act_ind = choose_action qmat eps !state idactions in
    (* Update board accordingly to action *)
    Game.play board !tetromino action ;
    tetromino := Game.Tetromino.make_rand () ;
    let nheight = Game.Board.height board in
    let reward = r (nheight - !height)
    and nstate = get_state board !tetromino in
    (* Update Q matrix *)
    qmat.(!state).(act_ind) <- (1. -. alpha i) *. qmat.(!state).(act_ind) +.
                              (alpha i) *.
                              (reward +.
                               gam *. (Auxfct.flarray_max qmat.(nstate))) ;
    state := nstate ;
    height := nheight
  done ;
  board

(** Train the Q matrix with ngames of nturns each *)
let train qmat eps gam alpha ngames ntetr =
  (* Should ideally be updated during process, limiting height *)
  let bh = 2 * ntetr + 1 in
  for i = 0 to ngames do
    let fboard = (update_qmat bh qmat eps gam alpha ntetr) in
    let fheight = Game.Board.height fboard in
    Printf.printf "%f %d\n" (log (float_of_int (1 + i))) fheight
  done

(** Plays a game of ntetr with qmat *)
let play qmat ntetr =
  let board = Game.Board.make (2 * ntetr + 1)
  and tetromino = ref (Game.Tetromino.make_rand ()) in
  let  state = ref (get_state board !tetromino) in
  for i = 0 to ntetr - 1 do
    let actids = Game.Tetromino.available_actids !tetromino in
    let action, _ = choose_action qmat 0. !state actids in
    Game.play board !tetromino action ;
    tetromino := Game.Tetromino.make_rand () ;
    state := get_state board !tetromino;
    (* graphic part *)
    Display.draw_board
      (Game.Board.to_arr
         (max 0 (Game.Board.height board - 10))
         (Game.Board.height board + 5) board)
      i (Game.Board.height board)
  done ;
  Printf.printf "%d Tetrominos: final height of %d\n" ntetr
    (Game.Board.height board) ;
  board
