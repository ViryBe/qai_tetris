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

(** Manages command line *)
module Clargs : sig
  (** Type of the parameters *)
  type t

  (** Gives the training parameters,
      @return [(alphap, gamma, epsilon, ngames)] *)
  val train_params : t -> float * float * float * int

  (** Gives input output paramters regarding Q matrices *)
  val qio_params : t -> string option * string option

  (** Get use mode, demo or training *)
  val demo_mode : t -> bool

  (** Gives rules
      @return [ntetr] number of tetrominos *)
  val rules : t -> int

  (** Parse the command line *)
  val parse : string array -> t
end
