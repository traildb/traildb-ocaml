
(*
m4 is already a build-time depdendency of OPAM
so despite its horribleness we are not really adding an
obnoxious dependency here

VOID_PTR is intended for types that the user cannot create
on their own OCaml-side
Generate a ptr and ptr_opt for a given type
*)








(* TODO: This is almost certainly wrong,
since tdb_error is an enum, but I do not
know how to get the width of an enum on
an arbitrary platform, using a void*
seems to work. *)

(* non_nullable pointer to error *)
type error = unit Ctypes.ptr;;
let error = Ctypes.ptr Ctypes.void;;

(* nullable pointer to error *)
type error_opt = unit Ctypes.ptr;;
let error_opt = Ctypes.ptr_opt Ctypes.void;;


(* non_nullable pointer to tdb *)
type tdb = unit Ctypes.ptr;;
let tdb = Ctypes.ptr Ctypes.void;;

(* nullable pointer to tdb *)
type tdb_opt = unit Ctypes.ptr;;
let tdb_opt = Ctypes.ptr_opt Ctypes.void;;

(* non_nullable pointer to cons *)
type cons = unit Ctypes.ptr;;
let cons = Ctypes.ptr Ctypes.void;;

(* nullable pointer to cons *)
type cons_opt = unit Ctypes.ptr;;
let cons_opt = Ctypes.ptr_opt Ctypes.void;;

(* non_nullable pointer to cursor *)
type cursor = unit Ctypes.ptr;;
let cursor = Ctypes.ptr Ctypes.void;;

(* nullable pointer to cursor *)
type cursor_opt = unit Ctypes.ptr;;
let cursor_opt = Ctypes.ptr_opt Ctypes.void;;

(* non_nullable pointer to event_filter *)
type event_filter = unit Ctypes.ptr;;
let event_filter = Ctypes.ptr Ctypes.void;;

(* nullable pointer to event_filter *)
type event_filter_opt = unit Ctypes.ptr;;
let event_filter_opt = Ctypes.ptr_opt Ctypes.void;;

(* non_nullable pointer to event *)
type event = unit Ctypes.ptr;;
let event = Ctypes.ptr Ctypes.void;;

(* nullable pointer to event *)
type event_opt = unit Ctypes.ptr;;
let event_opt = Ctypes.ptr_opt Ctypes.void;;

(* non_nullable pointer to trail *)
type trail = unit Ctypes.ptr;;
let trail = Ctypes.ptr Ctypes.void;;

(* nullable pointer to trail *)
type trail_opt = unit Ctypes.ptr;;
let trail_opt = Ctypes.ptr_opt Ctypes.void;;


(* uint32_t *)
let tdb_field_of_int = Unsigned.UInt32.of_int;;
type tdb_field = Unsigned.uint32;;
let tdb_field = Ctypes.uint32_t;;


(* uint64_t *)
type tdb_item = Unsigned.uint64;;
let tdb_item = Ctypes.uint64_t;;

(* uint64_t *)
type timestamp = Unsigned.uint64;;
let timestamp = Ctypes.uint64_t;;

(* uint64_t *)
type trail_id = Unsigned.uint64;;
let trail_id = Ctypes.uint64_t;;

(* uint64_t *)
type tdb_val = Unsigned.uint64;;
let tdb_val = Ctypes.uint64_t;;


(* fixed array of 16 bytes *)
type uuid = Unsigned.uint8 Ctypes.ptr;;
let uuid = Ctypes.ptr Ctypes.uint8_t;;

type uuid_opt = Unsigned.uint8 Ctypes.ptr;;
let uuid_opt = Ctypes.ptr Ctypes.uint8_t;;

(* const char **values *)
type values = string Ctypes.ptr;;
let values = Ctypes.ptr Ctypes.string;;

(* const uint64_t *value_lengths *)
type value_lengths = Unsigned.uint64 Ctypes.ptr;;
let value_lengths = Ctypes.ptr Ctypes.uint64_t;;

(* TODO: arguments with this type in the C codebase are typically
 * referred to with value_length as far as I can tell.
 * This type is separated from value_lengths because
 * it is not an array. It seems to be used as
 * an optional value, not sure yet exactly how *)
(* uint64_t *value_length *)
type single_value_length = Unsigned.uint64 Ctypes.ptr;;
let single_value_length = Ctypes.ptr Ctypes.uint64_t;;

(*
 * tdb_opt_key is an enum
 * tdb_opt_value is a union of a (void * )
 * and a uint64_t.
 * 
 * I do not know the exact semantics of this type.
 *
type opt_key = unit Ctypes.ptr;;
let opt_key = Ctypes.ptr Ctypes.void;;

type opt_value = unit Ctypes.ptr;;
let opt_value = Ctypes.ptr Ctypes.void;;
*)

