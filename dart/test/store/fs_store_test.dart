library ferret.test.store.fs_store;

class FSStoreTest {
  //< Test::Unit::TestCase
  setup() {
    _dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    _dir = new FSDirectory(_dpath, true);
  }

  teardown() {
    _dir.close();
    Dir[File.join(_dpath, "*")].each((path) {
      try {
        File.delete(path);
      } catch (_) {}
    });
  }

  test_fslock() {
    lock_name = "_file.f1";
    lock_file_path = make_lock_file_path(lock_name);
    expect(!File.exists(lock_file_path), "There should be no lock file");
    lock = _dir.make_lock(lock_name);
    expect(!File.exists(lock_file_path), "There should still be no lock file");
    expect(!lock.locked, "lock shouldn't be locked yet");

    lock.obtain();

    expect(lock.locked(), "lock should now be locked");

    expect(File.exists(lock_file_path), "A lock file should have been created");

    expect(_dir.exists(lfname(lock_name)), "The lock should exist");

    lock.release();

    expect(!lock.locked(), "lock should be freed again");
    expect(
        !File.exists(lock_file_path), "The lock file should have been deleted");
  }

//  make_and_loose_lock() {
//    lock = _dir.make_lock("finalizer_lock");
//    lock.obtain()
//    lock = null;
//  }
//
//  test_fslock_finalizer() {
//    lock_name = "finalizer_lock";
//    lock_file_path = make_lock_file_path(lock_name);
//    expect(! File.exists?(lock_file_path), "There should be no lock file");
//
//    make_and_loose_lock();
//
//    //expect(File.exists(lock_file_path), "There should now be a lock file");
//
//    lock = _dir.make_lock(lock_name);
//    expect(lock.locked?, "lock should now be locked");
//
//    GC.start();
//
//    expect(! lock.locked?, "lock should be freed again");
//    expect(! File.exists?(lock_file_path), "The lock file should have been deleted");
//  }

  test_permissions() {
    _S_IRGRP = 0040;
    _S_IWGRP = 0020;

    dpath = File.expand_path(
        File.join(File.dirname(__FILE__), '../../temp/fsdir_permissions'));

    FileUtils.mkdir_p(dpath);
    dstat = File.stat(dpath);

    File.chown(null, 'id -G'.split.last.to_i, dpath);
    File.chmod(dstat.mode | _S_IRGRP | _S_IWGRP, dpath);

    dir = new FSDirectory(dpath, true);

    file_name = 'test_permissions';
    file_path = File.join(dpath, file_name);

    dir.touch(file_name);

    mode = File.stat(file_path).mode;

    expect(mode & _S_IRGRP == _S_IRGRP, "file should be group-readable");
    expect(mode & _S_IWGRP == _S_IWGRP, "file should be group-writable");
    //ensure
    if (dstat) {
      File.chown(nil, dstat.gid, dpath);
      File.chmod(dstat.mode, dpath);
    }

    if (dir) {
      dir.refresh();
      dir.close();
    }
  }

  make_lock_file_path(name) {
    lock_file_path = File.join(_dpath, lfname(name));
    if (File.exists(lock_file_path)) {
      File.delete(lock_file_path);
    }
    return lock_file_path;
  }

  lfname(name) {
    return "ferret-${name}.lck";
  }
}
