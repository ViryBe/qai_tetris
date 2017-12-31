(** Implements a tetris game *)

(** An action executed by the player *)
module Action : sig

  (** The type of an action *)
  type t

  (** Number of actions *)
  val card : int

  (** Default action *)
  val none : t
end

(** Manipulates tetrominos in the board *)
module Tetromino : sig
  (** Tetromino type *)
  type t

  (** The dimension of a tetromino (n \times n square) *)
  val dim : int

  (** Set of tetrominos *)
  val set : t list

  (** Generates a random tetromino *)
  val make_rand : unit -> t

  (** Outputs the list of available actions for the tetromino *)
  val get_actions : t -> Action.t list
end

(** Module using the overall board *)
module Board : sig
  (** The tetris board *)
  type t

  (** Creates an empty board of a given height *)
  val make : int -> t

  (** Gives the height of the given board, i.e. number of stages stacked *)
  val height : t -> int

  (** Width of the considered board *)
  val width : int

  (** Creates a representation of the board *)
  val to_arr : int -> int -> t -> int array array
  (** [to_arr l u b] outputs a matrix representing the board
      [b] from line [l] to line [u] (included) where each element is
      one if the square is occupied by a tetromino else zero *)

  (** Prints board to stdout from [low] to [up] if precised *)
  val print : ?low:int -> ?up:int -> t -> unit

  (** Saves representation of board to a file *)
  val to_file : string -> t -> unit
  (** [to_file fname b] saves board [b] to file [fname] *)

  (** Reverts the board to its state before the last action *)
  val revert : t -> unit
end

(** Plays a turn and gives updated board *)
val play : Board.t -> Tetromino.t -> Action.t -> unit
(** [play b t a] plays the action [a] on tetromino [t] in board [b], updating
    it in place consequently *)
