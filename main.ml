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

let check_demo d =
  if d then
    if !(cl_params.qpath) = "" then
      raise (Arg.Bad "path to Q matrix required in demo mode")
    else cl_params.demo := true
  else cl_params.demo := false (* Leave it to false *)

(** Speclist for argument parsing, mind the order *)
let speclist = [
  ("-q", Arg.String check_qpath, "path of Q matrix file");
  ("-demo", Arg.Bool check_demo, "demo mode");
  ("-n", Arg.Set_int cl_params.ngames, "number of games played");
  ("-epsilon", Arg.Float (float_check cl_params.epsilon),
   "frequency of random action, in [0, 1]");
  ("-gamma", Arg.Float (float_check cl_params.gamma),
   "sight length of the policy, in [0, 1]");
  ("-alpha", Arg.Set_float cl_params.alphap, "parameter of the learning rate");
]

let () =
  (** Usage string *)
  let usage = "Usage: " ^ Sys.argv.(0) ^
              " [-q matpath -demo bool] [-epsilon float] " ^
              "[-gamma float] [-alpha float] [-n int]" in
  Arg.parse
    speclist
    (fun x -> raise (Arg.Bad ("Bad argument: " ^ x)))
    usage;
  (* Init logconf *)
  Bolt.Logger.log "main" Bolt.Level.INFO "Qai tetris started" ;
  Printf.printf "Parameters: eps=%f:gam=%f:ngames=%d\n" !(cl_params.epsilon)
    !(cl_params.gamma) !(cl_params.ngames) ;
  (* Launching program *)
  if !(cl_params.demo) (* Demo mode *)
  then let qmat = Aio.load_mat !(cl_params.qpath) in
      ignore (Agent.play qmat Game.tetromino_per_game)
  else
    (* Set Q matrix (load or create *)
    let qinit = if !(cl_params.qpath) = "" then
        Array.make_matrix state_card (Array.length Game.Action.set) 0. else
        Aio.load_mat !(cl_params.qpath)
    in
    (* Start training *)
    Agent.train qinit !(cl_params.epsilon) !(cl_params.gamma)
      (fun k -> 1. /. (1. +. !(cl_params.alphap) *. float k))
      !(cl_params.ngames) Game.tetromino_per_game
