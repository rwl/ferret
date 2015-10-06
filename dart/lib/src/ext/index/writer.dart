part of ferret.ext.index;

/// The IndexWriter is the class used to add documents to an index. You can
/// also delete documents from the index using this class. The indexing
/// process is highly customizable.
class IndexWriter {
  final Ferret _ferret;
  final int handle;

  /*static const WRITE_LOCK_TIMEOUT = 1;
  static const COMMIT_LOCK_TIMEOUT = 10;
  static const WRITE_LOCK_NAME = WRITE_LOCK_NAME;
  static const COMMIT_LOCK_NAME = COMMIT_LOCK_NAME;
  static const DEFAULT_CHUNK_SIZE = default_config.chunk_size;
  static const DEFAULT_MAX_BUFFER_MEMORY = default_config.max_buffer_memory;
  static const DEFAULT_TERM_INDEX_INTERVAL = default_config.index_interval;
  static const DEFAULT_DOC_SKIP_INTERVAL = default_config.skip_interval;
  static const DEFAULT_MERGE_FACTOR = default_config.merge_factor;
  static const DEFAULT_MAX_BUFFERED_DOCS = default_config.max_buffered_docs;
  static const DEFAULT_MAX_MERGE_DOCS = default_config.max_merge_docs;
  static const DEFAULT_MAX_FIELD_LENGTH = default_config.max_field_length;
  static const DEFAULT_USE_COMPOUND_FILE = default_config.use_compound_file ? Qtrue : Qfalse;*/

  /*var _boost;

  var _create;
  var _create_if_missing;
  var _field_infos;

  var _chunk_size;
  var _max_buffer_memory;
  var _term_index_interval;
  var _doc_skip_interval;
  var _merge_factor;
  var _max_buffered_docs;
  var _max_merge_docs;
  var _max_field_length;
  var _use_compound_file;*/

//  analysis.Analyzer _analyzer;

