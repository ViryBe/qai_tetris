(** Main module of the tetris player, starts everything *)

(* Mutable global references used to store parameters *)
let epsilon = ref 0. (** Random action frequency *)
let gamma = ref 0. (** Sight length of the agent *)
let ngames = ref 0 (** Number of games to be played *)
let demo = ref false (** Training or playing *)
let qpath = ref "" (** Path of the q matrix to load *)
let logconf = ref "" (** Path to bolt log conf file *)

(** Usage string *)
let usage = "Usage: " ^ Sys.argv.(0) ^ " [-demo -q matpath] [-epsilon float] " ^
            "[-g float] [-n int]"

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
    qpath := given_qpath
  else raise (Arg.Bad ("File " ^ given_qpath ^ " does not exist"))

(** Speclist for argument parsing *)
let speclist = [
  ("-demo", Arg.Set demo, ": set demo mode");
  ("-q", Arg.String check_qpath, ": set path of Q matrix file");
  ("-n", Arg.Set_int ngames, ": set number of games played");
  ("-epsilon", Arg.Float (float_check epsilon),
   ": set frequency of random action, in [0, 1]");
  ("-gamma", Arg.Float (float_check gamma),
   ": set sight length of the policy, in [0, 1]");
  ("-logconf", Arg.Set_string logconf, ": load bolt log config file");
]

let () =
  (* Init logconf *)
  if !logconf <> "" then Unix.putenv "BOLT_CONFIG" !logconf ;
  Bolt.Logger.log "main" Bolt.Level.INFO "Qai tetris started" ;
  Arg.parse
    speclist
    (fun x -> raise (Arg.Bad ("Bad argument: " ^ x)))
    usage;
  Printf.printf "%f %f %d %b\n" !epsilon !gamma !ngames !demo
