(* open Ctypes;; *)
let (@->) = Ctypes.(@->);;
let returning = Ctypes.returning;;

open Foreign;;

type tdb = unit Ctypes.ptr;;
let tdb = Ctypes.ptr Ctypes.void;;

type cons = unit Ctypes.ptr;;
let cons = Ctypes.ptr Ctypes.void;;

type error = unit Ctypes.ptr;;
let error = Ctypes.ptr Ctypes.void;;

(* fixed array of 16 bytes *)
type uuid = unit Ctypes.ptr;;
let uuid = Ctypes.ptr Ctypes.void;;

(* uint64 *)
type timestamp = Unsigned.uint64;;
let timestamp = Ctypes.uint64_t;;

(* const char **values *)
type values = unit Ctypes.ptr;;
let values = Ctypes.ptr Ctypes.void;;

let tdb_cons_init = 
  foreign "tdb_cons_init" (Ctypes.void @-> returning cons);;

let tdb_cons_open =
  foreign "tdb_cons_open" (cons @-> Ctypes.string @-> Ctypes.ptr Ctypes.string @-> returning error);;

let tdb_cons_close =
  foreign "tdb_cons_close" (cons @-> returning Ctypes.void);;

let tdb_cons_add =
  foreign "tdb_cons_add" (cons @-> uuid @-> timestamp @-> values @-> returning error);;

let tdb_cons_append =
  foreign "tdb_cons_append" (cons @-> tdb @-> returning error);;

let tdb_cons_finalize =
  foreign "tdb_cons_finalize" (cons @-> returning error);;