  /// Create a new [IndexWriter]. You should either pass a path or a directory
  /// to this constructor. For example, here are three ways you can create an
  /// [IndexWriter]:
  ///
  ///     var dir = new RAMDirectory();
  ///     var iw = new IndexWriter(dir: dir);
  ///
  ///     dir = new FSDirectory("/path/to/index");
  ///     iw = new IndexWriter(dir: dir);
  ///
  ///     iw = new IndexWriter(path: "/path/to/index");
  ///
  /// [dir] is a [Directory] object. You should either pass a [dir] or a [path]
  /// when creating an index.
  /// [path] is a string representing the path to the index directory. If you
  /// are creating the index for the first time the directory will be created if
  /// it's missing. You should not choose a directory which contains other files
  /// as they could be over-written. To protect against this set
  /// [create_if_missing] to false.
  /// Set [create_if_missing] to `true` to create the index if no index is found
  /// in the specified directory. Otherwise, use the existing index.
  /// Setting [create] to `true` creates the index, even if one already exists.
  /// That means any existing index will be deleted. It is probably better to
  /// use the [create_if_missing] option so that the index is only created the
  /// first time when it doesn't exist.
  /// [field_infos] is the [FieldInfos] object to use when creating a new index
  /// if [create_if_missing] or [create] is set to `true`. If an existing index
  /// is opened then this parameter is ignored.
  /// [analyzer] sets the default analyzer for the index. This is used by both
  /// the [IndexWriter] and the [QueryParser] to tokenize the input. The default
  /// is the [StandardAnalyzer].
  /// [chunk_size] is a memory performance tuning parameter. Sets the default
  /// size of chunks of memory malloced for use during indexing. You can usually
  /// leave this parameter as is.
  /// [max_buffer_memory] is a memory performance tuning parameter. Sets the
  /// amount of memory to be used by the indexing process. Set to a larger value
  /// to increase indexing speed. Note that this only includes memory used by
  /// the indexing process, not the rest of your application.
  /// [term_index_interval] is the skip interval between terms in the term
  /// dictionary. A smaller value will possibly increase search performance
  /// while also increasing memory usage and impacting negatively impacting
  /// indexing performance.
  /// [doc_skip_interval] is the skip interval for document numbers in the
  /// index. As with [term_index_interval] you have a trade-off. A smaller
  /// number may increase search performance while also increasing memory usage
  /// and impacting negatively impacting indexing performance.
  /// [merge_factor] must never be less than 2. Specifies the number of segments
  /// of a certain size that must exist before they are merged. A larger value
  /// will improve indexing performance while slowing search performance.
  /// [max_buffered_docs] is the maximum number of documents that may be stored
  /// in memory before being written to the index. If you have a lot of memory
  /// and are indexing a large number of small documents (like products in a
  /// product database for example) you may want to set this to a much higher
  /// number (like [Ferret.FIX_INT_MAX]). If you are worried about your
  /// application crashing during the middle of index you might set this to a
  /// smaller number so that the index is committed more often. This is like
  /// having an auto-save in a word processor application.
  /// Set [max_merge_docs] to limit the number of documents that go into a
  /// single segment. Use this to avoid extremely long merge times during
  /// indexing which can make your application seem unresponsive. This is only
  /// necessary for very large indexes (millions of documents).
  /// [max_field_length] is the maximum number of terms added to a single field.
  /// This can be useful to protect the indexer when indexing documents from the
  /// web for example. Usually the most important terms will occur early on in a
  /// document so you can often safely ignore the terms in a field after a
  /// certain number of them. If you wanted to speed up indexing and same space
  /// in your index you may only want to index the first 1000 terms in a field.
  /// On the other hand, if you want to be more thorough and you are indexing
  /// documents from your file-system you may set this parameter to
  /// [Ferret.FIX_INT_MAX].
  /// [use_compound_file] uses a compound file to store the index. This prevents
  /// an error being raised for having too many files open at the same time. The
  /// default is true but performance is better if this is set to false.
  ///
  /// Both [IndexReader] and IndexWriter allow you to delete documents. You
  /// should use the [IndexReader] to delete documents by document id and
  /// [IndexWriter] to delete documents by term which we'll explain now. It is
  /// preferrable to delete documents from an index using [IndexWriter] for
  /// performance reasons. To delete documents using the [IndexWriter] you
  /// should give each document in the index a unique ID. If you are indexing
  /// documents from the file-system this unique ID will be the full file path.
  /// If indexing documents from the database you should use the primary key as
  /// the ID field. You can then use the delete method to delete a file
  /// referenced by the ID. For example:
  ///
  ///     index_writer.delete('id', "/path/to/indexed/file");
  factory IndexWriter(Ferret ferret,
      {Directory dir,
      String path,
      bool create_if_missing: true,
      bool create: false,
      FieldInfos field_infos,
      analysis.Analyzer analyzer,
      int chunk_size: 0x100000,
      int max_buffer_memory: 0x1000000,
      int term_index_interval: 128,
      int doc_skip_interval: 16,
      int merge_factor: 10,
      int max_buffered_docs: 10000,
      max_merge_docs,
      int max_field_length: 10000,
      bool use_compound_file: true}) {
    var p_store = dir != null ? dir.handle : 0;
    var p_analyzer = analyzer != null ? analyzer.handle : 0;
    var p_fis = field_infos != null ? field_infos.handle : 0;
    // TODO: remaining args
    int h = ferret.callFunc('frjs_iw_init', [
      create ? 1 : 0,
      create_if_missing ? 1 : 0,
      p_store,
      p_analyzer,
      p_fis
    ]);
    return new IndexWriter._(ferret, h); //, analyzer);
  }

  IndexWriter._(this._ferret, this.handle); //, this._analyzer);

  /// Returns the number of documents in the [Index]. Note that deletions
  /// won't be taken into account until the [IndexWriter] has been committed.
  int doc_count() => _ferret.callFunc('frt_iw_doc_count');

  /// Close the [IndexWriter]. This will close and free all resources used
  /// exclusively by the index writer. The garbage collector will do this
  /// automatically if not called explicitly.
  void close() {
    _ferret.callFunc('frt_iw_close', [handle]);
  }

