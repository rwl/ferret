library ferret.test.utils.bit_vector;

import 'dart:math' show Random;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

void bitVectorTest() {
  final Random _r = new Random();

  int rand(max) => _r.nextInt(max);

  test('bv_get_set', () {
    var bv = new BitVector();
    expect(bv.count(), equals(0));

    bv.set(10);
    expect(bv.get(10), isTrue);
    expect(bv[10], isTrue);
    expect(bv.count(), equals(1));

    bv[10] = false;
    expect(bv[10], isFalse);

    bv[10] = true;
    expect(bv[10], isTrue);

    bv[10] = null;
    expect(bv[10], isFalse);

    bv[10] = true;
    expect(bv[10], isTrue);

    bv.unset(10);
    expect(bv[10], isFalse);

    bv[10] = true;
    expect(bv[10], isTrue);
  });

  test('bv_count', () {
    var bv = new BitVector();
    bv.set(10);
    expect(bv.count(), equals(1));

    bv.set(20);
    expect(bv.get(20), isTrue);
    expect(bv.count(), equals(2));

    bv.set(21);
    expect(bv.get(21), isTrue);
    expect(bv.count(), equals(3));

    bv.unset(21);
    expect(bv.get(21), isFalse);
    expect(bv.count(), equals(2));

    bv[20] = null;
    expect(bv.get(20), isFalse);
    expect(bv.count(), equals(1));

    range(50, 101).forEach((i) => bv.set(i));
    range(50, 101).forEach((i) => expect(bv[i], isTrue));
    expect(bv.get(10), isTrue);
    expect(bv.count(), equals(52));

    bv.clear();
    expect(0, equals(bv.count()));
    range(50, 101).forEach((i) => expect(bv[i], isFalse));
    expect(bv.get(10), isFalse);
  });

  test('bv_eql_hash', () {
    var bv1 = new BitVector();
    var bv2 = new BitVector();
    expect(bv1, equals(bv2));
    expect(bv1.hash(), equals(bv2.hash()));

    bv1.set(10);
    expect(bv1, isNot(equals(bv2)));
    expect(bv1.hash(), isNot(equals(bv2.hash())));

    bv2.set(10);
    expect(bv1, equals(bv2));
    expect(bv1.hash(), equals(bv2.hash()));

    range(10).forEach((i) => bv1.set(i * 31));
    expect(bv1, isNot(equals(bv2)));
    expect(bv1.hash(), isNot(equals(bv2.hash())));

    range(10).forEach((i) => bv2.set(i * 31));
    expect(bv1, equals(bv2));
    expect(bv1.hash(), equals(bv2.hash()));

    bv1.clear();
    expect(bv1, isNot(equals(bv2)));
    expect(bv1.hash(), isNot(equals(bv2.hash())));

    bv2.clear();
    expect(bv1, equals(bv2));
    expect(bv1.hash(), equals(bv2.hash()));
  });

  const BV_COUNT = 500;
  const BV_SIZE = 1000;

  test('bv_and', () {
    var bv1 = new BitVector();
    var bv2 = new BitVector();
    var set1 = 0, set2 = 0, count = 0;

    range(BV_COUNT).forEach((i) {
      var bit = rand(BV_SIZE);
      bv1.set(bit);
      set1 |= (1 << bit);
    });

    range(BV_COUNT).forEach((i) {
      var bit = rand(BV_SIZE);
      bv2.set(bit);
      var bitmask = (1 << bit);
      if (((set1 & bitmask) > 0) && ((set2 & bitmask) == 0)) {
        set2 |= (1 << bit);
        count += 1;
      }
    });

    var and_bv = bv1 & bv2;
    expect(count, equals(and_bv.count()));
    range(BV_SIZE).forEach((i) {
      expect(((set2 & (1 << i)) > 0), equals(and_bv[i]));
    });

    bv2.andx(bv1);
    expect(bv2, equals(and_bv));

    bv2 = new BitVector();
    and_bv = bv1 & bv2;

    expect(bv2, equals(and_bv), reason: "and_bv should be empty");
    expect(0, equals(and_bv.count()));

    bv1 = new BitVector();
    bv2 = new BitVector().not();
    bv1.set(10);
    bv1.set(11);
    bv1.set(20);
    expect(bv1, equals(bv1 & bv2),
        reason: "bv anded with empty not bv should be same");
  });

  test('bv_or', () {
    var bv1 = new BitVector();
    var bv2 = new BitVector();
    var set = 0, count = 0;

    range(BV_COUNT).forEach((i) {
      var bit = rand(BV_SIZE);
      bv1.set(bit);
      var bitmask = (1 << bit);
      if ((set & bitmask) == 0) {
        count += 1;
        set |= bitmask;
      }
    });

    range(BV_COUNT).forEach((i) {
      var bit = rand(BV_SIZE);
      bv2.set(bit);
      var bitmask = (1 << bit);
      if ((set & bitmask) == 0) {
        count += 1;
        set |= bitmask;
      }
    });

    var or_bv = bv1 | bv2;
    expect(count, equals(or_bv.count()));
    range(BV_SIZE).forEach((i) {
      expect(((set & (1 << i)) > 0), equals(or_bv[i]));
    });

    bv2.orx(bv1);
    expect(bv2, equals(or_bv));

    bv2 = new BitVector();
    or_bv = bv1 | bv2;

    expect(bv1, equals(or_bv));
  });

  test('bv_xor', () {
    var bv1 = new BitVector();
    var bv2 = new BitVector();
    var set1 = 0, set2 = 0, count = 0;

    range(BV_COUNT).forEach((i) {
      var bit = rand(BV_SIZE);
      bv1.set(bit);
      set1 |= (1 << bit);
    });

    range(BV_COUNT).forEach((i) {
      var bit = rand(BV_SIZE);
      bv2.set(bit);
      set2 |= (1 << bit);
    });

    var bitmask = 1;
    set1 ^= set2;
    range(BV_SIZE).forEach((i) {
      if ((set1 & bitmask) > 0) {
        count += 1;
      }
      bitmask <<= 1;
    });

    var xor_bv = bv1 ^ bv2;
    range(BV_SIZE).forEach((i) {
      expect(((set1 & (1 << i)) > 0), equals(xor_bv[i]));
    });
    expect(count, equals(xor_bv.count()));

    bv2.xorx(bv1);
    expect(bv2, equals(xor_bv));

    bv2 = new BitVector();
    xor_bv = bv1 ^ bv2;

    expect(bv1, equals(xor_bv));
  });

  test('bv_not', () {
    var bv = new BitVector();
    [1, 5, 25, 41, 97, 185].forEach((i) => bv.set(i));
    var not_bv = ~bv;
    expect(bv.count(), equals(not_bv.count()));
    range(200).forEach((i) => expect(bv[i], isNot(equals(not_bv[i]))));

    not_bv.notx();
    expect(bv, equals(not_bv));
  });

  const SCAN_SIZE = 200;
  const SCAN_INC = 97;

  test('scan', () {
    var bv = new BitVector();

    range(SCAN_SIZE).forEach((i) => bv.set(i * SCAN_INC));
    var not_bv = ~bv;

    range(SCAN_SIZE).forEach((i) {
      expect(i * SCAN_INC, equals(bv.next_from((i - 1) * SCAN_INC + 1)));
      expect(
          i * SCAN_INC, equals(not_bv.next_unset_from((i - 1) * SCAN_INC + 1)));
    });
    expect(bv.next_from((SCAN_SIZE - 1) * SCAN_INC + 1), equals(-1));
    expect(not_bv.next_unset_from((SCAN_SIZE - 1) * SCAN_INC + 1), equals(-1));

    var bit = 0;
    bv.each((i) {
      expect(bit, equals(i));
      bit += SCAN_INC;
    });
    expect(bit, equals(SCAN_SIZE * SCAN_INC));

    bit = 0;
    not_bv.each((i) {
      expect(bit, equals(i));
      bit += SCAN_INC;
    });
    expect(bit, equals(SCAN_SIZE * SCAN_INC));

    bv.reset_scan();
    not_bv.reset_scan();
    range(SCAN_SIZE).forEach((i) {
      expect(i * SCAN_INC, equals(bv.next()));
      expect(i * SCAN_INC, equals(not_bv.next_unset()));
    });
    expect(bv.next(), equals(-1));
    expect(not_bv.next_unset(), equals(-1));

    bv.clear();
    range(SCAN_SIZE).forEach((i) => bv.set(i));
    not_bv = ~bv;

    range(SCAN_SIZE).forEach((i) {
      expect(bv.next(), equals(i));
      expect(not_bv.next_unset(), equals(i));
    });
    expect(bv.next(), equals(-1));
    expect(not_bv.next_unset(), equals(-1));

    bit = 0;
    bv.each((i) {
      expect(bit, equals(i));
      bit += 1;
    });
    expect(bit, equals(SCAN_SIZE));

    bit = 0;
    not_bv.each((i) {
      expect(bit, equals(i));
      bit += 1;
    });
    expect(bit, equals(SCAN_SIZE));
  });

  test('to_a', () {
    var bv = new BitVector();
    var ary = (range(1, 100).map((_) => rand(1000)).toList()..sort())
        .toSet()
        .toList();
    ary.forEach((i) => bv.set(i));
    expect(ary, equals(bv.to_a()));
  });
}
