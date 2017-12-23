(** Q learning with a matrix *)

(** The agent type *)
type t

(** State encodding *)
type s

(** Memory, none with Q matrix *)
type mem

(** Creates a matrix *)
val make : int -> t
(** The matrix is filled with [neg_infinity] with zeros where actions are
    available *)

(** Creates the memory, does nothing in the case of Q matrix *)
val mem_make : _ -> mem

(** Based on the difference of height between the two boards *)
val r : Game.Board.t -> Game.Board.t -> float

(** Updates the matrix in place *)
val update : t -> s -> int -> s -> float -> float -> float -> mem -> int ->
  unit

(** Gets the required information from the board to choose action *)
val get_state : Game.Tetromino.t -> Game.Board.t -> s

(** Chooses an action *)
val choose_act : float array -> float -> int list -> Game.Action.t * int

(** Gives rewards currently associated to a state *)
val get_reward_exps : t -> s -> float array
(** [get_rewards a s] returns an array containing reward expectancies currently
    known by the agent *)
