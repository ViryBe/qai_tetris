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

(** Evaluation function defining reward *)
let get_reward board = Game.Board.height board

(** Function updating Q matrix *)
let train qmat eps gam alpha ngames action_set =
  (* Initialise state *)
  let board = ref (Game.Board.create ())
  and tetromino = ref (Game.Tetromino.create_ran ())
  in
  let state = ref (get_state !board !tetromino)
  in

  for i = 0 to ngames - 1 do
    (* Compute action *)
    let action = choose_action qmat !state action_set eps in
    (* Update board accordingly to action *)
    board := Game.play !board !tetromino action ;
    (* Compute the reward associated to the board *)
    let reward = get_reward !board in
    (* Create next state *)
    tetromino := Game.Tetromino.create_ran () ;
    let nstate = get_state board tetromino
    in
    (* Update Q matrix *)
    qmat.(!state).(action) <- (1. -. alpha i) *. qmat.(nstate).(action) +.
                             (alpha i) *. (float_of_int reward +.
                                           gam *. (flarray_max qmat.(nstate))) ;
    state := nstate
  done ;
  !board
