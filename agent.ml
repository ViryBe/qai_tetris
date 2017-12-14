module type AgentTools =
  sig
    type t

    val make : int -> t

    val update : t -> float -> float -> (int -> float) -> int -> Game.Board.t

    val get_state : Game.Tetromino.t -> Game.Board.t -> int

    val get_rewards : t -> int -> float array
  end

module type S =
  sig
    type t

    val make : int -> t

    val load : string -> t

    val save : t -> string -> unit

    val train : t -> float -> float -> (int -> float) -> int ->
      int -> unit

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

  let train ag eps gam alpha ngames ntetr =
    for i = 0 to ngames - 1 do
      let fboard = Ag.update ag eps gam alpha ntetr in
      let fheight = Game.Board.height fboard in
      Printf.printf "%d\n" fheight
    done

  let play ag ntetr =
    let board = Game.Board.make (2 * ntetr + 1)
    and tetromino = ref (Game.Tetromino.make_rand ()) in
    let  state = ref (Ag.get_state !tetromino board) in
    for i = 0 to ntetr - 1 do
      let actids = Game.Tetromino.get_actids !tetromino in
      let action, _ = Game.Action.choose (Ag.get_rewards ag !state) 0. actids in
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
