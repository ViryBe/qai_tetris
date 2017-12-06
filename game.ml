(** Converts bool to int *)
let int_of_bool b = if b then 1 else 0

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

  (** Extracts the translation component of an action *)
  let int_from_translation action = action.trans

  let get_rotation action = action.rot

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
  let action_to_id act =
    let rotint = match act.rot with
      | North -> 0
      | South -> 1
      | East -> 2
      | West -> 3
    in
    (act.trans lsl 2) + rotint

  (** The set of all possible actions *)
  let set =
    [|
      {rot = North; trans = 0};
      {rot = North; trans = 1};
      {rot = North; trans = 2};
      {rot = North; trans = 3};
      {rot = North; trans = 4};
      {rot = East; trans = 0};
      {rot = East; trans = 1};
      {rot = East; trans = 2};
      {rot = East; trans = 3};
      {rot = East; trans = 4};
      {rot = South; trans = 0};
      {rot = South; trans = 1};
      {rot = South; trans = 2};
      {rot = South; trans = 3};
      {rot = South; trans = 4};
      {rot = West; trans = 0};
      {rot = West; trans = 1};
      {rot = West; trans = 2};
      {rot = West; trans = 3};
      {rot = West; trans = 4}
    |]
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

  (** Array representation of tetrominos *)
  let to_arr = function
    | Square -> [| 1 ; 1 ; 1 ; 1 |]
    | Lshaped -> [| 2 ; 0 ; 2 ; 2 |]
    | Line -> [| 3 ; 0 ; 3 ; 0 |]
    | Diag -> [| 4 ; 0 ; 0 ; 4 |]
    | Dot -> [| 5 ; 0 ; 0 ; 0 |]

  (** Gives availbale actions for tetromino *)
  let to_action_set tetr =
    let ind_list = match tetr with
      (* North only *)
      | Square -> [0 ; 1 ; 2 ; 3 ; 4]
      (* All ortientations *)
      | Lshaped ->
          [ 0 ; 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10 ; 11 ; 12 ; 13 ; 14 ;
            15 ; 16 ; 17 ; 18 ; 19 ]
      (* North, West and South *)
      | Line -> [0 ; 1 ; 2 ; 3 ; 4 ; 15 ; 16 ; 17 ; 18 ; 10 ; 11 ; 12 ; 13]
      (* North & West *)
      | Diag | Dot -> [0 ; 1 ; 2 ; 3 ; 4 ; 15 ; 16 ; 17 ; 18 ]
    in
    let rec loop = function
      | [] -> []
      | hd :: tl -> Action.set.(hd) :: loop tl
    in
    Array.of_list (loop ind_list)

  (** Converts tetromino to int *)
  let to_int = function
    | Square -> 1
    | Lshaped -> 2
    | Line -> 3
    | Diag -> 4
    | Dot -> 5

  (** Generates a random tetromino *)
  let make_rand () =
    let n = Random.int card in
    if n = 0 then Square else if n = 1 then Lshaped else if n = 2 then Line
    else if n = 3 then Diag else Dot
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

let arr_find arr elt =
  let rec loop k =
    if arr.(k) = elt then k else loop (k+1)
  in
  loop 0

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
