open Core.Std;;

open Unix;;

let plan = TestSimple.plan;;

let file_exists = Core.Core_sys.file_exists;;
let uuid_of_string = Traildb.uuid_of_string;;

let uint64 = Unsigned.UInt64.of_int;;

let find_exn = List.Assoc.find_exn;;

let string_of_uint64 = Unsigned.UInt64.to_string;;

let backtick cmd = 
  let stdout = open_process_in cmd in
  In_channel.input_all stdout;;

let backtick_lines cmd =
  let stdout = open_process_in cmd in
  In_channel.input_lines stdout;;

(* split on colon and whitespace *)
let backtick_assoc cmd =
  let colon = Str.regexp_string ": " in
  let lines : string list = backtick_lines cmd in
  List.map lines ~f:(fun line ->
        match Str.bounded_split_delim colon line 2 with
        | [key; value] -> (key, value)
        | _ -> failwith "string does not contain \": \""
    )
