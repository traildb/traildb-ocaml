CFLAGS=-Wall -Werror
LDFLAGS=-ltraildb

.PHONY: all clean

all: info

%: %.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

clean:
	$(RM) ./*.o info
