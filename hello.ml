open Traildb;;

let main =
  (
    print_string "hi";
    ignore (tdb_cons_init ())
  );;

let () = main;;
