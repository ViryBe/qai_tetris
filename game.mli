(** Implements a tetris game *)

(** Module using the overall board *)
module Board :
  sig
    (** The tetris board *)
    type t

    (** Creates an empty board *)
    val create : unit -> t

    (** Gives the height of the given board, i.e. number of stages stacked *)
    val height : t -> int
  end

(** Manipulates tetrominos in the board *)
module Tetromino :
  sig
    (** Tetromino type *)
    type t

    (** Generates a random tetromino *)
    val create_ran : unit -> t
  end

(** An action executed by the player *)
type action

(** Plays a turn and gives updated board *)
val play : Board.t -> Tetromino.t -> action -> Board.t
