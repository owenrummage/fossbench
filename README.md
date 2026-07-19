> FOSSBench is ALPHA SOFTWARE, this means that scores reported from it should not be considered perfectly accurate. Across the machines we have tested (roughly 50 at the time of writing this) we have found it to be relatively accurate to what we would expect. This was more of a "for fun" project until someone confirms its validity on a larger scale.

# fossbench

fossbench - open source CPU benchmark

## Synopsis

```sh
make
./dist/fossbench-<os>-<arch> [--verbose] [--no-system-check] [--upload | --noupload]
```

## Description

fossbench measures CPU and memory performance. Its source code and result
database are public. Uploaded results provide the comparison data.

Version 0.2 adds a 32-bit integer test and a 12 MiB STREAM triad per thread. It
keeps the old 64-bit test as the lower-weight wide integer test and changes the
score weights. Version 0.1 and 0.2 scores are not comparable.

## Systems

| Architecture | Baseline |
|---|---|
| ARM64 | ARMv8-A with NEON |
| x86-64 | x86-64 with SSE2 |
| x86 32-bit | i386 with SSE2 |
| PowerPC 32-bit, big-endian | scalar fallback with runtime-selected extensions |
| PowerPC 64-bit, big-endian | PowerPC 970 with AltiVec |

Linux, macOS, and Windows are supported. Send a patch if a supported target
fails.

## Build

GNU Make, a C compiler, pthreads, and the system math library are required.
Linux and macOS also require OpenSSL. Windows uses WinHTTP.

Build for the current machine:

```sh
make
```

The output path is `dist/fossbench-<os>-<arch>`. Build and run it with:

```sh
make bench
```

The Makefile lists named build targets. Cross builds use standard GNU compiler
names. Override them when needed:

```sh
make linux-arm64 CC_ARM64=aarch64-linux-gnu-gcc
make linux-ppc32be CC_PPC32BE=powerpc-linux-gnu-gcc
make windows-amd64 CC_WINDOWS_AMD64=x86_64-w64-mingw32-gcc
```

The macOS AMD64 target defaults to macOS 10.5. Set `MACOS_AMD64_MIN` to change
the deployment target.

## Run

Run the generated binary:

```sh
./dist/fossbench-linux-amd64
```

Options:

```text
--verbose          print each workload
--no-system-check  skip the startup activity sample
--upload           upload without prompting
--noupload         do not prompt or upload
```

By default, fossbench samples system activity for ten seconds before a run. It
reports background CPU use, available memory, process count, and the OS kernel
or build. It does not collect process names or command lines.

Uploads are optional and anonymous. Every successful upload prints a claim
code and link that can be used to attach the result to a fossbench.net account:

```sh
./dist/fossbench-linux-amd64 --upload
```

Set another server at compile time:

```sh
make CFLAGS='-O2 -Wall -Wextra -DFB_API_BASE_URL=\"https://bench.example.com\"'
```

## Workloads

| Workload | Measurement |
|---|---|
| Integer math | 32-bit multiply, divide, shifts, and bit operations |
| Wide integer | 64-bit multiply, divide, shifts, and bit operations |
| Floating point | scalar double-precision arithmetic |
| Prime numbers | sieve of Eratosthenes to 2,000,000 |
| Extended instructions | 128-bit integer and floating-point vector work |
| Compression | LZ77 match finding on a generated 4 MiB corpus |
| Encryption | ChaCha20 on a 1 MiB buffer |
| Physics | direct-sum gravity for 512 bodies |
| Sorting | in-place heapsort of one million 32-bit integers |
| Memory latency | dependent pointer chasing through a cycle larger than cache |
| Memory bandwidth | STREAM triad with a 12 MiB working set per thread |

## Scores

Each workload uses a fixed reference rate:

```text
test score = 10000 * measured rate / reference rate
```

Single-core and multicore totals are weighted geometric means. Both use the
same references and weights.

| Workload | Weight |
|---|---:|
| Integer math | 10% |
| Wide integer | 3% |
| Floating point | 10% |
| Prime numbers | 5% |
| Extended instructions | 16% |
| Compression | 12% |
| Encryption | 8% |
| Physics | 3% |
| Sorting | 8% |
| Memory latency | 10% |
| Memory bandwidth | 15% |

The benchmark profile is in `src/app/benchmark.c`. Changing its reference
rates, weights, workload sizes, calibration time, or repeat count makes its
scores incompatible with the default build.

Memory latency is shown in nanoseconds per access. Its score uses pointer-chase
throughput. Memory placement and background system work affect the result.

## Tests

Run the correctness suite:

```sh
make test
```

It checks kernels against C implementations, known answers, or invariants. It
covers ChaCha20 RFC 8439, prime counts, sorting, physics momentum, pointer
chasing, deterministic output, and concurrent execution. Failure returns a
nonzero status.

## Files

```text
src/main.c                         option parsing and entry point
src/app/benchmark.c                workloads, timing, scoring, and run flow
src/app/benchmark.h                interface used by main.c
src/app/upload.c                   API payload and network transport
src/kernels/fossbench-arm64.S      ARM64 kernels
src/kernels/fossbench-amd64.S      x86-64 kernels
src/kernels/fossbench-i386.S       i386 kernels
src/kernels/fossbench-ppc32be.S    32-bit big-endian PowerPC kernels
src/kernels/fossbench-ppc64be.S    64-bit big-endian PowerPC kernels
src/test_kernels.c                 kernel correctness suite
```
