#include "internal.h"
#include "global.h"
#include "hash.h"
#include "hashset.h"
#include "bitvector.h"

void
frjs_init(void) {
	const char * const progname[] = { "dart" };
	frt_init(1, progname);
}

HashSetEntry *
frjs_hash_get_first(HashSet *hs) {
	return hs->first;
}

HashSetEntry *
frjs_hash_get_entry_next(HashSetEntry *hse) {
	return hse->next;
}

void *
frjs_hash_get_entry_elem(HashSetEntry *hse) {
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

void
frjs_bv_unset(BitVector *bv, int bit) {
	bv_unset(bv, bit);
}

BitVector *
frjs_bv_and_x(BitVector *bv1, BitVector *bv2) {
	return bv_and_x(bv1, bv2);
}

BitVector *
frjs_bv_and(BitVector *bv1, BitVector *bv2) {
	return bv_and(bv1, bv2);
}

BitVector *
frjs_bv_or_x(BitVector *bv1, BitVector *bv2) {
	return bv_or_x(bv1, bv2);
}

BitVector *
frjs_bv_or(BitVector *bv1, BitVector *bv2) {
	return bv_or(bv1, bv2);
}

BitVector *
frjs_bv_xor_x(BitVector *bv1, BitVector *bv2) {
	return bv_xor_x(bv1, bv2);
}

BitVector *
frjs_bv_xor(BitVector *bv1, BitVector *bv2) {
	return bv_xor(bv1, bv2);
}

BitVector *
frjs_bv_not_x(BitVector *bv) {
	return bv_not_x(bv);
}

BitVector *
frjs_bv_not(BitVector *bv) {
	return bv_not(bv);
}

int
frjs_bv_scan_next_unset(BitVector *bv) {
	return bv_scan_next_unset(bv);
}

int
frjs_bv_scan_next_unset_from(BitVector *bv, const int bit) {
	return bv_scan_next_unset_from(bv, bit);
}
