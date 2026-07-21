/* Runs the benchmark stuff that the kernels do not handle. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <ctype.h>

#if defined(_WIN32)
#  define WIN32_LEAN_AND_MEAN
#  include <windows.h>
#  include <tlhelp32.h>
#  include <winhttp.h>
#  include <process.h>
#else
#  include <pthread.h>
#  include <unistd.h>
#endif

#include "benchmark.h"
#include "hw_detect.h"
#if defined(__linux__)
#  include <dirent.h>
#endif

#if !defined(_WIN32) && !defined(FB_NO_UPLOAD)
#  include <sys/socket.h>
#  include <netdb.h>
#endif
#if defined(__APPLE__)
#  include <sys/types.h>
#  include <sys/sysctl.h>
#  include <mach/mach_time.h>
#  include <mach/mach.h>
#endif

/* The server URL can be changed when building. */
#ifndef FB_API_BASE_URL
#  define FB_API_BASE_URL "http://fossbench.net"
#endif
#define FB_VERSION "0.4.0"

/*
 * Native Integer Math and Memory Bandwidth are the only two *measured*
 * workloads written in C instead of a per-architecture assembly kernel. Because
 * they were compiled with whatever optimizer the build used, auto-vectorization
 * made their results depend on the compiler rather than the CPU: newer Clang
 * roughly tripled the integer result and inflated the STREAM triad by ~3x,
 * so the same machine scored very differently across builds. Pin both to
 * deterministic scalar code so every compiler measures the same work. These two
 * carry weight in web/src/scoring.js, so their stability matters to the score.
 */
#if defined(__GNUC__) && !defined(__clang__)
#  define FB_SCALAR_KERNEL __attribute__((optimize("O2", "no-tree-vectorize", "no-tree-slp-vectorize")))
#else
#  define FB_SCALAR_KERNEL
#endif
#if defined(__clang__)
#  define FB_SCALAR_LOOP _Pragma("clang loop vectorize(disable) interleave(disable)")
#else
#  define FB_SCALAR_LOOP
#endif

#if defined(__aarch64__) || defined(__arm64__) || defined(_M_ARM64)
#  define D_INT  "64-bit ALU: madd, umulh, udiv, bitops"
#  define D_FP   "double: fmadd, fdiv, fsqrt"
#  define D_SIMD "NEON ASIMD: 128-bit integer + float"
#elif defined(__x86_64__) || defined(_M_X64)
#  define D_INT  "64-bit ALU: imul, mul, div, bitops"
#  define D_FP   "double: mulsd/addsd, divsd, sqrtsd"
#  define D_SIMD "SSE2: 128-bit integer + float"
#elif defined(__i386__) || defined(_M_IX86)
#  define D_INT  "i386 integer ALU and software 64-bit arithmetic"
#  define D_FP   "x87 scalar double-precision floating point"
#  define D_SIMD "scalar extended-instruction fallback"
#elif defined(__powerpc64__)
#  define D_INT  "64-bit PowerPC integer ALU"
#  define D_FP   "PowerPC scalar double-precision floating point"
#  define D_SIMD "AltiVec: 128-bit integer vectors (PowerPC 970)"
#elif defined(__powerpc__)
#  define D_INT  "PPC32 integer ALU and software 64-bit arithmetic"
#  define D_FP   "PowerPC scalar double-precision floating point"
#  define D_SIMD "runtime-selected PS, VSX, AltiVec, or scalar"
#else
#  define D_INT  "64-bit integer ALU"
#  define D_FP   "double-precision FP"
#  define D_SIMD "128-bit SIMD: integer + float"
#endif

/* Get the current time. */

#if defined(_WIN32)
static double now_seconds(void)
{
	LARGE_INTEGER f, t;
	QueryPerformanceFrequency(&f);
	QueryPerformanceCounter(&t);
	return (double)t.QuadPart / (double)f.QuadPart;
}
#elif defined(__APPLE__)
static double now_seconds(void)
{
	static mach_timebase_info_data_t timebase;
	uint64_t ticks;

	if (timebase.denom == 0)
		mach_timebase_info(&timebase);
	ticks = mach_absolute_time();
	return (double)ticks * (double)timebase.numer /
	       (double)timebase.denom * 1e-9;
}
#else
#  include <time.h>
static double now_seconds(void)
{
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}
#endif

/* Functions provided by the kernel files. */

extern uint64_t fb_int_math(uint64_t iters);
extern uint64_t fb_fp_math(uint64_t iters);
extern uint64_t fb_primes(uint64_t limit, uint8_t *sieve);
extern uint64_t fb_simd(uint64_t iters, void *buf);
extern uint64_t fb_compress(const uint8_t *src, uint64_t len, uint32_t *ht);
extern uint64_t fb_chacha20(uint8_t *buf, uint64_t len,
			    const uint8_t key[32], uint64_t rounds);
extern uint64_t fb_physics(double *bodies, uint64_t n, uint64_t steps);
extern uint64_t fb_sort(uint32_t *a, uint64_t n);
extern uint64_t fb_chase(void **ptrs, uint64_t steps);

/* GCC/Clang optimised C copies used for the REAL score. */
extern uint64_t fb_c_int_math(uint64_t iters);
extern uint64_t fb_c_fp_math(uint64_t iters);
extern uint64_t fb_c_primes(uint64_t limit, uint8_t *sieve);
extern uint64_t fb_c_simd(uint64_t iters, void *buf);
extern uint64_t fb_c_compress(const uint8_t *src, uint64_t len, uint32_t *ht);
extern uint64_t fb_c_chacha20(uint8_t *buf, uint64_t len,
			      const uint8_t key[32], uint64_t rounds);
