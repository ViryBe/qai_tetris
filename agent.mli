(** Agent module, builds the Q matrix used by policy *)

module type AgentTools =
  sig
    (** The type of the agent, matrix or function *)
    type t

    (** Function updating the agent *)
    val update : t -> float -> float -> float -> int -> Game.Board.t -> unit
    (** [update t e g a n ] trains the agent through a game of [n] tetrominos
        with a frequency [e] of random action, a sight length of [g] and a
        learning rate of [a] *)

    (** Outputs state from the board and, if supplied, the tetromino *)
    val get_state : ?tetr:Game.Tetromino.t -> Game.Board.t -> int
  end

module type S =
  sig
    type t

    (** Inits a Q matrix filled with -infinity, placing zeros on slots to
        be used *)
    val make : unit -> t

    (** Builds a Q matrix used by agent to determine actions *)
    val train : t -> float -> float -> (int -> float) -> int ->
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
    (** [play q nt] gives the final board of the game composed of [nt]
        tetrominos
        played with matrix [q] *)
  end

module Make : functor (Ag : AgentTools) -> S
