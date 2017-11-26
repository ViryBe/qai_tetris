(** Main module of the tetris player, starts everything *)

(** Big mutable global record containing parameters *)
type glob_params = {
  epsilon : float ref;
  gamma : float ref;
  ngames : int ref;
  demo : bool ref;
  qpath : string ref;
}

(** Init command line params *)
let cl_params = {epsilon = ref 0. ; gamma = ref 0. ; ngames = ref 0 ;
                 demo = ref false ; qpath = ref ""}


(** Checks adequation of input float parameter
    @param var_ref reference used to store the parameter
    @param cl_param value input on command line *)
let float_check var_ref cl_param =
  if cl_param < 0. || cl_param > 1. then
    raise (Arg.Bad ("float not in [0, 1]"))
  else var_ref := cl_param 

(** Checks existence of file *)
let check_qpath given_qpath =
  if Sys.file_exists "qpath" then
    cl_params.qpath := given_qpath
  else raise (Arg.Bad ("File " ^ given_qpath ^ " does not exist"))

(** Speclist for argument parsing *)
let speclist = [
  ("-demo", Arg.Set cl_params.demo, ": set demo mode");
  ("-q", Arg.String check_qpath, ": set path of Q matrix file");
  ("-n", Arg.Set_int cl_params.ngames, ": set number of games played");
  ("-epsilon", Arg.Float (float_check cl_params.epsilon),
   ": set frequency of random action, in [0, 1]");
  ("-gamma", Arg.Float (float_check cl_params.gamma),
   ": set sight length of the policy, in [0, 1]");
]

let () =
  (** Usage string *)
  let usage = "Usage: " ^ Sys.argv.(0) ^ " [-demo -q matpath] [-epsilon float] " ^
              "[-g float] [-n int]" in
  Arg.parse
    speclist
    (fun x -> raise (Arg.Bad ("Bad argument: " ^ x)))
    usage;
  (* Init logconf *)
  Bolt.Logger.log "main" Bolt.Level.INFO "Qai tetris started" ;
  Printf.printf "%f %f %d %b\n" !(cl_params.epsilon) !(cl_params.gamma)
    !(cl_params.ngames) !(cl_params.demo)
