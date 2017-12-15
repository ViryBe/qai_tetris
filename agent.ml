module type AgentTools =
  sig
    type t

    type s

    val make : int -> t

    val update : t -> s -> int -> s -> float -> float -> float -> int -> unit

    val get_state : Game.Tetromino.t -> Game.Board.t -> s

    val get_reward_exps : t -> s -> float array

    val r : Game.Board.t -> Game.Board.t -> float

    val choose_act : float array -> float -> int list -> Game.Action.t * int
  end

module type S =
  sig
    type t

    val make : int -> t

    val load : string -> t

    val save : t -> string -> unit

    val train : t -> float -> float -> float -> int -> int -> unit

    val play : t -> int -> Game.Board.t
  end

module Make (Ag : AgentTools) : (S with type t = Ag.t) =
struct

  type t = Ag.t

  let make = Ag.make

  let load src =
    let infile = open_in src
    in
    let data = (Marshal.from_channel infile : t) in
    close_in infile ;
    data

  let save data dest =
    let outfile = open_out dest in
    Marshal.to_channel outfile data []

  let update ag eps gam par ntetr =
    let board = Game.Board.make (2 * ntetr)
    and tetromino = ref (Game.Tetromino.make_rand ()) in
    let state = ref (Ag.get_state !tetromino board)
    in
    for i = 0 to ntetr - 1 do
      (* Compute actions *)
      let idactions = Game.Tetromino.get_actids !tetromino in
      let action, act_ind = Ag.choose_act (Ag.get_reward_exps ag !state) eps
          idactions in
      (* Make a backup of the board *)
      let backboard = board in
        (* Update board accordingly to action *)
      Game.play board !tetromino action ;
      tetromino := Game.Tetromino.make_rand () ;
      let reward = Ag.r backboard board
      and nstate = Ag.get_state !tetromino board in
      Ag.update ag !state act_ind nstate reward gam par i;
      state := nstate
    done ;
    board

  let train ag eps gam alpha ngames ntetr =
    for i = 0 to ngames - 1 do
      let fboard = update ag eps gam alpha ntetr in
      let fheight = Game.Board.height fboard in
      Printf.printf "%d\n" fheight
    done

  let play ag ntetr =
    let board = Game.Board.make (2 * ntetr + 1)
    and tetromino = ref (Game.Tetromino.make_rand ()) in
    let  state = ref (Ag.get_state !tetromino board) in
    for i = 0 to ntetr - 1 do
      let actids = Game.Tetromino.get_actids !tetromino in
      let action, _ = Ag.choose_act (Ag.get_reward_exps ag !state) 0.
          actids in
      Game.play board !tetromino action ;
      tetromino := Game.Tetromino.make_rand () ;
      state := Ag.get_state !tetromino board;
      (* graphic part *)
      Display.draw_board
        (Game.Board.to_arr
           (max 0 (Game.Board.height board - 10))
           (Game.Board.height board + 5) board)
        i (Game.Board.height board)
    done ;
    Printf.printf "%d Tetrominos: final height of %d\n" ntetr
      (Game.Board.height board) ;
    board
end
