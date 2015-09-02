#include <locale.h>

#include "ferret.h"
#include "internal.h"
#include "index.h"

static char *frb_locale = NULL;

Analyzer *
frjs_standard_analyzer_init(bool lower, char **stop_words) {
	Analyzer *a;
//#ifndef POSH_OS_WIN32
	if (!frb_locale) {
		frb_locale = setlocale(LC_CTYPE, "");
	}
//#endif
	if (stop_words != NULL) {
		a = mb_standard_analyzer_new_with_words((const char **) stop_words,
				lower);
	} else {
		a = mb_standard_analyzer_new(lower);
	}
	return a;
}
