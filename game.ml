module Board = struct
  (** The tetris board *)
  type t = {
      board : int array array;
      mutable stacked_height : int ;
      tot_height : int
  }

  (** Width of the board *)
  let width = 6

  (** Creates an empty board *)
  let make h =
    {
      board = Array.make_matrix h width 0 ;
      stacked_height = 0 ;
      tot_height = h
    }

  (** Gives the height of the given board, i.e. number of stages stacked *)
  let height b = b.stacked_height

  (** Creates a representation of the board *)
  let to_arr low high board =
    let rec loop k =
      if k > high then [| [| |] |] else
        Array.append [| board.board.(k) |] (loop (k+1))
    in
    loop low

  (** Get the board, should be consistent with mutable policy *)
  let get_board b = b.board

  (** Checks whether line is full *)
  let is_full board x =
    Array.fold_left ( && ) true (Array.map (fun elt -> elt <> 0) board.(x))

  (** Returns height of board after placing a tetromino at (x, y) *)
  let assess_height board x y =
    if board.(x).(y) <> 0 || board.(x).(y+1) <> 0 then x else x-1

  (** Prints board to stdout *)
  let print ?low ?up board =
    Printf.printf "  ------\n" ;
    let lb =
      match low with
      | None -> 0
      | Some k -> k
    and ub =
      match up with
      | None -> board.stacked_height
      | Some k -> k
    in
    for i = ub downto max 0 lb do
      Printf.printf "%d:" i ;
      for j = 0 to width - 1 do
        Printf.printf "%s" (if board.board.(i).(j) <> 0 then "*" else " ")
      done ;
      print_newline ()
    done ;
    Printf.printf "  ------" ;
    print_newline ()

  (** Removes full lines *)
  let update_board b x =
    for i = 0 to 1 do
      let line = max 0 (x - i) in
      if is_full b.board line then
        (* We must be sure to have a line of false in the blitted area *)
        let len = height b - line + 1 in
        begin
          Array.blit b.board (line+1) b.board line len;
          (* Reset upper copied line to avoid dependencies *)
          b.board.(line + len) <- Array.make width 0 ;
          b.stacked_height <- b.stacked_height - 1
        end
    done

  (** Update height (in place) *)
  let update_height board new_height = board.stacked_height <- new_height

  (** Writes board to a file *)
  let to_file fname b =
    let fd = open_out fname in
    for i = b.stacked_height downto 0 do
      for j = 0 to width - 1 do
        Printf.fprintf fd "%s" (if b.board.(i).(j) <> 0 then "*" else " ")
      done ;
      Printf.fprintf fd "\n"
    done ;
    close_out fd
end

module Action = struct

  (** Available orientations for tetrominos *)
  type rotation = 
    | North
    | South
    | East
    | West

  (** The type of an action *)
  type t = {rot : rotation; trans : int}

  (** Number of actions *)
  let card = 20

  (** Extracts the translation component of an action *)
  let int_from_translation action = action.trans

  let get_rotation action = action.rot

  let rot_from_int k =
    if k = 0 then North else if k = 1 then South else if k = 2 then East else
    if k = 3 then West else failwith "invalid rotation integer"

  let int_from_rot = function
    | North -> 0
    | South -> 1
    | East -> 2
    | West -> 3

  (** 2D to 1D Array - index match *)
  let get_index i j = 2 * i + j

  (** Give the correct index for 1D Array after a rotation *)
  let make_rotation rotation i j =
    let n = get_index i j in
    match rotation with
    | North -> [|0;1;2;3|].(n)
    | East -> [|2;0;3;1|].(n)
    | South -> [|3;2;1;0|].(n)
    | West -> [|1;3;0;2|].(n)

  (** Associates an id to an action *)
  let to_int act =
    let rotint = int_from_rot act.rot in
    (act.trans lsl 2) + rotint

  (** Inverse function of the above *)
  let from_int id =
    let rot = id land 3
    and trans = (id land 28) lsr 2 in
    {rot = rot_from_int rot ; trans = trans}

  (** The set of all possible actions *)
  let set =
    let actset = Array.make card {rot = North ; trans = 0} in
    for i = 0 to card - 1 do
      let act = from_int i in
      actset.(i) <- act
    done ;
    actset

  let choose = fun rewards epsilon action_set ->
    let tirage = Random.float 1. in
    let actionid = if tirage > epsilon then Auxfct.argmax_r rewards
      else let rind = Random.int (List.length action_set - 1) in
        List.nth action_set rind
    in
    (from_int actionid, actionid)
