/* Platform-specific hardware and operating-system detection. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <ctype.h>

#include "hw_detect.h"

#if !defined(_WIN32)
#  include <sys/utsname.h>
#  include <unistd.h>
#endif
#if defined(__APPLE__)
#  include <sys/types.h>
#  include <sys/sysctl.h>
#endif
#if defined(_WIN32)
#  define WIN32_LEAN_AND_MEAN
#  ifndef _WIN32_WINNT
#    define _WIN32_WINNT 0x0601		/* GetLogicalProcessorInformationEx (Win7+). */
#  endif
#  include <windows.h>
#  if defined(__i386__) || defined(__x86_64__)
#    include <cpuid.h>
#  endif
#endif

#if defined(_WIN32)
#  define HW_OS "Windows"
#elif defined(__APPLE__)
#  define HW_OS "macOS"
#elif defined(__linux__)
#  define HW_OS "Linux"
#else
#  define HW_OS "POSIX"
#endif

#if defined(__aarch64__) || defined(__arm64__) || defined(_M_ARM64)
#  define HW_ARCH "ARM64"
#elif defined(__x86_64__) || defined(_M_X64)
#  define HW_ARCH "x86-64"
#elif defined(__i386__) || defined(_M_IX86)
#  define HW_ARCH "x86 32-bit"
#elif defined(__powerpc64__)
#  define HW_ARCH "PowerPC 64-bit big-endian"
#elif defined(__powerpc__)
#  define HW_ARCH "PowerPC 32-bit big-endian"
#else
#  define HW_ARCH "unknown"
#endif

const char *hw_arch_name(void)
{
	return HW_ARCH;
}

static void trim(char *s)
{
	char *p = s;
	size_t n;
	while (isspace((unsigned char)*p)) p++;
	if (p != s) memmove(s, p, strlen(p) + 1);
	n = strlen(s);
	while (n && isspace((unsigned char)s[n - 1])) s[--n] = '\0';
}

/* Pull a marketing name such as "Apple M3 Max" out of platform metadata. */
#if defined(__linux__) || defined(__APPLE__)
static int apple_m_name(const char *text, char *dst, size_t cap)
{
	const char *p;
	size_t n = 0;

	if (cap == 0 || text == NULL)
		return 0;
	for (p = text; *p; p++)
		if ((p == text || !isalnum((unsigned char)p[-1])) &&
		    !strncmp(p, "Apple M", 7) && isdigit((unsigned char)p[7]))
			break;
	if (!*p)
		return 0;
	while (p[n] && n + 1 < cap &&
	       (isalnum((unsigned char)p[n]) || p[n] == ' ' || p[n] == '-'))
		n++;
	while (n && (p[n - 1] == ' ' || p[n - 1] == '-')) n--;
	memcpy(dst, p, n);
	dst[n] = '\0';
	return n != 0;
}
#endif

/* Linux device trees identify Apple Silicon by its SoC code. */
#if defined(__linux__)
static int apple_m_name_from_soc(const char *text, char *dst, size_t cap)
{
	static const struct { const char *soc, *name; } chips[] = {
		{ "apple,t8103", "Apple M1" }, { "apple,t6000", "Apple M1 Pro" },
		{ "apple,t6001", "Apple M1 Max" }, { "apple,t6002", "Apple M1 Ultra" },
		{ "apple,t8112", "Apple M2" }, { "apple,t6020", "Apple M2 Pro" },
		{ "apple,t6021", "Apple M2 Max" }, { "apple,t6022", "Apple M2 Ultra" },
		{ "apple,t8122", "Apple M3" }, { "apple,t6031", "Apple M3 Pro" },
		{ "apple,t6034", "Apple M3 Max" }, { "apple,t8132", "Apple M4" },
		{ "apple,t6040", "Apple M4 Pro" }, { "apple,t6041", "Apple M4 Max" }
	};
	unsigned i;

	if (apple_m_name(text, dst, cap)) return 1;
	for (i = 0; i < sizeof chips / sizeof chips[0]; i++)
		if (strstr(text, chips[i].soc)) {
			snprintf(dst, cap, "%s", chips[i].name);
			return 1;
		}
	return 0;
}

#if defined(__linux__) && (defined(__aarch64__) || defined(__arm__))
struct arm_cpu_name { unsigned char implementer; unsigned short part; const char *name; };

