.PHONY: all clean generate test

# TODO: figure out how to make a library

# TODO: find a better way to exclude stuff in test
# in case we happen to write ml files there eventually
SOURCES := $(shell find . -type f -name '*.ml' -maxdepth 1)
TESTS := $(shell find ./t -type f -name '*.ml' -maxdepth 1)
TEST_EXES := $(patsubst %.ml,%.t,$(TESTS))

all: $(TEST_EXES)

clean:
	find ./t -type f -name '*.t' -exec $(RM) {} \;
	find ./t -type f -name '*.native' -exec $(RM) {} \;
	$(RM) -rf _build

# run tests under prove if it exists, fall back to
# our own test runner
test: all
	$(RM) -rf ./t/tmp
	mkdir -p ./t/tmp
	which prove && ( cd ./t && prove ) || ./t/run-test

# build native executable for tests
t/%.native: t/%.ml
	# builds the file in the current working directory for
	# some reason, it really shouldn't do that
	corebuild -pkg ctypes.foreign,testsimple -lflags -cclib,-ltraildb $@
	# move it into place
	mv $(notdir $@) $@

# move test files into location
t/%.t: t/%.native
	mv $< $@

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