extern uint64_t fb_c_physics(double *bodies, uint64_t n, uint64_t steps);
extern uint64_t fb_c_sort(uint32_t *a, uint64_t n);
extern uint64_t fb_c_chase(void **ptrs, uint64_t steps);

/* Test sizes and timing settings. */

#define PRIME_LIMIT	(2u * 1000u * 1000u)	/* Prime test size. */
#define COMPRESS_LEN	(4u * 1024u * 1024u)	/* Compression data size. */
#define HT_ENTRIES	(1u << 16)		/* Compression table size. */
#define CIPHER_LEN	(1u * 1024u * 1024u)	/* Encryption data size. */
#define SIMD_BUF	256			/* Small SIMD buffer. */
#define NBODY_N		512			/* Number of physics bodies. */
#define SORT_N		(1u << 20)		/* Number of values to sort. */
#define STREAM_N	(1u << 20)		/* 12 MiB triad working set. */
/* Use less memory on 32-bit PowerPC. */
#if defined(__powerpc__) && !defined(__powerpc64__)
#  define CHASE_NODES	(1u << 19)		/* Smaller pointer loop. */
#  define CHASE_DETAIL	"dependent-load pointer chase, 2 MiB"
#elif UINTPTR_MAX == UINT32_MAX
#  define CHASE_NODES	(1u << 21)		/* Pointer loop size. */
#  define CHASE_DETAIL	"dependent-load pointer chase, 8 MiB"
#else
#  define CHASE_NODES	(1u << 21)		/* Pointer loop size. */
#  define CHASE_DETAIL	"dependent-load pointer chase, 16 MiB"
#endif

#ifndef MIN_SECONDS
#  define MIN_SECONDS	0.4			/* Minimum run time. */
#endif
#ifndef REPEATS
#  define REPEATS	3			/* Number of tries. */
#endif

/* Simple repeatable random numbers. */

static uint64_t rng_state = 0x853c49e6748fea9bULL;

static uint64_t rng_next(void)
{
	uint64_t z = (rng_state += 0x9e3779b97f4a7c15ULL);
	z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
	z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
	return z ^ (z >> 31);
}

static void rng_reset(void) { rng_state = 0x853c49e6748fea9bULL; }

/* Allocate aligned memory for the kernels. */

static void *xalloc(size_t n)
{
	void *p = NULL;
#if defined(_WIN32)
	p = _aligned_malloc(n, 64);
#else
	if (posix_memalign(&p, 64, n) != 0)
		p = NULL;
#endif
	if (!p) {
		fprintf(stderr, "fossbench: out of memory (%zu bytes)\n", n);
		exit(1);
	}
	return p;
}

static void xfree(void *p)
{
#if defined(_WIN32)
	_aligned_free(p);
#else
	free(p);
#endif
}

struct background_metrics {
	double average_cpu_percent, peak_cpu_percent;
	long available_memory_mb, process_count;
	int samples, available;
};

#define MAX_TELEMETRY_SAMPLES 1800
#define MAX_TELEMETRY_PHASES 44

struct telemetry_sample {
	uint64_t elapsed_ms;
	double temperature_c, clock_mhz;
};

struct telemetry_phase {
	uint64_t elapsed_ms;
	const char *suite, *mode;
	int workload_index;
};

struct telemetry_monitor {
	struct telemetry_sample samples[MAX_TELEMETRY_SAMPLES];
	size_t count;
	struct telemetry_phase phases[MAX_TELEMETRY_PHASES];
	size_t phase_count;
	double started;
	volatile int stop;
#if defined(_WIN32)
	HANDLE thread;
#else
	pthread_t thread;
#endif
};

static void record_telemetry_phase(struct telemetry_monitor *monitor,
				   const char *suite, int workload_index,
				   const char *mode)
{
	struct telemetry_phase *phase;
	if (monitor->phase_count >= MAX_TELEMETRY_PHASES) return;
	phase = &monitor->phases[monitor->phase_count++];
	phase->elapsed_ms = (uint64_t)((now_seconds() - monitor->started) * 1000.0);
	phase->suite = suite;
	phase->workload_index = workload_index;
	phase->mode = mode;
}

static int read_number_file(const char *path, double *value)
{
	FILE *f = fopen(path, "r");
	int ok;
	if (!f) return 0;
	ok = fscanf(f, "%lf", value) == 1;
	fclose(f);
	return ok;
}

#if defined(__linux__)
static int read_text_file(const char *path, char *value, size_t cap)
{
	FILE *f = fopen(path, "r");
	if (!f || !fgets(value, (int)cap, f)) { if (f) fclose(f); return 0; }
	fclose(f);
	value[strcspn(value, "\r\n")] = '\0';
	return 1;
}

static int cpu_sensor_name(const char *name)
{
	return strstr(name, "cpu") || strstr(name, "CPU") || strstr(name, "package") ||
	       strstr(name, "Package") || strstr(name, "coretemp") || strstr(name, "k10temp") ||
	       strstr(name, "zenpower") || strstr(name, "x86_pkg_temp") || strstr(name, "soc_thermal");
}
#endif

