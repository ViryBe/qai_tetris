(** A Input Output module *)

(** @param dest path of file to which matrix will be serialised
    @param mat matrix to be serialised *)
let save_mat mat dest =
  let outfile = open_out dest
  in
  Marshal.to_channel outfile mat []

(** The danger here is that from_channel reads anything from the file, that is
    why we need the : float array array stuff, to force output type. {e Trying
    to read something else apparently ends in a segfault}.
    @param src path of file from which the matrix will be loaded
    @return matrix which were serialised in file *)
let load_mat src =
  let infile = open_in src
  in
  (Marshal.from_channel infile : float array array)

(** Saves a message as a game result
    @param msg string containing the message *)
let log_game msg = Bolt.Logger.log "gamesave" Bolt.Level.INFO msg

module Clargs = struct
  (** Holds all the parameters *)
  type t = {
    epsilon : float ;
    gamma : float ;
    alphap : float ;
    ngames : int ;
    demo : bool ;
    qpath : string ;
  }

  (** Create refs as arg parser works on ref. A bit overkill *)
  let epsilon = ref 0.
  let gamma = ref 0.
  let alphap = ref 0.
  let ngames = ref 0
  let demo = ref false
  let qpath = ref ""

  (** Usage string *)
  let usage = "Usage: " ^ Sys.argv.(0) ^
              " [-q matpath -demo bool] [-epsilon float] " ^
              "[-gamma float] [-alphap float] [-n int]"

  (** Checks adequation of input float parameter
      @param var_ref reference used to store the parameter
      @param cl_param value input on command line *)
  let float_check param_ref cl_param =
    if cl_param < 0. || cl_param > 1. then
      raise (Arg.Bad ("float not in [0, 1]"))
    else param_ref := cl_param

  (** Checks existence of file *)
  let check_qpath given_qpath =
    if Sys.file_exists !qpath then
      qpath := given_qpath
    else raise (Arg.Bad ("File " ^ given_qpath ^ " does not exist"))

  let check_demo d =
    if d then
      if !qpath = "" then
        raise (Arg.Bad "path to Q matrix required in demo mode")
      else demo := true
    else demo := false (* Leave it to false *)

  (** Speclist for argument parsing, mind the order *)
  let speclist = [
    ("-q", Arg.String check_qpath, "path of Q matrix file");
    ("-demo", Arg.Bool check_demo, "demo mode");
    ("-n", Arg.Set_int ngames, "number of games played");
    ("-epsilon", Arg.Float (float_check epsilon),
     "frequency of random action, in [0, 1]");
    ("-gamma", Arg.Float (float_check gamma),
     "sight length of the policy, in [0, 1]");
    ("-alpha", Arg.Set_float alphap, "parameter of the learning rate");
  ]

  let parse argv =
    Arg.parse_argv argv speclist
      (fun x -> raise (Arg.Bad ("Bad argument: " ^ x))) usage ;
    {epsilon = !epsilon ; gamma = !gamma ; alphap = !alphap ; ngames = !ngames ;
     demo = !demo ; qpath = !qpath }
end
