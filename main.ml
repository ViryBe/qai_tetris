(** Main module of the tetris player, starts everything *)

(** Number of states *)
let state_card = 20480 

(** Used for optional arguments:
    @param x the optional argument
    @param f the function calling x *)
let may ~f x =
  match x with
  | None -> ()
  | Some x -> ignore (f x)

let () =
  Random.self_init () ;
  (* Load command line parameters *)
  let clargs =
    try
      Aio.Clargs.parse Sys.argv
    with
    | Arg.Help str -> Printf.printf "%s" str ; raise (Arg.Help "")
    | Arg.Bad str -> Printf.printf "%s" str ; raise (Arg.Bad "")
  in
  let alphap, gam, eps, ngames = Aio.Clargs.train_params clargs
  and qload, qsave = Aio.Clargs.qio_params clargs
  and demo = Aio.Clargs.demo_mode clargs
  and ntetr = Aio.Clargs.rules clargs
  in
  (* Init logconf *)
  Bolt.Logger.log "main" Bolt.Level.INFO "Qai tetris started" ;
  (* Launching program *)
  if demo (* Demo mode *)
      then match qload with
      | Some qpath -> let qmat = Aio.Qio.load qpath in
          ignore (Agent.play qmat ntetr)
      | None -> raise (Arg.Bad "demo mode requires -qload")
  else
    (* Set Q matrix (load or create *)
    let qmat =
      match qload with
      | None -> Array.make_matrix state_card (Array.length Game.Action.set) 0.
      | Some str -> Aio.Qio.load str
    in
    (* Start training *)
    Agent.train qmat eps gam (fun k -> 1. /. (1. +. alphap *. float k))
      ngames ntetr ;
    (* Save matrix if qsave path is specified *)
    may (Aio.Qio.save qmat) qsave
