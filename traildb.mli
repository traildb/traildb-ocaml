val tdb_error_str : int -> string

module Cons : sig
  type t;;
  val create : root:string -> string list -> t;;
  val add : t -> uuid:string -> time:Unsigned.uint64 -> string list -> unit;;
  val finish : t -> unit;;
end;;

module Db : sig
  type t;;
  val of_path : string -> t;;
  val repr : t -> string;;
  val fields : t -> string list;;
  val lexicon_size : t -> string -> Unsigned.uint64 option;;
end;;

