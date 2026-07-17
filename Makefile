# fossmark - multi-core CPU benchmark
#
# The assembly kernels are architecture-specific:
#   src/fossmark.S         AArch64 (ARM64)
#   src/fossmark_x86_64.S  x86-64  (AMD64)
#   src/fossmark_ppc32.c   PowerPC 32-bit, including big-endian systems
# The C driver (src/main.c) is portable across architectures and OSes. A
# "binary that runs everywhere" is not possible - each OS/arch pair uses a
# different executable format and instruction set - so output is named per
# platform, e.g. dist/fossmark-linux-arm64, dist/fossmark-linux-amd64.
#
# Common targets:
#   make               build for the host arch (dist/fossmark-<os>-<arch>)
#   make linux-arm64   build the Linux/ARM64  binary
#   make linux-amd64   build the Linux/AMD64  binary
#   make macos-arm64   build the macOS/ARM64  binary
#   make macos-amd64   build the macOS/AMD64  binary
#   make all           build both Linux binaries
#   make bench         build for the host and run it
#   make test          build and run the kernel correctness tests (host arch)
#   make clean         remove dist/
#
# Cross-compiling: linux-amd64 on an ARM64 host (or vice versa) needs the
# matching cross toolchain. The compiler for each target defaults to the host
# `cc` when the host arch already matches, and to the conventional GNU cross
# compiler otherwise. Override with CC_ARM64=... / CC_AMD64=... if your
# toolchain is named differently, e.g.:
#   make linux-amd64 CC_AMD64=x86_64-linux-gnu-gcc-14
#   make linux-arm64 CC_ARM64="clang --target=aarch64-linux-gnu"
#
# On macOS, Apple Clang can build both architectures. The macOS compiler may
# be overridden for an osxcross or other cross toolchain:
#   make macos-arm64 CC_MACOS_ARM64=clang
#   make macos-amd64 CC_MACOS_AMD64=clang

CC      ?= cc
CFLAGS  ?= -O2 -Wall -Wextra
LDLIBS  ?= -lm
# The driver spreads each workload across all cores with pthreads.
PTHREAD := -pthread

DIST      := dist
DRIVER    := src/main.c
ASM_ARM64 := src/fossmark.S
ASM_AMD64 := src/fossmark_x86_64.S
SRC_PPC32 := src/fossmark_ppc32.c
ASM_PPC32 := src/fossmark_ppc32_ext.S

# ---- host detection: normalise `uname -m` to our arch names ----
HOST_ARCH := $(shell uname -m)
ifneq (,$(filter aarch64 arm64,$(HOST_ARCH)))
	HOST_ARCHNAME := arm64
	HOST_ASM      := $(ASM_ARM64)
else ifneq (,$(filter x86_64 amd64,$(HOST_ARCH)))
	HOST_ARCHNAME := amd64
	HOST_KERNEL   := $(ASM_AMD64)
else ifneq (,$(filter ppc powerpc ppc32 powerpc32,$(HOST_ARCH)))
	HOST_ARCHNAME := ppc32be
	HOST_KERNEL   := $(SRC_PPC32) $(ASM_PPC32)
else
	HOST_ARCHNAME := $(HOST_ARCH)
	$(error unsupported host architecture '$(HOST_ARCH)')
endif
ifeq ($(HOST_ARCHNAME),arm64)
	HOST_KERNEL := $(ASM_ARM64)
endif

# ---- host OS name for the native binary ----
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	OSNAME := linux
else ifeq ($(UNAME_S),Darwin)
	OSNAME := macos
else ifeq ($(OS),Windows_NT)
	OSNAME := windows
else
	OSNAME := $(shell uname -s | tr '[:upper:]' '[:lower:]')
endif

# ---- per-target compilers: native cc if the host matches, else a cross gcc ----
ifeq ($(HOST_ARCHNAME),arm64)
	CC_ARM64 ?= $(CC)
else
	CC_ARM64 ?= aarch64-linux-gnu-gcc
endif
ifeq ($(HOST_ARCHNAME),amd64)
	CC_AMD64 ?= $(CC)
else
	CC_AMD64 ?= x86_64-linux-gnu-gcc
