library ferret.index;

import 'ext/store.dart';
import 'ext/index.dart';
import 'ext/analysis/analysis.dart' as analysis;
import 'ext/search/search.dart';
import 'ext/query_parser.dart';

import 'field_infos_utils.dart';

class Index {
  var _key;
  FieldInfos _field_infos;
  bool _close_dir;
  String _path;
  bool _auto_flush;

  IndexReader _reader;
  IndexWriter _writer;
  Searcher _searcher;
  analysis.Analyzer _analyzer;

  Directory _dir;

  String _id_field;
  String _default_field;
  String _default_input_field;

  bool _open;
  QueryParser _qp;

  bool _create, _create_if_missing;

  /// If you create an [Index] without any options, it'll simply create an
  /// index in memory. But this class is highly configurable and every option
  /// that you can supply to [IndexWriter] and [QueryParser], you can also set
  /// here. Please look at the options for the constructors to these classes.
  ///
  /// [default_input_field] specifies the default field that will be used when
  /// you add a simple string to the index using [add_document].
  /// [id_field] is the field to search when doing searches on a term. For
  /// example, if you do a lookup by term "cat", ie index["cat"], this will be
  /// the field that is searched.
  /// [key] should only be used if you really know what you are doing.
  /// You can set a field or an array of fields to be the key for the index.
  /// So if you add a document with a same key as an existing document, the
  /// existing document will be replaced by the new object.  Using a multiple
  /// field key will slow down indexing so it should not be done if
  /// performance is a concern. A single field key (or id) should be find
  /// however. Also, you must make sure that your key/keys are either
  /// untokenized or that they are not broken up by the analyzer.
  /// Set [auto_flush] to true if you want the index automatically flushed
  /// every time you do a write (includes delete) to the index.
  /// This is useful if you have multiple processes accessing the index and
  /// you don't want lock errors. Setting [auto_flush] to true has a huge
  /// performance impact so don't use it if you are concerned about
  /// performance. In that case you should think about setting up a DRb
  /// indexing service.
  /// [lock_retry_time] specifies how long to wait before retrying to obtain
  /// the commit lock when detecting if the [IndexReader] is at the latest
  /// version.
  /// If you explicitly pass a [Directory] object to this class and you want
  /// [Index] to close it when it is closed itself then set [close_dir] to
  /// true.
  /// To use [TypedRangeQuery] instead of the standard [RangeQuery] when
  /// parsing range queries set [use_typed_range_query] to true. This is
  /// useful if you have number fields which you want to perform range queries
  /// on. You won't need to pad or normalize the data in the field in anyway
  /// to get correct results. However, performance will be a lot slower for
  /// large indexes, hence the default.
  ///
  ///     var index = new Index.new(analyzer: new WhiteSpaceAnalyzer());
  ///
  ///     var index = new Index(path: '/path/to/index',
  ///       create_if_missing: false, auto_flush: true);
  ///
  ///     var index = new Index(dir: directory, default_slop: 2,
  ///       handle_parse_errors: false);
  ///
  /// You can also pass a [Function] if you like. The index will be yielded
  /// and closed at the index of the box. For example:
  ///
  ///     new Index.func((index) {
  ///       /// Do stuff with index. Most of your actions will be cached.
  ///     });
  Index({dir, String default_input_field: 'id', String id_field: 'id',
      String default_field, key, auto_flush: false, num lock_retry_time: 2,
      close_dir: false, bool use_typed_range_query: true, field_infos,
      bool create: false, bool create_if_missing: true,
      analysis.Analyzer analyzer})
      : _auto_flush = auto_flush,
        _close_dir = close_dir {
    if (key is Iterable) {
      _key = key.map((k) => k.toString());
    } else {
      _key = key;
    }

    if (field_infos is String) {
      _field_infos = FieldInfosUtils.load(field_infos);
    } else {
      _field_infos = field_infos;
    }

    _create = create;
    _create_if_missing = create_if_missing;

    if (dir is String) {
      _path = dir;
    }
    if (_path != null) {
      _close_dir = true;
      try {
        _dir = FSDirectory.create(_path, create: _create);
      } on IOError catch (io) {
        _dir = FSDirectory.create(_path, create: _create_if_missing);
      }
    } else if (dir != null) {
      _dir = dir;
    } else {
      _create = true; // this should always be true for a new RAMDir
      _close_dir = true;
      _dir = new RAMDirectory();
    }

    //@dir.extend(MonitorMixin) unless @dir.kind_of? MonitorMixin
    //options[:dir] = @dir
    //@options = options
    if (!_dir.exists("segments") || _create) {
      new IndexWriter(
          dir: _dir,
          path: _path,
          create_if_missing: _create_if_missing,
          create: _create,
          field_infos: _field_infos).close();
    }
    if (analyzer == null) {
      _analyzer = new analysis.StandardAnalyzer();
    } else {
      _analyzer = analyzer;
    }

    _searcher = null;
    _writer = null;
    _reader = null;

    _create = false; // only create the first time if at all
    if (id_field == null && key is String) {
      _id_field = key;
    } else if (id_field != null) {
      _id_field = id_field;
    } else {
      _id_field = "id";
    }
    if (default_field != null) {
      _default_field = default_field;
    } else {
      _default_field = '*';
    }
    if (default_input_field != null) {
      _default_input_field = default_input_field;
    } else {
      _default_input_field = id_field;
    }

    /*if (default_input_field.respond_to(intern)) {
      _default_input_field = _default_input_field.intern;
    }*/
    _open = true;
    _qp = null;
    /*if (block) {
      yield self;
      self.close
    }*/
  }

