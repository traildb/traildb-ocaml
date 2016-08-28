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

let c_val_head c_val = match c_val with
  | Cons _ -> "Cons"
  | Tdb _ -> "Tdb"
  | Cursor _ -> "Cursor"
  | Filter _ -> "Filter"
  | Event _ -> "Event"
  | Err err -> "Err " ^ string_of_int err
  | Null str -> "Null " ^ str;;

let get_cons c_val = match c_val with
  | Cons a -> a
  | _ -> failwith ("invalid conversion to cons from " ^ c_val_head c_val);;

let get_tdb c_val = match c_val with
  | Tdb a -> a
  | _ -> failwith ("invalid conversion to cons from " ^ c_val_head c_val);;

let get_cursor c_val = match c_val with
  | Cursor a -> a
  | _ -> failwith ("invalid conversion to cons from " ^ c_val_head c_val);;

let get_event c_val = match c_val with
  | Event a -> a
  | _ -> failwith ("invalid conversion to cons from " ^ c_val_head c_val);;

let get_filter c_val = match c_val with
  | Filter a -> a
  | _ -> failwith ("invalid conversion to cons from " ^ c_val_head c_val);;