static double sample_cpu_temperature(void)
{
#if defined(__linux__)
	DIR *dir = opendir("/sys/class/thermal");
	struct dirent *entry;
	double hottest = -1.0;
	if (!dir) return -1.0;
	while ((entry = readdir(dir)) != NULL) {
		char path[512], type[128];
		double value;
		if (strncmp(entry->d_name, "thermal_zone", 12) != 0) continue;
		snprintf(path, sizeof(path), "/sys/class/thermal/%s/type", entry->d_name);
		if (!read_text_file(path, type, sizeof(type)) || !cpu_sensor_name(type)) continue;
		snprintf(path, sizeof(path), "/sys/class/thermal/%s/temp", entry->d_name);
		if (read_number_file(path, &value)) {
			if (value > 1000.0) value /= 1000.0;
			if (value >= 0.0 && value <= 150.0 && value > hottest) hottest = value;
		}
	}
	closedir(dir);
	if (hottest < 0.0) {
		dir = opendir("/sys/class/hwmon");
		if (!dir) return -1.0;
		while ((entry = readdir(dir)) != NULL) {
			char base[512], path[512], name[128];
			DIR *sensor_dir;
			struct dirent *sensor;
			if (strncmp(entry->d_name, "hwmon", 5) != 0) continue;
			snprintf(base, sizeof(base), "/sys/class/hwmon/%s", entry->d_name);
			snprintf(path, sizeof(path), "%s/name", base);
			if (!read_text_file(path, name, sizeof(name)) || !cpu_sensor_name(name)) continue;
			sensor_dir = opendir(base);
			if (!sensor_dir) continue;
			while ((sensor = readdir(sensor_dir)) != NULL) {
				size_t length = strlen(sensor->d_name);
				double value;
				if (strncmp(sensor->d_name, "temp", 4) != 0 || length < 7 || strcmp(sensor->d_name + length - 6, "_input") != 0) continue;
				snprintf(path, sizeof(path), "%s/%s", base, sensor->d_name);
				if (read_number_file(path, &value)) {
					if (value > 1000.0) value /= 1000.0;
					if (value >= 0.0 && value <= 150.0 && value > hottest) hottest = value;
				}
			}
			closedir(sensor_dir);
		}
		closedir(dir);
	}
	return hottest;
#else
	return -1.0;
#endif
}

static double sample_cpu_clock_mhz(void)
{
#if defined(__linux__)
	DIR *dir = opendir("/sys/devices/system/cpu");
	struct dirent *entry;
	double total = 0.0;
	long count = 0;
	if (dir) {
		while ((entry = readdir(dir)) != NULL) {
			char path[512], *end;
			double value;
			if (strncmp(entry->d_name, "cpu", 3) != 0 || !isdigit((unsigned char)entry->d_name[3])) continue;
			strtol(entry->d_name + 3, &end, 10);
			if (*end) continue;
			snprintf(path, sizeof(path), "/sys/devices/system/cpu/%s/cpufreq/scaling_cur_freq", entry->d_name);
			if (read_number_file(path, &value) && value > 0.0) { total += value / 1000.0; count++; }
		}
		closedir(dir);
	}
	if (count) return total / (double)count;
	{
		FILE *f = fopen("/proc/cpuinfo", "r");
		char line[256];
		if (!f) return -1.0;
		while (fgets(line, sizeof(line), f)) {
			double value;
			if (sscanf(line, "cpu MHz%*[^:]: %lf", &value) == 1 && value > 0.0) { total += value; count++; }
		}
		fclose(f);
	}
	return count ? total / (double)count : -1.0;
#elif defined(__APPLE__)
	{
		uint64_t hz = 0; size_t size = sizeof(hz);
		return sysctlbyname("hw.cpufrequency", &hz, &size, NULL, 0) == 0 && hz ? (double)hz / 1000000.0 : -1.0;
	}
#elif defined(_WIN32)
	{
		HKEY key; DWORD mhz = 0, size = sizeof(mhz), type = 0;
		if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0", 0, KEY_READ, &key) != ERROR_SUCCESS) return -1.0;
		if (RegQueryValueExA(key, "~MHz", NULL, &type, (LPBYTE)&mhz, &size) != ERROR_SUCCESS || type != REG_DWORD) mhz = 0;
		RegCloseKey(key);
		return mhz ? (double)mhz : -1.0;
	}
#else
	return -1.0;
#endif
}

static void record_telemetry_sample(struct telemetry_monitor *monitor)
{
	struct telemetry_sample *sample;
	if (monitor->count >= MAX_TELEMETRY_SAMPLES) return;
	sample = &monitor->samples[monitor->count++];
	sample->elapsed_ms = (uint64_t)((now_seconds() - monitor->started) * 1000.0);
	sample->temperature_c = sample_cpu_temperature();
	sample->clock_mhz = sample_cpu_clock_mhz();
}

static void telemetry_sleep(void)
{
#if defined(_WIN32)
	Sleep(25);
#else
	usleep(25000);
#endif
}

#if defined(_WIN32)
static DWORD WINAPI telemetry_entry(LPVOID arg)
#else
static void *telemetry_entry(void *arg)
#endif
{
	struct telemetry_monitor *monitor = (struct telemetry_monitor *)arg;
	double next = monitor->started;
	while (!monitor->stop) {
		double current = now_seconds();
		if (current >= next) { record_telemetry_sample(monitor); next += 0.25; }
		telemetry_sleep();
	}
	record_telemetry_sample(monitor);
#if defined(_WIN32)
	return 0;
#else
	return NULL;
#endif
}

static int start_telemetry_monitor(struct telemetry_monitor *monitor, double started)
{
	memset(monitor, 0, sizeof(*monitor));
	monitor->started = started;
#if defined(_WIN32)
	monitor->thread = CreateThread(NULL, 0, telemetry_entry, monitor, 0, NULL);
	return monitor->thread != NULL;
#else
	return pthread_create(&monitor->thread, NULL, telemetry_entry, monitor) == 0;
#endif
}

static void stop_telemetry_monitor(struct telemetry_monitor *monitor, int started)
{
	if (!started) return;
	monitor->stop = 1;
#if defined(_WIN32)
	WaitForSingleObject(monitor->thread, INFINITE);
	CloseHandle(monitor->thread);
#else
	pthread_join(monitor->thread, NULL);
#endif
}

struct cpu_snapshot { uint64_t total, idle; };

