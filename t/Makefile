.PHONY: all clean

MYROOT := t

SOURCES := $(wildcard *.ml)
DOT_NATIVE := $(patsubst %.ml,%.native,$(SOURCES))
TARGETS := $(patsubst %.ml,%.t,$(SOURCES))

all: $(TARGETS) ;

%.t: compile.artifact ;

compile.artifact: $(SOURCES)
	cd .. &&                                     \
	corebuild -pkg ctypes.foreign,testsimple     \
	    -lflags -cclib,-ltraildb                 \
	    $(addprefix $(MYROOT)/,$(DOT_NATIVE)) && \
	mv $(DOT_NATIVE) $(MYROOT)/
	find . -name '*.ml' | sed -e 's/.ml$$//' | xargs -I{} mv {}.native {}.t
	touch compile.artifact

clean:
	$(RM) -rf tmp
	$(RM) compile.artifact
	$(RM) $(DOT_NATIVE)
	$(RM) $(TARGETS)
