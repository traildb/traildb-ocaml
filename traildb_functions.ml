let (<<<) = Foreign.foreign;;

open Core.Std;;

open Ctypes;;
open Traildb_opaque_types;;

let (%) = Core.Std.Fn.compose;;

let (@@@) typ0 typ1 = typ0 @-> returning typ1;;

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

let tdb_cons_init_open root ofield_names num_ofields =
  let cons1 = tdb_cons_init () in
  match cons1 with
  | None -> Null "tdb_cons_init_open"
  | Some a -> (
      let err = tdb_cons_open a root ofield_names num_ofields in
      match err with
      | 0 -> Cons a
      | _ -> Err err
    );;

(* void tdb_cons_close(tdb_cons *cons) *)
let tdb_cons_close cs =
  let f = "tdb_cons_close" <<< opaque @@@ void in
  f (get_cons cs)
  ;;


(* tdb_error tdb_cons_add(tdb_cons *cons,
                          const uint8_t uuid[16],
                          const uint64_t timestamp,
                          const char **values,
                          const uint64_t *value_lengths) *)
let tdb_cons_add cs uuid time va le =
  let f = "tdb_cons_add" <<< opaque @-> ptr uint8_t @-> timestamp @-> ptr string @-> ptr uint64_t @@@ tdb_error in
  f (get_cons cs) uuid time va le;;

(* tdb_error tdb_cons_append(tdb_cons *cons, const tdb *db) *)
let tdb_cons_append cs db =
  let f = "tdb_cons_append" <<< opaque @-> opaque @@@ opaque in
  f (get_cons cs) (get_tdb db);;

(* tdb_error tdb_cons_finalize(tdb_cons *cons) *)
let tdb_cons_finalize cs =
  let f = "tdb_cons_finalize" <<< opaque @@@ tdb_error in
  f (get_cons cs);;

(* const char *tdb_error_str(tdb_error errcode) *)
let tdb_error_str =
  "tdb_error_str" <<< tdb_error @@@ string;;

(*  TODO: new
    (* tdb_field tdb_item_field(tdb_item item) *)
    let tdb_item_field =
    "tdb_item_field" <<< uint64_t @@@ uint32_t;;

*)

(* TODO: new

   (* tdb_val tdb_item_val(tdb_item item) *)
   let tdb_item_val =
   "tdb_item_val" <<< uint64_t @@@ uint32_t;;

*)

(*
(* tdb_item tdb_make_item(tdb_field field, tdb_val val) *)
let tdb_make_item =
  "tdb_make_item" <<< uint32_t @@@ uint64_t;;
   *)

(*
(* int tdb_item_is32(tdb_item item) *)
let tdb_item_is32 =
  "tdb_item_is32" <<< uint64_t @@@ int;;
   *)

(* tdb_error tdb_cons_set_opt(tdb_cons *cons,
                              tdb_opt_key key,
                              tdb_opt_value value) *)
(* TODO: wrap this thing *)
let tdb_cons_set_opt =
  "tdb_cons_set_opt" <<< opaque @-> opaque @-> opaque @@@ tdb_error;;

(* tdb_error tdb_cons_get_opt(tdb_cons *cons,
                              tdb_opt_key key,
                              tdb_opt_value *value) *)
(* TODO: wrap this thing *)
let tdb_cons_get_opt =
  "tdb_cons_get_opt" <<< opaque @-> opaque @-> opaque @@@ tdb_error;;


(* tdb reading stuff *)

(* tdb *tdb_init(void) *)
let tdb_init =
  "tdb_init" <<< void @@@ opaque_opt;;

(* tdb_error tdb_open(tdb *db, const char *orig_root) *)
let tdb_open =
  "tdb_open" <<< opaque @-> string @@@ tdb_error;;

(* helper function tdb_init_open *)
(* TODO better error messages *)
let tdb_init_open path =
  let tdb1 = tdb_init () in
  (match tdb1 with
   | None -> Null "tdb_init_open failed!"
   | Some tdb1 ->
     let err = tdb_open tdb1 path in
     (match err with
      | 0 -> (Tdb tdb1)
      | _ -> (Err err)
     )
  );;


(* void tdb_willneed(const tdb *db) *)
let tdb_willneed db =
  let f = "tdb_willneed" <<< opaque @@@ void in
  f (get_tdb db);;

(* void tdb_dontneed(const tdb *db) *)
let tdb_dontneed db =
  let f = "tdb_dontneed" <<< opaque @@@ void in
  f (get_tdb db);;