static int take_cpu_snapshot(struct cpu_snapshot *s)
{
#if defined(__linux__)
	FILE *f = fopen("/proc/stat", "r");
	unsigned long long user=0, nice=0, system=0, idle=0, wait=0, irq=0, softirq=0, steal=0;
	int n;
	if (!f) return 0;
	n = fscanf(f, "cpu %llu %llu %llu %llu %llu %llu %llu %llu",
		   &user, &nice, &system, &idle, &wait, &irq, &softirq, &steal);
	fclose(f); if (n < 4) return 0;
	s->idle = idle + wait;
	s->total = user + nice + system + idle + wait + irq + softirq + steal;
	return 1;
#elif defined(__APPLE__)
	host_cpu_load_info_data_t cpu; mach_msg_type_number_t count = HOST_CPU_LOAD_INFO_COUNT;
	if (host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (host_info_t)&cpu, &count) != KERN_SUCCESS) return 0;
	s->idle = cpu.cpu_ticks[CPU_STATE_IDLE];
	s->total = cpu.cpu_ticks[CPU_STATE_USER] + cpu.cpu_ticks[CPU_STATE_SYSTEM] + s->idle + cpu.cpu_ticks[CPU_STATE_NICE];
	return 1;
#elif defined(_WIN32)
	FILETIME idle, kernel, user; ULARGE_INTEGER i, k, u;
	if (!GetSystemTimes(&idle, &kernel, &user)) return 0;
	i.LowPart=idle.dwLowDateTime; i.HighPart=idle.dwHighDateTime;
	k.LowPart=kernel.dwLowDateTime; k.HighPart=kernel.dwHighDateTime;
	u.LowPart=user.dwLowDateTime; u.HighPart=user.dwHighDateTime;
	s->idle=i.QuadPart; s->total=k.QuadPart+u.QuadPart; return 1;
#else
	(void)s; return 0;
#endif
}

static void take_resource_snapshot(long *available_mb, long *processes)
{
	*available_mb = -1; *processes = -1;
#if defined(__linux__)
	{
		FILE *f=fopen("/proc/meminfo","r"); char line[256]; long kb;
		if (f) { while (fgets(line,sizeof(line),f)) if (sscanf(line,"MemAvailable: %ld kB",&kb)==1) { *available_mb=kb/1024; break; } fclose(f); }
	}
	{
		DIR *dir=opendir("/proc"); struct dirent *entry; long count=0;
		if (dir) { while ((entry=readdir(dir)) != NULL) { const char *p=entry->d_name; if (!*p) continue; while (*p && isdigit((unsigned char)*p)) p++; if (!*p) count++; } closedir(dir); *processes=count; }
	}
#elif defined(__APPLE__)
	{
		vm_statistics_data_t vm; mach_msg_type_number_t count=HOST_VM_INFO_COUNT; vm_size_t page;
		if (host_page_size(mach_host_self(),&page)==KERN_SUCCESS && host_statistics(mach_host_self(),HOST_VM_INFO,(host_info_t)&vm,&count)==KERN_SUCCESS)
			*available_mb=(long)(((uint64_t)vm.free_count+vm.inactive_count)*page/1024/1024);
	}
	{
		int mib[4]={CTL_KERN,KERN_PROC,KERN_PROC_ALL,0}; size_t bytes=0;
		if (sysctl(mib,4,NULL,&bytes,NULL,0)==0) *processes=(long)(bytes/sizeof(struct kinfo_proc));
	}
#elif defined(_WIN32)
	{
		MEMORYSTATUSEX ms; ms.dwLength=sizeof(ms); if (GlobalMemoryStatusEx(&ms)) *available_mb=(long)(ms.ullAvailPhys/1024/1024);
	}
	{
		HANDLE snap=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0); PROCESSENTRY32 entry; long count=0; entry.dwSize=sizeof(entry);
		if (snap!=INVALID_HANDLE_VALUE) { if (Process32First(snap,&entry)) do { count++; } while (Process32Next(snap,&entry)); CloseHandle(snap); *processes=count; }
	}
#endif
}

static void sample_background_metrics(struct background_metrics *m, int seconds)
{
	struct cpu_snapshot before, after; int i;
	memset(m,0,sizeof(*m)); m->available_memory_mb=-1; m->process_count=-1;
	printf("\n  checking background system activity for %d seconds",seconds); fflush(stdout);
	if (!take_cpu_snapshot(&before)) { printf("... unavailable\n"); return; }
	for (i=0;i<seconds;i++) {
#if defined(_WIN32)
		Sleep(1000);
#else
		sleep(1);
#endif
		if (take_cpu_snapshot(&after) && after.total>before.total) {
			uint64_t total=after.total-before.total, idle=after.idle-before.idle;
			double busy=100.0*(double)(total > idle ? total-idle : 0)/(double)total;
			m->average_cpu_percent+=busy; if (busy>m->peak_cpu_percent) m->peak_cpu_percent=busy;
			m->samples++; before=after;
		}
		printf("."); fflush(stdout);
	}
	take_resource_snapshot(&m->available_memory_mb,&m->process_count);
	if (m->samples) { m->average_cpu_percent/=m->samples; m->available=1; }
	printf(" done\n");
}

/* Buffers used while tests are running. */
struct workspace {
	uint8_t  *sieve;	/* Prime test buffer. */
	uint32_t *ht;		/* Compression table. */
	uint8_t  *cipher_buf;	/* ChaCha20 buffer, encrypted in place. */
	uint8_t  *simd_buf;	/* Small SIMD buffer. */
	double   *bodies;	/* n-body integration buffer. */
	uint32_t *sort_work;	/* the buffer we actually sort. */
	void    **chase;	/* private 16 MiB pointer-chase cycle. */
	float    *stream_a, *stream_b, *stream_c;
};

