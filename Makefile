# fossbench - multi-core CPU benchmark
#
# The assembly kernels are architecture-specific:
#   src/fossbench.S         AArch64 (ARM64)
#   src/fossbench_x86_64.S  x86-64  (AMD64)
#   src/fossbench_i386.S    x86     32-bit (i386, Pentium 4 baseline)
#   src/fossbench_ppc32.c   PowerPC 32-bit, including big-endian systems
#                          and the portable PPC64 kernel implementations
# The C driver (src/main.c) is portable across architectures and OSes. A
# "binary that runs everywhere" is not possible - each OS/arch pair uses a
# different executable format and instruction set - so output is named per
# platform, e.g. dist/fossbench-linux-arm64, dist/fossbench-linux-amd64.
#
# Common targets:
#   make               build for the host arch (dist/fossbench-<os>-<arch>)
#   make linux-arm64   build the Linux/ARM64  binary
#   make linux-amd64   build the Linux/AMD64  binary
#   make linux-ppc64be build Linux/PPC64 big-endian for an iMac G5
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
#   make linux-ppc64be CC_PPC64BE=powerpc64-linux-gnu-gcc
#
# On macOS, Apple Clang can build both architectures. The macOS compiler may
# be overridden for an osxcross or other cross toolchain:
#   make macos-arm64 CC_MACOS_ARM64=clang
#   make macos-amd64 CC_MACOS_AMD64=clang

CC      ?= cc
CFLAGS  ?= -O2 -Wall -Wextra
TLS_CFLAGS ?=
TLS_LDLIBS ?= -lssl -lcrypto
LDLIBS  ?= -lm $(TLS_LDLIBS)
# The driver spreads each workload across all cores with pthreads.
PTHREAD := -pthread

DIST      := dist
DRIVER    := src/main.c
ASM_ARM64 := src/fossbench.S
ASM_AMD64 := src/fossbench_x86_64.S
ASM_I386  := src/fossbench_i386.S
SRC_PPC32 := src/fossbench_ppc32.c
ASM_PPC32 := src/fossbench_ppc32_ext.S
SRC_PPC64 := src/fossbench_ppc32.c

# ---- host detection: normalise `uname -m` to our arch names ----
HOST_ARCH := $(shell uname -m)
ifneq (,$(filter aarch64 arm64,$(HOST_ARCH)))
	HOST_ARCHNAME := arm64
	HOST_ASM      := $(ASM_ARM64)
else ifneq (,$(filter x86_64 amd64,$(HOST_ARCH)))
	HOST_ARCHNAME := amd64
	HOST_KERNEL   := $(ASM_AMD64)
else ifneq (,$(filter i386 i486 i586 i686 x86,$(HOST_ARCH)))
	HOST_ARCHNAME := i386
	HOST_KERNEL   := $(ASM_I386)
else ifneq (,$(filter ppc powerpc ppc32 powerpc32,$(HOST_ARCH)))
	HOST_ARCHNAME := ppc32be
	HOST_KERNEL   := $(SRC_PPC32) $(ASM_PPC32)
else ifneq (,$(filter ppc64 powerpc64,$(HOST_ARCH)))
	HOST_ARCHNAME := ppc64be
	HOST_KERNEL   := $(SRC_PPC64)
else
	HOST_ARCHNAME := $(HOST_ARCH)
$(error unsupported host architecture '$(HOST_ARCH)')
endif
ifeq ($(HOST_ARCHNAME),i386)
	# The kernels are hand-written assembly (fossbench_i386.S) using SSE2
	# directly, so -msse2/-mfpmath=sse have nothing left to gate - only
	# main.c (the portable driver) is still compiled from C here.
	#
	# -fno-pie: i386 PIC costs a whole general-purpose register (already the
	# scarcest resource in 32-bit mode) for the life of any function that
	# touches global data or calls out - a tax amd64/arm64 don't pay the same
	# way. Paired with -no-pie at link time below.
	CFLAGS  += -march=pentium4 -fno-pie
	LDFLAGS += -no-pie
endif
ifeq ($(HOST_ARCHNAME),ppc64be)
	CFLAGS += -mcpu=970 -maltivec
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
ifeq ($(HOST_ARCHNAME),i386)
	CC_I386 ?= $(CC)