/* MIDR implementer and part numbers, kept in sync with Linux cputype.h. */
static const char *arm_core_name(unsigned implementer, unsigned part)
{
	static const struct arm_cpu_name names[] = {
		{0x41,0xC05,"Arm Cortex-A5"}, {0x41,0xC07,"Arm Cortex-A7"},
		{0x41,0xC08,"Arm Cortex-A8"}, {0x41,0xC09,"Arm Cortex-A9"},
		{0x41,0xC0D,"Arm Cortex-A12"}, {0x41,0xC0E,"Arm Cortex-A17"},
		{0x41,0xC0F,"Arm Cortex-A15"}, {0x41,0xD03,"Arm Cortex-A53"},
		{0x41,0xD04,"Arm Cortex-A35"}, {0x41,0xD05,"Arm Cortex-A55"},
		{0x41,0xD07,"Arm Cortex-A57"}, {0x41,0xD08,"Arm Cortex-A72"},
		{0x41,0xD09,"Arm Cortex-A73"}, {0x41,0xD0A,"Arm Cortex-A75"},
		{0x41,0xD0B,"Arm Cortex-A76"}, {0x41,0xD0C,"Arm Neoverse N1"},
		{0x41,0xD0D,"Arm Cortex-A77"}, {0x41,0xD0E,"Arm Cortex-A76AE"},
		{0x41,0xD40,"Arm Neoverse V1"}, {0x41,0xD41,"Arm Cortex-A78"},
		{0x41,0xD42,"Arm Cortex-A78AE"}, {0x41,0xD44,"Arm Cortex-X1"},
		{0x41,0xD46,"Arm Cortex-A510"}, {0x41,0xD47,"Arm Cortex-A710"},
		{0x41,0xD48,"Arm Cortex-X2"}, {0x41,0xD49,"Arm Neoverse N2"},
		{0x41,0xD4B,"Arm Cortex-A78C"}, {0x41,0xD4C,"Arm Cortex-X1C"},
		{0x41,0xD4D,"Arm Cortex-A715"}, {0x41,0xD4E,"Arm Cortex-X3"},
		{0x41,0xD4F,"Arm Neoverse V2"}, {0x41,0xD80,"Arm Cortex-A520"},
		{0x41,0xD81,"Arm Cortex-A720"}, {0x41,0xD82,"Arm Cortex-X4"},
		{0x41,0xD83,"Arm Neoverse V3AE"}, {0x41,0xD84,"Arm Neoverse V3"},
		{0x41,0xD85,"Arm Cortex-X925"}, {0x41,0xD87,"Arm Cortex-A725"},
		{0x41,0xD89,"Arm Cortex-A720AE"}, {0x41,0xD8B,"Arm C1-Pro"},
		{0x41,0xD8C,"Arm C1-Ultra"}, {0x41,0xD8E,"Arm Neoverse N3"},
		{0x41,0xD90,"Arm C1-Premium"},
		{0x42,0x100,"Broadcom Brahma-B53"}, {0x42,0x516,"Broadcom Vulcan"},
		{0x43,0x0A1,"Cavium ThunderX"}, {0x43,0x0A2,"Cavium ThunderX 81xx"},
		{0x43,0x0A3,"Cavium ThunderX 83xx"}, {0x43,0x0AF,"Cavium ThunderX2"},
		{0x43,0x0B1,"Marvell Octeon TX2 98xx"}, {0x43,0x0B2,"Marvell Octeon TX2 96xx"},
		{0x43,0x0B3,"Marvell Octeon TX2 95xx"}, {0x43,0x0B4,"Marvell Octeon TX2 95xxN"},
		{0x43,0x0B5,"Marvell Octeon TX2 95xxMM"}, {0x43,0x0B6,"Marvell Octeon TX2 95xxO"},
		{0x46,0x001,"Fujitsu A64FX"}, {0x48,0xD01,"HiSilicon TSV110"},
		{0x48,0xD02,"HiSilicon HIP09"}, {0x48,0xD06,"HiSilicon HIP12"},
		{0x4E,0x003,"NVIDIA Denver"}, {0x4E,0x004,"NVIDIA Carmel"},
		{0x4E,0x010,"NVIDIA Olympus"}, {0x50,0x000,"APM X-Gene"},
		{0x51,0x001,"Qualcomm Oryon"}, {0x51,0x200,"Qualcomm Kryo"},
		{0x51,0x800,"Qualcomm Falkor / Kryo Gold"}, {0x51,0x801,"Qualcomm Kryo Silver"},
		{0x51,0x802,"Qualcomm Kryo 3xx Gold"}, {0x51,0x803,"Qualcomm Kryo 3xx Silver"},
		{0x51,0x804,"Qualcomm Kryo 4xx Gold"}, {0x51,0x805,"Qualcomm Kryo 4xx Silver"},
		{0x51,0xC00,"Qualcomm Falkor"},
		{0x61,0x022,"Apple M1 Icestorm"}, {0x61,0x023,"Apple M1 Firestorm"},
		{0x61,0x024,"Apple M1 Pro Icestorm"}, {0x61,0x025,"Apple M1 Pro Firestorm"},
		{0x61,0x028,"Apple M1 Max Icestorm"}, {0x61,0x029,"Apple M1 Max Firestorm"},
		{0x61,0x032,"Apple M2 Blizzard"}, {0x61,0x033,"Apple M2 Avalanche"},
		{0x61,0x034,"Apple M2 Pro Blizzard"}, {0x61,0x035,"Apple M2 Pro Avalanche"},
		{0x61,0x038,"Apple M2 Max Blizzard"}, {0x61,0x039,"Apple M2 Max Avalanche"},
		{0x6D,0xD49,"Microsoft Azure Cobalt 100"},
		{0xC0,0xAC3,"Ampere-1"}, {0xC0,0xAC4,"Ampere-1A"}
	};
	unsigned i;
	for (i = 0; i < sizeof names / sizeof names[0]; i++)
		if (names[i].implementer == implementer && names[i].part == part)
			return names[i].name;
	return NULL;
}

