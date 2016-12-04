all: $(ALL_TARGETS);

clean:
	$(RM) -rf $(MASTER_TO_CLEAN); \
	$(RM) -rf $(TEST_TO_CLEAN);   \
	$(RM) -rf $(TEST_SCRIPT_TO_CLEAN)

test: all
	$(RM) -rf $(TEST_TMP_ROOT); mkdir $(TEST_TMP_ROOT)
	prove
