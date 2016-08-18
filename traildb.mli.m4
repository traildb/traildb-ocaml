(* all of these types are completely abstract *)

define(`CTYP',
`type' $1;;
`val' $1 : $1 `Ctypes_static.typ;;'

`type' $1_opt;;
`val' $1_opt : $1_opt `Ctypes_static.typ;;'


)

CTYP(`tdb')
CTYP(`cons')
CTYP(`error')
CTYP(`uuid')
CTYP(`values')
CTYP(`value_lengths')
CTYP(`tdb_field')
CTYP(`cursor')
CTYP(`event_filer')
CTYP(`event')
CTYP(`tdb_item')
CTYP(`tdb_val')
CTYP(`trail_id')

`
(* timestamp is actually a synonym for unsigned 64 int *)
'

`
type timestamp = Unsigned.uint64;;
val timestamp : timestamp Ctypes_static.typ;;
'

changequote([[[[,]]]])

[[[[
(* C functions *)


(* initialize a constructor *)
val tdb_cons_init : unit -> cons;;

(* open a constructor *)
val tdb_cons_open : cons -> string -> string Ctypes_static.ptr -> Unsigned.uint64 -> error;;

(* close a constructor *)
val tdb_cons_close : cons -> unit;;

val tdb_cons_add : cons -> uuid -> timestamp -> values -> value_lengths -> error;;

val tdb_cons_append : cons -> tdb -> error;;

val tdb_cons_finalize : cons -> error;;

val tdb_error_str : error -> string;;

val tdb_init : unit -> tdb;;

val tdb_open : tdb -> string -> error;;

val tdb_willneed : tdb -> unit;;

val tdb_dontneed : tdb -> unit;;

val tdb_close : tdb -> unit;;

val tdb_lexicon_size : tdb -> tdb_field -> Unsigned.uint64;;

val tdb_get_field : tdb -> string -> tdb_field Ctypes.ptr -> error;;
val pair_tdb_get_field : tdb -> string -> (tdb_field * error);;

val tdb_get_field_name : tdb -> tdb_field -> string;;

val tdb_get_item : tdb -> tdb_field -> string -> Unsigned.uint64 -> tdb_item;;

val tdb_get_value : tdb -> tdb_field -> tdb_val -> single_value_length;;

val tdb_get_item_value : tdb -> tdb_item -> single_value_length -> string;;

val tdb_get_uuid : tdb -> tdb_item -> uuid;;

val tdb_get_trail_id : tdb -> uuid -> trail_id Ctypes.ptr -> error;;
val pair_tdb_get_trail_id : tdb -> uuid -> (trail_id * error);;

val tdb_num_trails : tdb -> Unsigned.uint64;;

val tdb_num_events : tdb -> Unsigned.uint64;;

val tdb_num_fields : tdb -> Unsigned.uint64;;

val tdb_min_timestamp : tdb -> Unsigned.uint64;;

val tdb_max_timestamp : tdb -> Unsigned.uint64;;

val tdb_version : tdb -> Unsigned.uint64;;

val tdb_cursor_new : tdb -> cursor;;

val tdb_cursor_free : cursor -> unit;;

val tdb_cursor_unset_event_filter : cursor -> unit;;

val tdb_cursor_set_event_filter : cursor -> event_filter -> error;;

val tdb_get_trail : cursor -> trail_id -> error;;

val tdb_get_trail_length : cursor -> Unsigned.uint64;; 

val tdb_cursor_next : cursor -> event;;

(* uuid_of_string *)
(* is_tdb_err_ok *)

module Constructor : sig
  type t;;
  val create : root:string -> ofields:string list -> unit -> t;;
  val add : cons:t -> uuid:string -> timestamp:Unsigned.uint64 -> values:string list -> unit -> error;;
  val finish : cons:t -> unit -> error;;
end;;

module Db : sig
  type t;;
  val of_path : string -> t;;
  val repr : t -> string;;
  (* TODO: yes we do, need to make this change,
   * but only after we can cheaply compare errors *)
  (* TODO: do we want this to be a
   * covariant polymorphic variant? *)
  (* val get_trail_id : t -> string -> [> `Error | `Ok of trail_id];; *)
  val get_trail_id : t -> string -> (trail_id * error);;
  val get_uuid : t -> trail_id -> uuid;;
  val get_field : t -> string -> (tdb_field * error);;
  val version : t -> Unsigned.uint64;;
  (* our pointer can be null here *)
  val new_cursor : t -> (cursor);;
end;;
]]]]
