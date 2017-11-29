module Board = struct
  (** The tetris board *)
  type t = {
      board : int array array;
      stacked_height : int
  }

  (** Total height of the board TODO eh eh, remove *)
  let total_height = 2000

  (** Width of the board *)
  let width = 6

  (** Creates an empty board *)
  let make () =
    {board = Array.make_matrix total_height width 0;
     stacked_height = 0
    }

  (** Creates a board filled with board of height height *)
  let make_filled board height = {board = board; stacked_height = height}

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

  (** Returns height of board after placing a tetromino at (x, y) *)
  let assess_height board x y =
    if board.(x).(y) = 0 && board.(x).(y+1) = 0 then (x-1) else x

  (** Prints board to stdout *)
  let print board =
    Printf.printf "------------\n" ;
    for i = 0 to board.stacked_height do
      for j = 0 to width - 1 do
        Printf.printf "%d " board.board.(i).(j)
      done ;
      print_newline ()
    done ;
    Printf.printf "------------" ;
    print_newline ()

  let pop arr i =
    let ret = ref [||] in
    for j = 0 to (Array.length arr) -1 do
      if j <> i then
        ret := Array.append !ret  [|arr.(j)|]
    done;
    !ret

  let update_board board x =
    let nminus_mligne = ref 0 in
    let table = ref (get_board board) in
    for i = 0 to 1 do
    let line = x - i in
      if is_full !table line then
        begin
          (* Array.blit table (line+1)
             table line (height board - line + 1); *)
          table := pop !table line;

          nminus_mligne := !nminus_mligne + 1
        end;
    done;
    {board  = !table; stacked_height = (height board - !nminus_mligne)}

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
    let n = Random.int (Array.length tetromino_list) in
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

let collide table x y tetromino rotation =
  let n = ref(false) in
  for i=0 to 1 do
    for j=0 to 1 do
      if (Tetromino.to_arr tetromino).(Action.make_rotation rotation i j) = 1 &&
         (Board.get_board table).(x-i).(y+j) = 1  then
        begin
          n:= true;
        end
    done;
  done;
  !n

(** Places tetromino rotated at x y on board table *)
let place_tetromino table tetromino rotation x y =
  let board = Board.get_board table in
  for i=0 to 1 do
    for j=0 to 1 do
      board.(x - i).(y + j) <-
        board.(x - i).(y + j) +
        (Tetromino.to_arr  tetromino).(Action.make_rotation rotation i j);
    done;
  done;
  Board.make_filled board (max (Board.assess_height board x y)
                             (Board.height table))

let play board tetromino action =
  let x = ref((Board.height board) + 2) in (* +1 to add the new tetromino *)
  let y = Action.int_from_translation action in
  while !x > 0 && not (collide board !x y tetromino
                         (Action.get_rotation action)) do
    x := !x - 1;
  done;
  x := !x + 1 ;
  let nboard = place_tetromino board tetromino (Action.get_rotation action)
                      !x y in
  Board.update_board nboard !x
