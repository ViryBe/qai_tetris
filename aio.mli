(** Manages all inputs and outputs needed for the program, the learning
    part and the tetris part *)

(** Saves any matrix to disk*)
val save_mat : float array array -> string -> unit

(** Loads a marshalled matrix from file fpath*)
val load_mat : string -> float array array

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
    demo : bool ;
    qpath : string ;
  }

  (** Parse the command line *)
  val parse : string array -> t
end
