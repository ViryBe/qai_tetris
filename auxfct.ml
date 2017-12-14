
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

let arr_find arr elt =
  let rec loop k =
    if arr.(k) = elt then k else loop (k+1)
  in
  loop 0

let fold_left2_array f x a1 a2 =
  assert(Array.length a1 = Array.length a2);
  let accu = ref x in
  for i = 0 to Array.length a1 -1 do
    accu := f !accu a1.(i) a2.(i)
  done;
  !accu
