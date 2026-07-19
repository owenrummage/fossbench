# fossbench build file
# Use make for the current computer, or a named target for another one.

CC      ?= cc
CFLAGS  ?= -O2 -Wall -Wextra
TLS_CFLAGS ?=
TLS_LDLIBS ?= -lssl -lcrypto
LDLIBS  ?= -lm $(TLS_LDLIBS)
# Needed for the worker threads.
PTHREAD := -pthread

DIST      := dist
DRIVER    := src/main.c src/app/benchmark.c
ASM_ARM64 := src/kernels/fossbench-arm64.S
ASM_AMD64 := src/kernels/fossbench-amd64.S
ASM_I386  := src/kernels/fossbench-i386.S
ASM_PPC32 := src/kernels/fossbench-ppc32be.S
ASM_PPC64 := src/kernels/fossbench-ppc64be.S

# Figure out the host CPU.
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
	HOST_KERNEL   := $(ASM_PPC32)
else ifneq (,$(filter ppc64 powerpc64,$(HOST_ARCH)))
	HOST_ARCHNAME := ppc64be
	HOST_KERNEL   := $(ASM_PPC64)
else
	HOST_ARCHNAME := $(HOST_ARCH)
$(error unsupported host architecture '$(HOST_ARCH)')
endif
ifeq ($(HOST_ARCHNAME),i386)
	# Keep the old i386 target simple and non-PIE.
	CFLAGS  += -march=pentium4 -fno-pie
	LDFLAGS += -no-pie
endif
ifeq ($(HOST_ARCHNAME),ppc64be)
	CFLAGS += -mcpu=970 -maltivec
endif
ifeq ($(HOST_ARCHNAME),arm64)
	HOST_KERNEL := $(ASM_ARM64)
endif

# Figure out the host OS.
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

# Pick a compiler for each target.
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
# Windows uses MinGW.
CC_WINDOWS_AMD64 ?= x86_64-w64-mingw32-gcc
CC_WINDOWS_I386  ?= i686-w64-mingw32-gcc

NATIVE_BIN := $(DIST)/fossbench-$(OSNAME)-$(HOST_ARCHNAME)

# Plain make builds for this computer.
.DEFAULT_GOAL := native
.PHONY: all native linux-arm64 linux-amd64 linux-i386 linux-ppc32be linux-ppc64be macos-arm64 macos-amd64 windows-amd64 windows-i386 bench test clean

# Build the release targets.
all: linux-arm64 linux-amd64 linux-i386 linux-ppc32be linux-ppc64be windows-amd64 windows-i386

# Build for this computer.
native: $(NATIVE_BIN)

linux-arm64: $(DIST)/fossbench-linux-arm64
linux-amd64: $(DIST)/fossbench-linux-amd64
linux-i386: $(DIST)/fossbench-linux-i386
linux-ppc32be: $(DIST)/fossbench-linux-ppc32be
linux-ppc64be: $(DIST)/fossbench-linux-ppc64be
macos-arm64: $(DIST)/fossbench-macos-arm64
macos-amd64: $(DIST)/fossbench-macos-amd64
windows-amd64: $(DIST)/fossbench-windows-amd64.exe
windows-i386: $(DIST)/fossbench-windows-i386.exe

$(DIST)/fossbench-linux-arm64: $(DRIVER) $(ASM_ARM64) | $(DIST)
	$(CC_ARM64) $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_ARM64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-linux-amd64: $(DRIVER) $(ASM_AMD64) | $(DIST)
	$(CC_AMD64) $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_AMD64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-linux-i386: $(DRIVER) $(ASM_I386) | $(DIST)
	$(CC_I386) -m32 -march=pentium4 -fno-pie -no-pie $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_I386) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-linux-ppc32be: $(DRIVER) $(ASM_PPC32) | $(DIST)
	$(CC_PPC32BE) $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_PPC32) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-linux-ppc64be: $(DRIVER) $(ASM_PPC64) | $(DIST)
	$(CC_PPC64BE) -mcpu=970 -maltivec $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_PPC64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-macos-arm64: $(DRIVER) $(ASM_ARM64) | $(DIST)
	$(CC_MACOS_ARM64) -arch arm64 $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -o $@ $(DRIVER) $(ASM_ARM64) $(LDLIBS)
	@echo "built $@"

$(DIST)/fossbench-macos-amd64: $(DRIVER) $(ASM_AMD64) | $(DIST)
	MACOSX_DEPLOYMENT_TARGET=$(MACOS_AMD64_MIN) $(CC_MACOS_AMD64) -arch x86_64 -mmacosx-version-min=$(MACOS_AMD64_MIN) $(CFLAGS) $(TLS_CFLAGS) $(PTHREAD) $(LDFLAGS) -Wl,-no_fixup_chains -o $@ $(DRIVER) $(ASM_AMD64) $(LDLIBS)
	@echo "built $@"

# Windows builds are static and use WinHTTP.
$(DIST)/fossbench-windows-amd64.exe: $(DRIVER) $(ASM_AMD64) | $(DIST)
	$(CC_WINDOWS_AMD64) $(CFLAGS) $(PTHREAD) -static -o $@ $(DRIVER) $(ASM_AMD64) -lm -lwinhttp
	@echo "built $@"

$(DIST)/fossbench-windows-i386.exe: $(DRIVER) $(ASM_I386) | $(DIST)
	$(CC_WINDOWS_I386) -march=pentium4 $(CFLAGS) $(PTHREAD) -static -o $@ $(DRIVER) $(ASM_I386) -lm -lwinhttp
	@echo "built $@"

# Add a native rule if one was not already made above.
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
