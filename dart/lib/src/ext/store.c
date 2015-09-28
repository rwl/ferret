#include "internal.h"
#include "store.h"

int
frjs_dir_exists(Store *store, const char* fname) {
	return store->exists(store, fname);
}

void
frjs_dir_touch(Store *store, const char* fname) {
    store->touch(store, fname);
}

bool
frjs_dir_delete(Store *store, const char* fname) {
    return store->remove(store, fname) == 0;
}

int
frjs_dir_file_count(Store *store) {
    return store->count(store);
}

void
frjs_dir_refresh(Store *store) {
    store->clear_all(store);
}

void
frjs_dir_rename(Store *store, const char* from, const char* to) {
    store->rename(store, from, to);
}

bool
frjs_lock_obtain(Lock *lock) {
    return lock->obtain(lock) != 0;
}

char *
frjs_lock_get_name(Lock *lock) {
    return lock->name;
}

void
frjs_lock_release(Lock *lock) {
    lock->release(lock);
}

bool
frjs_lock_is_locked(Lock *lock) {
    return lock->is_locked(lock) != 0;
}
