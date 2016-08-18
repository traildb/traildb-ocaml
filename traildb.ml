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

let (@->) = Ctypes.(@->);;
let returning = Ctypes.returning;;
let (%) = Core.Std.Fn.compose;;

open Foreign;;
(* types and associated conversion functions *)
include Traildb_types;;

(*

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
let tdb_field_of_int = Unsigned.UInt32.of_int;;

(* uint64_t *)
type tdb_item = Unsigned.uint64;;
let tdb_item = Ctypes.uint64_t;;

type cursor = unit Ctypes.ptr;;
let cursor = Ctypes.ptr Ctypes.void;;

type event_filter = unit Ctypes.ptr;;
let event_filter = Ctypes.ptr Ctypes.void;;

type event = unit Ctypes.ptr;;
let event = Ctypes.ptr Ctypes.void;;

type trail = unit Ctypes.ptr;;
let trail = Ctypes.ptr Ctypes.void;;

(* TODO: arguments with this type in the C codebase are typically
 * referred to with value_length as far as I can tell.
 * This type is separated from value_lengths because
 * it is not an array. It seems to be used as
 * an optional value, not sure yet exactly how *)
(* uint64_t *value_length *)
type single_value_length = Unsigned.uint64 Ctypes.ptr;;
let single_value_length = Ctypes.ptr Ctypes.uint64_t;;

(* TODO: better handling of out parameters *)
(* uint64_t trail_id *)
type trail_id = Unsigned.uint64;;
let trail_id = Ctypes.uint64_t;;

(* uint64_t *)
type tdb_val = Unsigned.uint64;;
let tdb_val = Ctypes.uint64_t;;

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
  foreign "tdb_open" (tdb @-> Ctypes.string @-> returning error);;

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
  foreign "tdb_get_field" (tdb @-> Ctypes.string @-> Ctypes.ptr tdb_field @-> returning error);;
let pair_tdb_get_field tdb str =
  let buf = Ctypes.allocate_n Ctypes.uint32_t ~count:1 in
  let err = tdb_get_field tdb str buf in
  (* TODO: is there a memory safe way to do this? *)
  let arr = Ctypes.CArray.from_ptr buf 1 in
  let first_item = Ctypes.CArray.get arr 0 in
  (first_item, err);;

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
  foreign "tdb_get_trail_id" (tdb @-> uuid @-> Ctypes.ptr trail_id @-> returning error)
(* TODO: more idiomatic way of representing out parameters *)
(* TODO: deallocate? *)
let pair_tdb_get_trail_id tdb uuid =
  (* TODO: make sure we only need to allocate an array of 1 thing *)
  let buf = Ctypes.allocate_n Ctypes.uint64_t ~count:1 in
  let err = tdb_get_trail_id tdb uuid buf in
  (* TODO: is there a memory safe way to do this? *)
  let arr = Ctypes.CArray.from_ptr buf 1 in
  let first_item = Ctypes.CArray.get arr 0 in
  (first_item, err);;


(* uint64_t tdb_num_trails(const tdb *db) *)
let tdb_num_trails =
  foreign "tdb_num_trails" (tdb @-> returning Ctypes.uint64_t);;

(* uint64_t tdb_num_events(const tdb *db) *)
let tdb_num_events =
  foreign "tdb_num_events" (tdb @-> returning Ctypes.uint64_t);;

(* uint64_t tdb_num_fields(const tdb *db) *)
let tdb_num_fields =
  foreign "tdb_num_fields" (tdb @-> returning Ctypes.uint64_t);;

(* uint64_t tdb_min_timestamp(const tdb *db) *)
let tdb_min_timestamp =
  foreign "tdb_min_timestamp" (tdb @-> returning Ctypes.uint64_t);;

(* uint64_t tdb_max_timestamp(const tdb *db) *)
let tdb_max_timestamp =
  foreign "tdb_max_timestamp" (tdb @-> returning Ctypes.uint64_t);;

(* uint64_t tdb_version(const tdb *db) *)
let tdb_version =
  foreign "tdb_version" (tdb @-> returning Ctypes.uint64_t);;

(* TDB_EXPORT tdb_cursor *tdb_cursor_new(const tdb *db) *)
let tdb_cursor_new =
  foreign "tdb_cursor_new" (tdb @-> returning cursor);;

(* void tdb_cursor_free(tdb_cursor *c) *)
let tdb_cursor_free =
  foreign "tdb_cursor_free" (cursor @-> returning Ctypes.void);;

(* void tdb_cursor_unset_event_filter(tdb_cursor *cursor) *) 
let tdb_cursor_unset_event_filter =
  foreign "tdb_cursor_unset_event_filter" (cursor @-> returning Ctypes.void);;

(* tdb_error tdb_cursor_set_event_filter(tdb_cursor *cursor,
                                         const struct tdb_event_filter *filter) *)
let tdb_cursor_set_event_filter =
  foreign "tdb_cursor_set_event_filter" (cursor @-> event_filter @-> returning error);;

(* tdb_error tdb_get_trail(tdb_cursor *cursor,
                           uint64_t trail_id)  *)
let tdb_get_trail =
  foreign "tdb_get_trail" (cursor @-> trail_id @-> returning error);;

(* uint64_t tdb_get_trail_length(tdb_cursor *cursor) *)
let tdb_get_trail_length =
  foreign "tdb_get_trail_length" (cursor @-> returning Ctypes.uint64_t);;

(* extern const tdb_event *tdb_cursor_next(tdb_cursor *cursor); *)
let tdb_cursor_next =
  foreign "tdb_cursor_next" (cursor @-> returning event)

(* event filer stuff *)


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
  let err = tdb_error_str err in
  if err = "TDB_ERR_OK" then
    `Ok
  else
    `Error;;

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
          let value_lengths = List.map values0 ~f:(Unsigned.UInt64.of_int % String.length) in
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

module Db = struct
  type t = {
    tdb: tdb;
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
    let db = tdb_init () in
    let err = tdb_open db path in
    match is_tdb_err_ok err with
    | `Error -> failwith "failed to open tdb"
    | `Ok -> (
      let num_fields = tdb_num_fields db in
      let nth_field i = tdb_get_field_name db (tdb_field_of_int i) in
      (* TODO converting a UInt64 to an int can fail potentially!
       * we should probably use a different type here 
       * TODO: Is this how we convert from num_fields to a tdb_field? *)
      let fields = List.init (Unsigned.UInt64.to_int num_fields) ~f:nth_field in
      {
        tdb = db;
        fields = fields;
      }
    )
  )

  (* TODO: better error handling *)
  let get_trail_id db string =
    pair_tdb_get_trail_id db.tdb (uuid_of_string string |> Ctypes.CArray.start);;

  (* TODO: get_uuid can also fail *)
  let get_uuid db trail_id = tdb_get_uuid db.tdb trail_id;;

  let get_field db field_name =
    pair_tdb_get_field db.tdb field_name;;

  let version db =
    tdb_version db.tdb;;

  let new_cursor db =
    tdb_cursor_new db.tdb;;

end
