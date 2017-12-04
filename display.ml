let minisleep (sec: float) =
  ignore (Unix.select [] [] [] sec)

let std_len = 30

let draw_board = fun board nb_t height->
  for i = 0 to Array.length board -1 do
    for j = 0 to Array.length board.(i) -1 do
      if board.(i).(j) = 1 then
        (Graphics.set_color Graphics.red;Graphics.fill_rect (j*std_len) (i*std_len) std_len std_len)
      else if board.(i).(j) = 2 then
        (Graphics.set_color Graphics.blue;Graphics.fill_rect (j*std_len) (i*std_len) std_len std_len)
      else if board.(i).(j) = 3 then
        (Graphics.set_color Graphics.green;Graphics.fill_rect (j*std_len) (i*std_len) std_len std_len)
      else if board.(i).(j) = 4 then
        (Graphics.set_color Graphics.cyan;Graphics.fill_rect (j*std_len) (i*std_len) std_len std_len)
      else if board.(i).(j) = 5 then
        (Graphics.set_color Graphics.yellow;Graphics.fill_rect (j*std_len) (i*std_len) std_len std_len)
      else
        (Graphics.set_color Graphics.black;Graphics.fill_rect (j*std_len) (i*std_len) std_len std_len)
    done
  done;
  let s  = String.concat "" ["nb tetromino: ";string_of_int nb_t; ", hauteur: ";string_of_int height] in
  Graphics.set_color Graphics.black;
  Graphics.draw_string s;
  minisleep 1.
