library ferret.test.store.store;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

abstract class StoreTest {
  // declare dir so inheritors can access it.
  Directory _dir;

  // test the basic file manipulation methods;
  // - exists?
  // - touch
  // - delete
  // - file_count
  test_basic_file_ops() {
    expect(0, equals(_dir.file_count()), reason: "directory should be empty");
    expect(_dir.exists('filename'), isFalse, reason: "File should not exist");
    _dir.touch('tmpfile1');
    expect(1, equals(_dir.file_count()),
        reason: "directory should have one file");
    _dir.touch('tmpfile2');
    expect(2, equals(_dir.file_count()),
        reason: "directory should have two files");
    expect(_dir.exists('tmpfile1'), isTrue, reason: "'tmpfile1' should exist");
    _dir.delete('tmpfile1');
    expect(_dir.exists('tmpfile1'), isFalse,
        reason: "'tmpfile1' should no longer exist");
    expect(1, equals(_dir.file_count()),
        reason: "directory should have one file");
  }

  test_rename() {
    _dir.touch("from");
    expect(_dir.exists('from'), isTrue, reason: "File should exist");
    expect(_dir.exists('to'), isFalse, reason: "File should not exist");
    var cnt_before = _dir.file_count();
    _dir.rename('from', 'to');
    var cnt_after = _dir.file_count();
    expect(cnt_before, equals(cnt_after),
        reason: "the number of files shouldn't have changed");
    expect(_dir.exists('to'), isTrue, reason: "File should now exist");
    expect(_dir.exists('from'), isFalse, reason: "File should no longer exist");
  }
}
