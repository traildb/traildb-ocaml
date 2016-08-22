open Core.Std;;
open Traildb_functions;;
open Printf;;
open Test_utils;;

module TS = TestSimple;;
let is = TestSimple.is;;
let test str x y = is x y str;;

let file_exists = Core.Core_sys.file_exists;;
let uuid_of_string = Traildb.uuid_of_string;;

let uint64 = Unsigned.UInt64.of_int;;

let consdir = "./t/tmp/raw_non_empty";;

let string_of_uint64 = Unsigned.UInt64.to_string;;

type row = {
  uuid: Unsigned.uint8 Ctypes.ptr;
  color: string;
  width: string;
  time: Unsigned.uint64;
}

let add_row tdb_cons row =
  tdb_cons_add
    tdb_cons
    row.uuid
    row.time
    (
      Ctypes.CArray.start (
        Ctypes.CArray.of_list
          Ctypes.string
          [row.color; row.width]
      )
    )
    (
      Ctypes.CArray.start (
        Ctypes.CArray.of_list
          Ctypes.uint64_t
          [
            row.color |> String.length |> uint64;
            row.width |> String.length |> uint64;
          ]
      )
    )

let main () =
  begin
    let () = plan 8 in
    let cons_opt = tdb_cons_init () in
    let cons = cons_opt |> Option.value_exn in
    let cons_err = (
      tdb_cons_open
        cons
        consdir
        (
          Ctypes.CArray.start (
            Ctypes.CArray.of_list
              Ctypes.string
              ["color"; "width"]
          )
        )
        (
          uint64 2
        )
    ) in
    let () =
      test "tdb_cons_open succeeded"
        cons_err 0 in

    let add_err = (
      add_row cons {
        uuid=(uuid_of_string "1234567812345678" |> Ctypes.CArray.start);
        color="red";
        width="blue";
        time=uint64 123;
      }
    ) in

    let () =
      test "tdb_cons_add succeeded"
        add_err 0 in

    let final_err = tdb_cons_finalize cons in
    let () =
      test "tdb_cons_finalize succeeded"
        final_err 0 in
    let tdb1 = tdb_init_open "./t/tmp/raw_non_empty" in
    let () = (
      test "tdb_num_trails" 
        (tdb_num_trails tdb1 |> string_of_uint64) "1";
      test "tdb_num_events"
        (tdb_num_events tdb1 |> string_of_uint64) "1";
      test "tdb_num_fields"
        (tdb_num_fields tdb1 |> string_of_uint64) "3"; 
      (* TODO: counterintuitively, the minimum of an empty timestamp is empty *)
      test "tdb_min_timestamp"
        (tdb_min_timestamp tdb1 |> string_of_uint64) "123";
      test "tdb_max_timestamp"
        (tdb_max_timestamp tdb1 |> string_of_uint64) "123";
    )
    in
    ()
  end

let () = main ();;