  /// Add a document to the index. See [Document]. A document can also be a
  /// simple map object.
  void add_document(doc) {
    int p_doc = _ferret.callFunc('frt_doc_new');

    if (doc is Map) {
      if (doc.containsKey('boost') && doc['boost'] is num) {
        _ferret.callFunc(
            'frjs_doc_set_boost', [p_doc, doc['boost'].toDouble()]);
      }

      doc.forEach((k, v) {
        if (k == null) {
          return;
        }

        int symbol = _ferret.intern(k);

        int p_df = _ferret.callFunc('frt_doc_get_field', [p_doc, symbol]);
        if (p_df == 0) {
          p_df = _ferret.callFunc('frt_df_new', [symbol]);
        }

        if (v is Map && v.containsKey('boost') && v['boost'] is num) {
          _ferret.callFunc('frjs_df_set_boost', [p_df, v['boost'].toDouble()]);
        }

        if (v is List) {
          _ferret.callFunc('frjs_df_set_destroy_data', [p_df, 1]);
          v.forEach((a) {
            var a_str = a.toString();
            int p_a = _ferret.heapString(a_str);
            _ferret.callFunc('frt_df_add_data_len', [p_df, p_a, a_str.length]);
            _ferret.free(p_a);
          });
        } else if (v is String) {
          int p_v = _ferret.heapString(v);
          _ferret.callFunc('frt_df_add_data_len', [p_df, p_v, v.length]);
          _ferret.free(p_v);
        } else {
          _ferret.callFunc('frjs_df_set_destroy_data', [p_df, 1]);

          var v_str = v.toString();
          int p_v = _ferret.heapString(v_str);
          _ferret.callFunc('frt_df_add_data_len', [p_df, p_v, v_str.length]);
          _ferret.free(p_v);
        }
        _ferret.callFunc('frt_doc_add_field', [p_doc, p_df]);
      });
    } else if (doc is List) {
      int fsym_content = _ferret.intern('content');

      int p_df = _ferret.callFunc('frt_df_new', [fsym_content]);

      _ferret.callFunc('frjs_df_set_destroy_data', [p_df, 1]);

      doc.forEach((a) {
        var a_str = a.toString();
        int p_a = _ferret.heapString(a_str);
        _ferret.callFunc('frt_df_add_data_len', [p_df, p_a, a_str.length]);
        _ferret.free(p_a);
      });
      _ferret.callFunc('frt_doc_add_field', [p_doc, p_df]);
    } else if (doc is String) {
      int fsym_content = _ferret.intern('content');

      int p_df = _ferret.callFunc('frt_df_new', [fsym_content]);

      int p_v = _ferret.heapString(doc);
      _ferret.callFunc('frt_df_add_data_len', [p_df, p_v, doc.length]);
      _ferret.free(p_v);

      _ferret.callFunc('frt_doc_add_field', [p_doc, p_df]);
    } else {
      int fsym_content = _ferret.intern('content');

      int p_df = _ferret.callFunc('frt_df_new', [fsym_content]);

      var s = doc.toString();
      int p_v = _ferret.heapString(s);
      _ferret.callFunc('frt_df_add_data_len', [p_df, p_v, s.length]);
      _ferret.free(p_v);

      _ferret.callFunc('frt_doc_add_field', [p_doc, p_df]);
    }

    _ferret.callFunc('frt_iw_add_doc', [handle, p_doc]);
    _ferret.callFunc('frt_doc_destroy', [p_doc]);
  }

  /// Alias for [add_document].
  operator <<(doc) => add_document(doc);

  /// Optimize the index for searching. This commits any unwritten data to the
  /// index and optimizes the index into a single segment to improve search
  /// performance. This is an expensive operation and should not be called too
  /// often. The best time to call this is at the end of a long batch indexing
  /// process. Note that calling the optimize method do not in any way effect
  /// indexing speed (except for the time taken to complete the optimization
  /// process).
  void optimize() => _ferret.callFunc('frt_iw_optimize');

  /// Explicitly commit any changes to the index that may be hanging around in
  /// memory. You should call this method if you want to read the latest index
  /// with an [IndexWriter].
  void commit() => _ferret.callFunc('frt_iw_commit');

  /// Use this method to merge other indexes into the one being written by
  /// [IndexWriter]. This is useful for parallel indexing. You can have
  /// several indexing processes running in parallel, possibly even on
  /// different machines. Then you can finish by merging all of the indexes
  /// into a single index.
  //void add_readers(List readers) => frb_iw_add_readers;

