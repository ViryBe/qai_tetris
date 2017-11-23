(** Manages all inputs and outputs needed for the program, the learning
 * part and the tetris part *)

(** Saves any float matrix to disk*)
val save_mat : string -> 'a array array -> bool
(** @param 1 matrix to save
 *  @return boolean indicating whether matrix has been saved successfully *)

(** Loads a marshalled matrix *)
val load_mat : string -> 'a array array
(** @param string path to file containing data *)
