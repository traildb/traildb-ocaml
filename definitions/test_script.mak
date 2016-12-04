# generate the C test script
$(TEST_SCRIPT_ROOT)/%: $(TEST_SCRIPT_ROOT)/%.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)
