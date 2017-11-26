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

  (** Gives the height of the given board, i.e. number of stages stacked *)
  let height b = b.stacked_height

  (** Creates a representation of the board *)
  let to_arr l h b = b.board
  (** [to_arr l u b] outputs a matrix representing the board
      [b] from line [l] to line [u] (included) where each element is
      one if the square is occupied by a tetromino else zero *)
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

  (** Extracts the rotation component of an action *)
  let int_from_rotation action = match action.rot with
    | North -> 0
    | East -> 1
    | South -> 2
    | West -> 3

  (** Extracts the translation component of an action *)
  let int_from_translation action = match action.trans with
    | Column x -> x

  (** 2D to 1D Array - index match *)
  let get_index i j = 2*i + j

  (** Give the correct index for 1D Array after a rotation *)
  let get_rotation rotation i j =
    let n = get_index i j in
    match rotation with
    | North -> [|0;1;2;3|].(n)
    | East -> [|2;0;3;1|].(n)
    | South -> [|3;2;1;0|].(n)
    | West -> [|1;3;0;2|].(n)

end

let tetromino_per_game = 10000

let rotation_90 i j =
  let height, width = 2,2 in
  2*(height + 1 - j ) + i

  (*
let play board tetromino action =
  let x = Action.int_translation action in
  x
  *)
