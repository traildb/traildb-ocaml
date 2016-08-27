.PHONY: all clean

MYROOT := t

SOURCES := $(wildcard *.ml)
DOT_NATIVE := $(patsubst %.ml,%.native,$(SOURCES))
TARGETS := $(patsubst %.ml,%.t,$(SOURCES))

all: $(SOURCES)
	cd .. &&                                     \
	corebuild -pkg ctypes.foreign,testsimple     \
	    -lflags -cclib,-ltraildb                 \
	    $(addprefix $(MYROOT)/,$(DOT_NATIVE)) && \
	mv $(DOT_NATIVE) $(MYROOT)/
	find . -name '*.ml' | sed -e 's/.ml$$//' | xargs -I{} mv {}.native {}.t

clean:
	$(RM) -rf tmp
	$(RM) $(DOT_NATIVE)
	$(RM) $(TARGETS)
