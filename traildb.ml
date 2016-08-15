let (@->) = Ctypes.(@->);;
let returning = Ctypes.returning;;
let (%) = Core.Std.Fn.compose;;

open Foreign;;

type tdb = unit Ctypes.ptr;;
let tdb = Ctypes.ptr Ctypes.void;;

type cons = unit Ctypes.ptr;;
let cons = Ctypes.ptr Ctypes.void;;

type error = unit Ctypes.ptr;;
let error = Ctypes.ptr Ctypes.void;;

(* fixed array of 16 bytes *)
type uuid = Unsigned.uint8 Ctypes.ptr;;
let uuid = Ctypes.ptr Ctypes.uint8_t;;

(* uint64 *)
type timestamp = Unsigned.uint64;;
let timestamp = Ctypes.uint64_t;;

(* const char **values *)
type values = string Ctypes.ptr;;
let values = Ctypes.ptr Ctypes.string;;

(* const uint64_t *value_lengths *)
type value_lengths = Unsigned.uint64 Ctypes.ptr;;
let value_lengths = Ctypes.ptr Ctypes.uint64_t;;

(*
 * tdb_opt_key is an enum
 * tdb_opt_value is a union of a (void * )
 * and a uint64_t.
 * 
 * I don't know the exact semantics of this type.
 *
type opt_key = unit Ctypes.ptr;;
let opt_key = Ctypes.ptr Ctypes.void;;

type opt_value = unit Ctypes.ptr;;
let opt_value = Ctypes.ptr Ctypes.void;;
*)

(* tdb_cons *tdb_cons_init(void) *)
let tdb_cons_init = 
  foreign "tdb_cons_init" (Ctypes.void @-> returning cons);;

(* tdb_error tdb_cons_open(tdb_cons *cons,
                                   const char *root,
                                   const char **ofield_names,
                                   uint64_t num_ofields) *)
let tdb_cons_open =
  foreign "tdb_cons_open" (cons @-> Ctypes.string @-> Ctypes.ptr Ctypes.string @-> Ctypes.uint64_t  @-> returning error);;

(* void tdb_cons_close(tdb_cons *cons) *)
let tdb_cons_close =
  foreign "tdb_cons_close" (cons @-> returning Ctypes.void);;


(* tdb_error tdb_cons_add(tdb_cons *cons,
                                  const uint8_t uuid[16],
                                  const uint64_t timestamp,
                                  const char **values,
                                  const uint64_t *value_lengths) *)
let tdb_cons_add =
  foreign "tdb_cons_add" (cons @-> uuid @-> timestamp @-> values @-> value_lengths @-> returning error);;

(* tdb_error tdb_cons_append(tdb_cons *cons, const tdb *db) *)
let tdb_cons_append =
  foreign "tdb_cons_append" (cons @-> tdb @-> returning error);;

(* tdb_error tdb_cons_finalize(tdb_cons *cons) *)
let tdb_cons_finalize =
  foreign "tdb_cons_finalize" (cons @-> returning error);;

(* tdb_error tdb_cons_set_opt(tdb_cons *cons,
                                      tdb_opt_key key,
                                      tdb_opt_value value) *)
(* let tdb_cons_set_opt =
  foreign "tdb_cons_set_opt" (cons @-> opt_key @-> opt_value @-> returning error);; *)

(* tdb_error tdb_cons_get_opt(tdb_cons *cons,
                                      tdb_opt_key key,
                                      tdb_opt_value *value) *)
(* let tdb_cons_get_opt =
  foreign "tdb_cons_get_opt" (cons @-> opt_key @-> opt_value @-> returning tdb_error) *)

(* higher-level stuff *)

(* TODO: replace with implementation that doesn't copy the string unnecessarily *)
let uuid_of_string string =
  let len = String.length string in
  let zero = Unsigned.UInt8.of_int 0 in
  let array = Ctypes.CArray.make Ctypes.uint8_t ~initial:zero len in
  (for i = 0 to (len - 1) do
    Ctypes.CArray.set array i (string.[i] |> int_of_char |> Unsigned.UInt8.of_int )
  done;
  array)


(* TODO list or array *)
module Constructor = struct
  type t = {
    cons : tdb;
    root : string;
    ofields : string list;
  };;

  (* TODO: handle error from tdb_cons_open *)
  (* TODO: memory management of the path C-string? *)
  let create ~root ~ofields () =
    let cons = tdb_cons_init () in
    let len_ofields = Unsigned.UInt64.of_int
    (List.length ofields) in
    let c_ofields =
      (let list = Ctypes.CArray.of_list Ctypes.string ofields in
      let c_ofields = Ctypes.CArray.start list in
      c_ofields) in
    let err =
      tdb_cons_open cons root c_ofields len_ofields in
    { cons=cons; root=root; ofields=ofields };;

  (* TODO: dictionary interface *)
  (* TODO: better error representation *)
  let add ~cons:cons0 ~cookie:cookie0 ~timestamp:timestamp0 ~values:values0 () =
    match String.length cookie0 with
    | 32 ->
        (
          let value_lengths = List.map (Unsigned.UInt64.of_int % String.length) values0 in
          let value_lengths = Ctypes.CArray.of_list Ctypes.uint64_t value_lengths in
          let value_lengths = Ctypes.CArray.start value_lengths in
          Some (
            tdb_cons_add 
            cons0.cons
            (uuid_of_string cookie0 |> Ctypes.CArray.start)
            timestamp0
            (values0 |> Ctypes.CArray.of_list Ctypes.string |> Ctypes.CArray.start)
            value_lengths
          ) : error option
        )
    | _ -> None;;



end;;


