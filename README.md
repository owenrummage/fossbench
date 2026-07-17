# fossbench

fossbench is an open-source CPU benchmark with nine assembly workloads and a
small C driver. It measures each workload twice: once on a single core and once
across every available core. The final report includes separate single-core and
multicore scores.

The repository currently builds an executable named `fossmark` for ARM64,
x86-64, and 32- or 64-bit big-endian PowerPC. The C driver handles timing, memory,
threads, output, and scoring. Performance-sensitive kernels live in
architecture-specific backend files.

## Workloads

| Test | What it measures |
|---|---|
| Integer math | 64-bit multiplication, division, shifts, and bit operations |
| Floating point math | Scalar double-precision multiplication, addition, division, and square roots |
| Prime numbers | A sieve of Eratosthenes up to 2,000,000 |
| Extended instructions | 128-bit SIMD integer and floating point work using NEON or SSE2 |
| Compression | An LZ77 match finder over a 4 MiB generated corpus |
| Encryption | ChaCha20 with 20 rounds over a 1 MiB buffer |
| Physics | Direct-sum gravity for 512 bodies |
| Sorting | In-place heapsort of one million 32-bit integers |
| Memory latency | Dependent pointer chasing through a private cache-exceeding cycle |

The benchmark increases each test's iteration count until one run takes at
least two seconds. It then keeps the fastest of three runs. Each kernel returns
a checksum, and fossbench stops if repeated runs produce different results.

During the multicore pass, every thread gets its own mutable workspace. This
keeps the kernels free of data races and prevents shared scratch buffers from
distorting the result.

## Build and run

You need a C compiler, GNU Make, OpenSSL development headers and libraries,
pthreads, and the system math library.

```sh
make
make bench
```

`make` builds a binary for the host at
`dist/fossmark-<os>-<arch>`. `make bench` builds that binary and runs it.

Other targets are available for explicit platforms and architectures:

```sh
make linux-arm64
make linux-amd64
make linux-ppc32be
make linux-ppc64be       # PowerPC 970 / iMac G5
make macos-arm64
make macos-amd64
make all
```

`make all` builds all four Linux targets. Cross-compilation requires a suitable
toolchain. Override the target compiler when its name differs from the default:

```sh
make linux-arm64 CC_ARM64=aarch64-linux-gnu-gcc
make linux-amd64 CC_AMD64=x86_64-linux-gnu-gcc
make linux-ppc32be CC_PPC32BE=powerpc-linux-gnu-gcc
make linux-ppc64be CC_PPC64BE=powerpc64-linux-gnu-gcc
```

Apple Clang can build either macOS architecture with `-arch`. Windows timing
and allocation code exists in the driver, but the Makefile does not include a
Windows target and the x86-64 assembly currently follows the System V ABI.

The macOS AMD64 target is linked for macOS 10.5 and disables chained fixups so
its Mach-O load commands are understood by legacy Intel Macs. Override the
deployment floor when needed with `MACOS_AMD64_MIN`, for example
`make macos-amd64 MACOS_AMD64_MIN=10.8`.

Run the benchmark with extra per-test details by passing `--verbose`:

```sh
./dist/fossmark-linux-amd64 --verbose
```

The exact filename depends on the host platform and architecture.

At startup, fossmark reports the detected CPU model, physical cores, logical
threads, installed memory, operating system, architecture, and compiler. At the
end it prints the composite scores and total benchmark duration, then asks
whether to upload the result. Uploading is anonymous and opt-in; no account or
API token is required.

The API base URL is defined by `FM_API_BASE_URL` in `src/main.c` and defaults to
`https://fossbench.net`. A release build can override it without editing the
source:

```sh
make CFLAGS='-O2 -Wall -Wextra -DFM_API_BASE_URL=\"https://bench.example.com\"'
```

HTTPS uploads use OpenSSL with certificate and hostname verification.

The PPC64 target is big-endian and is compiled for the PowerPC 970 with
AltiVec, matching the CPU used by the iMac G5. It targets 64-bit Linux; use a
PowerPC64 Linux installation or live environment on the machine to run it.

