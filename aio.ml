(** A Input Output module *)

(** @param dest path of file to which matrix will be serialised
    @param mat matrix to be serialised *)
let save_mat mat dest =
  let outfile = open_out dest
  in
  Marshal.to_channel outfile mat []

(** The danger here is that from_channel reads anything from the file, that is
    why we need the : float array array stuff, to force output type.
    @param src path of file from which the matrix will be loaded
    @return matrix which were serialised in file *)
let load_mat src =
  let infile = open_in src
  in
  (Marshal.from_channel infile : float array array)
