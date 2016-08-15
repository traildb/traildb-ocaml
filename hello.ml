open Traildb;;

let main =
  (
    print_string "hi";
    ignore (Constructor.create ~root:"./awesome" ~ofields:[] ())
  );;

let () = main;;