PPC64 is source-build support only. The commonly available PPC64 cross-build
libc requires POWER6 instructions and produces release binaries that fault on
the iMac G5's PowerPC 970. Build `linux-ppc64be` natively on the G5 so it uses
the compatible Arch POWER ELFv2 runtime.

Release binaries statically include OpenSSL. Linux releases are fully static;
macOS releases retain only Apple's required system-library linkage because the
macOS toolchain does not support fully static executables.

## Continuous integration and releases

Pushing a Git tag runs the GitHub Actions build and correctness tests. If they
succeed, the workflow creates a GitHub Release named `Release <tag name>` with
Linux archives for AMD64, ARM64, and PPC32 big-endian; macOS archives for AMD64
and ARM64; and a `SHA256SUMS` file. PPC64 remains available as a source build.

## Scores

Each workload receives a score relative to a reference rate:

```text
test score = 10000 * measured rate / reference rate
```

The single-core and multicore totals are weighted geometric means of the nine
test scores. Both passes use the same reference rates and weights, so their
ratio gives a direct view of scaling across the machine's available cores.

| Test | Weight |
|---|---:|
| Integer math | 20% |
| Memory latency | 16% |
| Compression | 14% |
| Sorting | 12% |
| Extended instructions | 11% |
| Floating point math | 9% |
| Encryption | 8% |
| Prime numbers | 6% |
| Physics | 4% |

The reference rates, weights, target score, workload sizes, calibration floor,
and repeat count are compile-time constants in `src/main.c`. Changing them
creates a different benchmark profile, so scores from that build should not be
compared with scores from the default build.

Memory latency is displayed as nanoseconds per access, but its score uses the
underlying pointer-chase throughput. Latency results are sensitive to memory
placement and operating-system activity, so some variation between runs is
normal.

## Architecture support

The kernel backends use only baseline instructions for their architecture:

* `src/fossmark.S` uses ARMv8-A and NEON under AAPCS64.
* `src/fossmark_x86_64.S` uses baseline x86-64 and SSE2 under the System V ABI.
* `src/fossmark_ppc32.c` is endian-safe and keeps a baseline 32-bit PowerPC
  fallback. At runtime, the extended-instruction test uses Paired Singles when
  the device-tree `compatible` property begins with `nintendo,`; otherwise it
  selects VSX, AltiVec, or the scalar fallback in that order according to
  Linux `AT_HWCAP`.
* The same C backend builds for 64-bit big-endian PowerPC. Its PPC64 path uses
  the PowerPC 970's AltiVec unit and leaves out the PPC32-only assembly helpers.

The PPC32 build uses a 2 MiB pointer-chase cycle, which exceeds the 750CL's L2
cache while keeping peak benchmark memory consumption below 32 MiB. Other
architectures retain the default 16 MiB cycle.

The assembly kernel files contain no system calls or calls into the C library.
The same ARM64 source can be assembled for Linux, macOS, Windows, and BSD object formats.
The current x86-64 source supports Linux, macOS, and the BSDs that use the
System V calling convention.

One binary cannot run on every supported target because operating systems and
architectures use different executable formats and instruction sets. Build a
separate binary for each operating system and architecture pair.

## Tests

The correctness suite checks all nine kernels against C reference
implementations, known answers, or invariants. Most checks also run concurrently
on every available core to catch shared-state and reentrancy bugs.

```sh
make test
```

The suite covers the RFC 8439 ChaCha20 test vector, prime counts, sorting output,
physics momentum, pointer-chase behavior, and deterministic results. It exits
with a nonzero status if any check fails.

## Source layout

```text
src/main.c              portable benchmark driver and scoring
src/fossmark.S          ARM64 kernels
src/fossmark_x86_64.S   x86-64 kernels
src/fossmark_ppc32.c    PPC32/PPC64 big-endian kernels
src/fossmark_ppc32_ext.S optional PPC32 PS, VSX, and AltiVec kernels
src/test_kernels.c      correctness suite
Makefile                native and cross-build targets
dist/                   generated binaries
```