  /// Delete all documents in the index with the given [term] in
  /// the field [field]. You should usually have a unique document id which
  /// you use with this method, rather then deleting all documents with the
  /// word "the" in them. There are of course exceptions to this rule. For
  /// example, you may want to delete all documents with the term "viagra"
  /// when deleting spam.
  void delete(String field, String term) {
    var p_term = _ferret.heapString(term);
    int symbol = _ferret.intern(field);

    _ferret.callFunc('frt_iw_delete_term', [handle, symbol, p_term]);

    _ferret.free(p_term);
  }

  /// Delete all documents in the index with the given [terms] in
  /// the field [field]. You should usually have a unique document id which
  /// you use with this method, rather then deleting all documents with the
  /// word "the" in them. There are of course exceptions to this rule. For
  /// example, you may want to delete all documents with the term "viagra"
  /// when deleting spam.
  void deleteAll(String field, List<String> terms) {
    terms.forEach((term) => delete(field, term)); // TODO: alloc field once
  }

  /// Get the [FieldInfos] object for this [IndexWriter]. This is useful if
  /// you need to dynamically add new fields to the index with specific
  /// properties.
  FieldInfos get field_infos => new FieldInfos._wrap(
      _ferret, _ferret.callFunc('frjs_iw_field_infos', [handle]));

  /// Get the [Analyzer] for this [IndexWriter]. This is useful if you need
  /// to use the same analyzer in a [QueryParser].
  /*analysis.Analyzer get analyzer {
    if (_analyzer != null) {
      _analyzer.handle = _ferret.callFunc('frjs_iw_get_analyzer', [handle]);
      return _analyzer;
    }
    return null;
  }*/

  /// Set the [Analyzer] for this [IndexWriter]. This is useful if you need to
  /// change the analyzer for a special document. It is risky though as the
  /// same analyzer will be used for all documents during search.
  /*void set analyzer(analysis.Analyzer a) {
    _ferret.callFunc('frjs_iw_set_analyzer', [handle, a.handle]);
  }*/

  /// Returns the current version of the index writer.
  int get version => _ferret.callFunc('frjs_iw_version', [handle]);

  int get chunk_size => _ferret.callFunc('frjs_iw_get_chunk_size', [handle]);

  void set chunk_size(int size) {
    _ferret.callFunc('frjs_iw_set_chunk_size', [handle, size]);
  }

  int get max_buffer_memory =>
      _ferret.callFunc('frjs_iw_get_max_buffer_memory', [handle]);

  void set max_buffer_memory(int max) {
    _ferret.callFunc('frjs_iw_set_max_buffer_memory', [handle, max]);
  }

  int get term_index_interval =>
      _ferret.callFunc('frjs_iw_get_index_interval', [handle]);

  void set term_index_interval(int interval) {
    _ferret.callFunc('frjs_iw_set_index_interval', [handle, interval]);
  }

  int get doc_skip_interval =>
      _ferret.callFunc('frjs_iw_get_skip_interval', [handle]);

  void set doc_skip_interval(int interval) {
    _ferret.callFunc('frjs_iw_set_skip_interval', [handle, interval]);
  }

  int get merge_factor =>
      _ferret.callFunc('frjs_iw_get_merge_factor', [handle]);

  void set merge_factor(int factor) {
    _ferret.callFunc('frjs_iw_set_merge_factor', [handle, factor]);
  }

  int get max_buffered_docs =>
      _ferret.callFunc('frjs_iw_get_max_buffered_docs', [handle]);

  void set max_buffered_docs(int max) {
    _ferret.callFunc('frjs_iw_set_max_buffered_docs', [handle, max]);
  }

  int get max_merge_docs =>
      _ferret.callFunc('frjs_iw_get_max_merge_docs', [handle]);

  void set max_merge_docs(int max) {
    _ferret.callFunc('frjs_iw_set_max_merge_docs', [handle, max]);
  }

  int get max_field_length =>
      _ferret.callFunc('frjs_iw_get_max_field_length', [handle]);

  void set max_field_length(int len) {
    _ferret.callFunc('frjs_iw_set_max_field_length', [handle, len]);
  }

  bool get use_compound_file =>
      _ferret.callFunc('frjs_iw_get_use_compound_file', [handle]) != 0;

  void set use_compound_file(bool use) {
    _ferret.callFunc('frjs_iw_set_use_compound_file', [handle, use ? 1 : 0]);
  }
}