  /// Returns an array of strings with the matches highlighted. The [query] can
  /// either a query [String] or a [Query] object. The [doc_id] is the id of
  /// the document you want to highlight (usually returned by the search
  /// methods). There are also a number of options you can pass.
  ///
  /// The [default_field] is the field that is usually highlighted but you can
  /// specify which [field] you want to highlight. If you want to highlight
  /// multiple fields then you will need to call this method multiple times.
  /// Highlighted terms will be in the centre of the excerpt. Set
  /// [excerpt_length] to `all` to highlight the entire field.
  /// [pre_tag] is the tag to place to the left of the match. You'll probably
  /// want to change this to a "<span>" tag with a class. Try `\033[36m` for
  /// use in a terminal.
  /// [post_tag] should close the [pre_tag]. Try tag `\033[m` in the terminal.
  /// [ellipsis] is the string that is appended at the beginning and end of
  /// excerpts (unless the excerpt hits the start or end of the field.
  /// Alternatively you may want to use the HTML entity `&#8230;` or the UTF-8
  /// string `\342\200\246`.
  List<String> highlight(query, String doc_id, {field, int excerpt_length: 150,
      int num_excerpts: 2, String pre_tag: '<b>', String post_tag: '</b>',
      String ellipsis: '...'}) {
    //@dir.synchronize do
    _ensure_searcher_open();
    if (field == null) {
      field = _default_field;
    }
    return _searcher.highlight(_do_process_query(query), doc_id, field,
        excerpt_length: excerpt_length,
        num_excerpts: num_excerpts,
        pre_tag: pre_tag,
        post_tag: post_tag,
        ellipsis: ellipsis);
  }

  /// Closes this index by closing its associated reader and writer objects.
  void close() {
    //@dir.synchronize do
    if (!_open) {
      throw new StateError("tried to close an already closed directory");
    }
    if (_searcher != null) {
      _searcher.close();
    }
    if (_reader != null) {
      _reader.close();
    }
    if (_writer != null) {
      _writer.close();
    }
    if (_close_dir) {
      _dir.close();
    }

    _open = false;
  }

  /// Get the reader for this index.
  /// NOTE: This will close the writer from this index.
  IndexReader get reader {
    _ensure_reader_open();
    return _reader;
  }

  /// Get the searcher for this index.
  /// NOTE: This will close the writer from this index.
  Searcher get searcher {
    _ensure_searcher_open();
    return _searcher;
  }

  /// Get the writer for this index.
  /// NOTE: This will close the reader from this index.
  IndexWriter get writer {
    _ensure_writer_open();
    return _writer;
  }

