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

module O = Traildb_opaque_types;;

let tdb_error_str = T.tdb_error_str;;

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
    `Error err;;

(* TODO list or array *)
module Cons = struct
  type t = {
    cons : O.tdb_c_val;
    root : string;
    ofields : string list;
  };;

  (* TODO: memory management of the path C-string? *)
  let create ~root ofields =
    let len_ofields = Unsigned.UInt64.of_int
        (List.length ofields) in
    let c_ofields =
      (let list = Ctypes.CArray.of_list Ctypes.string ofields in
       let c_ofields = Ctypes.CArray.start list in
       c_ofields) in
    let cons =
      T.tdb_cons_init_open root c_ofields len_ofields in
    { cons=cons; root=root; ofields=ofields };;

  (* TODO: dictionary interface *)
  (* TODO: better error representation *)
  let add cons0 ~uuid:uuid0 ~time:time0 values0 =
    match String.length uuid0 with
    | 16 ->
      (
        let value_lengths = List.map values0 ~f:(fun x -> x |> String.length |> Unsigned.UInt64.of_int) in
        let value_lengths = Ctypes.CArray.of_list Ctypes.uint64_t value_lengths in
        let value_lengths = Ctypes.CArray.start value_lengths in
        let error_code = (
          T.tdb_cons_add 
            cons0.cons
            (uuid_of_string uuid0 |> Ctypes.CArray.start)
            time0
            (values0 |> Ctypes.CArray.of_list Ctypes.string |> Ctypes.CArray.start)
            value_lengths
        ) in
        (
          match error_code with
          | 0 -> ()
          | x -> failwith (Printf.sprintf "exit status: %d" x)
        )
      )
    | _ -> invalid_arg "uuid must be exactly 16 bytes"
  ;;

  let finish cons0 =
    let err = T.tdb_cons_finalize cons0.cons in
    let _ = T.tdb_cons_close cons0.cons in
    match err with
    | 0 -> ()
    | x -> failwith (Printf.sprintf "exit status: %d" x)
end;;

module Db = struct
  type t = {
    tdb: O.tdb_c_val;
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
        let db = T.tdb_init_open path in
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
  ;;


  let fields t = t.fields;;

  (* TODO, we're ignore err incorporate into the return type
     somehow *)
  let lexicon_size t field = 
    let (id, err) = T.pair_tdb_get_field t.tdb field in
    match err with
    | 0 -> Some (T.tdb_lexicon_size t.tdb id)
    | _ -> None
  ;;
end;;
