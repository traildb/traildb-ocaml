.PHONY:
	all

all: hello.byte hello.native

clean:
	$(RM) hello.native hello.byte
	$(RM) -rf _build

hello.native: hello.ml
	corebuild -pkg ctypes.foreign -lflags -cclib,-ltraildb hello.native

# fails on OS X at runtime with
# 
# % ./hello.byte
# Fatal error: exception Dl.DL_error("dlsym(RTLD_DEFAULT, tdb_cons_init): symbol not found")
#
# even happens when DYLD_LIBRARY_PATH contains the libtraildb.dylib and libtraildb.a files
#
# hello.byte: hello.ml
# 	corebuild -pkg ctypes.foreign -lflags -cclib,-ltraildb hello.byte
