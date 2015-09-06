#include <sys/stat.h>

#include "internal.h"
#include "index.h"

int
frjs_fis_size(FieldInfos *fis) {
    return fis->size;
}

FieldInfo *
frjs_fis_get_field_info(FieldInfos *fis, int i) {
    if (i < 0) {
        i += fis->size;
    }
    if (i >= 0 && i < fis->size) {
        FieldInfo *fi = fis->fields[i];
        if (fi) {
            REF(fi);
        }
        return fi;
    }
    return NULL;
}

FieldInfo *
frjs_fis_get_field(FieldInfos *fis, char *name) {
    FieldInfo *fi = fis_get_field(fis, I(name));
    if (fi) {
        REF(fi);
    }
    return fi;
}

void
frjs_fis_add(FieldInfos *fis, FieldInfo *fi) {
    fis_add_field(fis, fi);
    REF(fi);
}

void
frjs_fis_add_field(FieldInfos *fis, char *name, StoreValue store,
        IndexValue index, TermVectorValue term_vector, float boost) {
    FieldInfo *fi = fi_new(I(name), store, index, term_vector);
    fi->boost = boost;
    fis_add_field(fis, fi);
}

static void _mkdir(const char *dir) {
    char tmp[4096];
    char *p = NULL;
    size_t len;

    snprintf(tmp, sizeof(tmp), "%s", dir);
    len = strlen(tmp);
    if(tmp[len - 1] == '/') {
        tmp[len - 1] = 0;
    }
    for(p = tmp + 1; *p; p++) {
        if(*p == '/') {
            *p = 0;
            mkdir(tmp, S_IRWXU);
            *p = '/';
        }
    }
    mkdir(tmp, S_IRWXU);
}

void
frjs_fis_create_index(FieldInfos *fis, Store *store, const char *dir) {
    if (store) {
        REF(store);
    } else {
        _mkdir(dir);
        store = open_fs_store(dir);
    }
    index_create(store, fis);
    store_deref(store);
}

FieldInfo *
frjs_fi_init(const char* name, StoreValue store, IndexValue index,
        TermVectorValue term_vector, float boost) {
    FieldInfo *fi = fi_new(I(name), store, index, term_vector);
    fi->boost = boost;
    return fi;
}

const char*
frjs_fi_name(FieldInfo *fi) {
    return S(fi->name);
}

bool
frjs_fi_is_stored(FieldInfo *fi) {
    return fi_is_stored(fi);
}

bool
frjs_fi_is_compressed(FieldInfo *fi) {
    return fi_is_compressed(fi);
}

bool
frjs_fi_is_indexed(FieldInfo *fi) {
    return fi_is_indexed(fi);
}

bool
frjs_fi_is_tokenized(FieldInfo *fi) {
    return fi_is_tokenized(fi);
}

bool
frjs_fi_omit_norms(FieldInfo *fi) {
    return fi_omit_norms(fi);
}

bool
frjs_fi_store_term_vector(FieldInfo *fi) {
    return fi_store_term_vector(fi);
}

bool
frjs_fi_store_positions(FieldInfo *fi) {
    return fi_store_positions(fi);
}

bool
frjs_fi_store_offsets(FieldInfo *fi) {
    return fi_store_offsets(fi);
}

bool
frjs_fi_has_norms(FieldInfo *fi) {
    return fi_has_norms(fi);
}

float
frjs_fi_boost(FieldInfo *fi) {
    return fi->boost;
}