static long              g_ncores  = 1;	/* active online cores. */
static struct workspace *g_ws;		/* g_ncores per-thread workspaces. */

static uint8_t  *g_corpus;	/* shared, read-only compression input. */
static uint8_t   g_key[32];	/* shared, read-only cipher key. */
static uint8_t  *g_cipher_src;	/* pristine plaintext, copied per-core. */
static uint8_t  *g_simd_src;	/* pristine NEON seed, copied per-core. */
static double   *g_bodies_src;	/* pristine initial conditions. */
static uint32_t *g_sort_src;	/* pristine unsorted data. */
static int g_c_backend;		/* zero = RAW assembly, one = REAL C. */


/* Synthesise a compressible corpus. */
static void build_corpus(uint8_t *buf, size_t len)
{
	static const char *words[] = {
		"the", "quick", "brown", "fox", "jumps", "over", "lazy",
		"dog", "benchmark", "processor", "assembly", "vector",
		"memory", "cache", "pipeline", "instruction", "compress",
		"data", "system", "performance", "register", "kernel"
	};
	const size_t nwords = sizeof(words) / sizeof(words[0]);
	size_t pos = 0;

	while (pos < len) {
		const char *w = words[rng_next() % nwords];
		size_t wl = strlen(w);

		if (pos + wl + 1 > len)
			break;
		memcpy(buf + pos, w, wl);
		pos += wl;
		buf[pos++] = (rng_next() % 8 == 0) ? '\n' : ' ';
	}
	while (pos < len)
		buf[pos++] = ' ';
}

/* Build a random pointer loop. */
static void build_chase(void **nodes, size_t n)
{
	size_t *perm = xalloc(n * sizeof(size_t));
	size_t i;

	for (i = 0; i < n; i++)
		perm[i] = i;
	for (i = n - 1; i > 0; i--) {
		size_t j = (size_t)(rng_next() % i);	/* Do not pick the current item. */
		size_t t = perm[i];
		perm[i] = perm[j];
		perm[j] = t;
	}
	for (i = 0; i < n; i++)
		nodes[perm[i]] = (void *)&nodes[perm[(i + 1) % n]];

	xfree(perm);
}

static void setup(void)
{
	size_t i;
	long   t;

	rng_reset();

	/* Set up data shared by the workers. */
	g_corpus     = xalloc(COMPRESS_LEN);
	g_cipher_src = xalloc(CIPHER_LEN);
	g_simd_src   = xalloc(SIMD_BUF);
	g_bodies_src = xalloc(NBODY_N * 8 * sizeof(double));
	g_sort_src   = xalloc(SORT_N * sizeof(uint32_t));

	build_corpus(g_corpus, COMPRESS_LEN);

	for (i = 0; i < CIPHER_LEN; i++)
		g_cipher_src[i] = (uint8_t)rng_next();
	for (i = 0; i < 32; i++)
		g_key[i] = (uint8_t)rng_next();
	for (i = 0; i < SIMD_BUF; i++)
		g_simd_src[i] = (uint8_t)rng_next();
	for (i = 0; i < SORT_N; i++)
		g_sort_src[i] = (uint32_t)rng_next();

	/* Set up the physics bodies. */
	for (i = 0; i < NBODY_N; i++) {
		double *b = &g_bodies_src[i * 8];
		b[0] = (double)(rng_next() % 2000) / 1000.0 - 1.0;
		b[1] = (double)(rng_next() % 2000) / 1000.0 - 1.0;
		b[2] = (double)(rng_next() % 2000) / 1000.0 - 1.0;
		b[3] = (double)(rng_next() % 900) / 1000.0 + 0.1;  /* Keep mass above zero. */
		b[4] = b[5] = b[6] = 0.0;
		b[7] = 0.0;
	}

	/* Give every worker its own buffers. */
	g_ws = xalloc((size_t)g_ncores * sizeof *g_ws);
	for (t = 0; t < g_ncores; t++) {
		struct workspace *w = &g_ws[t];

		w->sieve      = xalloc(PRIME_LIMIT);
		w->ht         = xalloc(HT_ENTRIES * sizeof(uint32_t));
		w->cipher_buf = xalloc(CIPHER_LEN);
		w->simd_buf   = xalloc(SIMD_BUF);
		w->bodies     = xalloc(NBODY_N * 8 * sizeof(double));
		w->sort_work  = xalloc(SORT_N * sizeof(uint32_t));
		w->chase      = xalloc(CHASE_NODES * sizeof(void *));
		w->stream_a   = xalloc(STREAM_N * sizeof(float));
		w->stream_b   = xalloc(STREAM_N * sizeof(float));
		w->stream_c   = xalloc(STREAM_N * sizeof(float));

		memcpy(w->cipher_buf, g_cipher_src, CIPHER_LEN);
		memcpy(w->simd_buf,   g_simd_src,   SIMD_BUF);
		build_chase(w->chase, CHASE_NODES);
		for (i = 0; i < STREAM_N; i++) {
			w->stream_a[i] = (float)(i & 1023) * (1.0f / 1024.0f);
			w->stream_b[i] = (float)((i * 17) & 1023) * (1.0f / 1024.0f);
			w->stream_c[i] = 0.0f;
		}
	}
}

static void teardown(void)
{
	long t;

	for (t = 0; t < g_ncores; t++) {
		struct workspace *w = &g_ws[t];

		xfree(w->sieve);      xfree(w->ht);        xfree(w->cipher_buf);
		xfree(w->simd_buf);   xfree(w->bodies);    xfree(w->sort_work);
		xfree(w->chase);
		xfree(w->stream_a); xfree(w->stream_b); xfree(w->stream_c);
	}
	xfree(g_ws);

	xfree(g_corpus);     xfree(g_cipher_src); xfree(g_simd_src);
	xfree(g_bodies_src); xfree(g_sort_src);
}

