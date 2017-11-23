(** Main module of the tetris player, starts everything *)

let epsilon = ref 0.
let gamma = ref 0.
let ngames = ref 0
let demo = ref false
let qpath = ref ""

(** Usage string *)
let usage = "Usage: " ^ Sys.argv.(0) ^ " [-d -q matpath] [-e epsilon] " ^
            "[-g gamma] [-n ngames]"

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
  ("-d", Arg.Set demo, ": set demo mode");
  ("-q", Arg.String check_qpath, ": set path of Q matrix file");
  ("-n", Arg.Set_int ngames, ": set number of games played");
  ("-e", Arg.Float (float_check epsilon),
   ": set frequency of random action, in [0, 1]");
  ("-g", Arg.Float (float_check gamma),
   ": set sight length of the policy, in [0, 1]");
]

let () =
  Arg.parse
    speclist
    (fun x -> raise (Arg.Bad ("Bad argument: " ^ x)))
    usage;
  Printf.printf "%f %f %d %b\n" !epsilon !gamma !ngames !demo
