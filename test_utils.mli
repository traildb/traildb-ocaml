open Core.Std;;

val plan : int -> unit;;

val file_exists : ?follow_symlinks:(bool) -> string -> [ `No | `Unknown | `Yes ];;

(* TODO: val uuid_of_string *)
val uint64 : int -> Unsigned.uint64;;

val string_of_uint64 : Unsigned.uint64 -> string;;

val backtick : string -> string;;

val backtick_lines : string -> string list;;

val backtick_assoc : string -> (string * string) list;;
