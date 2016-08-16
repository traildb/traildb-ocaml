open Traildb;;

let main = 
  begin
    print_string "hi";
    let cons = Constructor.create ~root:"./awesome" ~ofields:[] () in
    (Constructor.add ~cons:cons ~uuid:"whateverwhatever" ~timestamp:(Unsigned.UInt64.of_int 32) ~values:[] () |> tdb_error_str |> Printf.printf "%s\n";
    Constructor.add ~cons:cons ~uuid:"whateverwhatever" ~timestamp:(Unsigned.UInt64.of_int 64) ~values:[] () |> tdb_error_str |> Printf.printf "%s\n";
    Constructor.finish ~cons:cons () |> tdb_error_str |> Printf.printf "%s\n")
  end;;

let () = main;;