/* Code that runs and times each test. */

/* Run one kernel with its workspace. */
typedef uint64_t (*run_fn)(uint64_t n, struct workspace *ws);

struct test {
	const char *name;
	const char *detail;
	run_fn      run;
	uint64_t    start_n;
	double      work_per_n;	/* Amount of work used to calculate the raw rate. */
	const char *unit;
};

static uint64_t run_int(uint64_t n, struct workspace *ws)
{
	(void)ws;
	return g_c_backend ? fb_c_int_math(n * 100000) : fb_int_math(n * 100000);
}

FB_SCALAR_KERNEL
static uint64_t run_int32(uint64_t n, struct workspace *ws)
{
	uint32_t a = 0x9e3779b9u, b = 0xbf58476du;
	uint32_t c = 0x94d049bbu, d = 0x2545f491u;
	uint64_t i, iters = n * 100000;
	(void)ws;
	FB_SCALAR_LOOP
	for (i = 0; i < iters; i++) {
		a = a * 0xdeadbeefu + b;
		b = b * 0xdeadbeefu + c;
		c = c * 0x9e3779b1u + d;
		d = d * 0x9e3779b1u + a;
		a ^= (c >> 7) | (c << 25);
		b ^= (d >> 11) | (d << 21);
		c ^= (a >> 17) | (a << 15);
		d ^= (b >> 23) | (b << 9);
	}
	return (uint64_t)(a ^ b ^ c ^ d);
}
static uint64_t run_fp(uint64_t n, struct workspace *ws)
{
	(void)ws;
	return g_c_backend ? fb_c_fp_math(n * 100000) : fb_fp_math(n * 100000);
}
static uint64_t run_primes(uint64_t n, struct workspace *ws)
{
	uint64_t c = 0;
	for (uint64_t i = 0; i < n; i++)
		c += g_c_backend ? fb_c_primes(PRIME_LIMIT, ws->sieve) :
				     fb_primes(PRIME_LIMIT, ws->sieve);
	return c;
}
static uint64_t run_simd(uint64_t n, struct workspace *ws)
{
	/* Reset the SIMD buffer before running. */
	memcpy(ws->simd_buf, g_simd_src, SIMD_BUF);
	return g_c_backend ? fb_c_simd(n * 100000, ws->simd_buf) :
			     fb_simd(n * 100000, ws->simd_buf);
}
static uint64_t run_compress(uint64_t n, struct workspace *ws)
{
	uint64_t c = 0;
	for (uint64_t i = 0; i < n; i++)
		c += g_c_backend ? fb_c_compress(g_corpus, COMPRESS_LEN, ws->ht) :
				     fb_compress(g_corpus, COMPRESS_LEN, ws->ht);
	return c;
}
static uint64_t run_crypto(uint64_t n, struct workspace *ws)
{
	return g_c_backend ? fb_c_chacha20(ws->cipher_buf, CIPHER_LEN, g_key, n) :
			     fb_chacha20(ws->cipher_buf, CIPHER_LEN, g_key, n);
}
static uint64_t run_physics(uint64_t n, struct workspace *ws)
{
	/* Reset the physics data before running. */
	memcpy(ws->bodies, g_bodies_src, NBODY_N * 8 * sizeof(double));
	return g_c_backend ? fb_c_physics(ws->bodies, NBODY_N, n) :
			     fb_physics(ws->bodies, NBODY_N, n);
}
static uint64_t run_sort(uint64_t n, struct workspace *ws)
{
	uint64_t c = 0;
	for (uint64_t i = 0; i < n; i++) {
		/* Reset the sort data before running. */
		memcpy(ws->sort_work, g_sort_src, SORT_N * sizeof(uint32_t));
		c ^= g_c_backend ? fb_c_sort(ws->sort_work, SORT_N) :
				     fb_sort(ws->sort_work, SORT_N);
	}
	return c;
}
static uint64_t run_chase(uint64_t n, struct workspace *ws)
{
	return g_c_backend ? fb_c_chase(ws->chase, n * 1000000) :
			     fb_chase(ws->chase, n * 1000000);
}

FB_SCALAR_KERNEL
static uint64_t run_stream(uint64_t n, struct workspace *ws)
{
	uint64_t pass, checksum = 0;
	const float scale = 1.0009765625f;
	for (pass = 0; pass < n; pass++) {
		size_t i;
		float *restrict a = ws->stream_a;
		float *restrict b = ws->stream_b;
		float *restrict c = ws->stream_c;
		FB_SCALAR_LOOP
		for (i = 0; i < STREAM_N; i++)
			c[i] = a[i] + scale * b[i];
	}
	{
		uint32_t bits;
		memcpy(&bits, &ws->stream_c[(n * 104729u) & (STREAM_N - 1)], sizeof bits);
		checksum = bits;
	}
	return checksum;
}

static const struct test tests[] = {
	{ "Native Integer Math",  "common 32-bit multiply/add/rotate mix",
	  run_int32,    20, 100000.0 * 16,  "Mops/s" },
	{ "Wide Integer Math",    D_INT,
	  run_int,      20, 100000.0 * 24,  "Mops/s" },
	{ "Floating Point Math",  D_FP,
	  run_fp,       20, 100000.0 * 20,  "Mops/s" },
	{ "Prime Numbers",        "sieve of Eratosthenes to 2M",
	  run_primes,    1, (double)PRIME_LIMIT, "Mcand/s" },
	{ "Extended Instructions",D_SIMD,
	  run_simd,     10, 100000.0 * 32,  "Mops/s" },
	{ "Compression",          "LZ77 match finder, 4 MiB corpus",
	  run_compress,  1, (double)COMPRESS_LEN, "MB/s" },
	{ "Encryption",           "ChaCha20, 20 rounds, 1 MiB",
	  run_crypto,    4, (double)CIPHER_LEN, "MB/s" },
	{ "Physics",              "512-body direct-sum gravity",
	  run_physics,   4, (double)NBODY_N * NBODY_N, "Mpair/s" },
	{ "Sorting",              "heapsort, 1M uint32",
	  run_sort,      1, (double)SORT_N * 20,  "Mkey-cmp/s" },
	{ "Memory Latency",       CHASE_DETAIL,
	  run_chase,     1, 1000000.0,      "ns/access" },
	{ "Memory Bandwidth",     "STREAM triad, 12 MiB working set per thread",
	  run_stream,    16, (double)STREAM_N * 12.0, "MB/s" },
};

