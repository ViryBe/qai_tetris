(** Q learning with a matrix *)

(** The agent type *)
type t

(** Creates a matrix *)
val make : int -> t
(** The matrix is filled with [neg_infinity] with zeros where actions are
    available *)

(** Updates the matrix in place *)
val update : t -> float -> float -> (int -> float) -> int -> Game.Board.t

(** Gets the required information from the board to choose action *)
val get_state : Game.Tetromino.t -> Game.Board.t -> int

(** Gives rewards currently associated to a state *)
val get_rewards : t -> int -> float array
(** [get_rewards a s] returns an array containing reward expectancies currently
    known by the agent *)
