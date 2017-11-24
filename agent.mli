(** Agent module, builds the Q matrix used by policy *)

(** Builds a Q matrix used by agent to determine actions *)
val train : float array array -> float -> float -> (int -> float) -> int ->
  float array array

val play : float array array -> float -> Game.board -> Game.tetromino ->
  Game.action array -> Game.action
