/// The Store module contains all the classes required to handle the storing
/// of an index.
///
/// NOTE: You can currently store an index on a file-system or in memory. If
/// you want to add a different type of [Directory], like a database
/// [Directory] for instance, you will need to implement it in C.
library ferret.ext.store;

/// A Directory is an object which is used to access the index storage.
/// Dart's IO API is not used so that we can use different storage
/// mechanisms to store the index. Some examples are:
///
/// * File system based storage (currently implemented as [FSDirectory])
/// * RAM based storage (currently implemented as [RAMDirectory])
/// * Database based storage
///
/// NOTE: Once a file has been written and closed, it can no longer be
/// modified. To make any changes to the file it must be deleted and
/// rewritten. For this reason, the method to open a file for writing is
/// called `create_output`, while the method to open a file for reading is
/// called `open_input`. If there is a risk of simultaneous modifications of
/// the files then locks should be used. See [Lock] to find out how.
abstract class Directory {
  static const LOCK_PREFIX;

  close() => frb_dir_close;
  bool exists() => frb_dir_exists;
  touch() => frb_dir_touch;
  delete() => frb_dir_delete;
  file_count() => frb_dir_file_count;
  refresh() => frb_dir_refresh;
  rename() => frb_dir_rename;
  make_lock() => frb_dir_make_lock;
}

/// A [Lock] is used to lock a data source so that not more than one
/// output stream can access a data source at one time. It is possible
/// that locks could be disabled. For example a read only index stored
/// on a CDROM would have no need for a lock.
///
/// You can use a lock in two ways. Firstly:
///
///     write_lock = _directory.make_lock(LOCK_NAME);
///     write_lock.obtain(WRITE_LOCK_TIME_OUT);
///     ... # Do your file modifications # ...
///     write_lock.release();
///
/// Alternatively you could use the while locked method. This ensures that
/// the lock will be released once processing has finished.
///
///     write_lock = _directory.make_lock(LOCK_NAME);
///     write_lock.while_locked(WRITE_LOCK_TIME_OUT, () {
///       ... # Do your file modifications # ...
///     });
class Lock {
  obtain() => frb_lock_obtain;
  while_locked() => frb_lock_while_locked;
  release() => frb_lock_release;
  bool locked() => frb_lock_is_locked;
}

class LockError implements Exception {}

/// Memory resident [Directory] implementation. You should use a
/// [RAMDirectory] during testing but otherwise you should stick with
/// [FSDirectory]. While loading an index into memory may slightly speed
/// things up, on most operating systems there won't be much difference so
/// it wouldn't be worth your trouble.
class RAMDirectory extends Directory {
  RAMDirectory() {
    frb_ramdir_init;
  }
}

/// File-system resident [Directory] implementation. The [FSDirectory] will
/// use a single directory to store all of it's files. You should not
/// otherwise touch this directory. Modifying the files in the directory will
/// corrupt the index. The one exception to this rule is you may need to delete
/// stale lock files which have a `.lck` extension.
class FSDirectory extends Directory {
  static FSDirectory create() {
    frb_fsdir_new;
  }
}
