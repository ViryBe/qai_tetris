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

module Make (Ag : AgentTools) = struct
end
