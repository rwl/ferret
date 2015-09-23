#include "internal.h"
#include "global.h"
#include "hash.h"

void
frjs_init(void) {
	const char * const progname[] = { "dart" };
	frt_init(1, progname);
}

HashSetEntry *
frjs_hash_set_first(HashSet *hs) {
	return hs->first;
}

HashSetEntry *
frjs_hash_set_entry_next(HashSetEntry *hse) {
	return hse->next;
}

void *
frjs_hash_set_entry_elem(HashSetEntry *hse) {
	return hse->elem;
}

int
frjs_hash_get_size(Hash *hash) {
	return hash->size;
}

void *
frjs_hash_get_key(Hash *hash, int i) {
	HashEntry *he;
	if (i >= 0 && i < hash->size) {
		he = &hash->table[i];
		if (he != NULL) {
			return he->key;
		}
	}
	return NULL;
}

void *
frjs_hash_get_value(Hash *hash, int i) {
	HashEntry *he;
	if (i >= 0 && i < hash->size) {
		he = &hash->table[i];
		if (he != NULL) {
			return he->value;
		}
	}
	return NULL;
}

int
frjs_bv_count(BitVector *bv) {
    return bv->count;
}

bool
frjs_bv_extends_as_ones(BitVector *bv) {
    return bv->extends_as_ones;
}
