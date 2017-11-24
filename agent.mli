(** Agent module, builds the Q matrix used by policy *)

(** Builds a Q matrix used by agent to determine actions *)
val train : float array array -> float -> float -> (int -> float) -> int ->
  Game.board
