
(** Auxiliary functions *)


(** Simple fuction giving the max of an array *)
let flarray_max arr = Array.fold_left max arr.(0) arr

(** Argmax with random choice if two same max *)
let argmax_r arr =
  let epscmp = 1.e-5 in (* Equality on floats isn't reliable *)
  let len = Array.length arr in
  let maxv = flarray_max arr in
  let rec build_maxis k =
    if k >= len then []
    else if arr.(k) >= maxv -. epscmp && arr.(k) <= maxv +. epscmp
    then k :: build_maxis (k+1)
    else build_maxis (k+1)
  in
  let maxis = build_maxis 0 in
  List.nth maxis (Random.int (List.length maxis))

(** One to one mapping from bool array to digit *)
let arr2dig arr =
  let line_bin = Array.map (fun elt -> if elt = 0 then 0 else 1) arr in
  Array.fold_left (fun acc elt -> (acc lsl 1) + elt) 0 line_bin

(** Outputs the two last lines of the board *)
let get_board_top board =
  let height = Game.Board.height board in
  if height >= 2 then
    Game.Board.to_arr (height - 1) height board else
    Game.Board.to_arr 0 height board

let arr_find arr elt =
  let rec loop k =
    if arr.(k) = elt then k else loop (k+1)
  in
  loop 0
