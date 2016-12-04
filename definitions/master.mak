# catch errors early
CFLAGS += -Wall -Werror
# link ltraildb when building C test scripts
LDFLAGS += -ltraildb

# master root where all the OCaml source files are
MASTER_ROOT := .
# all the files that need to be cleaned up in the master directory
MASTER_TO_CLEAN := _build $(wildcard $(MASTER_ROOT)/*.native)
# the main test directory
TEST_ROOT := ./t
# the test directory for scripts
TEST_SCRIPT_ROOT := ./t/scripts
# tmp directory for tests
TEST_TMP_ROOT := ./t/tmp

# test source files
TEST_SOURCES := $(wildcard $(TEST_ROOT)/*.ml)
# compiled test files
TEST_DOT_NATIVE := $(patsubst %.ml,%.native,$(TEST_SOURCES))
# test targets
TEST_TARGETS := $(patsubst %.ml,%.t,$(TEST_SOURCES))
# all the stuff to clean up in TEST, including the tmp directory
TEST_TO_CLEAN := $(TEST_DOT_NATIVE) $(TEST_TARGETS) $(TEST_TMP_ROOT)
# all the test script files to clean
TEST_SCRIPT_TO_CLEAN := $(wildcard $(TEST_SCRIPT_ROOT)/*.o) $(TEST_SCRIPT_ROOT)/info
# everything to build in the test scripts
TEST_SCRIPT_TARGETS := $(TEST_SCRIPT_ROOT)/info

# corebuild flags needed to build the .t test binaries
TEST_COREBUILD_FLAGS := -pkg ctypes.foreign,testsimple -lflags -cclib,-ltraildb

# all the targets
ALL_TARGETS := $(TEST_TARGETS) $(TEST_SCRIPT_TARGETS)