static const char *arm_implementer_name(unsigned implementer)
{
	switch (implementer) {
	case 0x41: return "Arm"; case 0x42: return "Broadcom";
	case 0x43: return "Cavium/Marvell"; case 0x46: return "Fujitsu";
	case 0x47: return "Google"; case 0x48: return "HiSilicon";
	case 0x4D: return "Motorola/Freescale"; case 0x4E: return "NVIDIA";
	case 0x50: return "APM"; case 0x51: return "Qualcomm";
	case 0x53: return "Samsung"; case 0x56: return "Marvell";
	case 0x61: return "Apple"; case 0x66: return "Faraday";
	case 0x69: return "Intel"; case 0x6D: return "Microsoft";
	case 0x70: return "Phytium"; case 0xC0: return "Ampere";
	default: return "Unknown ARM vendor";
	}
}

static void format_arm_cores(char *dst, size_t cap,
			     const unsigned implementers[], const unsigned parts[], int count)
{
	int i; size_t used = 0;
	if (cap == 0) return;
	dst[0] = '\0';
	for (i = 0; i < count && used + 1 < cap; i++) {
		const char *name = arm_core_name(implementers[i], parts[i]);
		int n;
		if (name)
			n = snprintf(dst + used, cap - used, "%s%s", used ? " + " : "", name);
		else
			n = snprintf(dst + used, cap - used, "%s%s (MIDR 0x%02X/0x%03X)",
				     used ? " + " : "", arm_implementer_name(implementers[i]),
				     implementers[i], parts[i]);
		if (n < 0 || (size_t)n >= cap - used) { dst[cap - 1] = '\0'; break; }
		used += (size_t)n;
	}
}

static const char *apple_m_name_from_midr(const unsigned implementers[],
					 const unsigned parts[], int count)
{
	int i, generation = 0, tier = 0;
	for (i = 0; i < count; i++) {
		if (implementers[i] != 0x61) return NULL;
		switch (parts[i]) {
		case 0x022: case 0x023: if (generation < 1) generation = 1; break;
		case 0x024: case 0x025: generation = 1; if (tier < 1) tier = 1; break;
		case 0x028: case 0x029: generation = 1; tier = 2; break;
		case 0x032: case 0x033: if (generation < 2) generation = 2; break;
		case 0x034: case 0x035: generation = 2; if (tier < 1) tier = 1; break;
		case 0x038: case 0x039: generation = 2; tier = 2; break;
		default: return NULL;
		}
	}
	if (generation == 1) return tier == 2 ? "Apple M1 Max" : tier == 1 ? "Apple M1 Pro" : "Apple M1";
	if (generation == 2) return tier == 2 ? "Apple M2 Max" : tier == 1 ? "Apple M2 Pro" : "Apple M2";
	return NULL;
}
#endif