  /// Adds a document to this index, using the provided [analyzer] instead of
  /// the local analyzer if provided.  If the document contains more than
  /// [IndexWriter.MAX_FIELD_LENGTH] terms for a given field, the remainder
  /// are discarded.
  ///
  /// There are three ways to add a document to the index.
  /// To add a document you can simply add a string or an array of strings.
  /// This will store all the strings in the "" (ie empty string) field
  /// (unless you specify the [default_field] when you create the index).
  ///
  ///     index.add("This is a new document to be indexed");
  ///     index.addAll(["And here", "is another", "new document", "to be indexed"]);
  ///
  /// But these are pretty simple documents. If this is all you want to index
  /// you could probably just use [SimpleSearch]. So let's give our documents
  /// some fields:
  ///
  ///     index.addDocument({"title": "Programming Ruby", "content": "blah blah blah"});
  ///     index.addDocument({"title": "Programming Ruby", "content": "yada yada yada"});
  ///
  /// Or if you are indexing data stored in a database, you'll probably want
  /// to store the id:
  ///
  ///     index.addDocument({"id": row.id, "title": row.title, "date": row.date});
  ///
  /// See [FieldInfos] for more information on how to set field properties.
  void add_document(doc, [analysis.Analyzer analyzer]) {
    //@dir.synchronize do
    _ensure_writer_open();
    if (doc is String || doc is List) {
      doc = {_default_input_field: doc};
    }

    // delete existing documents with the same key
    if (_key != null) {
      if (_key is List) {
        _key.forEach((field) {
          var query = new BooleanQuery()
            ..add_query(new TermQuery(field, doc[field].to_s), occur: 'must');
          query_delete(query);
        });
      } else {
        var id = doc[_key];
        if (id != null) {
          _writer.delete(_key, term: id.toString());
        }
      }
    }
    _ensure_writer_open();

    if (analyzer != null) {
      var old_analyzer = _writer.analyzer;
      _writer.analyzer = analyzer;
      _writer.add_document(doc);
      _writer.analyzer = old_analyzer;
    } else {
      _writer.add_document(doc);
    }

    if (_auto_flush) {
      flush();
    }
  }

  /// Alias for [add_document].
  Index operator <<(doc) {
    add_document(doc);
    return this;
  }

  /// Run a query through the [Searcher] on the index. A [TopDocs] object is
  /// returned with the relevant results. The [query] is a built in [Query]
  /// object or a query string that can be parsed by the Ferret::QueryParser.
  ///
  /// The [offset] of the start of the section of the result-set to return.
  /// This is used for paging through results. Let's say you have a page
  /// size of 10. If you don't find the result you want among the first 10
  /// results then set [offset] to 10 and look at the next 10 results, then
  /// 20 and so on.
  /// This is the number of results you want returned, also called the page
  /// size. Set [limit] to `all` to return all results.
  /// A [Sort] object or [sort] string describing how the field should be
  /// sorted. A sort string is made up of field names which cannot contain
  /// spaces and the word `DESC` if you want the field reversed, all
  /// separated by commas. For example; `rating DESC, author, title`. Note
  /// that Ferret will try to determine a field's type by looking at the
  /// first term in the index and seeing if it can be parsed as an integer
  /// or a float. Keep this in mind as you may need to specify a fields type
  /// to sort it correctly. For more on this, see the documentation for
  /// [SortField].
  /// A [Filter] object to [filter] the search results with.
  /// [filter_proc] is a [Proc] which takes the `doc_id`, the `score` and the
  /// [Searcher] object as its parameters and returns a [bool] value
  /// specifying whether the result should be included in the result set.
  TopDocs search(query, {int offset: 0, int limit: 10, sort, Filter filter,
      Function filter_proc}) {
    //@dir.synchronize do
    return _do_search(query,
        offset: offset,
        limit: limit,
        sort: sort,
        filter: filter,
        filter_proc: filter_proc);
  }

