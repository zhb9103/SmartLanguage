
CC=gcc
CFLAGS=-std=c11 -g -fno-common -Wall -Wno-switch -fpermissive

SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)

TEST_SRCS=$(wildcard test/*.c)
TESTS=$(TEST_SRCS:.c=.exe)

# Stage 1

smart: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(OBJS): smart.h 

test/%.exe: smart test/%.c
	./smart -Iinclude -Itest -c -o test/$*.o test/$*.c
	$(CC) -pthread -o $@ test/$*.o -xc test/common

test: $(TESTS)
	for i in $^; do echo $$i; ./$$i || exit 1; echo; done
	test/driver.sh ./smart

test-all: test test-stage2

all: test-all

# Stage 2

stage2/smart: $(OBJS:%=stage2/%)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

stage2/%.o: smart %.c
	mkdir -p stage2/test
	./smart -c -o $(@D)/$*.o $*.c

stage2/test/%.exe: stage2/smart test/%.c
	mkdir -p stage2/test
	./stage2/smart -Iinclude -Itest -c -o stage2/test/$*.o test/$*.c
	$(CC) -pthread -o $@ stage2/test/$*.o -xc test/common

test-stage2: $(TESTS:test/%=stage2/test/%)
	for i in $^; do echo $$i; ./$$i || exit 1; echo; done
	test/driver.sh ./stage2/smart

# Misc.

clean:
	rm -rf smart tmp* $(TESTS) test/*.s test/*.exe stage2
	find * -type f '(' -name '*~' -o -name '*.o' ')' -exec rm {} ';'

.PHONY: test clean test-stage2
