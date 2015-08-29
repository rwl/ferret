#include "ferret.h"

static char*
fjs_te_next(uintptr_t handle)
{
    TermEnum *te = (TermEnum *) handle;
    return te->next(te);
}
