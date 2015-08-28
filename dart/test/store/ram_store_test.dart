library ferret.test.store.ram_store;

class RAMStoreTest {
  //< Test::Unit::TestCase
  setup() {
    _dir = new RAMDirectory();
  }

  teardown() {
    _dir.close();
  }

  test_ramlock() {
    name = "lfile";
    lfile = Directory.LOCK_PREFIX + name + ".lck";
    expect(!_dir.exists(lfile), "There should be no lock file");
    lock = _dir.make_lock(name);
    expect(!_dir.exists(lfile), "There should still be no lock file");
    expect(!_dir.exists(lfile),
        "The lock should be hidden by the FSDirectories directory scan");
    expect(!lock.locked, "lock shouldn't be locked yet");
    lock.obtain();
    expect(lock.locke, "lock should now be locked");
    expect(_dir.exists(lfile), "A lock file should have been created");
    lock.release();
    expect(!lock.locked, "lock should be freed again");
    expect(!_dir.exists(lfile), "The lock file should have been deleted");
  }
}
