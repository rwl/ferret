
#include "internal.h"
#include "index.h"

int
frjs_lzd_size(LazyDoc *lazy_doc) {
        return lazy_doc->size;
}

LazyDocField *
frjs_lzd_field(LazyDoc *lazy_doc, int i) {
        if (i < 0) {
                i += lazy_doc->size;
        }
        if (i >= 0 && i < lazy_doc->size) {
                return lazy_doc->fields[i];
        }
        return NULL;
}

const char*
frjs_lzd_field_name(LazyDocField *df) {
        return S(df->name);
}

int
frjs_lzd_field_size(LazyDocField *df) {
        return df->size;
}

int
frjs_lzd_field_length(LazyDocField *df) {
        return df->len;
}

int
frjs_lzd_field_data_length(LazyDocField *df, int i) {
        return df->data[i].length;
}