  /// Run a query through the [Searcher] on the index. A [TopDocs] object is
  /// returned with the relevant results. The [query] is a [Query] object or a
  /// query string that can be validly parsed by the [QueryParser]. The
  /// [Searcher.search_each] method yields the internal document id (used to
  /// reference documents in the [Searcher] object like this;
  /// `searcher[doc_id]`) and the search score for that document. It is
  /// possible for the score to be greater than 1.0 for some queries and
  /// taking boosts into account. This method will also normalize scores to
  /// the range 0.0..1.0 when the max-score is greater than 1.0.
  ///
  /// Optionally, specify the [offset] of the start of the section of the
  /// result-set to return.
  /// This is used for paging through results. Let's say you have a page size
  /// of 10. If you don't find the result you want among the first 10 results
  /// then set [offset] to 10 and look at the next 10 results, then 20 and so
  /// on.
  /// [limit] is the number of results you want returned, also called the
  /// page size. Set [limit] to `all` to return all results.
  /// A [Sort] object or [sort] string describing how the field should be
  /// sorted. A sort string is made up of field names which cannot contain
  /// spaces and the word `DESC` if you want the field reversed, all
  /// separated by commas. For example; `rating DESC, author, title`. Note
  /// that Ferret will try to determine a field's type by looking at the first
  /// term in the index and seeing if it can be parsed as an integer or a
  /// float. Keep this in mind as you may need to specify a fields type to
  /// sort it correctly. For more on this, see the documentation for
  /// [SortField].
  /// [filter_proc] is a [Proc] which takes the `doc_id`, the `score` and the
  /// [Searcher] object as its parameters and returns a [bool] value
  /// specifying whether the result should be included in the result set.
  ///
  /// returns:: The total number of hits.
  ///
  ///     index.search_each(query) do |doc, score|
  ///       print("hit document number #{doc} with a score of #{score}");
  ///     }
  TopDocs search_each(query, {int offset: 0, int limit: 10, sort, Filter filter,
      Function filter_proc}) {
    //# :yield: doc, score
    //@dir.synchronize do
    _ensure_searcher_open();
    query = _do_process_query(query);

    _searcher.search_each(query,
        offset: offset,
        limit: limit,
        sort: sort,
        filter: filter,
        filter_proc: filter_proc,
        fn: (doc, score) {
      //yield doc, score
    });
  }

  /// Run a query through the [Searcher] on the index, ignoring scoring and
  /// starting at [start_doc] and stopping when [limit] matches have been
  /// found. It returns an array of the matching document numbers.
  ///
  /// There is a big performance advange when using this search method on a
  /// very large index when there are potentially thousands of matching
  /// documents and you only want say 50 of them. The other search methods need
  /// to look at every single match to decide which one has the highest score.
  /// This search method just needs to find [limit] number of matches before
  /// it returns.
  ///
  /// Optionally, specify the [start_doc] to start the search from.
  /// NOTE: very carefully that this is not the same as the `offset` parameter
  /// used in the other search methods which refers to the offset in the
  /// result-set. This is the document to start the scan from. So if you
  /// scanning through the index in increments of 50 documents at a time
  /// you need to use the last matched doc in the previous search to start
  /// your next search. See the example below.
  /// [limit] is the number of results you want returned, also called the
  /// page size. Set [limit] to `all` to return all results.
  ///
  /// TODO: add option to return loaded documents instead.
  ///
  ///     start_doc = 0
  ///     begin
  ///       results = @searcher.scan(query, :start_doc => start_doc)
  ///       yield results # or do something with them
  ///       start_doc = results.last
  ///       /// start_doc will be nil now if results is empty, ie no more matches
  ///     end while start_doc
  List<int> scan(query, {int start_doc: 0, int limit: 50}) {
    //@dir.synchronize do
    _ensure_searcher_open();
    query = _do_process_query(query);

    return _searcher.scan(query, start_doc: start_doc, limit: limit);
  }

  /// Retrieves a document/documents from the index. The method for retrieval
  /// depends on the type of the argument passed.
  ///
  /// If [arg] is an [int] then return the document based on the internal
  /// document number.
  ///
  /// If [arg] is a [Range], then return the documents within the range based
  /// on internal document number.
  ///
  /// If [arg] is a [String] then search for the first document with [arg] in
  /// the [id] field. The [id] field is either `id` or whatever you set
  /// `id_field` parameter to when you create the Index object.
  LazyDoc doc(arg) {
    //@dir.synchronize do
    var id = arg;
    if (id is String) {
      _ensure_reader_open();
      var term_doc_enum = _reader.term_docs_for(_id_field, id);
      return term_doc_enum.next() ? _reader[term_doc_enum.doc()] : null;
    } else {
      _ensure_reader_open(false);
      return _reader[arg];
    }
  }