else
	CC_I386 ?= cc
endif
CC_MACOS_ARM64 ?= $(CC)
CC_MACOS_AMD64 ?= $(CC)
MACOS_AMD64_MIN ?= 10.5
ifeq ($(HOST_ARCHNAME),ppc32be)
	CC_PPC32BE ?= $(CC)
else
	CC_PPC32BE ?= powerpc-linux-gnu-gcc
endif
ifeq ($(HOST_ARCHNAME),ppc64be)
	CC_PPC64BE ?= $(CC)
else
	CC_PPC64BE ?= powerpc64-linux-gnu-gcc
endif

NATIVE_BIN := $(DIST)/fossbench-$(OSNAME)-$(HOST_ARCHNAME)

# `make` with no target builds the host binary, as before.
.DEFAULT_GOAL := native
.PHONY: all native linux-arm64 linux-amd64 linux-i386 linux-ppc32be linux-ppc64be macos-arm64 macos-amd64 bench test clean

# `make all` builds all Linux binaries.
all: linux-arm64 linux-amd64 linux-i386 linux-ppc32be linux-ppc64be

# `make native` (and bare `make`) build for whatever host you are on.
native: $(NATIVE_BIN)

linux-arm64: $(DIST)/fossbench-linux-arm64
linux-amd64: $(DIST)/fossbench-linux-amd64
linux-i386: $(DIST)/fossbench-linux-i386
linux-ppc32be: $(DIST)/fossbench-linux-ppc32be
linux-ppc64be: $(DIST)/fossbench-linux-ppc64be
macos-arm64: $(DIST)/fossbench-macos-arm64
macos-amd64: $(DIST)/fossbench-macos-amd64

$(DIST)/fossbench-linux-arm64: $(DRIVER) $(ASM_ARM64) | $(DIST)
	$(CC_ARM64) $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_ARM64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-linux-amd64: $(DRIVER) $(ASM_AMD64) | $(DIST)
	$(CC_AMD64) $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_AMD64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-linux-i386: $(DRIVER) $(ASM_I386) | $(DIST)
	$(CC_I386) -m32 -march=pentium4 -fno-pie -no-pie $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_I386) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-linux-ppc32be: $(DRIVER) $(SRC_PPC32) $(ASM_PPC32) | $(DIST)
	$(CC_PPC32BE) $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(SRC_PPC32) $(ASM_PPC32) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-linux-ppc64be: $(DRIVER) $(SRC_PPC64) | $(DIST)
	$(CC_PPC64BE) -mcpu=970 -maltivec $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(SRC_PPC64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-macos-arm64: $(DRIVER) $(ASM_ARM64) | $(DIST)
	$(CC_MACOS_ARM64) -arch arm64 $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_ARM64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-macos-amd64: $(DRIVER) $(ASM_AMD64) | $(DIST)
	MACOSX_DEPLOYMENT_TARGET=$(MACOS_AMD64_MIN) $(CC_MACOS_AMD64) -arch x86_64 -mmacosx-version-min=$(MACOS_AMD64_MIN) $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -Wl,-no_fixup_chains -o $@ $(DRIVER) $(ASM_AMD64) $(LDLIBS)
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
ifeq ($(OSNAME)-$(HOST_ARCHNAME),linux-i386)
NATIVE_HAS_RULE := yes
endif
ifeq ($(OSNAME)-$(HOST_ARCHNAME),linux-ppc32be)
NATIVE_HAS_RULE := yes
endif
ifeq ($(OSNAME)-$(HOST_ARCHNAME),linux-ppc64be)
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
	$(CC) $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(HOST_KERNEL) $(LDLIBS)
	@echo "built $@"
endif

$(DIST):
	mkdir -p $(DIST)

# Build for the host and run the benchmark.
bench: $(NATIVE_BIN)
	./$(NATIVE_BIN)

# Build and run the kernel correctness tests for the host arch.
test: | $(DIST)
	$(CC) $(CFLAGS) $(PTHREAD) $(LDFLAGS) -o $(DIST)/test_kernels src/test_kernels.c $(HOST_KERNEL) -lm
	./$(DIST)/test_kernels

clean:
	rm -rf $(DIST)
