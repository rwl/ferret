#include "global.h"

void frjs_init(void) {
	const char * const progname[] = { "dart" };
	frt_init(1, progname);
}
