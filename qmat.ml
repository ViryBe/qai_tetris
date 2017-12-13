(** Manages agent training and embodies the agent *)

(** Number of lines used to compute a state *)
let line_per_state = 2

(** Outputs the two last lines of the board *)
let get_board_top board =
  let height = Game.Board.height board in
  if height >= 2 then
    Game.Board.to_arr (height - 1) height board else
    Game.Board.to_arr 0 height board

(** Reward function *)
let r x = if x >= 2 then -200.
  else if x = 1 then -100.
  else if x = 0 then 1.
  else 100. *. (float (abs x))

(** Outputs state from board repr and a tetromino *)
let get_state board tetromino =
  let board_repr = get_board_top board
  and intetr = Game.Tetromino.to_int tetromino in
  let board_one = Array.fold_left Array.append [| |] board_repr in
  let dig_board = Auxfct.arr2dig board_one in
  intetr lsl (Game.Board.width * 2) + dig_board

(** chose an action for the current state
    @return [(action, action_mo)] with action an Action.t and action_no the
            id of the action *)
let choose_action = fun rewards epsilon action_set ->
  let tirage = Random.float 1. in
  let actionid = if tirage > epsilon then Auxfct.argmax_r rewards
    else let rind = Random.int (List.length action_set - 1) in
      List.nth action_set rind
  in
  (Game.Action.from_int actionid, actionid)

(** Puts zeros on usable actions in a Q matrix *)
let init_qmat qmat =
  let tetr_per_state = Game.Board.width * line_per_state in
  let state_per_tetr = truncate (2. ** (float tetr_per_state)) in
  let tetr_range_st = ref 0 in
  (* Writes the zeros in the Q matrix for only one tetromino *)
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
  List.iter init_qmat_aux Game.Tetromino.set

(** Function updating Q matrix, plays one game *)
let update_qmat bheight qmat eps gam alpha ntetr =
  (* Initialise state *)
  let board = Game.Board.make bheight
  and tetromino = ref (Game.Tetromino.make_rand ()) in
  let state = ref (get_state board !tetromino)
  and height = ref (Game.Board.height board) in

  for i = 0 to ntetr - 1 do
    (* Compute action *)
    let idactions = Game.Tetromino.get_actids !tetromino in
    let action, act_ind = choose_action qmat.(!state) eps idactions in
    (* Update board accordingly to action *)
    Game.play board !tetromino action ;
    tetromino := Game.Tetromino.make_rand () ;
    let nheight = Game.Board.height board in
    let reward = r (nheight - !height)
    and nstate = get_state board !tetromino in
    (* Update Q matrix *)
    qmat.(!state).(act_ind) <- qmat.(!state).(act_ind) +.
                               (alpha i) *.  (reward +.
                                gam *. (Auxfct.flarray_max qmat.(nstate)) -.
                                qmat.(!state).(act_ind));
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
    Printf.printf "%d\n" fheight
  done

(** Plays a game of ntetr with qmat *)
let play qmat ntetr =
  let board = Game.Board.make (2 * ntetr + 1)
  and tetromino = ref (Game.Tetromino.make_rand ()) in
  let  state = ref (get_state board !tetromino) in
  for i = 0 to ntetr - 1 do
    let actids = Game.Tetromino.get_actids !tetromino in
    let action, _ = choose_action qmat.(!state) 0. actids in
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