#define NTESTS (sizeof(tests) / sizeof(tests[0]))

struct result {
	double   rate;		/* Measured speed. */
	uint64_t checksum;
	double   seconds;
	uint64_t iters;
	int      threads;	/* Number of worker threads. */
};

/* Data passed to a worker thread. */
struct job {
	run_fn            run;
	uint64_t          n;
	struct workspace *ws;
	uint64_t          result;
};

#if defined(_WIN32)
static unsigned WINAPI job_entry(void *arg)
#else
static void *job_entry(void *arg)
#endif
{
	struct job *j = arg;
	j->result = j->run(j->n, j->ws);
	return 0;
}

/* Run a kernel on all requested threads. */
static uint64_t dispatch(run_fn run, uint64_t n, int threads)
{
	struct job *jobs = xalloc((size_t)threads * sizeof *jobs);
#if defined(_WIN32)
	HANDLE *tids = threads > 1
			 ? xalloc((size_t)(threads - 1) * sizeof *tids) : NULL;
#else
	pthread_t  *tids = threads > 1
			 ? xalloc((size_t)(threads - 1) * sizeof *tids) : NULL;
#endif
	int i, spawned = 0;
	uint64_t agg = 0;

	for (i = 0; i < threads; i++) {
		jobs[i].run = run;
		jobs[i].n   = n;
		jobs[i].ws  = &g_ws[i];
	}
	for (i = 1; i < threads; i++) {
#if defined(_WIN32)
		tids[spawned] = (HANDLE)_beginthreadex(NULL, 0, job_entry, &jobs[i], 0, NULL);
		if (tids[spawned] != NULL)
			spawned++;
		else
			job_entry(&jobs[i]);	/* Run it here if the thread fails. */
#else
		if (pthread_create(&tids[spawned], NULL, job_entry, &jobs[i]) == 0)
			spawned++;
		else
			job_entry(&jobs[i]);	/* Run it here if the thread fails. */
#endif
	}

	job_entry(&jobs[0]);			/* The main thread does the first job. */

	for (i = 0; i < spawned; i++) {
#if defined(_WIN32)
		WaitForSingleObject(tids[i], INFINITE);
		CloseHandle(tids[i]);
#else
		pthread_join(tids[i], NULL);
#endif
	}
	for (i = 0; i < threads; i++)
		agg += jobs[i].result;

	xfree(jobs);
	xfree(tids);
	return agg;
}

static struct result run_test(const struct test *t, int threads)
{
	struct result r;
	uint64_t n = t->start_n;
	double elapsed = 0.0, total = 0.0, average;
	uint64_t checksum = 0;
	int i, samples;

	/* Increase the work until it runs long enough. */
	for (;;) {
		double t0 = now_seconds();
		checksum = dispatch(t->run, n, threads);
		elapsed = now_seconds() - t0;

		if (elapsed >= MIN_SECONDS)
			break;
		if (elapsed < 0.001) {
			n *= 8;			/* Increase it a lot when timing is too short. */
		} else {
			double scale = (MIN_SECONDS * 1.3) / elapsed;
			if (scale < 1.5)
				scale = 1.5;
			if (scale > 8.0)
				scale = 8.0;
			n = (uint64_t)((double)n * scale) + 1;
		}
	}

	/* Average every measured run. Keeping only the fastest rewarded a single
	 * lucky sample and hid the run-to-run variation that real machines show;
	 * the mean is a more representative and reproducible throughput. */
	total = elapsed;
	samples = 1;
	for (i = 1; i < REPEATS; i++) {
		double t0 = now_seconds();
		uint64_t c = dispatch(t->run, n, threads);
		double e = now_seconds() - t0;

		if (c != checksum) {
			fprintf(stderr,
				"fossbench: %s is non-deterministic "
				"(checksum %llu != %llu)\n", t->name,
				(unsigned long long)c,
				(unsigned long long)checksum);
			exit(2);
		}
		total += e;
		samples++;
	}
	average = total / samples;

	r.seconds  = average;
	r.iters    = n;
	r.checksum = checksum;
	r.threads  = threads;
	/* Calculate the total speed. */
	r.rate     = ((double)threads * (double)n * t->work_per_n) / average / 1e6;
	return r;
}

/* Pick the value shown in the rate column. */
static double display_metric(const struct test *t, const struct result *r)
{
	if (t->run == run_chase) {
		double hops = (double)r->iters * t->work_per_n;	/* Per core. */
		return r->seconds / hops * 1e9;			/* Convert it to nanoseconds. */
	}
	return r->rate;
}

#if !defined(FB_NO_UPLOAD)
#  include "upload.c"
#endif
/* Print the results. */

