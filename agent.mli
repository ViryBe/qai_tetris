(** Agent module, builds the Q matrix used by policy *)

(** Module signature of an agent *)
module type AgentTools =
  sig
    (** The type of the agent, matrix or function *)
    type t

    (** Makes an agent *)
    val make : int -> t
    (** [make s] makes an agent suitable for a model with [s] possible states *)

    (** Function updating the agent *)
    val update : t -> float -> float -> (int -> float) -> int -> Game.Board.t
    (** [update t e g a n ] trains the agent through a game of [n] tetrominos
        with a frequency [e] of random action, a sight length of [g] and a
        learning rate of [a] (which is a function) *)

    (** Outputs state from the board and, if supplied, the tetromino *)
    val get_state : Game.Tetromino.t -> Game.Board.t -> int

    (** Gives rewards currently associated to a state *)
    val get_rewards : t -> int -> float array
    (** [get_rewards a s] returns an array containing reward expectancies
        currently known by the agent *)
  end

(** Module signature of the output of the functor *)
module type S =
  sig
    type t

    (** Gives birth to an agent, eager to learn *)
    val make : int -> t
    (** [make ?a s] prepares the agent for a game with [s] states *)

    (** Loads a t datum from the disk *)
    val load : string -> t
    (** [load s] returns data contained in file [s]; type check is done when
        loading from file (with [Marshal.from_channel i : t]) *)

    (** Saves the agent to disk *)
    val save : t -> string -> unit
    (** [save a f] saves the agent [a] to file name [f] *)

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
    val play : t -> int -> Game.Board.t
    (** [play q nt] gives the final board of the game composed of [nt]
        tetrominos
        played with matrix [q] *)
  end

module Make : functor (Ag : AgentTools) -> S with type t = Ag.t
