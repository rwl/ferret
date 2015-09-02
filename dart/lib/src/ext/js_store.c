
#include <stdint.h>

#include "ferret.h"
#include "internal.h"
#include "store.h"

/*static char*
fjs_te_next(uintptr_t handle)
{
    TermEnum *te = (TermEnum *) handle;
    return te->next(te);
}*/

uintptr_t
frjs_ramdir_init(uintptr_t hstore)
{
    Store *store;
    if (hstore) {
        Store *ostore = (Store *) hstore;
        store = open_ram_store_and_copy(ostore, false);
    } else {
        store = open_ram_store();
    }
    return (uintptr_t) store;
}

int
frjs_dir_exists(uintptr_t hstore, const char* fname)
{
    Store *store = (Store *) hstore;
    return store->exists(store, fname);
}
