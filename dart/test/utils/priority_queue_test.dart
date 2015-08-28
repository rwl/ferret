library ferret.test.utils.priority_queue;

class PriorityQueueTest {
  //< Test::Unit::TestCase

  static const PQ_STRESS_SIZE = 1000;

  test_pq() {
    pq = new PriorityQueue(4);
    assert_equal(0, pq.size);
    assert_equal(4, pq.capacity);
    pq.insert("bword");
    assert_equal(1, pq.size);
    assert_equal("bword", pq.top);

    pq.insert("cword");
    assert_equal(2, pq.size);
    assert_equal("bword", pq.top);

    pq.add("dword");
    assert_equal(3, pq.size);
    assert_equal("bword", pq.top);

    pq.add("eword");
    assert_equal(4, pq.size);
    assert_equal("bword", pq.top);

    pq.add("aword");
    assert_equal(4, pq.size);
    assert_equal("bword", pq.top, "aword < all other elements so ignore");

    pq.add("fword");
    assert_equal(4, pq.size);
    assert_equal(
        "cword", pq.top, "bword got pushed off the bottom of the queue");

    assert_equal("cword", pq.pop());
    assert_equal(3, pq.size);
    assert_equal("dword", pq.pop());
    assert_equal(2, pq.size);
    assert_equal("eword", pq.pop());
    assert_equal(1, pq.size);
    assert_equal("fword", pq.pop());
    assert_equal(0, pq.size);
    assert_nil(pq.top);
    assert_nil(pq.pop);
  }

  test_pq_clear() {
    pq = new PriorityQueue(3);
    pq.add("word1");
    pq.add("word2");
    pq.add("word3");
    assert_equal(3, pq.size);
    pq.clear();
    assert_equal(0, pq.size);
    assert_nil(pq.top);
    assert_nil(pq.pop);
  }

  //#define PQ_STRESS_SIZE 1000
  test_stress_pq() {
    pq = new PriorityQueue(PQ_STRESS_SIZE);
    PQ_STRESS_SIZE.times(() {
      pq.insert("<#{rand(PQ_STRESS_SIZE)}>");
    });

    prev = pq.pop();
    (PQ_STRESS_SIZE - 1).times(() {
      curr = pq.pop();
      expect(prev <= curr, "${prev} should be less than #{curr}");
      prev = curr;
    });
    pq.clear();
  }

  test_pq_block() {
    pq = new PriorityQueue(21, (a, b) => a > b);
    100.times(() {
      pq.insert("<#{rand(50)}>");
    });

    prev = pq.pop();
    20.times(() {
      curr = pq.pop();
      expect(prev >= curr, "${prev} should be greater than ${curr}");
      prev = curr;
    });
    assert_equal(0, pq.size);
  }

  test_pq_proc() {
    pq = new PriorityQueue(less_than: (a, b) => a.size > b.size, capacity: 21);
    100.times(() {
      pq.insert("x" * rand(50));
    });

    prev = pq.pop();
    20.times(() {
      curr = pq.pop();
      expect(prev.size >= curr.size, "${prev} should be greater than ${curr}");
      prev = curr;
    });
    assert_equal(0, pq.size);
  }
}
