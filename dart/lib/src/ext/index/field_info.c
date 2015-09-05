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

bool
frjs_fi_is_tokenized(FieldInfo *fi) {
    return fi_is_tokenized(fi);
}
