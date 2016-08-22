open Core.Std;;
open Traildb_functions;;
open Printf;;
open Test_utils;;

module TS = TestSimple;;
let is = TestSimple.is;;
let test str x y = is x y str;;

let consdir = "./t/tmp/raw_empty_with_fields";;

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

let main =
  begin
    let () = plan 7 in
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


    let final_err = tdb_cons_finalize cons in
    let () =
      test "tdb_cons_finalize succeeded"
        final_err 0 in
    let tdb1 = tdb_init_open "./t/tmp/raw_empty_with_fields" in
    let () =
      test "tdb_num_trails" 
        (tdb_num_trails tdb1 |> string_of_uint64) "0";
      test "tdb_num_events"
        (tdb_num_events tdb1 |> string_of_uint64) "0";
      test "tdb_num_fields"
        (tdb_num_fields tdb1 |> string_of_uint64) "3";
      (* TODO: counterintuitively, the minimum of an empty timestamp is zero *)
      test "tdb_min_timestamp"
        (tdb_min_timestamp tdb1 |> string_of_uint64) (Unsigned.UInt64.max_int |> string_of_uint64);
      test "tdb_max_timestamp"
        (tdb_max_timestamp tdb1 |> string_of_uint64) "0";
    in
    ()
  end
