
#include "internal.h"
#include "search.h"
#include "array.h"

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
    Query *rq = searcher->rewrite(searcher, q);
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
    Query *q = fq_new(query, filter);
    REF(query);
    REF(filter);
    return q;
}

void
frjs_spq_set_max_terms(SpanPrefixQuery *q, int max_terms) {
    q->max_terms = max_terms;
}

char *
frjs_f_to_s(Filter *f) {
    return f->to_s(f);
}

bool
frjs_sf_is_reverse(SortField *sf) {
    return sf->reverse;
}

const char *
frjs_sf_get_name(SortField *sf) {
    return sf->field ? S(sf->field) : NULL;
}

int
frjs_sf_get_type(SortField *sf) {
    return (int) sf->type;
}

SortField *
frjs_sort_field_doc() {
    return (SortField *) &SORT_FIELD_DOC;
}

SortField *
frjs_sort_field_score() {
    return (SortField *) &SORT_FIELD_SCORE;
}

SortField *
frjs_sort_field_doc_rev() {
    return (SortField *) &SORT_FIELD_DOC_REV;
}

SortField *
frjs_sort_field_score_rev() {
    return (SortField *) &SORT_FIELD_SCORE_REV;
}

void
frjs_sort_field_reverse(SortField *sf) {
    sf->reverse = !sf->reverse;
}

void
frjs_sort_set_destroy_all(Sort *sort, bool val) {
    sort->destroy_all = val;
}

int
frjs_sort_get_size(Sort *sort) {
    return sort->size;
}

SortField *
frjs_sort_get_sort_field(Sort *sort, int index) {
    return sort->sort_fields[index];
}

void
frjs_searcher_set_close_ir(IndexSearcher *sea, bool val) {
    sea->close_ir = val;
}

void
frjs_sea_close(Searcher *sea) {
    sea->close(sea);
}

IndexReader *
frjs_sea_get_reader(IndexSearcher *sea) {
    return sea->ir;
}

int
frjs_sea_doc_freq(Searcher *sea, char *field, char *term) {
    return sea->doc_freq(sea, I(field), term);
}

LazyDoc *
frjs_sea_doc(Searcher *sea, int doc_id) {
    return sea->get_lazy_doc(sea, doc_id);
}

int
frjs_sea_max_doc(Searcher *sea) {
    return sea->max_doc(sea);
}

TopDocs *
frjs_sea_search(Searcher *sea, Query *query, int offset, int limit,
        Filter *filter, Sort *sort) {
    PostFilter *post_filter = NULL;
    return sea->search(sea, query, offset, limit, filter, sort, post_filter, 0);
}

int
frjs_td_get_size(TopDocs *td) {
    return td->size;
}

Hit *
frjs_td_get_hit(TopDocs *td, int i) {
    return td->hits[i];
}

int
frjs_td_get_total_hits(TopDocs *td) {
    return td->total_hits;
}

int
frjs_hit_get_doc(Hit *hit) {
    return hit->doc;
}

float
frjs_hit_get_score(Hit *hit) {
    return hit->score;
}

float
frjs_td_get_max_score(TopDocs *td) {
    return td->max_score;
}

float
frjs_expl_get_score(Explanation *expl) {
    return expl->value;
}

int *
frjs_sea_scan(Searcher *sea, Query *q, int start_doc, int limit, int *count) {
    int *doc_array = ALLOC_N(int, limit);
    *count = searcher_search_unscored(sea, q, doc_array, limit, start_doc);
    return doc_array;
}

Explanation *
frjs_sea_explain(Searcher *sea, Query *query, int doc_id) {
    return sea->explain(sea, query, doc_id);
}

char **
frjs_sea_highlight(Searcher *sea,
        Query *query,
        const int doc_num,
        char *field,
        const int excerpt_len,
        const int num_excerpts,
        const char *pre_tag,
        const char *post_tag,
        const char *ellipsis,
        int *size) {
    char **excerpts;
    if ((excerpts = searcher_highlight(sea, query, doc_num, I(field),
            excerpt_len, num_excerpts, pre_tag, post_tag,
            ellipsis)) != NULL) {
        *size = ary_size(excerpts);
        return excerpts;
    }
    return NULL;
}
