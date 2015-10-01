library ferret.test.store.store_lock;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

class Switch {
  static int __counter;
  static int get counter => __counter;

  static set counter(int counter) {
    __counter = counter;
  }
}

storeLockTest(Directory makeDir(), closeDir(Directory d)) {
  bool can_obtain_lock(Lock lock, double lock_time_out) {
    try {
      lock.obtain(timeout: lock_time_out);
      return true;
    } on Exception catch (_) {}
    return false;
  }

  group('lock', () {
    Directory dir;

    setUp(() => dir = makeDir());
    tearDown(() => closeDir(dir));

    test('locking', () {
      var lock_time_out = 0.001; // we want this test to run quickly
      var lock1 = dir.make_lock("l.lck");
      var lock2 = dir.make_lock("l.lck");

      expect(lock2.locked(), isFalse);
      expect(lock1.obtain(timeout: lock_time_out), isTrue);
      expect(lock2.locked(), isTrue);

      expect(can_obtain_lock(lock2, lock_time_out), isFalse);

      var exception_thrown = false;
      try {
        lock2.while_locked(() {
          expect(false, "lock should not have been obtained");
        }, timeout: lock_time_out);
      } catch (_) {
        exception_thrown = true;
      } finally {
        expect(exception_thrown, isTrue);
      }

      lock1.release();
      expect(lock2.obtain(timeout: lock_time_out), isTrue);
      lock2.release();

      Switch.counter = 0;

      var t = new Thread(() {
        lock1.while_locked(() {
          Switch.counter = 1;
          // make sure lock2 obtain test was run
          while (Switch.counter < 2) {}
          Switch.counter = 3;
        }, timeout: lock_time_out);
      });
      t.run();

      // make sure thread has started and lock been obtained
      while (Switch.counter < 1) {}

      expect(can_obtain_lock(lock2, lock_time_out), isFalse,
          reason: "lock 2 should not be obtainable");

      Switch.counter = 2;
      while (Switch.counter < 3) {}

      expect(lock2.obtain(timeout: lock_time_out), isTrue);
      lock2.release();
    });
  });
}
