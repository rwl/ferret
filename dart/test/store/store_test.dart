library ferret.test.store.store;

class StoreTest {
  // declare dir so inheritors can access it.
  var dir;

  // test the basic file manipulation methods;
  // - exists?
  // - touch
  // - delete
  // - file_count
  test_basic_file_ops() {
    assert_equal(0, _dir.file_count(), "directory should be empty");
    expect(!_dir.exists('filename'), "File should not exist");
    _dir.touch('tmpfile1');
    assert_equal(1, _dir.file_count(), "directory should have one file");
    _dir.touch('tmpfile2');
    assert_equal(2, _dir.file_count(), "directory should have two files");
    expect(_dir.exists('tmpfile1'), "'tmpfile1' should exist");
    _dir.delete('tmpfile1');
    expect(!_dir.exists('tmpfile1'), "'tmpfile1' should no longer exist");
    assert_equal(1, _dir.file_count(), "directory should have one file");
  }

  test_rename() {
    _dir.touch("from");
    expect(_dir.exists('from'), "File should exist");
    expect(!_dir.exists('to'), "File should not exist");
    cnt_before = _dir.file_count();
    _dir.rename('from', 'to');
    cnt_after = _dir.file_count();
    assert_equal(
        cnt_before, cnt_after, "the number of files shouldn't have changed");
    expect(_dir.exists('to'), "File should now exist");
    expect(!_dir.exists('from'), "File should no longer exist");
  }
}
