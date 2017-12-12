
(** makes a pause of x sec (float) *)
let minisleep (sec: float) =
  ignore (Unix.select [] [] [] sec)


(* cst values related to graphical mesures *)
let std_len = 30
let total_width = 400
let total_height = 700

(** Display the board with a different color for each tetromino *)
let draw_board = fun board nb_t height->
  for i = 0 to Array.length board -1 do
    for j = 0 to Array.length board.(i) -1 do
      Graphics.set_color (
        if board.(i).(j) = 1 then Graphics.yellow else
        if board.(i).(j) = 2 then Graphics.red else
        if board.(i).(j) = 3 then Graphics.cyan else
        if board.(i).(j) = 4 then Graphics.green else
        if board.(i).(j) = 5 then Graphics.magenta else
                                  Graphics.black;
      );
      Graphics.fill_rect (j*std_len) (i*std_len) std_len std_len
    done
  done;
  (* print the score *)
  let s  = String.concat ""
      ["nb tetromino: ";
       string_of_int nb_t;
       ", hauteur: ";
       string_of_int height]
  in
  let x_str = ( Game.Board.width * std_len + 10) in
  let y_str = 0 in
  Graphics.moveto x_str y_str;
  Graphics.set_color Graphics.white;
  Graphics.fill_rect x_str y_str 500 100;
  Graphics.set_color Graphics.black;
  Graphics.draw_string s;
  minisleep 0.1
