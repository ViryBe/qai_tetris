(** Manages all inputs and outputs needed for the program, the learning
    part and the tetris part *)

module Qio : sig

  (** Basic type of the Q matrix *)
  type t = float array array

  (** Saves any matrix to disk*)
  val save : float array array -> string -> unit

  (** Loads a marshalled matrix from file fpath*)
  val load : string -> float array array
end

(** Logs the result of a game *)
val log_game : string -> unit

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
    qpath : string ;
  }

  (** Parse the command line *)
  val parse : string array -> t
end
