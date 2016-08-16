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

(* uint32_t *)
type tdb_field = Unsigned.uint32;;
let tdb_field = Ctypes.uint32_t;;

(* uint64_t *)
type tdb_item = Unsigned.uint64;;
let tdb_item = Ctypes.uint64_t;;

(* TODO: arguments with this type in the C codebase are typically
 * referred to with value_length as far as I can tell.
 * This type is separated from value_lengths because
 * it is not an array. It seems to be used as
 * an optional value, not sure yet exactly how *)
(* uint64_t *value_length *)
type single_value_length = Unsigned.uint64 Ctypes.ptr;;
let single_value_length = Ctypes.ptr Ctypes.uint64_t;;

(* uint64_t *trail_id *)
type trail_id = Unsigned.uint64 Ctypes.ptr;;
let trail_id = Ctypes.ptr Ctypes.uint64_t;;

(* uint64_t *)
type tdb_val = Unsigned.uint64;;
let tdb_val = Ctypes.ptr Ctypes.uint64_t;;

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

let tdb_error_str =
  foreign "tdb_error_str" (error @-> returning Ctypes.string);;

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


(* tdb reading stuff *)

(* tdb *tdb_init(void) *)
let tdb_init =
  foreign "tdb_init" (Ctypes.void @-> returning tdb);;

(* tdb_error tdb_open(tdb *db, const char *orig_root) *)
let tdb_open =
  foreign "tdb_open" (tdb @-> returning Ctypes.string);;

(* void tdb_willneed(const tdb *db) *)
let tdb_willneed =
  foreign "tdb_willneed" (tdb @-> returning Ctypes.void);;

(* void tdb_dontneed(const tdb *db) *)
let tdb_dontneed =
  foreign "tdb_dontneed" (tdb @-> returning Ctypes.void);;

(* void tdb_close(tdb *db) *)
let tdb_close =
  foreign "tdb_close" (tdb @-> returning Ctypes.void);;

(* will return >= 1 for every field that exists and zero for fields that
 * do not exist. this is what we want to expose in a slightly higher-level api *)
(* uint64_t tdb_lexicon_size(const tdb *db, tdb_field field) *)
let tdb_lexicon_size =
  foreign "tdb_lexicon_size" (tdb @-> tdb_field @-> returning Ctypes.uint64_t);;

(* TODO: why does get field take both a string name and an int? 
 * What does this function actually do? *)
(* tdb_error tdb_get_field(const tdb *db,
                           const char *field_name,
                           tdb_field *field *)
let tdb_get_field =
  foreign "tdb_get_field" (tdb @-> Ctypes.string @-> tdb_field @-> returning error);;

(* const char *tdb_get_field_name(const tdb *db,
 *                                tdb_field field) *)
let tdb_get_field_name =
  foreign "tdb_get_field_name" (tdb @-> tdb_field @-> returning Ctypes.string);;

(* tdb_item tdb_get_item(const tdb *db,
                         tdb_field field,
                         const char *value,
                         uint64_t value_length) *)
let tdb_get_item =
  foreign "tdb_get_item" (tdb @-> tdb_field @-> Ctypes.string @-> Ctypes.uint64_t @-> returning tdb_item);;


(* TODO: NOTE: the interface for this function is confusing
 * value_length is not an array, it's sometimes legitimately NULL
 * and sometimes 0, and those two cases need to be distinguished *)
(* const char *tdb_get_value(const tdb *db,
                             tdb_field field,
                             tdb_val val,
                             uint64_t *value_length) *)
let tdb_get_value =
  foreign "tdb_get_item" (tdb @-> tdb_field @-> tdb_val @-> returning single_value_length);;

(* const char *tdb_get_item_value(const tdb *db,
                                  tdb_item item,
                                  uint64_t *value_length) *)
let tdb_get_item_value =
  foreign "tdb_get_item_value" (tdb @-> tdb_item @-> single_value_length @-> returning Ctypes.string);;

(* const uint8_t *tdb_get_uuid(const tdb *db,
                               uint64_t trail_id) *)
let tdb_get_uuid =
  foreign "tdb_get_uuid" (tdb @-> tdb_item @-> returning uuid);;


(* tdb_error tdb_get_trail_id(const tdb *db,
                              const uint8_t *uuid,
                              uint64_t *trail_id) *)
let tdb_get_trail_id =
  foreign "tdb_get_trail_id" (tdb @-> uuid @-> trail_id @-> returning error)

(* TODO: stopped at
 *
 * TDB_EXPORT uint64_t tdb_num_trails(const tdb *db)
 * {
   * * return db->num_trails;
   *)




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
    cons : cons;
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
  let add ~cons:cons0 ~uuid:uuid0 ~timestamp:timestamp0 ~values:values0 () =
    match String.length uuid0 with
    | 16 ->
        (
          let value_lengths = List.map (Unsigned.UInt64.of_int % String.length) values0 in
          let value_lengths = Ctypes.CArray.of_list Ctypes.uint64_t value_lengths in
          let value_lengths = Ctypes.CArray.start value_lengths in
          (
            tdb_cons_add 
            cons0.cons
            (uuid_of_string uuid0 |> Ctypes.CArray.start)
            timestamp0
            (values0 |> Ctypes.CArray.of_list Ctypes.string |> Ctypes.CArray.start)
            value_lengths
          )
        )
    | _ -> invalid_arg "uuid must be exactly 16 bytes";;

  let finish ~cons:cons0 () =
    let err = tdb_cons_finalize cons0.cons in
    let _ = tdb_cons_close cons0.cons in
    err
end;;

module TrailDB = struct
  type t = {
    tdb: tdb
  }

  let of_path path = failwith "not yet implemented";;
end
