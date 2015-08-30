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

  /// It is a good idea to close a directory when you have finished using it.
  /// Although the garbage collector will currently handle this for you, this
  /// behaviour may change in future.
  close() => frb_dir_close;

  /// Return true if a file with the name [file_name] exists in the directory.
  bool exists(String file_name) => frb_dir_exists;

  /// Create an empty file in the directory with the name [file_name].
  touch(String file_name) => frb_dir_touch;

  /// Remove file [file_name] from the directory. Returns true if successful.
  delete(String file_name) => frb_dir_delete;

  /// Return a count of the number of files in the directory.
  int file_count() => frb_dir_file_count;

  /// Delete all files in the directory. It gives you a clean slate.
  refresh() => frb_dir_refresh;

  /// Rename a file from [from] to [to]. An error will be raised if the file
  /// doesn't exist or there is some other type of IOError.
  rename(String from, String to) => frb_dir_rename;

  /// Make a lock with the name [lock_name]. Note that lockfiles will be
  /// stored in the directory with other files but they won't be visible to
  /// you. You should avoid using files with a `.lck` extension as this
  /// extension is reserved for lock files.
  Lock make_lock(String lock_name) => frb_dir_make_lock;
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
  /// Obtain a lock. Returns true if lock was successfully obtained. Make sure
  /// the lock is released using [Lock.release]. Otherwise you'll be left with
  /// a stale lock file.
  ///
  /// The [timeout] defaults to 1 second and 5 attempts are made to obtain
  /// the lock. If you're doing large batch updates on the index with multiple
  /// processes you may need to increase the lock timeout but 1 second will be
  /// substantial in most cases.
  ///
  /// Returns `true` if lock was successfully obtained. Raises a [LockError]
  /// otherwise.
  bool obtain({timeout = 1}) => frb_lock_obtain;

  /// Run the code in a block while a lock is obtained, automatically
  /// releasing the lock when the block returns.
  ///
  /// Returns `true` if lock was successfully obtained. Raises a [LockError]
  /// otherwise.
  bool while_locked({timeout = 1, fn}) => frb_lock_while_locked;

  /// Release the lock. This should only be called by the process which
  /// obtains the lock.
  release() => frb_lock_release;

  /// Returns `true` if the lock has been obtained.
  bool locked() => frb_lock_is_locked;
}

class LockError implements Exception {}

/// Memory resident [Directory] implementation. You should use a
/// [RAMDirectory] during testing but otherwise you should stick with
/// [FSDirectory]. While loading an index into memory may slightly speed
/// things up, on most operating systems there won't be much difference so
/// it wouldn't be worth your trouble.
class RAMDirectory extends Directory {
  /// Create a new RAMDirectory.
  ///
  /// You can optionally load another [Directory] (usually a [FSDirectory])
  /// into memory. This may be useful to speed up search performance but
  /// usually the speedup won't be worth the trouble. Be sure to benchmark.
  RAMDirectory({dir: null}) {
    frb_ramdir_init;
  }
}

/// File-system resident [Directory] implementation. The [FSDirectory] will
/// use a single directory to store all of it's files. You should not
/// otherwise touch this directory. Modifying the files in the directory will
/// corrupt the index. The one exception to this rule is you may need to delete
/// stale lock files which have a `.lck` extension.
class FSDirectory extends Directory {
  /// Create a new FSDirectory at [path] which must be a valid path on your
  /// file system. If it doesn't exist it will be created. You can also
  /// specify the [create] parameter. If [create] is true the [FSDirectory]
  /// will be refreshed as new. That is to say, any existing files in the
  /// directory will be deleted.
  static FSDirectory create(path, {bool create: false}) {
    frb_fsdir_new;
  }
}