static void print_header(const struct system_info *info)
{
	printf("\n");
	printf("  fossbench %s - multi-core CPU benchmark\n", FB_VERSION);
	printf("  ------------------------------------------------------------------\n");
	printf("  CPU:       %s\n", info->cpu);
	printf("  model:     %s\n", info->model[0] ? info->model : "unknown");
	printf("  cores:     %ld physical / %ld threads\n", info->cpu_cores, info->cpu_threads);
	printf("  memory:    %ld MB\n", info->memory_mb);
	printf("  caches:    L1 %ld KB / L2 %ld KB / L3 %ld KB\n",
	       info->l1_cache_kb, info->l2_cache_kb, info->l3_cache_kb);
	printf("  OS:        %s (%s)\n", info->operating_system, hw_arch_name());
	printf("  kernel:    %s\n", info->kernel[0] ? info->kernel : "unknown");
	printf("  compiler:  %s\n", info->compiler);
	printf("\n");
	printf("  %-24s %12s  %-11s %8s\n",
	       "TEST", "RATE", "UNIT", "TIME");
	printf("  --------------------------------------------------------------------------\n");
	fflush(stdout);
}

int fossbench_run(int verbose, int upload_mode, int system_check)
{
	struct result raw_multi[NTESTS], raw_single[NTESTS];
	struct result real_multi[NTESTS], real_single[NTESTS];
	struct system_info system_info;
	struct background_metrics background;
	struct telemetry_monitor telemetry;
	double benchmark_started;
	int telemetry_started;
	uint64_t duration_ms;
	size_t i;

	hw_detect_system(&system_info);
	g_ncores = system_info.cpu_threads;
	memset(&background, 0, sizeof(background));
	background.available_memory_mb = background.process_count = -1;
	if (system_check) {
		sample_background_metrics(&background, 10);
		if (background.available) {
			printf("  background CPU: %.1f%% average / %.1f%% peak\n",
			       background.average_cpu_percent, background.peak_cpu_percent);
			if (background.available_memory_mb >= 0)
				printf("  available memory: %ld MB of %ld MB\n", background.available_memory_mb, system_info.memory_mb);
			if (background.process_count >= 0) printf("  processes: %ld\n", background.process_count);
			if (background.average_cpu_percent >= 10.0)
				printf("  warning: background CPU activity may reduce benchmark scores\n");
		}
	}
	benchmark_started = now_seconds();
	telemetry_started = start_telemetry_monitor(&telemetry, benchmark_started);

	printf("\n  preparing workloads...");
	fflush(stdout);
	setup();
	printf(" done\n");

	print_header(&system_info);

	printf("  RAW score suite (architecture assembly)\n");
	g_c_backend = 0;
	for (i = 0; i < NTESTS; i++) {
		printf("  %-24s", tests[i].name);
		fflush(stdout);

		/* Run every test with all cores and one core. */
		record_telemetry_phase(&telemetry, "asm", (int)i, "multicore");
		raw_multi[i]  = run_test(&tests[i], (int)g_ncores);
		record_telemetry_phase(&telemetry, "asm", (int)i, "singlecore");
		raw_single[i] = run_test(&tests[i], 1);

		printf(" %12.1f  %-11s %7.2fs\n",
		       display_metric(&tests[i], &raw_multi[i]), tests[i].unit,
		       raw_multi[i].seconds);
		if (verbose)
			printf("  %-24s   %s\n"
			       "  %-24s   1-core: %.1f %s   %ld-core: %.1f %s\n",
			       "", tests[i].detail, "",
			       display_metric(&tests[i], &raw_single[i]), tests[i].unit,
			       g_ncores, display_metric(&tests[i], &raw_multi[i]), tests[i].unit);
		fflush(stdout);
	}

	printf("  --------------------------------------------------------------------------\n");
	printf("  REAL score suite (optimised portable C)\n");
	g_c_backend = 1;
	for (i = 0; i < NTESTS; i++) {
		printf("  %-24s", tests[i].name);
		fflush(stdout);
		record_telemetry_phase(&telemetry, "c", (int)i, "multicore");
		real_multi[i] = run_test(&tests[i], (int)g_ncores);
		record_telemetry_phase(&telemetry, "c", (int)i, "singlecore");
		real_single[i] = run_test(&tests[i], 1);
		printf(" %12.1f  %-11s %7.2fs\n",
		       display_metric(&tests[i], &real_multi[i]), tests[i].unit,
		       real_multi[i].seconds);
		if (verbose)
			printf("  %-24s   %s\n"
			       "  %-24s   1-core: %.1f %s   %ld-core: %.1f %s\n",
			       "", tests[i].detail, "",
			       display_metric(&tests[i], &real_single[i]), tests[i].unit,
			       g_ncores, display_metric(&tests[i], &real_multi[i]), tests[i].unit);
	}

	printf("  --------------------------------------------------------------------------\n");
	stop_telemetry_monitor(&telemetry, telemetry_started);

	duration_ms = (uint64_t)((now_seconds() - benchmark_started) * 1000.0);
	printf("  %-24s %41.2fs\n", "TOTAL DURATION", (double)duration_ms / 1000.0);
	printf("\n");

	teardown();

	{
		int do_upload;

		if (upload_mode == 1) {
			do_upload = 1;
		} else if (upload_mode == 2) {
			do_upload = 0;
			printf("  Result was not uploaded.\n");
		} else {
			char answer[16];
			printf("  Upload this result to %s? [y/N] ", FB_API_BASE_URL);
			fflush(stdout);
			do_upload = fgets(answer, sizeof(answer), stdin) &&
				    (answer[0] == 'y' || answer[0] == 'Y');
			if (!do_upload)
				printf("  Result was not uploaded.\n");
		}

		if (do_upload) {
#if defined(FB_NO_UPLOAD)
			fprintf(stderr, "  Upload support is disabled in this build.\n");
#else
			upload_results(&system_info, raw_multi, raw_single,
				       real_multi, real_single, duration_ms, &background,
				       &telemetry);
#endif
		}
	}
	return 0;
}
