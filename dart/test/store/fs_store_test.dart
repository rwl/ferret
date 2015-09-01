library ferret.test.store.fs_store;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

class FSStoreTest {
  //< Test::Unit::TestCase
  String _dpath;
  Directory _dir;

  setUp() {
    _dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    _dir = FSDirectory.create(_dpath, create: true);
  }

  tearDown() {
    _dir.close();
    Dir[File.join(_dpath, "*")].each((path) {
      try {
        File.delete(path);
      } catch (_) {}
    });
  }

  test_fslock() {
    var lock_name = "_file.f1";
    var lock_file_path = make_lock_file_path(lock_name);
    expect(File.exists(lock_file_path), isFalse,
        reason: "There should be no lock file");
    var lock = _dir.make_lock(lock_name);
    expect(File.exists(lock_file_path), isFalse,
        reason: "There should still be no lock file");
    expect(lock.locked(), isFalse, reason: "lock shouldn't be locked yet");

    lock.obtain();

    expect(lock.locked(), isTrue, reason: "lock should now be locked");

    expect(File.exists(lock_file_path), isTrue,
        reason: "A lock file should have been created");

    expect(_dir.exists(lfname(lock_name)), "The lock should exist");

    lock.release();

    expect(lock.locked(), isFalse, reason: "lock should be freed again");
    expect(File.exists(lock_file_path), isFalse,
        reason: "The lock file should have been deleted");
  }

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

  test_permissions() {
    var _S_IRGRP = 0040;
    var _S_IWGRP = 0020;

    var dpath = File.expand_path(
        File.join(File.dirname(__FILE__), '../../temp/fsdir_permissions'));

    FileUtils.mkdir_p(dpath);
    var dstat = File.stat(dpath);

    File.chown(null, 'id -G'.split.last.to_i, dpath);
    File.chmod(dstat.mode | _S_IRGRP | _S_IWGRP, dpath);

    var dir = FSDirectory.create(dpath, create: true);

    var file_name = 'test_permissions';
    var file_path = File.join(dpath, file_name);

    dir.touch(file_name);

    var mode = File.stat(file_path).mode;

    expect(mode & _S_IRGRP == _S_IRGRP, "file should be group-readable");
    expect(mode & _S_IWGRP == _S_IWGRP, "file should be group-writable");
    //ensure
    if (dstat) {
      File.chown(null, dstat.gid, dpath);
      File.chmod(dstat.mode, dpath);
    }

    if (dir) {
      dir.refresh();
      dir.close();
    }
  }

  make_lock_file_path(name) {
    var lock_file_path = File.join(_dpath, lfname(name));
    if (File.exists(lock_file_path)) {
      File.delete(lock_file_path);
    }
    return lock_file_path;
  }

  lfname(name) => "ferret-${name}.lck";
}
