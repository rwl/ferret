#include "internal.h"
#include "store.h"

int frjs_dir_exists(Store *store, const char* fname) {
	return store->exists(store, fname);
}
