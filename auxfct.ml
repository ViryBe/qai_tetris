
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

let fold_left2 f x a b =
  assert(Array.length a = Array.length b);
  let accu = ref x in
  for i = 0 to Array.length a -1 do
    accu := f !accu a.(i) b.(i)
  done;
  !accu


let dot a b =
  fold_left2 (fun accu e1 e2 -> accu +.e1 *.e2 ) 0. a b


(** implementation from :
  * https://github.com/ocaml/ocaml/blob/trunk/stdlib/array.ml
  *)
let map2 f a b =
  let la = Array.length a in
  let lb = Array.length b in
  if la <> lb then
    invalid_arg "Array.map2: arrays must have the same length"
  else begin
    if la = 0 then [||] else begin
      let r = Array.make la (f (Array.unsafe_get a 0) (Array.unsafe_get b 0)) in
      for i = 1 to la - 1 do
        Array.unsafe_set r i (f (Array.unsafe_get a i) (Array.unsafe_get b i))
      done;
      r
    end
  end
