# fossbench

fossbench is a CPU benchmarking tool thats fully open-source. The core idea is to build an open-source alternative to Passmark, Geekbench, and the like by providing our entire database for free to the public. Crowdsourcing the data to ensure its accuracy without any hidden strings being pulled behind the scenes.

## Supported systems

fossbench builds on Linux, macOS, and Windows for these architectures:

| Architecture | Baseline |
|---|---|
| ARM64 | ARMv8-A with NEON |
| x86-64 | baseline x86-64 with SSE2 |
| x86 32-bit | baseline i386 with SSE2 |
| PowerPC 32-bit big-endian | scalar fallback with runtime-selected extended instructions |
| PowerPC 64-bit big-endian | PowerPC 970 with AltiVec |

If you find something it doesnt run on, please make a PR with patches if you think you can make it!

## Building

You need GNU Make, a C compiler, pthreads, and the system math library. Linux
and macOS builds also need OpenSSL headers and libraries. Windows uses WinHTTP
and does not depend on OpenSSL.

Build for the current machine:

```sh
make
```

The binary is written to `dist/fossbench-<os>-<arch>`. To build it and start a
benchmark immediately, run:

```sh
make bench
```

Named targets are available when you want a specific build, these can be found in the Makefile.

Cross builds use conventional GNU toolchain names by default. Override a
compiler when your toolchain uses a different name:

```sh
make linux-arm64 CC_ARM64=aarch64-linux-gnu-gcc
make linux-ppc32be CC_PPC32BE=powerpc-linux-gnu-gcc
make windows-amd64 CC_WINDOWS_AMD64=x86_64-w64-mingw32-gcc
```

The macOS AMD64 build defaults to macOS 10.5 compatibility. Set
`MACOS_AMD64_MIN` to choose another deployment target.

## Running a benchmark

Run the binary directly. The exact name depends on your build:

```sh
./dist/fossbench-linux-amd64
```

Useful options:

```text
--verbose          print details for each workload
--no-system-check  skip the startup system activity sample
--upload           upload the result without prompting
--noupload         do not prompt or upload
```

Before a normal run, fossbench samples system activity for ten seconds. It
reports background CPU use, available memory, process count, and the OS kernel
or build. It does not collect process names or command lines.

Result uploads are optional and anonymous unless you provide an API token. To
attach a result to your fossbench.net account, create a benchmark client token
on the site and export it before running the benchmark:

```sh
export FOSSBENCH_TOKEN=fb_your_token_here
./dist/fossbench-linux-amd64 --upload
```

You can point a build at another server with a compile-time definition:

```sh
make CFLAGS='-O2 -Wall -Wextra -DFB_API_BASE_URL=\"https://bench.example.com\"'
```

## What it measures

| Workload | Measurement |
|---|---|
| Integer math | 64-bit multiplication, division, shifts, and bit operations |
| Floating point | scalar double-precision arithmetic |
| Prime numbers | sieve of Eratosthenes up to 2,000,000 |
| Extended instructions | 128-bit integer and floating point vector work |
| Compression | LZ77 match finding over a generated 4 MiB corpus |
| Encryption | ChaCha20 over a 1 MiB buffer |
| Physics | direct-sum gravity for 512 bodies |
| Sorting | in-place heapsort of one million 32-bit integers |
| Memory latency | dependent pointer chasing through a private cycle larger than cache |

## Scores

A workload score compares its measured rate with a fixed reference rate:

```text
test score = 10000 * measured rate / reference rate
```

The single-core and multicore totals are weighted geometric means. Both passes
use the same references and weights.

| Workload | Weight |
|---|---:|
| Integer math | 20% |
| Memory latency | 16% |
| Compression | 14% |
| Sorting | 12% |
| Extended instructions | 11% |
| Floating point | 9% |
| Encryption | 8% |
| Prime numbers | 6% |
| Physics | 4% |

The benchmark profile lives in `src/app/benchmark.c`. Changing its reference
rates, weights, workload sizes, calibration time, or repeat count makes scores
incompatible with the default build.

Memory latency is printed in nanoseconds per access, though scoring uses the
underlying pointer-chase throughput. Memory placement and background operating
system work can move this result between runs.

## Tests

The correctness suite compares the kernels with C implementations, known
answers, or invariants. It covers the RFC 8439 ChaCha20 vector, prime counts,
sorting, physics momentum, pointer chasing, deterministic output, and concurrent
execution.

```sh
make test
```

The command exits with a nonzero status when a check fails.

## Repository layout

```text
src/main.c                         command-line parsing and entrypoint
src/app/benchmark.c                workload setup, timing, scoring, and run flow
src/app/benchmark.h                function used by main.c
src/app/upload.c                   API payload and network transport
src/kernels/fossbench-arm64.S      ARM64 kernels
src/kernels/fossbench-amd64.S      x86-64 kernels
src/kernels/fossbench-i386.S       i386 kernels
src/kernels/fossbench-ppc32be.S    32-bit big-endian PowerPC kernels
src/kernels/fossbench-ppc64be.S    64-bit big-endian PowerPC kernels
src/test_kernels.c                 kernel correctness suite
```
