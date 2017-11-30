(** Manages all inputs and outputs needed for the program, the learning
    part and the tetris part *)

module Qio : sig

  (** Basic type of the Q matrix *)
  type t = float array array

  (** Saves any matrix to disk*)
  val save : t -> string -> unit

  (** Loads a marshalled matrix from file fpath*)
  val load : string -> t
end

(** Logs the result of a game *)
val log_game : string -> unit

(** Logs reward in a gnuplot friendly format *)
val log_reward : float -> unit

(** Manages command line *)
module Clargs : sig
  (** Type of the parameters *)
  type t = {
    epsilon : float ;
    gamma : float ;
    alphap : float ;
    ngames : int ;
    ntetr : int ;
    demo : bool ;
    qload : string option ;
    qsave : string option ;
  }

  (** Parse the command line *)
  val parse : string array -> t
end
