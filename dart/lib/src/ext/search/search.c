
#include "internal.h"
#include "index.h"

char *
frjs_q_to_s(Query *q, char *field) {
    return q->to_s(q, I(field));
}

double
frjs_q_get_boost(Query *q) {
    return (double) q->boost;
}

void
frjs_q_set_boost(Query *q, double boost) {
    q->boost = (float) boost;
}

bool
frjs_q_eql(Query *q, Query *other) {
    return q->eq(q, other) ? true : false;
}

unsigned long
frjs_q_hash(Query *q) {
    return q->hash(q);
}

HashSet *
frjs_q_get_terms(Query *q, Searcher *searcher) {
    HashSet *terms = hs_new((hash_ft)&term_hash,
                            (eq_ft)&term_eq,
                            (free_ft)term_destroy);
    Query *rq = searcher->rewrite(sea, q);
    rq->extract_terms(rq, terms);
    q_deref(rq);
    return terms;
}

const char *
frjs_term_get_field(Term *term) {
    return S(term->field);
}

char *
frjs_term_get_text(Term *term) {
    return term->text;
}

BooleanClause *
frjs_bc_init(Query *sub_q, unsigned int occur) {
    REF(sub_q);
    return bc_new(sub_q, occur);
}

bool
frjs_bc_is_required(BooleanClause *bc) {
    return bc->is_required;
}

bool
frjs_bc_is_prohibited(BooleanClause *bc) {
    return bc->is_prohibited;
}

int
frjs_phq_get_slop(PhraseQuery *q) {
    return q->slop;
}

void
frjs_phq_set_slop(PhraseQuery *q, int slop) {
    q->slop = slop;
}

void
frjs_mtq_set_max_terms(Query *q, int max_terms) {
    MTQMaxTerms(q) = max_terms;
}

int
frjs_fq_pre_len(FuzzyQuery *q) {
    return q->pre_len;
}

float
frjs_fq_min_sim(FuzzyQuery *q) {
    return q->min_sim;
}

Query *
frjs_fqq_init(Query *query, Filter *filter) {
    Query *q = fq_new(query, f);
    REF(query);
    REF(filter);
    return q
}

void
frjs_spq_set_max_terms(SpanPrefixQuery *q, int max_terms) {
    q->max_terms = max_terms;
}
