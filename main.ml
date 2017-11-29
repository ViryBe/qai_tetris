(** Main module of the tetris player, starts everything *)

(** Number of states *)
let state_card = 65535

let () =
  Random.self_init () ;
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
  (* Launching program *)
  if cl_params.demo (* Demo mode *)
      then match cl_params.qload with
      | Some qpath -> let qmat = Aio.Qio.load qpath in
          ignore (Agent.play qmat cl_params.ntetr)
      | None -> raise (Arg.Bad "demo mode requires -qload")
  else
    (* Set Q matrix (load or create *)
    let qinit =
      match cl_params.qload with
      | None -> Array.make_matrix state_card (Array.length Game.Action.set) 0.
      | Some str -> Aio.Qio.load str
    in
    (* Start training *)
    Agent.train ?qpath:cl_params.qsave qinit cl_params.epsilon cl_params.gamma
      (fun k -> 1. /. (1. +. cl_params.alphap *. float k))
      cl_params.ngames cl_params.ntetr
