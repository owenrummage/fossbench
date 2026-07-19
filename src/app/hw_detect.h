#ifndef FOSSBENCH_HW_DETECT_H
#define FOSSBENCH_HW_DETECT_H

struct system_info {
	char cpu[256];
	char model[256];
	char operating_system[256];
	char compiler[128];
	char kernel[128];
	long cpu_cores;
	long cpu_threads;
	long memory_mb;
};

const char *hw_arch_name(void);
void hw_detect_system(struct system_info *info);

#endif
