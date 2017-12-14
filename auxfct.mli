val flarray_max : 'a array -> 'a
val argmax_r : float array -> int
val arr2dig : int array -> int
val arr_find : 'a array -> 'a -> int

(** fold_left on 2 arrays *)
val fold_left2_array : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b array -> 'c array -> 'a
