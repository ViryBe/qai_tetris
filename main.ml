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
  (* Launching program *)
  if demo (* Demo mode *)
      then match qload with
      | Some qpath ->
          begin
            (* init graphics window *)
            let size = (" " ^ (string_of_int (Display.total_width)) ^
                        "x" ^ (string_of_int (Display.total_height))) in
            Graphics.open_graph (size) ;
            let qmat = Aio.Qio.load qpath in
            let _ = Agent.play qmat ntetr in
            Graphics.close_graph ()
          end
      | None -> raise (Arg.Bad "demo mode requires -qload")
  else
    (* Set Q matrix (load or create *)
    let qmat =
      match qload with
      | None ->
          Array.make_matrix state_card Game.Action.card 0.
          (*
            let proto_mat = Array.make_matrix state_card Game.Action.card
                neg_infinity in
            Agent.init_qmat proto_mat ;
            proto_mat
          *)
      | Some str -> Aio.Qio.load str
    and alpha k = 1. /. (1. +. alphap *. float k)
    in
    (* Start training *)
    Printf.printf "#ngames=%d:ntetr=%d:gamma=%f:alphap=%f:eps=%f\n"
      ngames ntetr gam alphap eps ;
    Agent.train qmat eps gam alpha ngames ntetr ;
    (* Save matrix if qsave path is specified *)
    may (Aio.Qio.save qmat) qsave;
