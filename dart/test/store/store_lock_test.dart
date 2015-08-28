library ferret.test.store.store_lock;

class Switch {
  static get counter {
    return __counter;
  }
  static set counter(counter) {
    __counter = counter;
  }
}

class StoreLockTest {
  test_locking() {
    lock_time_out = 0.001; // we want this test to run quickly
    lock1 = _dir.make_lock("l.lck");
    lock2 = _dir.make_lock("l.lck");

    assert(!lock2.locked);
    assert(lock1.obtain(lock_time_out));
    assert(lock2.locked);

    assert(!can_obtain_lock(lock2, lock_time_out));

    exception_thrown = false;
    try {
      lock2.while_locked(lock_time_out, () {
        expect(false, "lock should not have been obtained");
      });
    } catch (_) {
      exception_thrown = true;
    } finally {
      assert(exception_thrown);
    }

    lock1.release();
    assert(lock2.obtain(lock_time_out));
    lock2.release();

    Switch.counter = 0;

    t = new Thread(() {
      lock1.while_locked(lock_time_out, () {
        Switch.counter = 1;
        // make sure lock2 obtain test was run
        while (Switch.counter < 2) {}
        Switch.counter = 3;
      });
    });
    t.run();

    // make sure thread has started and lock been obtained
    while (Switch.counter < 1) {}

    expect(!can_obtain_lock(lock2, lock_time_out),
        "lock 2 should not be obtainable");

    Switch.counter = 2;
    while (Switch.counter < 3) {}

    assert(lock2.obtain(lock_time_out));
    lock2.release();
  }

  bool can_obtain_lock(lock, lock_time_out) {
    try {
      lock.obtain(lock_time_out);
      return true;
    } on Exception catch (e) {}
    return false;
  }
}
