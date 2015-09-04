// #include "../ferret.h"
#include "internal.h"
#include "index.h"
// #include "symbol.h"

IndexWriter *
frjs_iw_init(bool create, bool create_if_missing, Store *store,
Analyzer *analyzer, FieldInfos *fis) {
	IndexWriter *iw = NULL;
	Config config = default_config;

//    rb_scan_args(argc, argv, "01", &roptions);
	/*if (argc > 0) {
	 Check_Type(roptions, T_HASH);

	 if ((rval = rb_hash_aref(roptions, sym_dir)) != Qnil) {
	 Check_Type(rval, T_DATA);
	 store = DATA_PTR(rval);
	 } else if ((rval = rb_hash_aref(roptions, sym_path)) != Qnil) {
	 StringValue(rval);
	 frb_create_dir(rval);
	 store = open_fs_store(rs2s(rval));
	 DEREF(store);
	 }

	 // Let ruby's garbage collector handle the closing of the store
	 // if (!close_dir) {
	 // close_dir = RTEST(rb_hash_aref(roptions, sym_close_dir));
	 // }

	 // use_compound_file defaults to true
	 config.use_compound_file =
	 (rb_hash_aref(roptions, sym_use_compound_file) == Qfalse)
	 ? false
	 : true;

	 if ((rval = rb_hash_aref(roptions, sym_analyzer)) != Qnil) {
	 analyzer = frb_get_cwrapped_analyzer(rval);
	 }

	 create = RTEST(rb_hash_aref(roptions, sym_create));
	 if ((rval = rb_hash_aref(roptions, sym_create_if_missing)) != Qnil) {
	 create_if_missing = RTEST(rval);
	 }
	 SET_INT_ATTR(chunk_size);
	 SET_INT_ATTR(max_buffer_memory);
	 SET_INT_ATTR(index_interval);
	 SET_INT_ATTR(skip_interval);
	 SET_INT_ATTR(merge_factor);
	 SET_INT_ATTR(max_buffered_docs);
	 SET_INT_ATTR(max_merge_docs);
	 SET_INT_ATTR(max_field_length);
	 }*/
	if (NULL == store) {
		store = open_ram_store();
		DEREF(store);
	}
	if (!create && create_if_missing && !store->exists(store, "segments")) {
		create = true;
	}
	if (create) {
		if (fis != NULL) {
			index_create(store, fis);
		} else {
			fis = fis_new(STORE_YES, INDEX_YES,
			TERM_VECTOR_WITH_POSITIONS_OFFSETS);
			index_create(store, fis);
			fis_deref(fis);
		}
	}

	iw = iw_open(store, analyzer, &config);
	return iw;
}

/*void
frjs_iw_delete_term(IndexWriter *iw, const char* field, const char* term) {
	iw_delete_term(iw, frt_intern(field), term);
}*/

/*void
frjs_iw_delete_terms(IndexWriter *iw, const char* field, const char** terms,
const int term_cnt) {
	iw_delete_terms(iw, I(field), terms, term_cnt);
}*/

FieldInfos *
frjs_iw_field_infos(IndexWriter *iw) {
	FieldInfos *fis = iw->fis;
	REF(fis);
	return fis;
}

Analyzer *
frjs_iw_get_analyzer(IndexWriter *iw) {
	Analyzer *a = iw->analyzer;
	REF(a);
	return a;
}

void
frjs_iw_set_analyzer(IndexWriter *iw, Analyzer *a) {
	a_deref(iw->analyzer);
	iw->analyzer = a;
}

frt_u64
frjs_iw_version(IndexWriter *iw) {
	return iw->sis->version;
}

int
frjs_iw_get_chunk_size(IndexWriter *iw) {
	return iw->config.chunk_size;
}

void
frjs_iw_set_chunk_size(IndexWriter *iw, int val) {
	iw->config.chunk_size = val;
}

int
frjs_iw_get_max_buffer_memory(IndexWriter *iw) {
	return iw->config.max_buffer_memory;
}

void
frjs_iw_set_max_buffer_memory(IndexWriter *iw, int val) {
	iw->config.max_buffer_memory = val;
}

int
frjs_iw_get_index_interval(IndexWriter *iw) {
	return iw->config.index_interval;
}

void
frjs_iw_set_index_interval(IndexWriter *iw, int val) {
	iw->config.index_interval = val;
}

int
frjs_iw_get_skip_interval(IndexWriter *iw) {
	return iw->config.skip_interval;
}

void
frjs_iw_set_skip_interval(IndexWriter *iw, int val) {
    iw->config.skip_interval = val;
}

int
frjs_iw_get_merge_factor(IndexWriter *iw) {
	return iw->config.merge_factor;
}

void
frjs_iw_set_merge_factor(IndexWriter *iw, int val) {
	iw->config.merge_factor = val;
}

int
frjs_iw_get_max_buffered_docs(IndexWriter *iw) {
	return iw->config.max_buffered_docs;
}

void
frjs_iw_set_max_buffered_docs(IndexWriter *iw, int val) {
	iw->config.max_buffered_docs = val;
}

int
frjs_iw_get_max_merge_docs(IndexWriter *iw) {
	return iw->config.max_merge_docs;
}

void
frjs_iw_set_max_merge_docs(IndexWriter *iw, int val) {
	iw->config.max_merge_docs = val;
}

int
frjs_iw_get_max_field_length(IndexWriter *iw) {
	return iw->config.max_field_length;
}

void
frjs_iw_set_max_field_length(IndexWriter *iw, int val) {
	iw->config.max_field_length = val;
}

bool
frjs_iw_get_use_compound_file(IndexWriter *iw) {
	return iw->config.use_compound_file;
}

void
frjs_iw_set_use_compound_file(IndexWriter *iw, bool val) {
	iw->config.use_compound_file = val;
}
