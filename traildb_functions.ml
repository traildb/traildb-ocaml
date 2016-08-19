let (<<<) = Foreign.foreign;;

open Ctypes;;

let (%) = Core.Std.Fn.compose;;

let (@@@) typ0 typ1 = typ0 @-> returning typ1;;

let opaque = ptr void;;
let opaque_opt = ptr_opt void;;

(* tdb_error is an abstract type *)
let tdb_error = int;;

let tdb_field = uint32_t;;

let tdb_item = uint64_t;;
let timestamp = uint64_t;;
let tdb_val = uint64_t;;

(* tdb_cons *tdb_cons_init(void) *)
let tdb_cons_init = 
  "tdb_cons_init" <<< void @@@ opaque_opt;;

(* tdb_error tdb_cons_open(tdb_cons *cons,
                           const char *root,
                           const char **ofield_names,
                           uint64_t num_ofields) *)
let tdb_cons_open =
  "tdb_cons_open" <<< opaque @-> string @-> ptr string @-> uint64_t @@@ tdb_error;;
  
(* void tdb_cons_close(tdb_cons *cons) *)
let tdb_cons_close =
  "tdb_cons_close" <<< opaque @@@ void;;


(* tdb_error tdb_cons_add(tdb_cons *cons,
                          const uint8_t uuid[16],
                          const uint64_t timestamp,
                          const char **values,
                          const uint64_t *value_lengths) *)
let tdb_cons_add =
  "tdb_cons_add" <<< opaque @-> ptr uint8_t @-> timestamp @-> ptr string @-> ptr uint64_t @@@ tdb_error;;

(* tdb_error tdb_cons_append(tdb_cons *cons, const tdb *db) *)
let tdb_cons_append =
  "tdb_cons_append" <<< opaque @-> opaque @@@ opaque;;

(* tdb_error tdb_cons_finalize(tdb_cons *cons) *)
let tdb_cons_finalize =
  "tdb_cons_finalize" <<< opaque @@@ tdb_error;;

(* const char *tdb_error_str(tdb_error errcode) *)
let tdb_error_str =
  "tdb_error_str" <<< tdb_error @@@ string;; 

(* tdb_error tdb_cons_set_opt(tdb_cons *cons,
                              tdb_opt_key key,
                              tdb_opt_value value) *)
let tdb_cons_set_opt =
  "tdb_cons_set_opt" <<< opaque @-> opaque @-> opaque @@@ tdb_error;;

(* tdb_error tdb_cons_get_opt(tdb_cons *cons,
                              tdb_opt_key key,
                              tdb_opt_value *value) *)
let tdb_cons_get_opt =
  "tdb_cons_get_opt" <<< opaque @-> opaque @-> opaque @@@ tdb_error;;


(* tdb reading stuff *)

(* tdb *tdb_init(void) *)
let tdb_init =
  "tdb_init" <<< void @@@ opaque_opt;;

(* tdb_error tdb_open(tdb *db, const char *orig_root) *)
let tdb_open =
  "tdb_open" <<< opaque @-> string @@@ tdb_error;;

(* void tdb_willneed(const tdb *db) *)
let tdb_willneed =
  "tdb_willneed" <<< opaque @@@ void;;

(* void tdb_dontneed(const tdb *db) *)
let tdb_dontneed =
  "tdb_dontneed" <<< opaque @@@ void;;

(* void tdb_close(tdb *db) *)
let tdb_close =
  "tdb_close" <<< opaque @@@ void

(* will return >= 1 for every field that exists and zero for fields that
 * do not exist. this is what we want to expose in a slightly higher-level api *)
(* uint64_t tdb_lexicon_size(const tdb *db, tdb_field field) *)
let tdb_lexicon_size =
  "tdb_lexicon_size" <<< opaque @-> opaque @@@ uint64_t;;

(* TODO: why does get field take both a string name and an int? 
 * What does this function actually do? *)