endif
CC_MACOS_ARM64 ?= $(CC)
CC_MACOS_AMD64 ?= $(CC)
ifeq ($(HOST_ARCHNAME),ppc32be)
	CC_PPC32BE ?= $(CC)
else
	CC_PPC32BE ?= powerpc-linux-gnu-gcc
endif

NATIVE_BIN := $(DIST)/fossmark-$(OSNAME)-$(HOST_ARCHNAME)

# `make` with no target builds the host binary, as before.
.DEFAULT_GOAL := native
.PHONY: all native linux-arm64 linux-amd64 linux-ppc32be macos-arm64 macos-amd64 bench test clean

# `make all` builds all Linux binaries.
all: linux-arm64 linux-amd64 linux-ppc32be

# `make native` (and bare `make`) build for whatever host you are on.
native: $(NATIVE_BIN)

linux-arm64: $(DIST)/fossmark-linux-arm64
linux-amd64: $(DIST)/fossmark-linux-amd64
linux-ppc32be: $(DIST)/fossmark-linux-ppc32be
macos-arm64: $(DIST)/fossmark-macos-arm64
macos-amd64: $(DIST)/fossmark-macos-amd64

$(DIST)/fossmark-linux-arm64: $(DRIVER) $(ASM_ARM64) | $(DIST)
	$(CC_ARM64) $(CFLAGS) $(PTHREAD) -o $@ $(DRIVER) $(ASM_ARM64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossmark-linux-amd64: $(DRIVER) $(ASM_AMD64) | $(DIST)
	$(CC_AMD64) $(CFLAGS) $(PTHREAD) -o $@ $(DRIVER) $(ASM_AMD64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossmark-linux-ppc32be: $(DRIVER) $(SRC_PPC32) $(ASM_PPC32) | $(DIST)
	$(CC_PPC32BE) $(CFLAGS) $(PTHREAD) -o $@ $(DRIVER) $(SRC_PPC32) $(ASM_PPC32) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossmark-macos-arm64: $(DRIVER) $(ASM_ARM64) | $(DIST)
	$(CC_MACOS_ARM64) -arch arm64 $(CFLAGS) $(PTHREAD) -o $@ $(DRIVER) $(ASM_ARM64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossmark-macos-amd64: $(DRIVER) $(ASM_AMD64) | $(DIST)
	$(CC_MACOS_AMD64) -arch x86_64 $(CFLAGS) $(PTHREAD) -o $@ $(DRIVER) $(ASM_AMD64) $(LDLIBS)
	@echo "built $@"

# When the host is Linux/ARM64 or Linux/AMD64, the native binary IS one of the
# linux-* targets above, so no separate recipe is defined (that would be a
# duplicate). Otherwise - e.g. macOS/ARM64 - provide the native recipe here.
ifeq ($(OSNAME)-$(HOST_ARCHNAME),linux-arm64)
NATIVE_HAS_RULE := yes
endif
ifeq ($(OSNAME)-$(HOST_ARCHNAME),linux-amd64)
NATIVE_HAS_RULE := yes
endif
ifeq ($(OSNAME)-$(HOST_ARCHNAME),linux-ppc32be)
NATIVE_HAS_RULE := yes
endif
ifeq ($(OSNAME)-$(HOST_ARCHNAME),macos-arm64)
NATIVE_HAS_RULE := yes
endif
ifeq ($(OSNAME)-$(HOST_ARCHNAME),macos-amd64)
NATIVE_HAS_RULE := yes
endif
ifneq ($(NATIVE_HAS_RULE),yes)
$(NATIVE_BIN): $(DRIVER) $(HOST_KERNEL) | $(DIST)
	$(CC) $(CFLAGS) $(PTHREAD) -o $@ $(DRIVER) $(HOST_KERNEL) $(LDLIBS)
	@echo "built $@"
endif

$(DIST):
	mkdir -p $(DIST)

# Build for the host and run the benchmark.
bench: $(NATIVE_BIN)
	./$(NATIVE_BIN)

# Build and run the kernel correctness tests for the host arch.
test: | $(DIST)
	$(CC) $(CFLAGS) $(PTHREAD) -o $(DIST)/test_kernels src/test_kernels.c $(HOST_KERNEL) $(LDLIBS)
	./$(DIST)/test_kernels

clean:
	rm -rf $(DIST)
