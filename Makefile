.PHONY: all clean

SOURCES := $(find . -type f -name '*.ml' -maxdepth 1)
SOURCES += traildb_types.ml.m4

all: hello.native

clean:
	$(RM) src/traildb_types.ml
	$(RM) hello.native
	$(RM) -rf _build

traildb_types.ml: traildb_types.ml.m4
	m4 $< > $@

hello.native: $(SOURCES)
	corebuild -pkg ctypes.foreign -lflags -cclib,-ltraildb $@

# Actually this is completely expected,
# libffi does not support the bytecode compiler yet.
#
# fails on OS X at runtime with
# 
# % ./hello.byte
# Fatal error: exception Dl.DL_error("dlsym(RTLD_DEFAULT, tdb_cons_init): symbol not found")
#
# even happens when DYLD_LIBRARY_PATH contains the libtraildb.dylib and libtraildb.a files
#
# hello.byte: hello.ml
# 	corebuild -pkg ctypes.foreign -lflags -cclib,-ltraildb hello.byte
