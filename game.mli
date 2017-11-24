(** Implements a tetris game *)

(** The tetris board *)
type board

(** Creates a empty board *)
val create_board : unit -> board

(** Gives height of a board, i.e. number of stages stacked *)
val board_height : board -> int

(** Tetromino, i.e. a piece of tetris, on which the player acts *)
type tetromino

(** Generates a random tetromino *)
val random_piece : unit -> tetromino

(** An action executed by the player *)
type action

(** Plays a turn and gives updated board *)
val play : board -> tetromino -> action -> board
