`
(*
m4 is already a build-time depdendency of OPAM
so despite its horribleness we are not really adding an
obnoxious dependency here

VOID_PTR is intended for types that the user cannot create
on their own OCaml-side
Generate a ptr and ptr_opt for a given type
*)
'

define(`VOID_PTR',
`(* non_nullable pointer to' $1 `*)'
`type' $1 `= unit Ctypes.ptr;;'
`let' $1 `= Ctypes.ptr Ctypes.void;;'

`(* nullable pointer to' $1 `*)'
`type' $1_opt `= unit Ctypes.ptr;;'
`let' $1_opt `= Ctypes.ptr_opt Ctypes.void;;'
)

define(`UINT32',
`(* uint32_t *)'
`let' $1_of_int `= Unsigned.UInt32.of_int;;'
`type' $1 `= Unsigned.uint32;;'
`let' $1 `= Ctypes.uint32_t;;'
)

define(`UINT64',
`(* uint64_t *)'
`type' $1 `= Unsigned.uint64;;'
`let' $1 `= Ctypes.uint64_t;;'
)

`(* TODO: This is almost certainly wrong,
since tdb_error is an enum, but I do not
know how to get the width of an enum on
an arbitrary platform, using a void*
seems to work. *)'

VOID_PTR(`error')

VOID_PTR(`tdb')
VOID_PTR(`cons')
VOID_PTR(`cursor')
VOID_PTR(`event_filter')
VOID_PTR(`event')
VOID_PTR(`trail')

UINT32(`tdb_field')

UINT64(`tdb_item')
UINT64(`timestamp')
UINT64(`trail_id')
UINT64(`tdb_val')

`(* fixed array of 16 bytes *)
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
'
