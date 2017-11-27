module Board = struct
  (** The tetris board *)
  type t = {board : int array array; stacked_height : int}

  (** Total height of the board *)
  let total_height = 20000

  (** Total length of the board *)
  let total_length = 6


  (** Creates an empty board *)
  let make () =
    {board = Array.make_matrix total_length total_height 0;
     stacked_height = 0
    }

  let update_board board height =
    {board = board; stacked_height = height}

  (** Gives the height of the given board, i.e. number of stages stacked *)
  let height b = b.stacked_height

  (** Creates a representation of the board *)
  let to_arr low high board =
    let rec loop k =
      if k > high then [| [| |] |] else
        Array.append [| board.board.(k) |] (loop (k+1))
    in
    loop low

  (** Get the board *)
  let get_board b = b.board

  (** Checks whether line is full *)
  let is_full board x =
    let n = ref 0 in
    for i = 0 to 5 do
      if board.(x).(i) = 1 then n := !n + 1;
    done;
    !n = 6

  (** Document me! *)
  let update_height board x y =
    if board.(x).(y) = 0 && board.(x).(y+1) = 0 then x else x-1
end

module Tetromino = struct
  (** Tetromino type *)
  type t = Piece of int array

  (* List of pieces of the game *)
  let tetromino_list =
    [|
      Piece [|1;1;1;1|]; (* square *)
      Piece [|1;0;1;0|]; (* line *)
      Piece [|1;0;0;0|]; (* point *)
      Piece [|1;0;1;1|]; (* L shape *)
      Piece [|1;0;0;1|]  (* diag *)
    |]

  (** Generates a random tetromino *)
  let make_rand () =
    let n = Random.int 6 in
    tetromino_list.(n)

  (** Outputs an array representation of a tetromino *)
  let to_arr p = match p with
    | Piece x -> x

end

module Action = struct

  type rotation = North | South | East | West
  type translation = Column of int (* Int between 0 and 4 *)

  (** The type of an action *)
  type t = {rot : rotation; trans : translation}

  (** Extracts the translation component of an action *)
  let int_from_translation action = match action.trans with
    | Column x -> x

  (** 2D to 1D Array - index match *)
  let get_index i j = 2*i + j

  let get_rotation action = action.rot

  (** Give the correct index for 1D Array after a rotation *)
  let make_rotation rotation i j =
    let n = get_index i j in
    match rotation with
    | North -> [|0;1;2;3|].(n)
    | East -> [|2;0;3;1|].(n)
    | South -> [|3;2;1;0|].(n)
    | West -> [|1;3;0;2|].(n)

  (** The set of all possible actions *)
  let set =
    [|{rot=North; trans = Column 0};
      {rot=North; trans = Column 1};
      {rot=North; trans = Column 2};
      {rot=North; trans = Column 3};
      {rot=North; trans = Column 4};
      {rot=East; trans = Column 0};
      {rot=East; trans = Column 1};
      {rot=East; trans = Column 2};
      {rot=East; trans = Column 3};
      {rot=East; trans = Column 4};
      {rot=South; trans = Column 0};
      {rot=South; trans = Column 1};
      {rot=South; trans = Column 2};
      {rot=South; trans = Column 3};
      {rot=South; trans = Column 4};
      {rot=West; trans = Column 0};
      {rot=West; trans = Column 1};
      {rot=West; trans = Column 2};
      {rot=West; trans = Column 3};
      {rot=West; trans = Column 4}
    |]

end

let tetromino_per_game = 10000

let collide table x y tetromino rotation =
  let n = ref 0 in
  for i=0 to 1 do
    for j=0 to 1 do
      n := (Tetromino.to_arr tetromino).(Action.make_rotation rotation i j) +
           (Board.get_board table).(x+i).(y+j)
    done;
  done;
  !n > 4

let place_tetromino table tetromino rotation x y =
  let board = Board.get_board table in
  for i=0 to 1 do
    for j=0 to 1 do
      board.(x+i).(j+y) <-
        board.(x+i).(y+j) +
        (Tetromino.to_arr  tetromino).(Action.make_rotation rotation i j)
    done;
  done;
  Board.update_board board
    (max (Board.update_height board x y) (Board.height table))

let play board tetromino action =
  let x = ref(Board.height board + 1) in (* +1 to add the new tetromino *)
  let y = Action.int_from_translation action in
  while not (collide board !x y tetromino (Action.get_rotation action)) &&  !x > 0 do
    x := !x - 1
  done;
  let t = place_tetromino board tetromino (Action.get_rotation action) !x y in
  for i=0 to 1 do
    let table = Board.get_board t in
    let line = !x - i in
    if Board.is_full table line then
      Array.blit table (line+1) table line ((Board.height t)-line-1)
  done;
  t
