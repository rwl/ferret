#include "ferret.h"
#include "internal.h"
#include "store.h"

Store* frjs_ramdir_init(Store *ostore) {
	Store *store;
	if (ostore) {
		store = open_ram_store_and_copy(ostore, false);
	} else {
		store = open_ram_store();
	}
	return store;
}

int frjs_dir_exists(Store *store, const char* fname) {
	return store->exists(store, fname);
}
