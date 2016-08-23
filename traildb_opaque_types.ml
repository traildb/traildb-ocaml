open Core.Std;;
open Ctypes;;

let opaque = ptr void;;
let opaque_opt = ptr_opt void;;

type opaque = unit ptr;;

type tdb_c_val =
    Cons of opaque
  | Tdb of opaque
  | Cursor of opaque
  | Filter of opaque
  | Event of opaque
  | Err of int
  | Null of string;;

let get_cons c_val = match c_val with
  | Cons a -> a
  | _ -> failwith "invalid conversion";;

let get_tdb c_val = match c_val with
  | Tdb a -> a
  | _ -> failwith "invalid conversion";;

let get_cursor c_val = match c_val with
  | Cursor a -> a
  | _ -> failwith "invalid conversion";;

let get_event c_val = match c_val with
  | Event a -> a
  | _ -> failwith "invalid conversion";;

let get_filter c_val = match c_val with
  | Filter a -> a
  | _ -> failwith "invalid conversion";;

let c_val_head c_val = match c_val with
  | Cons _ -> "Cons"
  | Tdb _ -> "Tdb"
  | Cursor _ -> "Cursor"
  | Filter _ -> "Filter"
  | Event _ -> "Event"
  | Err _ -> "Err"
  | Null _ -> "Null";;
