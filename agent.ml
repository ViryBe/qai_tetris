(** Simple fuction giving the max of an array *)
let flarray_max arr = Array.fold_left max 0. arr

(** Evaluation function defining reward *)
let get_reward board = Game.board_height board

(** Function updating Q matrix *)
let train qmat eps gam alpha ngames action_set =
  (* Initialise state *)
  let board = ref (Game.create_board ())
  and tetromino = ref (Game.random_piece ())
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
    tetromino := Game.random_piece () ;
    let nstate = get_state board tetromino
    in
    (* Update Q matrix *)
    qmat.(!state).(action) <- (1. -. alpha i) *. qmat.(nstate).(action) +.
                             (alpha i) *. (float_of_int reward +.
                                           gam *. (flarray_max qmat.(nstate))) ;
    state := nstate
  done ;
  !board
