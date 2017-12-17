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
  let module Ag = Agent.Make(Qmat) in
  (* Launching program *)
  if demo then(* Demo mode *)
  (* init graphics window *)
    let size = (" "^(string_of_int (Display.total_width))
              ^"x"^(string_of_int (Display.total_height))) in

    match qload with
    | Some qpath -> let qag = Ag.load qpath in
      (Graphics.open_graph (size);
       ignore (Ag.play qag ntetr);
       Graphics.close_graph ();)
    | None -> raise (Arg.Bad "demo mode requires -qload")
  else
    (* Set Q matrix (load or create *)
    let qag =
      match qload with
      | None -> Ag.make state_card
      | Some str -> Ag.load str
    in
    (* Start training *)
    Printf.printf "#ngames=%d:ntetr=%d:gamma=%f:alphap=%f:eps=%f\n"
      ngames ntetr gam alphap eps ;
    Ag.train qag eps gam alphap ngames ntetr ;
    (* Save matrix if qsave path is specified *)
    may (Ag.save qag) qsave;
