(** Implements a tetris game *)

(** Module using the overall board *)
module Board : sig
  (** The tetris board *)
  type t

  (** Creates an empty board *)
  val create : unit -> t

  (** Gives the height of the given board, i.e. number of stages stacked *)
  val height : t -> int

  (** Creates a representation of the board *)
  val to_arr : int -> int -> t -> int array array
  (** [to_arr l u b] outputs a matrix representing the board
      [b] from line [l] to line [u] (included) where each element is
      one if the square is occupied by a tetromino else zero *)
end

(** Manipulates tetrominos in the board *)
module Tetromino : sig
  (** Tetromino type *)
  type t

  (** Generates a random tetromino *)
  val create_ran : unit -> t

  (** Outputs an array representation of a tetromino *)
  val to_arr : t -> int array
end

(** An action executed by the player *)
module Action : sig

  (** The type of an action *)
  type t

  (** Number of available actions *)
  val card : int

  (** Extracts the rotation component of an action *)
  val rotation : t -> int

  (** Extracts the translation component of an action *)
  val translation : t -> int
end

(** Plays a turn and gives updated board *)
val play : Board.t -> Tetromino.t -> Action.t -> Board.t
(** [play b t a] plays the action [a] on tetromino [t] in board [b] and returns
    a new board with the consequences of the turn *)
