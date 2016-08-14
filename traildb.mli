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

(* initialize a constructor *)
val tdb_cons_init : unit -> tdb;;

(* open a constructor *)
val tdb_cons_open : cons -> string -> string Ctypes_static.ptr -> error;;

(* close a constructor *)
val tdb_cons_close : cons -> unit;;

val tdb_cons_add : cons -> uuid -> timestamp -> values -> error;;

val tdb_cons_append : cons -> tdb -> error

val tdb_cons_finalize : cons -> error