(* tdb_error tdb_get_field(const tdb *db,
                           const char *field_name,
                           tdb_field *field *)
let tdb_get_field =
  "tdb_get_field" <<< opaque @-> string @-> ptr uint32_t @@@ opaque
let pair_tdb_get_field tdb str =
  let buf = allocate_n uint32_t ~count:1 in
  let err = tdb_get_field tdb str buf in
  (* TODO: is there a memory safe way to do this? *)
  let arr = Ctypes.CArray.from_ptr buf 1 in
  let first_item = Ctypes.CArray.get arr 0 in
  (first_item, err);;

(* const char *tdb_get_field_name(const tdb *db,
 *                                tdb_field field) *)
let tdb_get_field_name =
  "tdb_get_field_name" <<< opaque @-> tdb_field @@@ string_opt;;

(* tdb_item tdb_get_item(const tdb *db,
                         tdb_field field,
                         const char *value,
                         uint64_t value_length) *)
let tdb_get_item =
  "tdb_get_item" <<< opaque @-> opaque @-> string @-> uint64_t @@@ tdb_item;;


(* TODO: okay this is definitely not right *)
(* TODO: NOTE: the interface for this function is confusing
 * value_length is not an array, it's sometimes legitimately NULL
 * and sometimes 0, and those two cases need to be distinguished *)
(* const char *tdb_get_value(const tdb *db,
                             tdb_field field,
                             tdb_val val,
                             uint64_t *value_length) *)
let tdb_get_value =
  "tdb_get_value" <<< opaque @-> opaque @-> tdb_val @-> ptr uint64_t @@@ string_opt

(* const char *tdb_get_item_value(const tdb *db,
                                  tdb_item item,
                                  uint64_t *value_length) *)
let tdb_get_item_value =
  "tdb_get_item_value" <<< opaque @-> tdb_item @-> ptr uint64_t @@@ string_opt;;

(* TODO is this a pointer or pointer opt? *)
(* const uint8_t *tdb_get_uuid(const tdb *db,
                               uint64_t trail_id) *)
let tdb_get_uuid =
  "tdb_get_uuid" <<< opaque @-> uint64_t @@@ ptr_opt uint8_t;;


(* tdb_error tdb_get_trail_id(const tdb *db,
                              const uint8_t *uuid,
                              uint64_t *trail_id) *)
let tdb_get_trail_id =
  "tdb_get_trail_id" <<< opaque @-> ptr uint8_t @-> ptr uint64_t @@@ tdb_error
(* TODO: more idiomatic way of representing out parameters *)
(* TODO: deallocate? *)
let pair_tdb_get_trail_id tdb uuid =
  (* TODO: make sure we only need to allocate an array of 1 thing *)
  let buf = allocate_n uint64_t ~count:1 in
  let err = tdb_get_trail_id tdb uuid buf in
  (* TODO: is there a memory safe way to do this? *)
  let arr = Ctypes.CArray.from_ptr buf 1 in
  let first_item = Ctypes.CArray.get arr 0 in
  (first_item, err);;


(* uint64_t tdb_num_trails(const tdb *db) *)
let tdb_num_trails =
  "tdb_num_trails" <<< opaque @@@ uint64_t;;

(* uint64_t tdb_num_events(const tdb *db) *)
let tdb_num_events =
  "tdb_num_events" <<< opaque @@@ uint64_t;;

(* uint64_t tdb_num_fields(const tdb *db) *)
let tdb_num_fields =
  "tdb_num_fields" <<< opaque @@@ uint64_t;;

(* uint64_t tdb_min_timestamp(const tdb *db) *)
let tdb_min_timestamp =
  "tdb_min_timestamp" <<< opaque @@@ uint64_t;;

(* uint64_t tdb_max_timestamp(const tdb *db) *)
let tdb_max_timestamp =
  "tdb_max_timestamp" <<< opaque @@@ uint64_t;;

(* uint64_t tdb_version(const tdb *db) *)
let tdb_version =
  "tdb_version" <<< opaque @@@ uint64_t;;

(* tdb_cursor *tdb_cursor_new(const tdb *db) *)
let tdb_cursor_new =
  "tdb_cursor_new" <<< opaque @@@ opaque_opt;;

(* void tdb_cursor_free(tdb_cursor *c) *)
let tdb_cursor_free =
  "tdb_cursor_free" <<< opaque @@@ void;;

(* void tdb_cursor_unset_event_filter(tdb_cursor *cursor) *) 
let tdb_cursor_unset_event_filter =
  "tdb_cursor_unset_event_filter" <<< opaque @@@ void;; 

(* tdb_error tdb_cursor_set_event_filter(tdb_cursor *cursor,
                                         const struct tdb_event_filter *filter) *)
let tdb_cursor_set_event_filter =
  "tdb_cursor_set_event_filter" <<< opaque @-> opaque @@@ tdb_error;;

(* tdb_error tdb_get_trail(tdb_cursor *cursor,
                           uint64_t trail_id)  *)
let tdb_get_trail =
  "tdb_get_trail" <<< opaque @-> uint64_t @@@ tdb_error;;

(* uint64_t tdb_get_trail_length(tdb_cursor *cursor) *)
let tdb_get_trail_length =
  "tdb_get_trail_length" <<< opaque @@@ uint64_t;;

(* extern const tdb_event *tdb_cursor_next(tdb_cursor *cursor); *)
let tdb_cursor_next =
  "tdb_cursor_next" <<< opaque @@@ opaque_opt;;

(* event filter stuff *)

(* struct tdb_event_filter *tdb_event_filter_new(void) *)
let tdb_event_filter_new =
  "tdb_event_filter_new" <<< void @@@ opaque_opt;;


