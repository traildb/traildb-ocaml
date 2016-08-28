.PHONY: all clean

all:
	cd t && $(MAKE) all
	cd t/scripts && $(MAKE) all

clean:
	$(RM) -rf _build
	cd t && $(MAKE) clean
	cd t/scripts && $(MAKE) clean

test: all
	prove
