#ifndef __FERRET_H_
#define __FERRET_H_

#include "internal.h"
#include "index.h"

/* Index */
extern void frjs_init(void);

extern IndexWriter* frjs_iw_init(bool create, bool create_if_missing,
Store *store, Analyzer *analyzer, FieldInfos *fis);

/* Analysis */
extern Analyzer* frjs_standard_analyzer_init(bool lower, char **stop_words);

/* Store */
extern Store* frjs_ramdir_init(Store *store);
extern int frjs_dir_exists(Store *store, const char* fname);

extern void frjs_doc_set_boost(Document *doc, float boost);

extern void frjs_df_set_boost(DocField *df, float boost);

extern void frjs_df_set_destroy_data(DocField *df, bool destroy_data);

#endif
