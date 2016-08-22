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
  | Err of opaque
  | ErrOpt of opaque_opt
  | ErrNotReady of opaque_opt;;

let get_cons c_val = match c_val with
  | Cons a -> Cons a
  | ConsOpt (Some a) -> Cons a
  | _ -> failwith "invalid conversion";;

let get_cons1 c_val = match c_val with
  | Cons a -> Cons a
  | ConsOpt (Some a) -> Cons a
  | ConsNotReady (some a) -> Cons a
  | _ -> failwith "invalid conversion";;

let get_tdb c_val = match c_val with
  | Tdb a -> Tdb a
  | TdbOpt (Some a) -> Tdb a
  | _ -> failwith "invalid conversion";;

let get_tdb c_val = match c_val with
  | Err a -> Err a
  | ErrOpt (Some a) -> Err a
  | _ -> failwith "invalid conversion";;