  LazyDoc operator [](arg) => doc(arg);

  /// Retrieves the `term_vector` for a document. The document can be
  /// referenced by either a string [id] to match the id field or an integer
  /// corresponding to Ferret's document number.
  ///
  /// See: [IndexReader.term_vector]
  TermVector term_vector(id, field) {
    //@dir.synchronize do
    _ensure_reader_open();
    if (id is String || id is Symbol) {
      var term_doc_enum = _reader.term_docs_for(_id_field, id.to_s);
      if (term_doc_enum.next != null) {
        id = term_doc_enum.doc;
      } else {
        return null;
      }
    }
    return _reader.term_vector(id, field);
  }

  /// Iterate through all documents in the index. This method preloads the
  /// documents so you don't need to call [load] on the document to load all
  /// the fields.
  void each(fn(doc)) {
    //@dir.synchronize do
    _ensure_reader_open();
    for (int i = 0; i < _reader.max_doc(); i++) {
      if (!_reader.deleted(i)) {
        //yield _reader[i].load
        fn(_reader[i].load());
      }
    }
  }

  /// Deletes a document/documents from the index. The method for determining
  /// the document to delete depends on the type of the argument passed.
  ///
  /// If [arg] is an [int] then delete the document based on the internal
  /// document number. Will raise an error if the document does not exist.
  ///
  /// If [arg] is a [String] then search for the documents with [arg] in the
  /// id field. The id field is either `id` or whatever you set `id_field`
  /// parameter to when you create the [Index] object. Will fail quietly if
  /// the no document exists.
  ///
  /// If [arg] is a [Map] or a [List] then a batch delete will be performed.
  /// If [arg] is an [List] then it will be considered an array of `id`'s. If
  /// it is a [Map], then its keys will be used instead as the [List] of
  /// document `id`'s. If the `id` is an [int] then it is considered a
  /// Ferret document number and the corresponding document will be deleted.
  /// If the `id` is a [String] or a [Symbol] then the `id` will be considered
  /// a term and the documents that contain that term in the `id_field` will
  /// be deleted.
  void delete(arg) {
    //@dir.synchronize do
    if (arg is String) {
      _ensure_writer_open();
      _writer.delete(_id_field, term: arg);
    } else if (arg is int) {
      _ensure_reader_open();
      var cnt = _reader.delete(arg);
    } else if (arg is Map || arg is List) {
      _batch_delete(arg);
    } else {
      throw new ArgumentError("Cannot delete for arg of type #{arg.class}");
    }
    if (_auto_flush) {
      flush();
    }
  }

  /// Delete all documents returned by the query.
  ///
  /// The [query] can either be a [String] (in which case it is parsed by the
  /// standard query parser) or an actual query object.
  void query_delete(query) {
    //@dir.synchronize do
    _ensure_writer_open();
    _ensure_searcher_open();
    query = _do_process_query(query);
    _searcher.search_each(query, limit: "all").forEach((doc, score) {
      _reader.delete(doc);
    });
    if (_auto_flush) {
      flush();
    }
  }

  /// Returns true if document +n+ has been deleted
  bool deleted(n) {
    //@dir.synchronize do
    _ensure_reader_open();
    return _reader.deleted(n);
  }

  /// Update the document referenced by the document number [id] if [id] is an
  /// integer or all of the documents which have the term [id] if [id] is a
  /// term.
  /// For batch update of set of documents, for performance reasons, see
  /// [batch_update].
  ///
  /// [id] is the number of the document to update. Can also be a string
  /// representing the value in the `id` field. Also consider using the
  /// `key` attribute.
  void update(id, Map new_doc) {
    //@dir.synchronize do
    _ensure_writer_open();
    delete(id);
    if (id is String || id is Symbol) {
      _writer.commit();
    } else {
      _ensure_writer_open();
    }
    _writer.add_document(new_doc);
    if (_auto_flush) {
      flush();
    }
  }

