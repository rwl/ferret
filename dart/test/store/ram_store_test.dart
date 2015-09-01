library ferret.test.store.ram_store;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

class RAMStoreTest {
  //< Test::Unit::TestCase
  Directory _dir;

  setup() {
    _dir = new RAMDirectory();
  }

  teardown() {
    _dir.close();
  }

  test_ramlock() {
    var name = "lfile";
    var lfile = Directory.LOCK_PREFIX + name + ".lck";
    expect(_dir.exists(lfile), isFalse, reason: "There should be no lock file");
    var lock = _dir.make_lock(name);
    expect(_dir.exists(lfile), isFalse,
        reason: "There should still be no lock file");
    expect(_dir.exists(lfile), isFalse,
        reason: "The lock should be hidden by the FSDirectories directory scan");
    expect(lock.locked(), isFalse, reason: "lock shouldn't be locked yet");
    lock.obtain();
    expect(lock.locked(), isTrue, reason: "lock should now be locked");
    expect(_dir.exists(lfile), isTrue,
        reason: "A lock file should have been created");
    lock.release();
    expect(lock.locked(), isFalse, reason: "lock should be freed again");
    expect(_dir.exists(lfile), isFalse,
        reason: "The lock file should have been deleted");
  }
}
