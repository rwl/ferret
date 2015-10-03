library ferret.test.store.fs_store;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

import 'store_test.dart';
import 'store_lock_test.dart';

fsStoreTest(Ferret ferret) {
  const dpath = '/temp/fsdir';

  Directory makeDir() => new FSDirectory(ferret, dpath, create: true);

  void closeDir(Directory dir) {
    dir.close();
    Dir[File.join(dpath, "*")].each((path) {
      try {
        File.delete(path);
      } catch (_) {}
    });
  }

  storeTest(makeDir, closeDir);
  storeLockTest(makeDir, closeDir);

  String lfname(String name) => "ferret-${name}.lck";

  make_lock_file_path(name) {
    var lock_file_path = File.join(dpath, lfname(name));
    if (File.exists(lock_file_path)) {
      File.delete(lock_file_path);
    }
    return lock_file_path;
  }

  group('fsdir', () {
    Directory dir;

    setUp(() => dir = makeDir());
    tearDown(() => closeDir(dir));

    test('lock', () {
      var lock_name = "_file.f1";
      var lock_file_path = make_lock_file_path(lock_name);
      expect(File.exists(lock_file_path), isFalse,
          reason: "There should be no lock file");
      var lock = dir.make_lock(lock_name);
      expect(File.exists(lock_file_path), isFalse,
          reason: "There should still be no lock file");
      expect(lock.locked(), isFalse, reason: "lock shouldn't be locked yet");

      lock.obtain();

      expect(lock.locked(), isTrue, reason: "lock should now be locked");

      expect(File.exists(lock_file_path), isTrue,
          reason: "A lock file should have been created");

      expect(dir.exists(lfname(lock_name)), "The lock should exist");

      lock.release();

      expect(lock.locked(), isFalse, reason: "lock should be freed again");
      expect(File.exists(lock_file_path), isFalse,
          reason: "The lock file should have been deleted");
    });

//  make_and_loose_lock() {
//    var lock = _dir.make_lock("finalizer_lock");
//    lock.obtain()
//    lock = null;
//  }
//
//  test_fslock_finalizer() {
//    var lock_name = "finalizer_lock";
//    var lock_file_path = make_lock_file_path(lock_name);
//    expect(File.exists(lock_file_path), isFalse,
//        reason: "There should be no lock file");
//
//    make_and_loose_lock();
//
//    //expect(File.exists(lock_file_path), isTrue,
//    //    reason: "There should now be a lock file");
//
//    var lock = _dir.make_lock(lock_name);
//    expect(lock.locked(), isTrue, reason: "lock should now be locked");
//
//    GC.start();
//
//    expect(lock.locked(), isFalse, reason: "lock should be freed again");
//    expect(File.exists(lock_file_path), isFalse,
//        reason: "The lock file should have been deleted");
//  }

    test('permissions', () {
      var _S_IRGRP = 0040;
      var _S_IWGRP = 0020;

      var dpath2 = File.expand_path(
          File.join(File.dirname(__FILE__), '../../temp/fsdir_permissions'));

      FileUtils.mkdir_p(dpath2);
      var dstat = File.stat(dpath2);

      File.chown(null, 'id -G'.split.last.to_i, dpath2);
      File.chmod(dstat.mode | _S_IRGRP | _S_IWGRP, dpath2);

      var dir2 = FSDirectory.create(dpath2, create: true);

      var file_name = 'test_permissions';
      var file_path = File.join(dpath2, file_name);

      dir2.touch(file_name);

      var mode = File.stat(file_path).mode;

      expect(mode & _S_IRGRP == _S_IRGRP, "file should be group-readable");
      expect(mode & _S_IWGRP == _S_IWGRP, "file should be group-writable");
      //ensure
      if (dstat) {
        File.chown(null, dstat.gid, dpath2);
        File.chmod(dstat.mode, dpath2);
      }

      if (dir2 != null) {
        dir2.refresh();
        dir2.close();
      }
    });
  });
}
