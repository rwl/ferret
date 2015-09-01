library ferret.test.utils.priority_queue;

import 'dart:math' show Random;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

class PriorityQueueTest {
  //< Test::Unit::TestCase

  static final Random _r = new Random();

  static int rand(max) => _r.nextInt(max);

  static const PQ_STRESS_SIZE = 1000;

  test_pq() {
    var pq = new PriorityQueue(capacity: 4);
    expect(0, equals(pq.size));
    expect(4, equals(pq.capacity));
    pq.insert("bword");
    expect(1, equals(pq.size));
    expect("bword", equals(pq.top));

    pq.insert("cword");
    expect(2, equals(pq.size));
    expect("bword", equals(pq.top));

    pq.add("dword");
    expect(3, equals(pq.size));
    expect("bword", equals(pq.top));

    pq.add("eword");
    expect(4, equals(pq.size));
    expect("bword", equals(pq.top));

    pq.add("aword");
    expect(4, equals(pq.size));
    expect("bword", equals(pq.top),
        reason: "aword < all other elements so ignore");

    pq.add("fword");
    expect(4, equals(pq.size));
    expect("cword", equals(pq.top),
        reason: "bword got pushed off the bottom of the queue");

    expect("cword", equals(pq.pop()));
    expect(3, equals(pq.size));
    expect("dword", equals(pq.pop()));
    expect(2, equals(pq.size));
    expect("eword", equals(pq.pop()));
    expect(1, equals(pq.size));
    expect("fword", equals(pq.pop()));
    expect(0, equals(pq.size));
    expect(pq.top, isNull);
    expect(pq.pop, isNull);
  }

  test_pq_clear() {
    var pq = new PriorityQueue(capacity: 3);
    pq.add("word1");
    pq.add("word2");
    pq.add("word3");
    expect(3, equals(pq.size));
    pq.clear();
    expect(0, equals(pq.size));
    expect(pq.top, isNull);
    expect(pq.pop, isNull);
  }

  //#define PQ_STRESS_SIZE 1000
  test_stress_pq() {
    var pq = new PriorityQueue(capacity: PQ_STRESS_SIZE);
    PQ_STRESS_SIZE.times(() {
      pq.insert("<${rand(PQ_STRESS_SIZE)}>");
    });

    var prev = pq.pop();
    (PQ_STRESS_SIZE - 1).times(() {
      var curr = pq.pop();
      expect(prev <= curr, "${prev} should be less than ${curr}");
      prev = curr;
    });
    pq.clear();
  }

  test_pq_block() {
    var pq = new PriorityQueue(capacity: 21, less_than_proc: (a, b) => a > b);
    100.times(() {
      pq.insert("<${rand(50)}>");
    });

    var prev = pq.pop();
    20.times(() {
      var curr = pq.pop();
      expect(prev >= curr, "${prev} should be greater than ${curr}");
      prev = curr;
    });
    expect(0, equals(pq.size));
  }

  test_pq_proc() {
    var pq = new PriorityQueue(
        less_than_proc: (a, b) => a.size > b.size, capacity: 21);
    100.times(() {
      pq.insert("x" * rand(50));
    });

    var prev = pq.pop();
    20.times(() {
      var curr = pq.pop();
      expect(prev.size >= curr.size, "${prev} should be greater than ${curr}");
      prev = curr;
    });
    expect(0, equals(pq.size));
  }
}
