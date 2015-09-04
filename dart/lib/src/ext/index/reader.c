// #include "../ferret.h"
#include "internal.h"
#include "index.h"
// #include "symbol.h"

int
frjs_ir_num_docs(IndexReader *ir) {
	return ir->num_docs(ir);
}

bool
frjs_ir_is_deleted(IndexReader *ir, int doc_id) {
	return ir->is_deleted(ir, doc_id);
}

LazyDoc *
frjs_ir_get_lazy_doc(IndexReader *ir, int pos) {
	return ir->get_lazy_doc(ir, pos);
}

int
frjs_ir_max_doc(IndexReader *ir) {
	return ir->max_doc(ir);
}

bool
frjs_ir_has_deletions(IndexReader *ir) {
	return ir->has_deletions(ir);
}

TermVector *
frjs_ir_term_vector(IndexReader *ir, int doc_id, char* field) {
	return ir->term_vector(ir, doc_id, I(field));
}