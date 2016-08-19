open Traildb;;
open Printf;;

module TdbPaths = struct
  type t = {
    tempdir : string;
    file : string;
  }
end;;

let print_err_str x = x |> T.tdb_error_str |> printf "%s\n";;

(* add values *)
let make_database tdb_paths =
  let open TdbPaths in
  let cons = Constructor.create ~root:tdb_paths.tempdir ~ofields:[] () in
  begin
    Constructor.add ~cons:cons ~uuid:"whateverwhatever" ~timestamp:(Unsigned.UInt64.of_int 32) ~values:[] () |> print_err_str;
    Constructor.add ~cons:cons ~uuid:"whateverwhatever" ~timestamp:(Unsigned.UInt64.of_int 64) ~values:[] () |> print_err_str;
    cons
  end;;

(* print the contents of the database *)
let print_database tdb_paths = 
  let open TdbPaths in
  Db.of_path tdb_paths.file |> Db.repr |> printf "%s\n";;

let main = 
  begin
    printf "%s\n" "hi";
    let tdb_paths = TdbPaths.{tempdir = "./awesome"; file = "./awesome.tdb"} in
    let cons = make_database tdb_paths in
    let _ = Constructor.finish ~cons:cons () in
    print_database tdb_paths
  end;;

let () = main;;