(* void tdb_close(tdb *db) *)
let tdb_close db =
  let f = "tdb_close" <<< opaque @@@ void in
  f (get_tdb db);;

(* will return >= 1 for every field that exists and zero for fields that
 * do not exist. this is what we want to expose in a slightly higher-level api *)
(* uint64_t tdb_lexicon_size(const tdb *db, tdb_field field) *)
let tdb_lexicon_size db field =
  let f = "tdb_lexicon_size" <<< opaque @-> uint32_t @@@ uint64_t in
  f (get_tdb db) field;;

(* TODO: why does get field take both a string name and an int? 
 * What does this function actually do? *)
(* tdb_error tdb_get_field(const tdb *db,
                           const char *field_name,
                           tdb_field *field *)
let tdb_get_field =
  "tdb_get_field" <<< opaque @-> string @-> ptr uint32_t @@@ tdb_error 
let pair_tdb_get_field tdb str =
  let tdb = get_tdb tdb in
  let buf = allocate_n uint32_t ~count:1 in
  let err = tdb_get_field tdb str buf in
  (* TODO: is there a memory safe way to do this? *)
  let arr = Ctypes.CArray.from_ptr buf 1 in
  let first_item = Ctypes.CArray.get arr 0 in
  (first_item, err);;

(* const char *tdb_get_field_name(const tdb *db,
 *                                tdb_field field) *)
let tdb_get_field_name db field =
  let f = "tdb_get_field_name" <<< opaque @-> tdb_field @@@ string_opt in
  f (get_tdb db) field;;

(* tdb_item tdb_get_item(const tdb *db,
                         tdb_field field,
                         const char *value,
                         uint64_t value_length) *)
let tdb_get_item db field value le =
  let f = "tdb_get_item" <<< opaque @-> opaque @-> string @-> uint64_t @@@ tdb_item in
  f (get_tdb db) field value le;;


(* TODO: okay this is definitely not right *)
(* TODO: NOTE: the interface for this function is confusing
 * value_length is not an array, it's sometimes legitimately NULL
 * and sometimes 0, and those two cases need to be distinguished *)
(* const char *tdb_get_value(const tdb *db,
                             tdb_field field,
                             tdb_val val,
                             uint64_t *value_length) *)
let tdb_get_value db field value le =
  let f = "tdb_get_value" <<< opaque @-> opaque @-> tdb_val @-> ptr uint64_t @@@ string_opt in
  f (get_tdb db) field value le;;

(* const char *tdb_get_item_value(const tdb *db,
                                  tdb_item item,
                                  uint64_t *value_length) *)
let tdb_get_item_value db item le =
  let f = "tdb_get_item_value" <<< opaque @-> tdb_item @-> ptr uint64_t @@@ string_opt in
  f (get_tdb db) item le;;

(* TODO is this a pointer or pointer opt? *)
(* const uint8_t *tdb_get_uuid(const tdb *db,
                               uint64_t trail_id) *)
let tdb_get_uuid db trail_id =
  let f = "tdb_get_uuid" <<< opaque @-> uint64_t @@@ ptr_opt uint8_t in
  f (get_tdb db) trail_id;;


(* tdb_error tdb_get_trail_id(const tdb *db,
                              const uint8_t *uuid,
                              uint64_t *trail_id) *)
let tdb_get_trail_id =
  "tdb_get_trail_id" <<< opaque @-> ptr uint8_t @-> ptr uint64_t @@@ tdb_error
(* TODO: more idiomatic way of representing out parameters *)
(* TODO: deallocate? *)
let pair_tdb_get_trail_id tdb uuid =
  let tdb = get_cons tdb in 
  (* TODO: make sure we only need to allocate an array of 1 thing *)
  let buf = allocate_n uint64_t ~count:1 in
  let err = tdb_get_trail_id tdb uuid buf in
  (* TODO: is there a memory safe way to do this? *)
  let arr = Ctypes.CArray.from_ptr buf 1 in
  let first_item = Ctypes.CArray.get arr 0 in
  (first_item, err);;


(* uint64_t tdb_num_trails(const tdb *db) *)
let tdb_num_trails db =
  let f = "tdb_num_trails" <<< opaque @@@ uint64_t in
  f (get_tdb db);;

(* uint64_t tdb_num_events(const tdb *db) *)
let tdb_num_events db =
  let f = "tdb_num_events" <<< opaque @@@ uint64_t in
  f (get_tdb db);;

(* uint64_t tdb_num_fields(const tdb *db) *)
let tdb_num_fields db =
  let f = "tdb_num_fields" <<< opaque @@@ uint64_t in
  f (get_tdb db);;

(* uint64_t tdb_min_timestamp(const tdb *db) *)
let tdb_min_timestamp db =
  let f = "tdb_min_timestamp" <<< opaque @@@ uint64_t in
  f (get_tdb db);;

(* uint64_t tdb_max_timestamp(const tdb *db) *)
let tdb_max_timestamp db =
  let f = "tdb_max_timestamp" <<< opaque @@@ uint64_t in
  f (get_tdb db);;

(* uint64_t tdb_version(const tdb *db) *)
let tdb_version db =
  let f = "tdb_version" <<< opaque @@@ uint64_t in
  f (get_tdb db);;

(* tdb_cursor *tdb_cursor_new(const tdb *db) *)
let tdb_cursor_new db =
  let f = "tdb_cursor_new" <<< opaque @@@ opaque_opt in
  let out = f (get_tdb db) in
  match out with
  | None -> Null "tdb_cursor_new"
  | Some a -> Cursor a;;

(* void tdb_cursor_free(tdb_cursor *c) *)
let tdb_cursor_free c =
  let f = "tdb_cursor_free" <<< opaque @@@ void in
  f (get_cursor c);;

(* void tdb_cursor_unset_event_filter(tdb_cursor *cursor) *) 
let tdb_cursor_unset_event_filter c =
  let f = "tdb_cursor_unset_event_filter" <<< opaque @@@ void in
  f (get_cursor c);;

(* tdb_error tdb_cursor_set_event_filter(tdb_cursor *cursor,
                                         const struct tdb_event_filter *filter) *)
let tdb_cursor_set_event_filter c filter =
  let f = "tdb_cursor_set_event_filter" <<< opaque @-> opaque @@@ tdb_error in
  f (get_cursor c) (get_filter filter);;

(* tdb_error tdb_get_trail(tdb_cursor *cursor,
                           uint64_t trail_id)  *)
let tdb_get_trail c trail_id =
  let f = "tdb_get_trail" <<< opaque @-> uint64_t @@@ tdb_error in
  f (get_cursor c) trail_id;;

(* uint64_t tdb_get_trail_length(tdb_cursor *cursor) *)
let tdb_get_trail_length c =
  let f = "tdb_get_trail_length" <<< opaque @@@ uint64_t in
  f (get_cursor c)

(* extern const tdb_event *tdb_cursor_next(tdb_cursor *cursor); *)
let tdb_cursor_next c =
  let f = "tdb_cursor_next" <<< opaque @@@ opaque_opt in
  let out = f (get_cursor c) in
  match out with
  | None -> Null "tdb_cursor_next"
  | Some a -> Event a;;

(* event filter stuff *)

(* struct tdb_event_filter *tdb_event_filter_new(void) *)
let tdb_event_filter_new () =
  let f = "tdb_event_filter_new" <<< void @@@ opaque_opt in
  let out = f () in
  match out with
  | None -> Null "tdb_cursor_next"
  | Some a -> Filter a;;

(* void tdb_event_filter_free(struct tdb_event_filter *filter) *)
let tdb_event_filter_free filter =
  let f = "tdb_event_filter_free" <<< opaque @@@ void in
  f (get_filter filter);;

(* tdb_error tdb_event_filter_add_term(struct tdb_event_filter *filter,
                                       tdb_item term,
                                       int is_negative) *)
let tdb_event_filter_add_term filter item is_negative =
  let f = "tdb_event_filter_add_term" <<< opaque @-> tdb_item @-> int @@@ tdb_error in
  f (get_filter filter) item is_negative;;

(* tdb_error tdb_event_filter_new_clause(struct tdb_event_filter *filter) *)
let tdb_event_filter_new_clause filter =
  let f = "tdb_event_filter_new_clause" <<< opaque @@@ tdb_error in
  f (get_filter filter);;

(* these functions are not present in the latest release of tdb *)

(* uint64_t tdb_event_filter_num_clauses(const struct tdb_event_filter *filter); *)
(* let tdb_event_filter_num_clauses =
   "tdb_event_filter_num_clauses" <<< opaque @@@ uint64_t;; *)

(* tdb_error tdb_event_filter_get_item(const struct tdb_event_filter *filter,
                                    uint64_t clause_index,
                                    uint64_t item_index,
                                    tdb_item *item,
                                    int *is_negative) *)
(* let tdb_event_filter_get_item =
   "tdb_event_filter_get_item" <<< opaque @-> uint64_t @-> uint64_t @-> tdb_item @-> int @@@ tdb_error *)
