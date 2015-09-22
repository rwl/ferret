
#include "internal.h"
#include "search.h"

QParser *
frjs_qp_init(Analyzer *analyzer, HashSet *all_fields, HashSet *tkz_fields,
        HashSet *def_fields, bool handle_parse_errors, bool validate_fields,
        bool wild_card_downcase, bool or_default, int default_slop,
        bool clean_string, int max_clauses, bool use_keywords,
        bool use_typed_range_query) {
    QParser *qp;
    if (all_fields == NULL) {
        all_fields = hs_new_ptr(NULL);
    }

    if (!analyzer) {
        analyzer = mb_standard_analyzer_new(true);
    }

    qp = qp_new(analyzer);
    hs_destroy(qp->all_fields);
    hs_destroy(qp->def_fields);
    //hs_destroy(qp->tokenized_fields);

    if (def_fields) {
        hs_safe_merge(all_fields, def_fields);
    }
    if (tkz_fields) {
        hs_safe_merge(all_fields, tkz_fields);
    }
    qp->all_fields = all_fields;
    qp->def_fields = def_fields ? def_fields : all_fields;
    qp->tokenized_fields = tkz_fields ? tkz_fields : all_fields;
    qp->fields_top->fields = def_fields;

    qp->handle_parse_errors = handle_parse_errors;
    qp->allow_any_fields = !validate_fields;
    qp->wild_lower = wild_card_downcase;
    qp->or_default = or_default;
    qp->def_slop = default_slop;
    qp->clean_str = clean_string;
    qp->max_clauses = max_clauses;
    qp->use_keywords = use_keywords;
    qp->use_typed_range_query = use_typed_range_query;

    return qp;
}

Query *
frjs_qp_parse(QParser *qp, char *str, char **msg) {
    Query *q;
    TRY
        q = frb_get_q(qp_parse(qp, str));
        break;
    default:
        *msg = xcontext.msg;
        HANDLED();
        q = NULL;
    XENDTRY

    return q;
}

QueryType *
frjs_q_get_query_type(Query *q) {
    return q->type;
}

HashSet *
frjs_qp_all_fields(QParser *qp) {
    return qp->all_fields;
}

HashSet *
frjs_qp_tokenized_fields(QParser *qp) {
    return qp->tokenized_fields;
}

void
frjs_qp_set_fields(QParser *qp, HashSet *fields) {
    /* if def_fields == all_fields then we need to replace both */
    if (qp->def_fields == qp->all_fields) {
        qp->def_fields = NULL;
    }
    if (qp->tokenized_fields == qp->all_fields) {
        qp->tokenized_fields = NULL;
    }

    if (fields == NULL) {
        fields = hs_new_ptr(NULL);
    }

    /* make sure all the fields in tokenized fields are contained in
     * all_fields */
    if (qp->tokenized_fields) {
        hs_safe_merge(fields, qp->tokenized_fields);
    }

    /* delete old fields set */
    assert(qp->all_fields->free_elem_i == dummy_free);
    hs_destroy(qp->all_fields);

    /* add the new fields set and add to def_fields if necessary */
    qp->all_fields = fields;
    if (qp->def_fields == NULL) {
        qp->def_fields = fields;
        qp->fields_top->fields = fields;
    }
    if (qp->tokenized_fields == NULL) {
        qp->tokenized_fields = fields;
    }
}

void
frjs_qp_set_tkz_fields(QParser *qp, HashSet *fields) {
    if (qp->tokenized_fields != qp->all_fields) {
        hs_destroy(qp->tokenized_fields);
    }
    qp->tokenized_fields = fields;
}
