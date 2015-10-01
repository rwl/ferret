library ferret.test.store.store;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

storeTest(Directory makeDir(), closeDir(Directory d)) {
  group('store', () {
    Directory dir;

    setUp(() => dir = makeDir());
    tearDown(() => closeDir(dir));

    // test the basic file manipulation methods;
    // - exists?
    // - touch
    // - delete
    // - file_count
    test('basic_file_ops', () {
      expect(0, equals(dir.file_count()), reason: "directory should be empty");
      expect(dir.exists('filename'), isFalse, reason: "File should not exist");
      dir.touch('tmpfile1');
      expect(1, equals(dir.file_count()),
          reason: "directory should have one file");
      dir.touch('tmpfile2');
      expect(2, equals(dir.file_count()),
          reason: "directory should have two files");
      expect(dir.exists('tmpfile1'), isTrue, reason: "'tmpfile1' should exist");
      dir.delete('tmpfile1');
      expect(dir.exists('tmpfile1'), isFalse,
          reason: "'tmpfile1' should no longer exist");
      expect(1, equals(dir.file_count()),
          reason: "directory should have one file");
    });

    test('rename', () {
      dir.touch("from");
      expect(dir.exists('from'), isTrue, reason: "File should exist");
      expect(dir.exists('to'), isFalse, reason: "File should not exist");
      var cnt_before = dir.file_count();
      dir.rename('from', 'to');
      var cnt_after = dir.file_count();
      expect(cnt_before, equals(cnt_after),
          reason: "the number of files shouldn't have changed");
      expect(dir.exists('to'), isTrue, reason: "File should now exist");
      expect(dir.exists('from'), isFalse,
          reason: "File should no longer exist");
    });
  });
}
