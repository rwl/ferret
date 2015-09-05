#include "internal.h"
#include "index.h"

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

Hash *
frjs_ir_term_vectors(IndexReader *ir, int doc_id) {
	return ir->term_vectors(ir, doc_id);
}

TermDocEnum *
frjs_ir_term_docs(IndexReader *ir) {
	return ir->term_docs(ir);
}

TermDocEnum *
frjs_ir_term_positions(IndexReader *ir) {
	return ir->term_positions(ir);
}

int
frjs_ir_term_count(IndexReader *ir, char *field) {
	TermEnum *te = ir_terms(ir, I(field));
	int count = 0;
	while (te->next(te)) {
		count++;
	}
	te->close(te);
	return count;
}

FieldInfos *
frjs_ir_field_infos(IndexReader *ir) {
	FieldInfos *fis = ir->fis;
	if (fis) {
		REF(fis);
	}
	return fis;
}

u64
frjs_ir_version(IndexReader *ir) {
	return ir->sis->version;
}
