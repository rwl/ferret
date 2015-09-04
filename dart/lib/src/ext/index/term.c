// #include "../ferret.h"
#include "internal.h"
#include "index.h"

bool
frjs_tde_next(TermDocEnum *tde) {
	return tde->next(tde);
}

const char *
frjs_tv_get_field(TermVector *tv) {
	return S(tv->field);
}

TVTerm *
frjs_tv_get_term(TermVector *tv, int i) {
	TVTerm *terms = tv->terms;
	return &terms[i];
}

int
frjs_tv_get_term_cnt(TermVector *tv) {
	return tv->term_cnt;
}

char *
frjs_tvt_get_text(TVTerm *tv_term) {
	return tv_term->text;
}

int
frjs_tvt_get_freq(TVTerm *tv_term) {
	return tv_term->freq;
}

int
frjs_tvt_get_position(TVTerm *tv_term, int i) {
	int *positions = tv_term->positions;
	return positions[i];
}

int
frjs_tv_get_offset_cnt(TermVector *tv) {
	return tv->offset_cnt;
}

Offset *
frjs_tv_get_offset(TermVector *tv, int i) {
	Offset *offsets = tv->offsets;
	return &offsets[i];
}

u64
frjs_tv_offset_get_start(Offset *offset) {
	return (u64) offset->start;
}

u64
frjs_tv_offset_get_end(Offset *offset) {
	return (u64) offset->end;
}
