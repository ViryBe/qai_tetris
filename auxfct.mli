val flarray_max : 'a array -> 'a
val argmax_r : float array -> int
val arr2dig : int array -> int
val arr_find : 'a array -> 'a -> int

(** fold_left on 2 arrays *)
val fold_left2 : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b array -> 'c array -> 'a

(** map2 on 2 arrays *)
(* in the stdlib only since ocaml 4.03.0 *)
val map2 : ('a -> 'b -> 'c) -> 'a array -> 'b array -> 'c array

(** iter2 on 2 arrays *)
(* in the stdlib only since ocaml 4.03.0 *)
val iter2 : ('a -> 'b -> unit) -> 'a array -> 'b array -> unit

(** dot product *)
val dot : float array -> float array -> float
