(** A Input Output module *)

module Qio = struct

  (** Basic type of Q matrix *)
  type t = float array array

  (** @param dest path of file to which matrix will be serialised
      @param mat matrix to be serialised *)
  let save mat dest =
    let outfile = open_out dest
    in
    Marshal.to_channel outfile mat []

  (** The danger here is that from_channel reads anything from the file, that is
      why we need the : float array array stuff, to force output type. {e Trying
      to read something else apparently ends in a segfault}.
      @param src path of file from which the matrix will be loaded
      @return matrix which were serialised in file *)
  let load src =
    let infile = open_in src
    in
    (Marshal.from_channel infile : t)
end

(** Saves a message as a game result
    @param msg string containing the message *)
let log_game msg = Bolt.Logger.log "gamesave" Bolt.Level.INFO msg

(** Logs reward in a gnuplot friendly format *)
let log_reward rew = Bolt.Logger.log "gnuplot_reward" Bolt.Level.INFO
    (Printf.sprintf "%f" rew)

module Clargs = struct
  (** Holds all the parameters *)
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

  (** Create refs as arg parser works on ref. A bit overkill *)
  let epsilon = ref 0.05
  let gamma = ref 0.2
  let alphap = ref 1.
  let ngames = ref 4
  let ntetr = ref 100
  let demo = ref false
  let qload = ref None
  let qsave = ref None

  (** Usage string *)
  let usage = "Usage: " ^ Sys.argv.(0) ^
              " [-demo -qload string] [-epsilon float] " ^
              "[-gamma float] [-alphap float] [-ngames int] [-ntetr int] " ^
              "[-qsave string] [-qload string]"

  (** Checks adequation of input float parameter
      @param var_ref reference used to store the parameter
      @param cl_param value input on command line *)
  let float_check param_ref cl_param =
    if cl_param < 0. || cl_param > 1. then
      raise (Arg.Bad ("float not in [0, 1]"))
    else param_ref := cl_param

  (** Checks existence of file *)
  let check_qload given_qpath =
    if Sys.file_exists given_qpath then
      qload := Some given_qpath
    else raise (Arg.Bad ("File " ^ given_qpath ^ " does not exist"))

  (** Set the option *)
  let set_option opt_ref arg = opt_ref := Some arg

  (** Speclist for argument parsing, mind the order *)
  let speclist = [
    ("-demo", Arg.Set demo, "demo mode, requires qload");
    ("-ngames", Arg.Set_int ngames, "number of games played");
    ("-ntetr", Arg.Set_int ntetr, "number of tetrominos played in a game");
    ("-epsilon", Arg.Float (float_check epsilon),
     "frequency of random action, in [0, 1]");
    ("-gamma", Arg.Float (float_check gamma),
     "sight length of the policy, in [0, 1]");
    ("-alphap", Arg.Set_float alphap, "parameter of the learning rate");
    ("-qload", Arg.String check_qload, "path of Q matrix to load");
    ("-qsave", Arg.String (set_option qsave),
     "output file for generated Q matrix");
  ]

  let parse argv =
    Arg.parse_argv argv speclist
      (fun x -> raise (Arg.Bad ("Bad argument: " ^ x))) usage ;
    {epsilon = !epsilon ; gamma = !gamma ; alphap = !alphap ; ngames = !ngames ;
     ntetr = !ntetr ; demo = !demo ; qload = !qload ; qsave = !qsave }
end
