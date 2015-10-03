library ferret.test.store.ram_store;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

import 'store_test.dart';
import 'store_lock_test.dart';

ramStoreTest(Ferret ferret) {
  Directory makeDir() => new RAMDirectory(ferret);
  void closeDir(Directory dir) => dir.close();

  storeTest(makeDir, closeDir);
  storeLockTest(makeDir, closeDir);

  group('ramdir', () {
    Directory dir;

    setUp(() => dir = makeDir());
    tearDown(() => closeDir(dir));

    test('ramlock', () {
      var name = "lfile";
      var lfile = Directory.LOCK_PREFIX + name + ".lck";
      expect(dir.exists(lfile), isFalse,
          reason: "There should be no lock file");
      var lock = dir.make_lock(name);
      expect(dir.exists(lfile), isFalse,
          reason: "There should still be no lock file");
      expect(dir.exists(lfile), isFalse,
          reason:
              "The lock should be hidden by the FSDirectories directory scan");
      expect(lock.locked(), isFalse, reason: "lock shouldn't be locked yet");
      lock.obtain();
      expect(lock.locked(), isTrue, reason: "lock should now be locked");
      expect(dir.exists(lfile), isTrue,
          reason: "A lock file should have been created");
      lock.release();
      expect(lock.locked(), isFalse, reason: "lock should be freed again");
      expect(dir.exists(lfile), isFalse,
          reason: "The lock file should have been deleted");
    });
  });
}
