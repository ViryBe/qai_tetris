(** Agent module, builds the Q matrix used by policy *)

(** Builds a Q matrix used by agent to determine actions *)
val train : float array array -> float -> float -> (int -> float) -> int ->
  int -> unit
(** [train q e g ak ng nt] trains the matrix [q] with [e] the frequency of
    random choice,
    [g] the sight length of the agent, i.e. weight given to future turns to
    make an action,
    [ak : int -> float] the learning rate,
    [ng] the number of games played to train,
    [nt] number of tetrominos played in each game
*)

(** Plays a game *)
val play : float array array -> int -> Game.Board.t
(** [play q nt] gives the final board of the game composed of [nt] tetrominos
    played with matrix [q] *)
