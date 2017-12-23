(** Agent module, makes the agent given an operating mode and tools *)

(** Module signature of an agent *)
module type AgentTools =
  sig
    (** The type of the agent, matrix or function *)
    type t

    (** Representation of the state *)
    type s

    (** An auxiliary memory which can be used by the agent *)
    type mem

    (** Makes an agent *)
    val make : int -> t
    (** [make s] makes an agent suitable for a model with [s] possible states *)

    (** Makes the memory of the agent of the given size *)
    val mem_make : int -> mem

    (** Function updating the agent in place *)
    val update : t -> s -> int -> s -> float -> float -> float -> mem -> int ->
      unit
    (** [update ag s a ns r g p m i] updates the agent [ag] for the [i]th time
        in the game during the transition from state [s] to state [ns] through
        action [a] generating reward [r] with a sight length of [g], a
        parameter [p] and a memory [m].
    *)

    (** Outputs state from the board and, if supplied, the tetromino *)
    val get_state : Game.Tetromino.t -> Game.Board.t -> s

    (** Gives rewards currently associated to a state *)
    val get_reward_exps : t -> s -> float array
    (** [get_rewards a s] returns an array containing reward expectancies
        currently known by the agent *)

    (** Reward function *)
    val r : Game.Board.t -> Game.Board.t -> float

    (** Chooses an action considering reward expectancies *)
    val choose_act : float array -> float -> int list -> Game.Action.t * int
    (** [choose_act re e as] chooses an action among the action set [as] coded
        as int with a probability [e] of choosing randomly with [re] the list
        of reward expectancies
        @return [(a, aid)] the tuple of the action id and the action *)
  end

(** Module signature of the output of the functor *)
module type S =
  sig
    type t

    (** Gives birth to an agent, eager to learn *)
    val make : int -> t
    (** [make s] prepares the agent for a game with [s] states *)

    (** Loads a t datum from the disk *)
    val load : string -> t
    (** [load s] returns data contained in file [s]; type check is done when
        loading from file (with [Marshal.from_channel i : t]) *)

    (** Saves the agent to disk *)
    val save : t -> string -> unit
    (** [save a f] saves the agent [a] to file name [f] *)

    (** Builds a Q matrix used by agent to determine actions *)
    val train : t -> float -> float -> float -> int -> int -> unit
    (** [train q e g a ng nt] trains the matrix [q] with [e] the frequency of
        random choice,
        [g] the sight length of the agent, i.e. weight given to future turns to
        make an action,
        [a] a parameter used during learning
        [ng] the number of games played to train,
        [nt] number of tetrominos played in each game
    *)

    (** Plays a game *)
    val play : t -> int -> Game.Board.t
    (** [play ag nt] gives the final board of the game composed of [nt]
        tetrominos played by agent [ag] *)
  end

module Make : functor (Ag : AgentTools) -> S with type t = Ag.t
