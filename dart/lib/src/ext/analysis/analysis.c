#include <locale.h>

#include "internal.h"
#include "analysis.h"

static char *frb_locale = NULL;

char *
frjs_tk_get_text(Token *tk) {
	return tk->text;
}

off_t
frjs_tk_get_start(Token *tk) {
	return tk->start;
}

off_t
frjs_tk_get_end(Token *tk) {
	return tk->end;
}

int
frjs_tk_get_pos_inc(Token *tk) {
	return tk->pos_inc;
}

Token *
frjs_ts_next(TokenStream *ts) {
	return ts->next(ts);
}

void
frjs_ts_set_text(TokenStream *ts, char *text) {
	ts->reset(ts, text);
}

char *
frjs_ts_get_text(TokenStream *ts) {
	return ts->text;
}

TokenStream *
frjs_analyzer_token_stream(Analyzer *a, char *field, char *text) {
	TokenStream *ts = a_get_ts(a, I(field), text);
	/* Make sure that there is no entry already */
	//ts->text = text;
	return ts;
}

Analyzer *
frjs_standard_analyzer_init(bool lower, char **stop_words) {
	Analyzer *a;
#ifndef POSH_OS_WIN32
	if (!frb_locale) {
		frb_locale = setlocale(LC_CTYPE, "");
	}
#endif
	if (stop_words != NULL) {
		a = mb_standard_analyzer_new_with_words((const char **) stop_words,
				lower);
	} else {
		a = mb_standard_analyzer_new(lower);
	}
	return a;
}

Analyzer *
frjs_letter_analyzer_init(bool lower) {
#ifndef POSH_OS_WIN32
	if (!frb_locale) {
		frb_locale = setlocale(LC_CTYPE, "");
	}
#endif
	return mb_letter_analyzer_new(lower);
}

TokenStream *
frjs_letter_tokenizer_init(bool lower) {
#ifndef POSH_OS_WIN32
	if (!frb_locale) {
		frb_locale = setlocale(LC_CTYPE, "");
	}
#endif
	return mb_letter_tokenizer_new(lower);
}

TokenStream *
frjs_whitespace_tokenizer_init(bool lower) {
#ifndef POSH_OS_WIN32
	if (!frb_locale) {
		frb_locale = setlocale(LC_CTYPE, "");
	}
#endif
	return mb_whitespace_tokenizer_new(lower);
}

TokenStream *
frjs_standard_tokenizer_init() {
#ifndef POSH_OS_WIN32
	if (!frb_locale) {
		frb_locale = setlocale(LC_CTYPE, "");
	}
#endif
	return mb_standard_tokenizer_new();
}

Analyzer *
frjs_white_space_analyzer_init(bool lower) {
#ifndef POSH_OS_WIN32
	if (!frb_locale) {
		frb_locale = setlocale(LC_CTYPE, "");
	}
#endif
	return mb_whitespace_analyzer_new(lower);
}

Analyzer *
frjs_a_standard_analyzer_init(bool lower, char **stop_words) {
	Analyzer *a;
	if (stop_words != NULL) {
		a = standard_analyzer_new_with_words((const char **)stop_words,
			lower);
		free(stop_words);
	} else {
		a = standard_analyzer_new(lower);
	}
	return a;
}
