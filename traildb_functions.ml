open Foreign;;
open Traildb_types;;

let (@->) = Ctypes.(@->);;
let returning = Ctypes.returning;;
let (%) = Core.Std.Fn.compose;;

(* tdb_cons *tdb_cons_init(void) *)
let tdb_cons_init = 
  foreign "tdb_cons_init" (Ctypes.void @-> returning cons_opt);;

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
  foreign "tdb_init" (Ctypes.void @-> returning tdb_opt);;

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
  foreign "tdb_get_field_name" (tdb @-> tdb_field @-> returning Ctypes.string_opt);;

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
  foreign "tdb_get_item" (tdb @-> tdb_field @-> tdb_val @-> single_value_length @-> returning Ctypes.string_opt);;

(* const char *tdb_get_item_value(const tdb *db,
                                  tdb_item item,
                                  uint64_t *value_length) *)
let tdb_get_item_value =
  foreign "tdb_get_item_value" (tdb @-> tdb_item @-> single_value_length @-> returning Ctypes.string_opt);;

(* const uint8_t *tdb_get_uuid(const tdb *db,
                               uint64_t trail_id) *)
let tdb_get_uuid =
  foreign "tdb_get_uuid" (tdb @-> tdb_item @-> returning uuid_opt);;


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

(* tdb_cursor *tdb_cursor_new(const tdb *db) *)
let tdb_cursor_new =
  foreign "tdb_cursor_new" (tdb @-> returning cursor_opt);;

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
  foreign "tdb_cursor_next" (cursor @-> returning event_opt);;

(* event filter stuff *)

(* struct tdb_event_filter *tdb_event_filter_new(void) *)
let tdb_event_filter_new =
  foreign "tdb_event_filter_new" (Ctypes.void @-> returning event_filter_opt);;


