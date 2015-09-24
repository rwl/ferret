
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
