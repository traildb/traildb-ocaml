open Core.Std;;

(* TODO: move stuff that can return a null pointer to
 * use Ctypes.ptr_opt *)
(* TODO maybe use `Hex vs `Bin to
 * separate out cases where we want a hex string versus a binary
 * string *)
(* TODO We seriously need a better way to use out-parameters in functions
 * than using Ctypes.allocate_n to allocate a 1-element array
 * for now though, that's the best I got *)
(* TODO right now the allocate stuff uses Ctypes.uint32_t and Ctypes.uint64_t
 * instead of type synonym *)
(* We seriously need consistent error handling.
 * let's move everything over to `Ok | `Error *)
(* and have _exn variants as well *)
(* it would be a good idea to allow users to fold over traildbs as well *)

open Foreign;;
(* types and associated conversion functions *)
(* raw tdb functions *)
module T = Traildb_functions;;

(* higher-level stuff *)
(* TODO put the higher-level stuff that doesn't come directly from the C bindings in its own module *)

(* TODO: replace with implementation that doesn't copy the string unnecessarily *)
let uuid_of_string string =
  let len = String.length string in
  let zero = Unsigned.UInt8.of_int 0 in
  let array = Ctypes.CArray.make Ctypes.uint8_t ~initial:zero len in
  (for i = 0 to (len - 1) do
    Ctypes.CArray.set array i (string.[i] |> int_of_char |> Unsigned.UInt8.of_int )
  done;
  array)

(* TODO: we don't need to use a string here *)
let is_tdb_err_ok err =
  let err = T.tdb_error_str err in
  if err = "TDB_ERR_OK" then
    `Ok
  else
    `Error;;

(* TODO list or array *)
module Constructor = struct
  type t = {
    cons : unit Ctypes.ptr;
    root : string;
    ofields : string list;
  };;

  (* TODO: memory management of the path C-string? *)
  let create ~root ~ofields () =
    let cons = T.tdb_cons_init () |> Option.value_exn in
    let len_ofields = Unsigned.UInt64.of_int
    (List.length ofields) in
    let c_ofields =
      (let list = Ctypes.CArray.of_list Ctypes.string ofields in
      let c_ofields = Ctypes.CArray.start list in
      c_ofields) in
    let err =
      T.tdb_cons_open cons root c_ofields len_ofields in
    { cons=cons; root=root; ofields=ofields };;

  (* TODO: dictionary interface *)
  (* TODO: better error representation *)
  let add ~cons:cons0 ~uuid:uuid0 ~timestamp:timestamp0 ~values:values0 () =
    match String.length uuid0 with
    | 16 ->
        (
          let value_lengths = List.map values0 ~f:(fun x -> x |> String.length |> Unsigned.UInt64.of_int) in
          let value_lengths = Ctypes.CArray.of_list Ctypes.uint64_t value_lengths in
          let value_lengths = Ctypes.CArray.start value_lengths in
          (
            T.tdb_cons_add 
            cons0.cons
            (uuid_of_string uuid0 |> Ctypes.CArray.start)
            timestamp0
            (values0 |> Ctypes.CArray.of_list Ctypes.string |> Ctypes.CArray.start)
            value_lengths
          )
        )
    | _ -> invalid_arg "uuid must be exactly 16 bytes";;

  let finish ~cons:cons0 () =
    let err = T.tdb_cons_finalize cons0.cons in
    let _ = T.tdb_cons_close cons0.cons in
    err
end;;

module Db = struct
  type t = {
    tdb: unit Ctypes.ptr;
    fields: string list
  }

  let repr db =
    let rec join = function
      | [] -> ""
      | [x] -> x
      | (x::xs) -> x ^ " " ^ join xs in
    "tdb: " ^ join db.fields;;

  (* TODO: do we want to follow symlinks? *)
  (* TODO: report error message *)
  let of_path path = match Core.Core_sys.file_exists path with
  | `No -> failwith "path does not exist"
  | `Unknown -> failwith "path not known to exist"
  | `Yes -> (
    let db = T.tdb_init () |> Option.value_exn in
    let err = T.tdb_open db path in
    match is_tdb_err_ok err with
    | `Error -> failwith "failed to open tdb"
    | `Ok -> (
      let num_fields : Unsigned.uint64 = T.tdb_num_fields db in
      let nth_field (i : int) = T.tdb_get_field_name db (Unsigned.UInt32.of_int i) in
      (* TODO converting a UInt64 to an int can fail potentially!
       * we should probably use a different type here 
       * TODO: Is this how we convert from num_fields to a tdb_field? *)
      let len : int = Unsigned.UInt64.to_int num_fields in
      let fields_opt : string option list = List.init len ~f:nth_field in
      let fields : string list = List.map fields_opt ~f:(fun x -> Option.value_exn x) in
      {
        tdb = db;
        (* TODO: a value_exn does not belong here we 
         * should probable fail in a more informative way *)
        fields = fields;
      }
    )
  )

  (* TODO: better error handling *)
  let get_trail_id db string =
    T.pair_tdb_get_trail_id db.tdb (uuid_of_string string |> Ctypes.CArray.start);;

  (* TODO: get_uuid can also fail *)
  let get_uuid db trail_id = T.tdb_get_uuid db.tdb trail_id;;

  let get_field db field_name =
    T.pair_tdb_get_field db.tdb field_name;;

  let version db =
    T.tdb_version db.tdb;;

  let new_cursor db =
    T.tdb_cursor_new db.tdb;;

end
