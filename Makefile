# defaults, must be evaluated before everything else
include definitions/preamble.mak
# all variable definitions
include definitions/master.mak
# all definitions for test scripts
include definitions/test.mak
# definitons for C test scripts
include definitions/test_script.mak
# definitions for top-level tasks
include definitions/tasks.mak
