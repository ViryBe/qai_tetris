(** Main module of the tetris player, starts everything *)

(** Number of states *)
let state_card = 20480

let () =
  (* Load command line parameters *)
  let cl_params =
    try
      Aio.Clargs.parse Sys.argv
    with
    | Arg.Help str -> Printf.printf "%s" str ; raise (Arg.Help "")
    | Arg.Bad str -> Printf.printf "%s" str ; raise (Arg.Bad "")
  in
  (* Init logconf *)
  Bolt.Logger.log "main" Bolt.Level.INFO "Qai tetris started" ;
  Printf.printf "Parameters: eps=%f:gam=%f:alphap=%f:ngames=%d\n"
    cl_params.epsilon cl_params.gamma cl_params.alphap cl_params.ngames ;
  (* Launching program *)
  if cl_params.demo (* Demo mode *)
  then let qmat = Aio.Qio.load cl_params.qpath in
      ignore (Agent.play qmat Game.tetromino_per_game)
  else
    (* Set Q matrix (load or create *)
    let qinit = if cl_params.qpath = "" then
        Array.make_matrix state_card (Array.length Game.Action.set) 0. else
        Aio.Qio.load cl_params.qpath
    in
    (* Start training *)
    Agent.train qinit cl_params.epsilon cl_params.gamma
      (fun k -> 1. /. (1. +. cl_params.alphap *. float k))
      cl_params.ngames Game.tetromino_per_game
