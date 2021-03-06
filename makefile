# Setup and build

CC=gcc
CFLAGS=-Wall
LDFLAGS=
LIBS=
LD_LIBRARY_PATH=/usr/local/lib
SOURCES=$(shell find src/. -maxdepth 1 ! -name main.c -name "*.c")
CLI_SOURCES=$(shell find src/. -maxdepth 1 ! -name all_tests.c -name "*.c")
CLI_TARGET=romani

CHKLIB=-lcheck
CHECKMK=checkmk
CHECKS=$(shell find test/. -maxdepth 1 -name "*.check" | sort)

TEST_SOURCES=$(shell find test/. -maxdepth 1 ! -name main.c -name "*.c")
TEST_CFLAGS=$(CFLAGS) `pkg-config --cflags check`
TEST_LIBS=`pkg-config --libs --static check`
TEST_TARGET=all_tests

GCOV=gcov
GCOV_FLAGS=-fprofile-arcs -ftest-coverage
GCOV_TEST_TARGET=all_tests_gcov

LCOV=lcov
LCOV_FLAGS=-c --directory coverage --output-file main_coverage.info

GENHTML=genhtml
GENHTML_FLAGS=main_coverage.info --output-directory coverage

SPLINT=splint
SPLINT_FLAGS=+unixlib -compdef -mayaliasunique -immediatetrans

VALGRIND=valgrind
VALGRIND_FLAGS=--suppressions=valgrind.supp --leak-check=yes 
VALGRIND_CFLAGS=$(CFLAGS) -g
VALGRIND_TARGET=$(CLI_TARGET)_valgrind

all: splint test coverage valgrind

have_check:
	if [ -e $(LD_LIBRARY_PATH)/libcheck.a ]; then echo "libcheck.a ok!"; else echo "libcheck.a is not in $(LD_LIBRARY_PATH) as expected"; exit 1; fi;

checkmk: have_check
	$(CHECKMK) $(CHECKS) > test/all_tests.c

test: checkmk
	$(CC) $(TEST_CFLAGS) -o $(TEST_TARGET) $(SOURCES) $(TEST_SOURCES) $(CHKLIB) $(TEST_LIBS) -I src 
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) ./$(TEST_TARGET)

coverage: checkmk
	rm -Rf coverage
	$(CC) $(TEST_CFLAGS) $(GCOV_FLAGS) -o $(GCOV_TEST_TARGET) $(SOURCES) $(TEST_SOURCES) $(CHKLIB) $(TEST_LIBS) -I src 
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) ./$(GCOV_TEST_TARGET)
	$(GCOV) calculator.c
	$(GCOV) convert_roman.c
	$(GCOV) validate.c
	$(GCOV) adjust_roman.c
	$(GCOV) validate_rn.c
	mkdir -p coverage
	mv *.g??? coverage
	$(LCOV) $(LCOV_FLAGS)
	$(GENHTML) $(GENHTML_FLAGS)
	rm -f main_coverage.info

splint:
	$(SPLINT) $(SPLINT_FLAGS) -I src $(SOURCES) | tee all.splint

valgrind:
	$(CC) $(VALGRIND_CFLAGS) -o $(VALGRIND_TARGET) $(CLI_SOURCES) demo/main.c $(LIBS) -I src
	$(VALGRIND) $(VALGRIND_FLAGS) ./$(VALGRIND_TARGET) + IV MMXCIV

cli: 
	$(CC) $(CFLAGS) -o $(CLI_TARGET) $(CLI_SOURCES) demo/main.c $(LIBS) -I src

.PHONY: clean
clean:
	rm -f $(TEST_TARGET)
	rm -f $(GCOV_TEST_TARGET)
	rm -f $(CLI_TARGET)
	rm -f $(VALGRIND_TARGET)
	rm -f test/*_tests.c
	rm -f *.g???
	rm -f *.splint
	rm -Rf coverage
	rm -f main_coverage.info
