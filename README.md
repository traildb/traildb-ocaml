# traildb-ocaml

Under active development, do not use.

OCaml bindings for traildb.

Uses ctypes.foreign and libffi

## Make a traildb

    corebuild -pkg hello.native
    ./native

Dump the contents of `./awesome.tdb`

    $ tdb dump -i ./awesome.tdb
