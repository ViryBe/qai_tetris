(** Main module of the tetris player, starts everything *)

(** Big mutable global record containing parameters *)
type glob_params = {
  epsilon : float ref;
  gamma : float ref;
  alphap : float ref;
  ngames : int ref;
  demo : bool ref;
  qpath : string ref;
}

(** Init command line params *)
let cl_params = {epsilon = ref 0. ; gamma = ref 0. ; alphap = ref 0. ;
                 ngames = ref 0 ; demo = ref false ; qpath = ref ""}

(** Number of states *)
let state_card = 20480


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
  ("-demo", Arg.Set cl_params.demo, "demo mode");
  ("-q", Arg.String check_qpath, "path of Q matrix file");
  ("-n", Arg.Set_int cl_params.ngames, "number of games played");
  ("-epsilon", Arg.Float (float_check cl_params.epsilon),
   "frequency of random action, in [0, 1]");
  ("-gamma", Arg.Float (float_check cl_params.gamma),
   "sight length of the policy, in [0, 1]");
  ("-alpha", Arg.Set_float cl_params.alphap, "parameter of the learning rate");
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
  Printf.printf "Parameters: eps=%f:gam=%f:ngames=%d\n" !(cl_params.epsilon)
    !(cl_params.gamma) !(cl_params.ngames) ;
  (* Launching program *)
  if !(cl_params.demo)
  then if !(cl_params.qpath) = ""
    then raise (Arg.Bad "Demo mode requires qpath")
    else let qmat = Aio.load_mat !(cl_params.qpath) in
      ignore (Agent.play qmat Game.tetromino_per_game)
  else if !(cl_params.qpath) = ""
  then let qinit = Array.make_matrix state_card
           (Array.length Game.Action.set) 0. in
    Agent.train qinit !(cl_params.epsilon) !(cl_params.gamma)
      (fun k -> 1. /. (1. +. !(cl_params.alphap) *. float k))
      !(cl_params.ngames)
      Game.tetromino_per_game