/* Read the first device tree value. */
static int read_first_property(const char *path, char *dst, size_t cap)
{
	FILE *f;
	size_t n, i;

	if (cap == 0)
		return 0;
	f = fopen(path, "rb");
	if (f == NULL)
		return 0;
	n = fread(dst, 1, cap - 1, f);
	fclose(f);
	for (i = 0; i < n; i++)
		if ((unsigned char)dst[i] < 0x20)
			dst[i] = ' ';
	dst[n] = '\0';
	trim(dst);
	return dst[0] != '\0';
}
#endif

#if defined(_WIN32)
/* Count physical cores. Windows only exposes logical processors through
 * GetSystemInfo, so with SMT/HyperThreading every count was wrong (an 8-core /
 * 16-thread part reported 16 cores). Each RelationProcessorCore record returned
 * by GetLogicalProcessorInformationEx describes exactly one physical core. */
static long win_physical_cores(void)
{
	DWORD length = 0;
	BYTE *buffer, *p;
	long cores = 0;

	if (GetLogicalProcessorInformationEx(RelationProcessorCore, NULL, &length))
		return 0;
	if (GetLastError() != ERROR_INSUFFICIENT_BUFFER || length == 0)
		return 0;
	buffer = malloc(length);
	if (buffer == NULL)
		return 0;
	if (GetLogicalProcessorInformationEx(RelationProcessorCore,
			(PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX)buffer, &length)) {
		for (p = buffer; p < buffer + length; ) {
			PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX record =
				(PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX)p;
			if (record->Size == 0)
				break;			/* Guard against a malformed run. */
			if (record->Relationship == RelationProcessorCore)
				cores++;
			p += record->Size;
		}
	}
	free(buffer);
	return cores;
}
#endif

#if defined(__linux__)
/* Count physical cores from sysfs topology. PowerPC (and some ARM) kernels omit
 * the "physical id" / "core id" fields from /proc/cpuinfo, so those hosts fell
 * back to the thread count (a POWER8 with SMT8 reported 176 cores instead of
 * 22). Every thread of a physical core shares one thread-sibling group, and the
 * lowest thread id in that group uniquely identifies the core -- counting the
 * distinct groups is correct with SMT, without it, and across clusters whose
 * core_id numbering restarts (e.g. Apple Silicon under Asahi). */
static long linux_topology_cores(long max_threads)
{
	long seen[4096];
	int nseen = 0;
	long cpu, cores = 0;

	for (cpu = 0; cpu < max_threads && cpu < 4096; cpu++) {
		char path[192], value[256];
		long first;
		int i, duplicate = 0;

		snprintf(path, sizeof path,
			 "/sys/devices/system/cpu/cpu%ld/topology/thread_siblings_list", cpu);
		if (!read_first_property(path, value, sizeof value)) {
			snprintf(path, sizeof path,
				 "/sys/devices/system/cpu/cpu%ld/topology/core_cpus_list", cpu);
			if (!read_first_property(path, value, sizeof value))
				continue;
		}
		first = strtol(value, NULL, 0);	/* Lowest thread id of this core. */
		for (i = 0; i < nseen; i++)
			if (seen[i] == first) {
				duplicate = 1;
				break;
			}
		if (!duplicate && nseen < 4096) {
			seen[nseen++] = first;
			cores++;
		}
	}
	return cores;
}
#endif

