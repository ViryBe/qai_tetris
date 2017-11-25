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

    (** Creates a representation of the board *)
    val to_arr : int -> int -> t -> int array array
    (** {e to_arr low up board} outputs a matrix representing the board
        {e board} from line {e low} to line {e up}
        @return boolean matrix with true if block occupied by a tetromino, else
                false *)
  end

(** Manipulates tetrominos in the board *)
module Tetromino :
  sig
    (** Tetromino type *)
    type t

    (** Generates a random tetromino *)
    val create_ran : unit -> t

    (** Outputs an array representation of a tetromino *)
    val to_arr : t -> int array
  end

(** An action executed by the player *)
module Action : sig
  type t

  val rotation : t -> int
  val translation : t -> int
end

(** Plays a turn and gives updated board *)
val play : Board.t -> Tetromino.t -> Action.t -> Board.t
