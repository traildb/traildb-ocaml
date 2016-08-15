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

type value_lengths;;
val value_lengths : value_lengths Ctypes_static.typ;;


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

module Constructor : sig
  type t;;
  val create : root:string -> ofields:string list -> unit -> t;;
  val add : cons:t -> cookie:string -> timestamp:Unsigned.uint64 -> values:string list -> unit -> error;;
  val finish : cons:t -> unit -> error;;
end;;