void hw_detect_system(struct system_info *info)
{
	long detected_threads;
#if defined(__linux__)
	char cpuinfo_hardware[sizeof info->model] = "";
	char apple_soc[sizeof info->cpu] = "";
#if defined(__aarch64__) || defined(__arm__)
	unsigned arm_implementers[32], arm_parts[32], arm_implementer = 0;
	int arm_core_count = 0;
#endif
#endif
#if defined(_WIN32)
	{
		SYSTEM_INFO si;
		GetSystemInfo(&si);
		detected_threads = (long)si.dwNumberOfProcessors;
	}
#else
	detected_threads = sysconf(_SC_NPROCESSORS_ONLN);
#endif
	if (detected_threads < 1) detected_threads = 1;
	memset(info, 0, sizeof(*info));
	info->cpu_threads = detected_threads;
	info->cpu_cores = detected_threads;
	strncpy(info->cpu, HW_ARCH, sizeof(info->cpu) - 1);
	strncpy(info->operating_system, HW_OS, sizeof(info->operating_system) - 1);
#if defined(__clang__)
	snprintf(info->compiler, sizeof(info->compiler), "Clang %s", __clang_version__);
#elif defined(__GNUC__)
	snprintf(info->compiler, sizeof(info->compiler), "GCC %s", __VERSION__);
#elif defined(_MSC_VER)
	snprintf(info->compiler, sizeof(info->compiler), "MSVC %d", _MSC_VER);
#else
	strncpy(info->compiler, "Unknown", sizeof(info->compiler) - 1);
#endif

#if defined(__linux__)
	{
		struct utsname u;
		if (uname(&u) == 0)
			snprintf(info->kernel, sizeof(info->kernel), "%.62s %.64s", u.sysname, u.release);
	}
	{
		static const char *const model_paths[] = {
			"/sys/firmware/devicetree/base/compatible",
			"/sys/firmware/devicetree/base/model",
			"/proc/device-tree/compatible"
		};
		unsigned i;
		for (i = 0; i < sizeof model_paths / sizeof model_paths[0]; i++)
			if (read_first_property(model_paths[i], info->model,
						 sizeof info->model)) {
				apple_m_name_from_soc(info->model, apple_soc, sizeof apple_soc);
				break;
			}
	}
	{
		static const char *const soc_paths[] = {
			"/sys/devices/soc0/family", "/sys/devices/soc0/machine",
			"/sys/firmware/devicetree/base/compatible",
			"/proc/device-tree/compatible"
		};
		char value[512]; unsigned i;
		for (i = 0; !apple_soc[0] && i < sizeof soc_paths / sizeof soc_paths[0]; i++)
			if (read_first_property(soc_paths[i], value, sizeof value))
				apple_m_name_from_soc(value, apple_soc, sizeof apple_soc);
	}
	{
		FILE *f = fopen("/proc/cpuinfo", "r");
		char line[512];
		int pairs[1024][2], npairs = 0, physical = -1, core = -1;
		if (f) {
			while (fgets(line, sizeof(line), f)) {
				char *colon = strchr(line, ':');
				if (!colon) continue;
				*colon++ = '\0'; trim(line); trim(colon);
#if defined(__aarch64__) || defined(__arm__)
				if (!strcmp(line, "CPU implementer")) {
					arm_implementer = (unsigned)strtoul(colon, NULL, 0);
					continue;
				} else if (!strcmp(line, "CPU part")) {
					unsigned part = (unsigned)strtoul(colon, NULL, 0);
					int i, seen = 0;
					for (i = 0; i < arm_core_count; i++)
						if (arm_implementers[i] == arm_implementer && arm_parts[i] == part)
							seen = 1;
					if (!seen && arm_implementer && arm_core_count < 32) {
						arm_implementers[arm_core_count] = arm_implementer;
						arm_parts[arm_core_count++] = part;
					}
					continue;
				}
#endif
				if ((!strcmp(line, "model name") || !strcmp(line, "Processor") ||
				     !strcmp(line, "cpu")) && info->cpu[0] && !strcmp(info->cpu, HW_ARCH))
					strncpy(info->cpu, colon, sizeof(info->cpu) - 1);
				else if (!strcmp(line, "Hardware") && cpuinfo_hardware[0] == '\0')
					strncpy(cpuinfo_hardware, colon, sizeof cpuinfo_hardware - 1);
				else if (!strcmp(line, "physical id")) physical = atoi(colon);
				else if (!strcmp(line, "core id")) core = atoi(colon);
				if (physical >= 0 && core >= 0) {
					int i, seen = 0;
					for (i = 0; i < npairs; i++)
						if (pairs[i][0] == physical && pairs[i][1] == core) seen = 1;
					if (!seen && npairs < 1024) { pairs[npairs][0] = physical; pairs[npairs++][1] = core; }
					physical = core = -1;
				}
			}
			fclose(f);
			if (npairs > 0) info->cpu_cores = npairs;
		}
	}
	/* When /proc/cpuinfo did not distinguish cores from threads (PowerPC, ARM),
	 * recover the physical core count from sysfs topology. */
	if (info->cpu_cores == info->cpu_threads) {
		long cores = linux_topology_cores(info->cpu_threads);
		if (cores > 0)
			info->cpu_cores = cores;
	}
	if (apple_soc[0])
		snprintf(info->cpu, sizeof info->cpu, "%s", apple_soc);
#if defined(__aarch64__) || defined(__arm__)
	else {
		/* Some kernels expose MIDR only through sysfs, not /proc/cpuinfo. */
		if (arm_core_count == 0) {
			long cpu;
			for (cpu = 0; cpu < info->cpu_threads && cpu < 4096; cpu++) {
				char path[128], value[64]; unsigned long midr;
				int i, seen = 0;
				snprintf(path, sizeof path,
					 "/sys/devices/system/cpu/cpu%ld/regs/identification/midr_el1", cpu);
				if (!read_first_property(path, value, sizeof value)) continue;
				midr = strtoul(value, NULL, 0);
				for (i = 0; i < arm_core_count; i++)
					if (arm_implementers[i] == ((midr >> 24) & 0xff) &&
					    arm_parts[i] == ((midr >> 4) & 0xfff)) seen = 1;
				if (!seen && arm_core_count < 32) {
					arm_implementers[arm_core_count] = (unsigned)((midr >> 24) & 0xff);
					arm_parts[arm_core_count++] = (unsigned)((midr >> 4) & 0xfff);
				}
			}
		}
		if (arm_core_count > 0) {
			const char *apple_name = apple_m_name_from_midr(
				arm_implementers, arm_parts, arm_core_count);
			if (apple_name)
				snprintf(info->cpu, sizeof info->cpu, "%s", apple_name);
			else
				format_arm_cores(info->cpu, sizeof info->cpu,
						 arm_implementers, arm_parts, arm_core_count);
		}
	}
#endif
	/* Try the system files if CPU info is missing. */
#if defined(__aarch64__) || defined(__arm__)
	if (info->model[0] == '\0')
		read_first_property("/sys/class/dmi/id/product_name", info->model,
				    sizeof info->model);
#endif
	if (info->model[0] == '\0' && cpuinfo_hardware[0] != '\0')
		snprintf(info->model, sizeof info->model, "%s", cpuinfo_hardware);
	{
		FILE *f = fopen("/proc/meminfo", "r");
		char line[256]; long kb;
		if (f) {
			while (fgets(line, sizeof(line), f)) {
				if (sscanf(line, "MemTotal: %ld kB", &kb) == 1) {
					info->memory_mb = kb / 1024;
					break;
				}
			}
			fclose(f);
		}
	}
	{
		FILE *f = fopen("/etc/os-release", "r"); char line[512];
		if (f) { while (fgets(line, sizeof(line), f)) if (!strncmp(line, "PRETTY_NAME=", 12)) {
			char *v = line + 12; trim(v);
			if (v[0] == '\"') { memmove(v, v + 1, strlen(v)); if (strlen(v) && v[strlen(v)-1] == '\"') v[strlen(v)-1] = '\0'; }
			snprintf(info->operating_system, sizeof(info->operating_system), "%s", v); break;
		} fclose(f); }
	}
#elif defined(__APPLE__)
	{
		size_t n = sizeof(info->cpu); uint64_t mem = 0; size_t mn = sizeof(mem);
		size_t model_n = sizeof(info->model);
		int cores = 0; size_t cn = sizeof(cores);
		char brand[sizeof info->cpu] = "";
		if (sysctlbyname("machdep.cpu.brand_string", brand, &n, NULL, 0) == 0 && brand[0])
			snprintf(info->cpu, sizeof info->cpu, "%s", brand);
		else {
			uint32_t family = 0; size_t fn = sizeof family;
			const char *name = NULL;
			if (sysctlbyname("hw.cpufamily", &family, &fn, NULL, 0) == 0) {
				switch (family) {
				case 0x1b588bb3u: name = "Apple M1"; break;
				case 0xda33d83du: name = "Apple M2"; break;
				case 0x8765edeau: name = "Apple M3"; break;
				case 0x17d5b93au: name = "Apple M4"; break;
				}
			}
#if defined(__aarch64__) || defined(__arm64__) || defined(_M_ARM64)
			if (name == NULL) name = "Apple M-series";
#endif
			if (name != NULL) snprintf(info->cpu, sizeof info->cpu, "%s", name);
		}
		sysctlbyname("hw.model", info->model, &model_n, NULL, 0);
		if (sysctlbyname("hw.physicalcpu", &cores, &cn, NULL, 0) == 0) info->cpu_cores = cores;
		if (sysctlbyname("hw.memsize", &mem, &mn, NULL, 0) == 0) info->memory_mb = (long)(mem / 1024 / 1024);
	}
	{
		char product[64] = ""; size_t pn = sizeof(product);
		struct utsname u;
		if (sysctlbyname("kern.osproductversion", product, &pn, NULL, 0) == 0)
			snprintf(info->operating_system, sizeof(info->operating_system), "macOS %s", product);
		if (uname(&u) == 0)
			snprintf(info->kernel, sizeof(info->kernel), "%.62s %.64s", u.sysname, u.release);
	}
#elif defined(_WIN32)
	{
		HKEY key;
		char brand[sizeof info->cpu] = "";
		DWORD type = 0, bytes = sizeof brand;
		if (RegOpenKeyExA(HKEY_LOCAL_MACHINE,
			    "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0", 0,
			    KEY_QUERY_VALUE, &key) == ERROR_SUCCESS) {
			if (RegQueryValueExA(key, "ProcessorNameString", NULL, &type,
					     (BYTE *)brand, &bytes) == ERROR_SUCCESS &&
			    (type == REG_SZ || type == REG_EXPAND_SZ)) {
				brand[sizeof brand - 1] = '\0'; trim(brand);
				if (brand[0]) snprintf(info->cpu, sizeof info->cpu, "%s", brand);
			}
			RegCloseKey(key);
		}
	}
	{
		long cores = win_physical_cores();
		if (cores > 0)
			info->cpu_cores = cores;
	}
	{
		MEMORYSTATUSEX ms;
		ms.dwLength = sizeof(ms);
		if (GlobalMemoryStatusEx(&ms))
			info->memory_mb = (long)(ms.ullTotalPhys / 1024 / 1024);
	}
	{
		OSVERSIONINFOEXA version;
		typedef LONG (WINAPI *rtl_get_version_fn)(OSVERSIONINFOEXA *);
		rtl_get_version_fn rtl_get_version = (rtl_get_version_fn)(void *)
			GetProcAddress(GetModuleHandleA("ntdll.dll"), "RtlGetVersion");
		memset(&version, 0, sizeof(version)); version.dwOSVersionInfoSize = sizeof(version);
		if (rtl_get_version && rtl_get_version(&version) == 0) {
			snprintf(info->operating_system, sizeof(info->operating_system),
				 "Windows %lu.%lu (build %lu)", (unsigned long)version.dwMajorVersion,
				 (unsigned long)version.dwMinorVersion, (unsigned long)version.dwBuildNumber);
			snprintf(info->kernel, sizeof(info->kernel), "NT %lu.%lu build %lu",
				 (unsigned long)version.dwMajorVersion, (unsigned long)version.dwMinorVersion,
				 (unsigned long)version.dwBuildNumber);
		}
	}
#if defined(__i386__) || defined(__x86_64__)
	{
		/* Read the CPU name from CPUID. */
		unsigned eax, ebx, ecx, edx, max_ext;
		char brand[49];
		int i;
		__cpuid(0x80000000, eax, ebx, ecx, edx);
		max_ext = eax;
		if (max_ext >= 0x80000004) {
			for (i = 0; i < 3; i++) {
				__cpuid(0x80000002u + (unsigned)i, eax, ebx, ecx, edx);
				memcpy(brand + i * 16 + 0,  &eax, 4);
				memcpy(brand + i * 16 + 4,  &ebx, 4);
				memcpy(brand + i * 16 + 8,  &ecx, 4);
				memcpy(brand + i * 16 + 12, &edx, 4);
			}
			brand[48] = '\0';
			trim(brand);
			/* Prefer the registry name, which also works under ARM64 emulation. */
			if (brand[0] && !strcmp(info->cpu, HW_ARCH))
				snprintf(info->cpu, sizeof(info->cpu), "%s", brand);
		}
	}
#endif
#endif
}
