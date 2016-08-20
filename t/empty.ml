open Core.Std;;
open Traildb;;
open Printf;;

module TS = TestSimple;;
let is = TestSimple.is;;
let test str x y = is x y str;;

let file_exists = Core.Core_sys.file_exists;;

let uint64 = Unsigned.UInt64.of_int;;

module TdbPaths = struct
  type t = {
    tempdir : string;
    file : string;
  }
end;;

let print_err_str x = x |> tdb_error_str |> printf "%s\n";;

(* add values *)
let make_database tdb_paths =
  let open TdbPaths in
  let cons = Cons.create ~root:tdb_paths.tempdir [] in
  begin
    Cons.add cons ~uuid:"whateverwhatever" ~time:(uint64 32) [];
    Cons.add cons ~uuid:"whateverwhatever" ~time:(uint64 64) [];
    cons
  end;;

let main = 
  begin
    let tdb_paths = TdbPaths.{
        tempdir = "./t/tmp/empty";
        file = "./t/tmp/empty.tdb";
      } in
    let cons = make_database tdb_paths in
    (* constructor initialized, tests involving scratch space *)
    let () =
      test "scratch space \"empty\" exists"
        (file_exists "./t/tmp/empty") `Yes in
    let _ = Cons.finish cons in
    (* constructor finalized *)
    let () =
      test "created \"empty.tdb\" after finalization"
        (file_exists "./t/tmp/empty.tdb") `Yes in
    (* db opened *)
    let db = Db.of_path "./t/tmp/empty.tdb" in
    let () = (

      test "Db has single field \"time\""
        (Db.fields db) ["time"];

      test "Lexicon size for field \"time\" should be zero"
        (Db.lexicon_size db "time") (Some (uint64 0));

      test "Lexicon size for nonexistent field \"foobar\" should be none"
        (Db.lexicon_size db "foobar") None;


    ) in
    ()
  end;;

let () = main;;
