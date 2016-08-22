open Core.Std;;
open Ctypes;;

let opaque = ptr void;;
let opaque = ptr_opt void;;

type tdb_c_val =
    Cons of opaque
  | ConsOpt of opaque_opt
  | ConsNotReady of opaque_opt
  | Tdb of opaque
  | TdbOpt of opaque_opt
  | TdbNotReady of opaque_opt
  | Err of opaque;;

let get_cons c_val = match c_val with
  | Cons a -> Cons a
  | ConsOpt (Some a) -> Cons a
  | ConsNotReady _ -> failwith "not ready"
  | _ -> failwith "invalid conversion";;

let populate_cons c_val = match c_val with
  | ConsNotReady a -> a
  | _ -> failwith "invalid conversion";;

let get_tdb c_val = match c_val with
  | Tdb a -> Tdb a
  | TdbOpt (Some a) -> Tdb a
  | _ -> failwith "invalid conversion";;

let populate_tdb c_val = match c_val with
  | TdbNotReady a -> a
  | _ -> failwith "invalid conversion";;