end

module Tetromino = struct
  (** Tetromino type *)
  type t =
    | Square
    | Lshaped
    | Line
    | Diag
    | Dot

  (** Number of tetrominos *)
  let card = 5

  (** A list of all tetrominos *)
  let set = [ Square ; Lshaped ; Line ; Diag ; Dot ]

  (** Array representation of the tetrominos *)
  let arr_repr = [
    (Square, [| 1 ; 1 ; 1 ; 1 |]) ;
    (Lshaped, [| 2 ; 0 ; 2 ; 2 |]) ;
    (Line, [| 3 ; 0 ; 3 ; 0 |]) ;
    (Diag, [| 4 ; 0 ; 0 ; 4 |]) ;
    (Dot, [| 5 ; 0 ; 0 ; 0 |])
  ]

  (** Ids associated to tetrominos *)
  let ids = [(Square, 0) ; (Lshaped, 1) ; (Line, 2) ; (Diag, 3) ; (Dot, 4)]

  (** Array representation of tetrominos *)
  let to_arr tetr = List.assoc tetr arr_repr

  (** Associative list mapping tetromino to its available orientations *)
  let available_rots =
    [
      (Square, [ Action.North ]) ;
      (Lshaped, [ Action.North ; Action.West ; Action.South ; Action.East ]) ;
      (Line, [ Action.North ; Action.West ; Action.South ]) ;
      (Diag, [ Action.North ; Action.West ]) ;
      (Dot, [ Action.North ; Action.West ])
    ]

  (* Gives all actions associated to rotation *)
  let act_set_from_rot rot =
    let rec loop k =
      if k < 0 then []
      else Action.to_int {Action.rot = rot ; Action.trans = k} :: loop (k-1)
    in
    loop (Board.width - 2) (* 2 because a tetromino has a width of 2 *)

  (** Outputs actions ids of a tetromino *)
  let compute_actids tetr =
    let rots = List.assoc tetr available_rots in
    (tetr, List.fold_left (fun acc elt -> act_set_from_rot elt @ acc) [] rots)

  (** Associative list mapping tetrominos to their actions ids *)
  let t_to_actids = List.map compute_actids set

  (** @return actions ids associated to tetromino *)
  let get_actids tetr = List.assoc tetr t_to_actids

  (** Converts tetromino to int *)
  let to_int tetr = List.assoc tetr ids

  (** Generates a random tetromino *)
  let make_rand () =
    let n = Random.int card in
    List.nth set n
end

let collide table x y tetromino rotation =
  let n = ref(false) in
  for i = 0 to 1 do
    for j = 0 to 1 do
      let tetrarr = Tetromino.to_arr tetromino
      and ind_afterot = Action.make_rotation rotation i j in
      n := !n ||
           tetrarr.(ind_afterot) > 0 &&
           (Board.get_board table).(x-i).(y+j) <> 0;
    done;
  done;
  !n

(** Places tetromino rotated at x y on board table *)
let place_tetromino table tetromino rotation x y =
  let board = Board.get_board table in (* Still modifies table.board *)
  for i = 0 to 1 do
    for j = 0 to 1 do
      let tetrarr = Tetromino.to_arr tetromino in
      let tetrquarter = tetrarr.(Action.make_rotation rotation i j) in
      if tetrquarter > 0 then
        board.(x - i).(y + j) <- tetrquarter
    done;
  done;
  Board.update_height table (max (Board.assess_height board x y)
                               (Board.height table))

let play board tetromino action =
  let x = ref (Board.height board + 2) in (* +1 to add the new tetromino *)
  let y = Action.int_from_translation action in
  while !x > 0 && not (collide board !x y tetromino
                         (Action.get_rotation action)) do
    x := !x - 1;
  done;
  x := !x + 1 ;
  place_tetromino board tetromino (Action.get_rotation action) !x y ;
  Board.update_board board !x
