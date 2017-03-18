# Copyright (C) 2012,2013 IBM Corp.
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

CC = g++

CFLAGS = -g -O2 -std=c++11 -pthread -DFHE_THREADS -DFHE_DCRT_THREADS -DFHE_BOOT_THREADS

# useful flags:
#   -std=c++11
#   -DUSE_ALT_CRT  tells helib to use an alterntive to the default DoubleCRT
#                  representation...experimental...can be faster or slower
#                  depending on the operation mixture
#
#   -DNO_HALF_SIZE_PRIME  tells helib to not use the half size prime
#                         in the prime chain
#
#   -DEVALMAP_CACHED=0  tells helib to cache certain constants as ZZX's
#   -DEVALMAP_CACHED=1  tells helib to cache certain constants as DoubleCRT's
#                       these flags only affect bootstrapping
#
#   -DFHE_THREADS  tells helib to enable generic multithreading capabilities;
#                  must be used with a thread-enabled NTL and the -pthread
#                  flag should be passed to gcc
#
#   -DFHE_DCRT_THREADS  tells helib to use a multithreading strategy at the
#                       DoubleCRT level; requires -DFHE_THREADS (see above)
#
#   -DFHE_BOOT_THREADS  tells helib to use a multithreading strategy for
#                       bootstrapping; requires -DFHE_THREADS (see above)

#  If you get compilation errors, you may need to add -std=c++11 or -std=c++0x

$(info HElib requires NTL version 9.4.0 or higher, see http://shoup.net/ntl)
$(info If you get compilation errors, try to add/remove -std=c++11 in Makefile)
$(info)

LD = g++
AR = ar
ARFLAGS=rv
GMP=-lgmp
LDLIBS = -L/usr/local/lib -lntl $(GMP) -lm

TMP=$(wildcard src/*.cpp)
SRC=$(filter-out src/Test_%.cpp, $(TMP))

TMP=$(wildcard src/*.cpp)
TST_SRC=$(filter src/Test_%.cpp, $(TMP))

# build/*.o
OBJ=$(patsubst src/%.cpp, build/%.o, $(SRC))

TST_OBJ=$(patsubst src/%.cpp, build/%.o, $(TST_SRC))

TST_PROGS=$(patsubst src/%.cpp, bin/%_x, $(TST_SRC))

.PHONY: all
all: build/fhe.a

.PHONY: check
check: test
	@./bin/launch_tests.sh

.PHONY: test
test: $(TST_PROGS)

.PHONY: obj
obj: $(OBJ)

build/DoubleCRT.o: src/DoubleCRT.cpp src/AltCRT.cpp src/DoubleCRT.h \
		src/AltCRT.h
	$(CC) $(CFLAGS) -c src/DoubleCRT.cpp -o $@

build/%.o: src/%.cpp src/%.h
	$(CC) $(CFLAGS) -c $< -o $@

# Fallthrough target for CPP files with no corresponding header
build/%.o: src/%.cpp
	$(CC) $(CFLAGS) -c $< -o $@

build/fhe.a: $(OBJ)
	$(AR) $(ARFLAGS) $@ $^

bin/%_x: src/%.cpp build/fhe.a
	$(CC) $(CFLAGS) -o $@ $^ $(LDLIBS)

.PHONY: clean
clean:
	rm -f build/*.o bin/*_x bin/*_x.exe build/*.a core.*
	rm -rf bin/*.dSYM

.PHONY: info
info:
	: HElib require NTL version 9.4.0 or higher
	: Compilation flags are 'CFLAGS=$(CFLAGS)'
	: If errors occur, try adding/removing '-std=c++11' in Makefile
	:
