# copy binary to .t path
$(TEST_ROOT)/%.t: $(TEST_ROOT)/%.native 
	cp $< $@

# corebuild build this binary
# corebuild likes to be in the project root and create
# its own build directory, so we will allow it to do that
# note that corebuild takes the FULL path to the executable $@,
# but only produces something in the current directory
$(TEST_ROOT)/%.native:
	cd $(MASTER_ROOT);                       \
	corebuild $(TEST_COREBUILD_FLAGS) $@
	mv $(@F) $@
