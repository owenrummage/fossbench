#include <stdio.h>
#include <string.h>

#include "app/benchmark.h"

int main(int argc, char **argv)
{
	int verbose = 0;
	int upload_mode = 0;
	int system_check = 1;
	int i;

	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "--verbose") == 0) {
			verbose = 1;
		} else if (strcmp(argv[i], "--upload") == 0) {
			if (upload_mode == 2) {
				fprintf(stderr, "fossbench: --upload conflicts with --noupload\n");
				return 1;
			}
			upload_mode = 1;
		} else if (strcmp(argv[i], "--noupload") == 0) {
			if (upload_mode == 1) {
				fprintf(stderr, "fossbench: --noupload conflicts with --upload\n");
				return 1;
			}
			upload_mode = 2;
		} else if (strcmp(argv[i], "--no-system-check") == 0) {
			system_check = 0;
		} else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
			printf("usage: %s [-v|--verbose] [--upload|--noupload] [--no-system-check]\n", argv[0]);
			return 0;
		} else {
			fprintf(stderr, "fossbench: unknown option '%s'\n", argv[i]);
			return 1;
		}
	}

	return fossbench_run(verbose, upload_mode, system_check);
}