  /// Batch updates the documents in an index. You can pass either a [Map] or
  /// a [List].
  ///
  /// If you pass a [List] then each value needs to be a [Document] or a [Map]
  /// and each of those documents must have an [id_field] which will be used
  /// to delete the old document that this document is replacing.
  ///
  /// If you pass a [Map] then the keys of the [Map] will be considered the
  /// `id`'s and the values will be the new documents to replace the old ones
  /// with. If the `id` is an [int] then it is considered a Ferret document
  /// number and the corresponding document will be deleted.  If the `id` is a
  /// [String] or a [Symbol] then the `id` will be considered a term and the
  /// documents that contain that term in the [id_field] will be deleted.
  ///
  /// Note: No error will be raised if the document does not currently
  /// exist. A new document will simply be created.
  ///
  ///     /// will replace the documents with the id's id:133 and id:254
  ///     index.batch_update({
  ///       '133': {'id': '133', 'content': 'yada yada yada'},
  ///       '253': {'id': '253', 'content': 'bla bla bal'}
  ///     });
  ///
  ///     /// will replace the documents with the Ferret Document numbers 2 and 92
  ///     index.batch_update({
  ///       2: {'id': '133', 'content': 'yada yada yada'},
  ///       92: {'id': '253', 'content': 'bla bla bal'}
  ///     });
  ///
  ///     /// will replace the documents with the id's id:133 and id:254
  ///     /// this is recommended as it guarantees no duplicate keys
  ///     index.batch_update([
  ///       {'id': '133', 'content': 'yada yada yada'},
  ///       {'id': '253', 'content': 'bla bla bal'}
  ///     ]);
  void batch_update(docs) {
    //@dir.synchronize do
    var ids = null;
//    var values = null;
    if (docs is List) {
      to_s(v) => v == null ? v : v.toString();
      var ids = docs.map((doc) => to_s(doc[_id_field])).toList();
      if (ids.contains(null)) {
        throw new ArgumentError("all documents must have an ${_id_field} "
            "field when doing a batch update");
      }
    } else if (docs is Map) {
      ids = docs.keys;
      docs = docs.values;
    } else {
      throw new ArgumentError("must pass Map or Array");
    }
    _batch_delete(ids);
    _ensure_writer_open();
    docs.forEach((new_doc) => _writer.add_document(new_doc));
    flush();
  }

  /// Update all the documents returned by the query.
  ///
  /// Set the [query] to find documents you wish to update. Can either be
  /// a string (in which case it is parsed by the standard query parser) or
  /// an actual query object.
  /// [new_val] is the values we are updating. This can be a [String] in which
  /// case the default field is updated, or it can be a [Map], in which case,
  /// all fields in the map are merged into the old map. That is, the old
  /// fields are replaced by values in the new map if they exist.
  ///
  ///     index.add({'id': "26", 'title': "Babylon", 'artist': "David Grey"});
  ///     index.add({'id': "29", 'title': "My Oh My", 'artist': "David Grey"});
  ///
  ///     /// correct
  ///     index.query_update('artist:"David Grey"', {'artist': "David Gray"});
  ///
  ///     index["26"]
  ///     ///=> {'id': "26", 'title': "Babylon", 'artist': "David Gray"}
  ///     index["28"]
  ///     ///=> {'id': "28", 'title': "My Oh My", 'artist': "David Gray"}
  query_update(query, new_val) {
    //@dir.synchronize do
    _ensure_writer_open();
    _ensure_searcher_open();
    var docs_to_add = [];
    query = _do_process_query(query);
    _searcher.search_each(query, limit: 'all').forEach((id, score) {
      var document = _searcher[id].load;
      if (new_val is Map) {
        document.merge /*!*/ (new_val);
      } else if (new_val is String || new_val is Symbol) {
        document[_default_input_field] = new_val.to_s;
      }
      docs_to_add.add(document);
      _reader.delete(id);
    });
    _ensure_writer_open();
    docs_to_add.forEach((doc) => _writer.add_document(doc));
    if (_auto_flush) {
      flush();
    }
  }

  /// Returns true if any documents have been deleted since the index was last
  /// flushed.
  bool has_deletions() {
    //@dir.synchronize do
    _ensure_reader_open();
    return _reader.has_deletions();
  }

