(* all of these types are completely abstract *)

type tdb;;
val tdb : tdb Ctypes_static.typ;;

type cons;;
val cons : cons Ctypes_static.typ;;

type error;;
val error : error Ctypes_static.typ;;

type uuid;;
val uuid : uuid Ctypes_static.typ;;

type values;;
val values : values Ctypes_static.typ;;

type timestamp = Unsigned.uint64;;
val timestamp : timestamp Ctypes_static.typ;;

type value_lengths;;
val value_lengths : value_lengths Ctypes_static.typ;;

type tdb_field;;
val tdb_field : tdb_field Ctypes_static.typ;;

type single_value_length;;
val single_value_length : single_value_length Ctypes_static.typ;;

type tdb_item;;
val tdb_item : tdb_item Ctypes_static.typ;;

type tdb_val;;
val tdb_val : tdb_val Ctypes_static.typ;;

type trail_id;;
val trail_id : trail_id Ctypes_static.typ;;

(* initialize a constructor *)
val tdb_cons_init : unit -> tdb;;

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

val tdb_get_field : tdb -> string -> tdb_field -> error;;

val tdb_get_field_name : tdb -> tdb_field -> string;;

val tdb_get_item : tdb -> tdb_field -> string -> Unsigned.uint64 -> tdb_item;;

val tdb_get_value : tdb -> tdb_field -> tdb_val -> single_value_length;;

val tdb_get_item_value : tdb -> tdb_item -> single_value_length -> string;;

val tdb_get_uuid : tdb -> tdb_item -> uuid;;

val tdb_get_trail_id : tdb -> uuid -> trail_id -> error;;

val tdb_num_trails : tdb -> Unsigned.uint64;;

val tdb_num_events : tdb -> Unsigned.uint64;;

val tdb_num_fields : tdb -> Unsigned.uint64;;

val tdb_min_timestamp : tdb -> Unsigned.uint64;;

val tdb_max_timestamp : tdb -> Unsigned.uint64;;

val tdb_version : tdb -> Unsigned.uint64;;

(* uuid_of_string *)
(* is_tdb_err_ok *)

module Constructor : sig
  type t;;
  val create : root:string -> ofields:string list -> unit -> t;;
  val add : cons:t -> uuid:string -> timestamp:Unsigned.uint64 -> values:string list -> unit -> error;;
  val finish : cons:t -> unit -> error;;
end;;

module TrailDB : sig
  type t;;
  val of_path : string -> t;;
end;;


