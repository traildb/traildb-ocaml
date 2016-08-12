open Ctypes;;
open Foreign;;

type tdb = unit ptr;;
let tdb = ptr void;;

let tdb_cons_init = 
  foreign "tdb_cons_init" (void @-> returning tdb);;
