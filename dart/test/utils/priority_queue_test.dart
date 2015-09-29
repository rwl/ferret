library ferret.test.utils.priority_queue;

import 'dart:math' show Random;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

void priorityQueueTest() {
  final Random _r = new Random();

  int rand(max) => _r.nextInt(max);

  const PQ_STRESS_SIZE = 1000;

  test('pq', () {
    var pq = new PriorityQueue(capacity: 4);
    expect(0, equals(pq.size));
    expect(4, equals(pq.capacity()));
    pq.insert("bword");
    expect(1, equals(pq.size));
    expect("bword", equals(pq.top()));

    pq.insert("cword");
    expect(2, equals(pq.size));
    expect("bword", equals(pq.top()));

    pq.insert("dword");
    expect(3, equals(pq.size));
    expect("bword", equals(pq.top()));

    pq.insert("eword");
    expect(4, equals(pq.size));
    expect("bword", equals(pq.top()));

    pq.insert("aword");
    expect(4, equals(pq.size));
    expect("bword", equals(pq.top()),
        reason: "aword < all other elements so ignore");

    pq.insert("fword");
    expect(4, equals(pq.size));
    expect("cword", equals(pq.top()),
        reason: "bword got pushed off the bottom of the queue");

    expect("cword", equals(pq.pop()));
    expect(3, equals(pq.size));
    expect("dword", equals(pq.pop()));
    expect(2, equals(pq.size));
    expect("eword", equals(pq.pop()));
    expect(1, equals(pq.size));
    expect("fword", equals(pq.pop()));
    expect(0, equals(pq.size));
    expect(pq.top(), isNull);
    expect(pq.pop(), isNull);
  });

  test('pq_clear', () {
    var pq = new PriorityQueue(capacity: 3);
    pq.insert("word1");
    pq.insert("word2");
    pq.insert("word3");
    expect(3, equals(pq.size));
    pq.clear();
    expect(0, equals(pq.size));
    expect(pq.top(), isNull);
    expect(pq.pop(), isNull);
  });

  //#define PQ_STRESS_SIZE 1000
  test('stress_pq', () {
    var pq = new PriorityQueue(capacity: PQ_STRESS_SIZE);
    range(PQ_STRESS_SIZE).forEach((_) {
      pq.insert("<${rand(PQ_STRESS_SIZE)}>");
    });

    var prev = pq.pop();
    range(PQ_STRESS_SIZE - 1).forEach((_) {
      var curr = pq.pop();
      expect(prev.compareTo(curr), lessThanOrEqualTo(0),
          reason: "${prev} should be less than ${curr}");
      prev = curr;
    });
    pq.clear();
  });

  test('pq_block', () {
    var pq = new PriorityQueue(
        capacity: 21, less_than_proc: (a, b) => a.compareTo(b) > 0);
    range(100).forEach((_) {
      pq.insert("<${rand(50)}>");
    });

    var prev = pq.pop();
    range(20).forEach((_) {
      var curr = pq.pop();
      expect(prev.compareTo(curr), greaterThanOrEqualTo(0),
          reason: "${prev} should be greater than ${curr}");
      prev = curr;
    });
    expect(0, equals(pq.size));
  });

  test('pq_proc', () {
    var pq = new PriorityQueue(
        less_than_proc: (a, b) => a.length > b.length, capacity: 21);
    range(100).forEach((_) {
      pq.insert("x" * rand(50));
    });

    var prev = pq.pop();
    range(20).forEach((_) {
      var curr = pq.pop();
      expect(prev.length, greaterThanOrEqualTo(curr.length),
          reason: "${prev} should be greater than ${curr}");
      prev = curr;
    });
    expect(0, equals(pq.size));
  });
}
