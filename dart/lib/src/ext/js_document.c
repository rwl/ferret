#include "ferret.h"
#include "internal.h"
#include "store.h"

extern void frjs_doc_set_boost(Document *doc, float boost) {
	doc->boost = boost;
}

extern void frjs_df_set_boost(DocField *df, float boost) {
	df->boost = boost;
}

extern void frjs_df_set_destroy_data(DocField *df, bool destroy_data) {
	df->destroy_data = destroy_data;
}
