# Fossmark

A single-threaded CPU benchmark for ARM64 (AArch64), with the numeric kernels
hand-written in assembly and a small portable C driver to run and score them.

## What it measures

Nine workloads, each a tight assembly kernel:

| # | Test                    | What it exercises                                            |
|---|-------------------------|--------------------------------------------------------------|
| 1 | Integer Math            | 64-bit ALU: `madd`, `umulh`/`smulh`, `udiv`/`sdiv`, bit ops  |
| 2 | Floating Point Math     | scalar double: `fmadd`, `fdiv`, `fsqrt`                      |
| 3 | Prime Numbers           | sieve of Eratosthenes to 2,000,000 (strided memory + ALU)   |
| 4 | Extended Instructions   | NEON/ASIMD: 128-bit integer, widening, table, float vectors |
| 5 | Compression             | LZ77 match-finder over a 4 MiB corpus (branchy, cache probe) |
| 6 | Encryption              | ChaCha20, 20 rounds, NEON, over 1 MiB                        |
| 7 | Physics                 | 512-body direct-summation gravity, double precision         |
| 8 | Sorting                 | in-place heapsort of 1M `uint32` (branch + cache stress)    |
| 9 | Single-Threaded         | dependent-load pointer chase over 16 MiB (memory latency)   |

Each test auto-calibrates its iteration count until it runs long enough to be
timed reliably, then reports the best of several runs (the run least disturbed
by the OS scheduler). Every kernel returns a checksum that the driver verifies
across runs, so a miscompiled or non-deterministic kernel is caught rather than
silently mis-scored.

## Scoring

Each test's raw rate is normalised against a **reference machine** into a
unitless score, and the overall is a **weighted geometric mean** of those
scores:

```
S_i     = TARGET * (rate_i / REF_i)                       (per-test score)
Overall = TARGET * exp( Σ w_i·ln(rate_i/REF_i) / Σ w_i )  (weighted geo. mean)
```

The reference rates are the tuning machine's own rates, and `TARGET` is 20000,
so that machine scores ~20000 on every test and overall. Scaling is linear in
performance: a machine half as fast scores ~10000, one 10× slower ~2000, and a
future machine twice as fast ~40000 — so there is unbounded room both below and
above the reference.

The weights reflect each test's influence on **everyday, common-workload user
experience** — integer/general-purpose throughput and memory-latency-bound
responsiveness matter most; specialised floating-point and physics matter
least. This mirrors the weighted, integer-dominant approach of mainstream
suites such as Geekbench 6 (which splits integer/FP roughly 65/35 and combines
real-world workloads with a weighted mean).

| Test | Weight |
|---|---:|
| Integer Math          | 20% |
| Single-Threaded       | 16% |
| Compression           | 14% |
| Sorting               | 12% |
| Extended Instructions | 11% |
| Floating Point        |  9% |
| Encryption            |  8% |
| Prime Numbers         |  6% |
| Physics               |  4% |

Everything above is configurable via `#define`s at the top of `src/main.c`:
`FM_TARGET_SCORE`, the nine `FM_REF_*` reference rates, and the nine
`FM_WEIGHT_*` weights. Weights are relative — the code normalises by their sum,
so you can change one without rebalancing the rest. To re-baseline for a
different reference machine, set each `FM_REF_*` to that machine's measured
rate.

Note: the pointer-chase (Single-Threaded) test measures raw memory latency and
is the noisiest to sample, so the overall typically varies ~1–2% run to run.

## "Runs on all operating systems"

The **assembly is** OS-independent: `src/fossmark.S` contains no system calls,
no libc calls, and no external relocations. Every routine is a pure function of
its arguments under the AAPCS64 calling convention, so the same source
assembles and runs correctly on Linux (ELF), macOS (Mach-O), Windows (COFF) and
the BSDs. It avoids `x18` (reserved on Darwin/Windows) and the `v8`–`v15`
callee-saved vector bank.

A single *binary* that runs everywhere is not possible — Linux, macOS and
Windows use incompatible executable formats and system-call ABIs. So the
portable C driver (`src/main.c`) supplies the per-OS parts (timing, memory,
I/O), and you build one binary per platform. The Linux build is named
`fossmark-linux-arm64`.

## Build

```sh
make            # builds dist/fossmark-<os>-<arch> for the host
make linux-arm64
make linux-amd64
make macos-arm64
make macos-amd64
make bench      # build and run the benchmark
make test       # build and run the kernel correctness tests
```

Both macOS targets can be built on either Apple Silicon or Intel Macs; Apple
Clang selects the requested architecture with `-arch`. They produce
`dist/fossmark-macos-arm64` and `dist/fossmark-macos-amd64`, respectively.

Or by hand:

```sh
cc -O2 src/main.c src/fossmark.S -o dist/fossmark-linux-arm64 -lm
```

On macOS the same command produces a native binary (name it
`fossmark-macos-arm64`); on Windows use `clang` from the LLVM/MSVC toolchain.

## Testing

`src/test_kernels.c` is a standalone harness that validates each kernel against
an independent reference or invariant — the sieve against a C reference sieve,
the NEON ChaCha20 against a scalar reference anchored to the RFC 8439
known-answer vector, the sort against `qsort`, the N-body step against
conservation of momentum, and so on. It exits non-zero if any check fails.

```sh
make test
```