  /// Flushes all writes to the index. This will not optimize the index but it
  /// will make sure that all writes are written to it.
  ///
  /// NOTE: This is not necessary if you are only using this class. All writes
  /// will automatically flush when you perform an operation that reads the
  /// index.
  flush() {
    //@dir.synchronize do
    if (_reader != null) {
      if (_searcher != null) {
        _searcher.close();
        _searcher = null;
      }
      _reader.commit();
    } else if (_writer != null) {
      _writer.close();
      _writer = null;
    }
  }

  /// Alias for [flush].
  commit() => flush();

  /// Optimizes the index. This should only be called when the index will no
  /// longer be updated very often, but will be read a lot.
  optimize() {
    //@dir.synchronize do
    _ensure_writer_open();
    _writer.optimize();
    _writer.close();
    _writer = null;
  }

  /// Returns the number of documents in the index.
  int size() {
    //@dir.synchronize do
    _ensure_reader_open();
    return _reader.num_docs();
  }

  /// Merges all segments from an index or an array of indexes into this
  /// index. You can pass a single [Index], [Reader], [Directory] or an array
  /// of any single one of these.
  ///
  /// This may be used to parallelize batch indexing. A large document
  /// collection can be broken into sub-collections. Each sub-collection can
  /// be indexed in parallel, on a different thread, process or machine and
  /// perhaps all in memory. The complete index can then be created by
  /// merging sub-collection indexes with this method.
  ///
  /// After this completes, the index is optimized.
  void add_indexes(List indexes) {
    //@dir.synchronize do
    _ensure_writer_open();
    flatten(input) => input.expand((x) => x is Iterable ? flatten(x) : [x]);
    indexes = flatten(indexes); // make sure we have an array
    if (indexes.length == 0) {
      return; // nothing to do
    }
    if (indexes[0] is Index) {
      indexes.remove(this); // don't merge with self
      indexes = indexes.map((index) => index.reader).toList();
    } else if (indexes[0] is Directory) {
      indexes.remove(_dir); // don't merge with self
      indexes = indexes.map((dir) => new IndexReader(dir)).toList();
    } else if (indexes[0] is IndexReader) {
      indexes.remove(_reader); // don't merge with self
    } else {
      throw new ArgumentError(
          "Unknown index type when trying to merge indexes");
    }
    _ensure_writer_open();
    _writer.add_readers(indexes);
  }

  /// This is a simple utility method for saving an in memory or RAM index to
  /// the file system. The same thing can be achieved by using the
  /// [Index.add_indexes] method and you will have more options when
  /// creating the new index, however this is a simple way to turn a RAM index
  /// into a file system index.
  ///
  /// [directory] can either be a [Directory] object or a [String]
  /// representing the path to the directory where you would like to store the
  /// index.
  ///
  /// Set [create] true if you'd like to create the directory if it doesn't
  /// exist or copy over an existing directory. False if you'd like to merge
  /// with the existing directory.
  void persist(directory, [create = true]) {
    //synchronize do
    _close_all();
    var old_dir = _dir;
    if (directory is String) {
      _dir = FSDirectory.create(directory, create: create);
    } else if (directory is Directory) {
      _dir = directory;
    }
    //_dir.extend(MonitorMixin) unless @dir.kind_of? MonitorMixin
    //_dir = _dir;
    _create_if_missing = true;
    add_indexes([old_dir]);
  }

  String toString() {
    var buf = new StringBuffer();
    for (int i = 0; i < size(); i++) {
      if (!deleted(i)) {
        buf.write(this[i].toString() + "\n");
      }
    }
    return buf.toString();
  }

  /// Returns an [Explanation] that describes how [doc_id] scored against
  /// [query].
  ///
  /// This is intended to be used in developing [Similarity] implementations,
  /// and, for good performance, should not be displayed with every hit.
  /// Computing an explanation is as expensive as executing the query over the
  /// entire index.
  Explanation explain(query, doc_id) {
    //@dir.synchronize do
    _ensure_searcher_open();
    query = _do_process_query(query);

    return _searcher.explain(query, doc_id);
  }

  /// Turn a [query] string into a [Query] object with the [Index]'s
  /// [QueryParser].
  Query process_query(query) {
    //@dir.synchronize do
    _ensure_searcher_open();
    return _do_process_query(query);
  }

  /// Returns the [field_infos] object so that you can add new fields to the
  /// index.
  FieldInfos field_infos() {
    //@dir.synchronize do
    _ensure_writer_open();
    return _writer.field_infos;
  }

  void _ensure_writer_open() {
    if (!_open) {
      throw "tried to use a closed index";
    }
    if (_writer != null) {
      return;
    }
    if (_reader != null) {
      if (_searcher != null) {
        _searcher.close();
      }
      _reader.close();
      _reader = null;
      _searcher = null;
    }
    var w = new IndexWriter(
        dir: _dir,
        path: _path,
        create_if_missing: _create_if_missing,
        create: _create,
        field_infos: _field_infos,
        analyzer: _analyzer);
    _writer = w;
  }

  /// Returns the new reader if one is opened.
  IndexReader _ensure_reader_open([get_latest = true]) {
    if (!_open) {
      throw "tried to use a closed index";
    }
    if (_reader != null) {
      if (get_latest) {
        var latest = false;
        try {
          latest = _reader.latest();
        } on LockError catch (le) {
          sleep(
              _options['lock_retry_time']); // sleep for 2 seconds and try again
          latest = _reader.latest();
        }
        if (!latest) {
          if (_searcher != null) {
            _searcher.close();
          }
          _reader.close();
          _reader = new IndexReader(_dir);
          return _reader;
        }
      }
    } else {
      if (_writer != null) {
        _writer.close();
        _writer = null;
      }
      _reader = new IndexReader(_dir);
      return _reader;
    }
    return null; //false;
  }

  _ensure_searcher_open() {
    if (!_open) {
      throw "tried to use a closed index";
    }
    if (_ensure_reader_open() != null || _searcher == null) {
      _searcher = new Searcher(_reader);
    }
  }

  List _fields, _tokenized_fields, _all_fields;

  Query _do_process_query(query) {
    if (query is String) {
      if (_qp == null) {
        _qp = new QueryParser(_options);
      }
      /// we need to set this every time, in case a new field has been added
      if (_all_fields == false && _fields == null) {
        _qp.fields = _reader.fields;
      }
      if (_tokenized_fields == null) {
        _qp.tokenized_fields = _reader.tokenized_fields();
      }
      query = _qp.parse(query);
    }
    return query;
  }

  TopDocs _do_search(query,
      {offset: 0, limit: 10, sort, Filter filter, filter_proc}) {
    _ensure_searcher_open();
    query = _do_process_query(query);

    return _searcher.search(query,
        offset: offset,
        limit: limit,
        sort: sort,
        filter: filter,
        filter_proc: filter_proc);
  }

  void _close_all() {
    //@dir.synchronize do
    if (_searcher != null) {
      _searcher.close();
    }
    if (_reader != null) {
      _reader.close();
    }
    if (_writer != null) {
      ;
    }
    _reader = null;
    _searcher = null;
    _writer = null;
  }

  /// If [docs] is a [Map] or a [List] then a batch delete will be performed.
  /// If [docs] is a [List] then it will be considered an array of [id]'s. If
  /// it is a [Map], then its keys will be used instead as the [List] of
  /// document [id]'s. If the [id] is a [int] then it is considered a
  /// Ferret document number and the corresponding document will be deleted.
  /// If the [id] is a [String] or a [Symbol] then the [id] will be considered
  /// a term and the documents that contain that term in the [id_field] will
  /// be deleted.
  void _batch_delete(docs) {
    if (docs is Map) {
      docs = docs.keys;
    }
    if (docs is! List) {
      throw new ArgumentError("must pass List or Map");
    }
    var ids = [];
    var terms = [];
    docs.forEach((doc) {
      if (doc is String) {
        terms.add(doc);
//      } else if (doc is Symbol) {
//        terms.add(doc.to_s);
      } else if (doc is int) {
        ids.add(doc);
      } else {
        throw new ArgumentError("Cannot delete for arg of type #{id.class}");
      }
    });
    if (ids.length > 0) {
      _ensure_reader_open();
      ids.forEach((id) => _reader.delete(id));
    }
    if (terms.length > 0) {
      _ensure_writer_open();
      _writer.delete(_id_field, terms: terms);
    }
  }
}
