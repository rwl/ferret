part of ferret.ext.search;

/// The [Searcher] class basically performs the task that Ferret was built
/// for. It searches the index. To search the index the [Searcher] class wraps
/// an [IndexReader] so many of the tasks that you can perform on an
/// [IndexReader] are also available on a searcher including, most
/// importantly, accessing stored documents.
///
/// The main methods that you need to know about when using a [Searcher] are
/// the search methods. There is the [Searcher.search_each] method which
/// iterates through the results by document id and score and there is the
/// [Searcher.search] method which returns a [TopDocs] object. Another
/// important difference to note is that the [Searcher.search_each] method
/// normalizes the score to a value in the range 0.0..1.0 if the [max_score]
/// is greater than 1.0. [Searcher.search] does not. Apart from that they take
/// the same parameters and work the same way.
///
///     var searcher = new Searcher("/path/to/index");
///
///     searcher.search_each(new TermQuery('content', "ferret"),
///         filter: new RangeFilter('date', le: "2006"),
///         sort: "date DESC, title", (doc_id, score) {
///       print("${searcher[doc_id][title] scored ${score}");
///     });
class Searcher {
  final Ferret _ferret;
  final int handle;

  /// Create a new [Searcher] object. [dir] can either be a string path to an
  /// index directory on the file-system, an actual [Directory] object or a
  /// [IndexReader]. You should use the [IndexReader] for searching multiple
  /// indexes. Just open the [IndexReader] on multiple directories.
//  Searcher.dir(String path) {}

  factory Searcher.store(Ferret ferret, Directory dir) {
    int p_ir = ferret.callMethod('_frt_ir_open', [dir.handle]);
    return new Searcher._(ferret, p_ir);
  }

  factory Searcher(Ferret ferret, IndexReader ir) {
    return new Searcher._(ferret, ir.handle);
  }

  Searcher._(Ferret ferret, int p_ir)
      : _ferret = ferret,
        handle = ferret.callMethod('_frt_isea_new', [p_ir]) {
    ferret.callMethod('_frjs_searcher_set_close_ir', [handle, 0]);
  }

  /// Close the searcher. The garbage collector will do this for you or you can
  /// call this method explicitly.
  void close() => _ferret.callMethod('_frjs_sea_close', [handle]);

  /// Return the [IndexReader] wrapped by this searcher.
  IndexReader get reader {
    int p_ir = _ferret.callMethod('_frjs_sea_get_reader', [handle]);
    return new IndexReader.handle(p_ir);
  }

  /// Return the number of documents in which the term [term] appears in the
  /// field [field].
  int doc_freq(String field, String term) {
    int p_field = _ferret.allocString(field);
    int p_term = _ferret.allocString(term);
    int freq =
        _ferret.callMethod('_frjs_sea_doc_freq', [handle, p_field, p_term]);
    _ferret.free(p_field);
    _ferret.free(p_term);
    return freq;
  }

  /// Retrieve a document from the index. See [LazyDoc] for more details on
  /// the document returned. Documents are referenced internally by document
  /// ids which are returned by the Searchers search methods.
  LazyDoc get_document(int doc_id) {
    int p_ld = _ferret.callMethod('_frjs_sea_doc', [handle, doc_id]);
    return new LazyDoc.handle(p_ld);
  }

  /// Alias for [get_document].
  LazyDoc operator [](int doc_id) => get_document(doc_id);

  /// Returns 1 + the maximum document id in the index. It is the
  /// document_id that will be used by the next document added to the index.
  /// If there are no deletions, this number also refers to the number of
  /// documents in the index.
  int max_doc() => _ferret.callMethod('_frjs_sea_max_doc', [handle]);

  /// Run a query through the [Searcher] on the index. A [TopDocs] object is
  /// returned with the relevant results. The [query] is a built in [Query]
  /// object.
  ///
  /// [offset] is the offset of the start of the section of the
  /// result-set to return. This is used for paging through results. Let's
  /// say you have a page size of 10. If you don't find the result you want
  /// among the first 10 results then set [offset] to 10 and look at the next
  /// 10 results, then 20 and so on.
  /// [limit] is the number of results you want returned, also called the page
  /// size. Set [limit] to `all` to return all results.
  /// [sort] is a [Sort] object or sort string describing how the field
  /// should be sorted. A sort string is made up of field names which cannot
  /// contain spaces and the word "DESC" if you want the field reversed, all
  /// separated by commas. For example; "rating DESC, author, title". Note
  /// that Ferret will try to determine a field's type by looking at the first
  /// term in the index and seeing if it can be parsed as an integer or a
  /// float. Keep this in mind as you may need to specify a fields type to
  /// sort it correctly. For more on this, see the documentation for
  /// [SortField].
  /// [filter] is a [Filter] object to filter the search results with.
  /// [filter_proc] is a Proc which takes the doc_id, the score and the
  /// [Searcher] object as its parameters and returns either a [bool] value
  /// specifying whether the result should be included in the result set, or
  /// a [double] between 0 and 1.0 to be used as a factor to scale the score
  /// of the object. This can be used, for example, to weight the score
  /// of a matched document by it's age.
  TopDocs search(Query query,
      {int offset: 0,
      int limit: 10,
      Sort sort,
      Filter filter /*, filter_proc*/}) {
    if (offset < 0) {
      throw new ArgumentError("offset must be >= 0");
    }
    if (limit == 0 || limit < -1) {
      throw new ArgumentError.value(limit, 'limit');
    }
    int p_td = _ferret.callMethod('_frjs_sea_search',
        [handle, query.handle, offset, limit, filter.handle, sort.handle]);
    return new TopDocs._module(_ferret, p_td, this);
  }

  /// Run a query through the [Searcher] on the index. A [TopDocs] object is
  /// returned with the relevant results. The [query] is a Query object. The
  /// [Searcher.search_each] method yields the internal document id (used to
  /// reference documents in the [Searcher] object like this;
  /// `searcher[doc_id]`) and the search score for that document. It is
  /// possible for the score to be greater than 1.0 for some queries and
  /// taking boosts into account. This method will also normalize scores to
  /// the range 0.0..1.0 when the max-score is greater than 1.0.
  ///
  /// [offset] is the offset of the start of the section of the result-set to
  /// return. This is used for paging through results. Let's say you have a
  /// page size of 10. If you don't find the result you want among the first
  /// 10 results then set [offset] to 10 and look at the next 10 results, then
  /// 20 and so on.
  /// [limit] is the number of results you want returned, also called the page
  /// size. Set [limit] to `all` to return all results.
  /// [sort] is a [Sort] object or sort string describing how the field should
  /// be sorted. A sort string is made up of field names which cannot contain
  /// spaces and the word "DESC" if you want the field reversed, all separated
  /// by commas. For example; "rating DESC, author, title". Note that Ferret
  /// will try to determine a field's type by looking at the first term in the
  /// index and seeing if it can be parsed as an integer or a float. Keep this
  /// in mind as you may need to specify a fields type to sort it correctly.
  /// For more on this, see the documentation for [SortField].
  /// [filter] is a [Filter] object to filter the search results with.
  /// [filter_proc] is a filter Proc is a Proc which takes the doc_id, the
  /// score and the [Searcher] object as its parameters and returns a [bool]
  /// value specifying whether the result should be included in the result
  /// set.
  int search_each(Query query, fn(int doc, double score),
      {int offset: 0,
      int limit: 10,
      Sort sort,
      Filter filter /*, filter_proc*/}) {
    var td =
        search(query, offset: offset, limit: limit, sort: sort, filter: filter);
    var max_score = td.max_score > 1.0 ? td.max_score : 1.0;
    for (var hit in td.hits) {
      fn(hit.doc, hit.score / max_score);
    }
    var total = td.total_hits;
    td.destroy();
    return total;
  }

  /// Run a query through the [Searcher] on the index, ignoring scoring and
  /// starting at [start_doc] and stopping when [limit] matches have been
  /// found. It returns an array of the matching document numbers.
  ///
  /// There is a big performance advange when using this search method on a
  /// very large index when there are potentially thousands of matching
  /// documents and you only want say 50 of them. The other search methods
  /// need to look at every single match to decide which one has the highest
  /// score. This search method just needs to find [limit] number of matches
  /// before it returns.
  ///
  /// [start_doc] is the document to start the search from. NOTE very
  /// carefully that this is not the same as the [offset] parameter used in
  /// the other search methods which refers to the offset in the result-set.
  /// This is the document to start the scan from. So if you scanning through
  /// the index in increments of 50 documents at a time you need to use the
  /// last matched doc in the previous search to start your next search.
  /// [limit] is the number of results you want returned, also called the page
  /// size. Set [limit] to `all` to return all results.
  ///
  /// TODO: add option to return loaded documents instead
  ///
  /// FIXME:
  ///     var start_doc = 0;
  ///     _searcher.scan(query, start_doc: start_doc, () {
  ///       start_doc = results.last;
  ///       // start_doc will be nil now if results is empty, ie no more matches
  ///     }); while start_doc
  List<int> scan(Query query, {int start_doc: 0, int limit: 50}) {
    if (start_doc < 0) {
      throw new ArgumentError("start_doc must be >= 0");
    }
    if (limit == -1) {
      limit = 65536;
    }
    if (limit <= 0) {
      throw new ArgumentError("limit must be > 0");
    }
    int p_count = _ferret.callMethod('_malloc', [Int32List.BYTES_PER_ELEMENT]);
    _ferret.callMethod('setValue', [p_count, 0, 'i32']);

    int p_array = _ferret.callMethod(
        '_frjs_sea_scan', [handle, query.handle, start_doc, limit, p_count]);

    int count = _ferret.callMethod('getValue', [p_count, 'i32']);
    _ferret.free(p_count);

    var array = new List<int>.from(
        _ferret.callMethod('getInt32Array', [p_array, count]));
    _ferret.free(p_array);
    return array;
  }

  /// Create an explanation object to explain the score returned for a
  /// particular document at [doc_id] in the index for the query [query].
  ///
  ///     print(searcher.explain(query, doc_id).to_s());
  Explanation explain(Query query, int doc_id) {
    int p_expl =
        _ferret.callMethod('_frjs_sea_explain', [handle, query.handle, doc_id]);
    return new Explanation._handle(_ferret, p_expl);
  }

  /// Returns an array of strings with the matches highlighted.
  ///
  /// [excerpt_length] is the length of excerpt to show. Highlighted terms
  /// will be in the centre of the excerpt. Set to `all` to highlight the
  /// entire field.
  /// [num_excerpts] is the number of excerpts to return.
  /// [pre_tag] is the tag to place to the left of the match. You'll probably
  /// want to change this to a "<span>" tag with a class. Try `\033[7m` for
  /// use in a terminal.
  /// [post_tag] is the tag that should close the [pre_tag]. Try tag `\033[m`
  /// in the terminal.
  /// [ellipsis] is the string that is appended at the beginning and end of
  /// excerpts (unless the excerpt hits the start or end of the field. You'll
  /// probably want to change this so a Unicode ellipsis character.
  List<String> highlight(Query query, int doc_id, String field,
      {excerpt_length: 150,
      num_excerpts: 2,
      pre_tag: "<b>",
      post_tag: "</b>",
      ellipsis: "..."}) {
    if (excerpt_length == -1) {
      excerpt_length = 65536 ~/ 2;
    }
    int p_field = _ferret.allocString(field);
    int p_pre_tag = _ferret.allocString(pre_tag);
    int p_post_tag = _ferret.allocString(post_tag);
    int p_ellipsis = _ferret.allocString(ellipsis);

    int p_size = _ferret.callMethod('_malloc', [Int32List.BYTES_PER_ELEMENT]);
    _ferret.callMethod('setValue', [p_size, 0, 'i32']);

    int pp_high = _ferret.callMethod('_frjs_sea_highlight', [
      handle,
      query.handle,
      doc_id,
      p_field,
      excerpt_length,
      num_excerpts,
      p_pre_tag,
      p_post_tag,
      p_ellipsis,
      p_size
    ]);

    int size = _ferret.callMethod('getValue', [p_size, 'i32']);
    _ferret.free(p_size);

    if (pp_high == 0) {
      return null;
    }
    var p_high = _ferret.callMethod('getUint8List', [pp_high, size]);
    var high = new List<String>(size);
    for (var i = 0; i < size; i++) {
      high[i] = _ferret.stringify(p_high[i]);
      _ferret.free(p_high[i]);
    }
    _ferret.free(pp_high);
    return high;
  }
}

/// See [Searcher] for the methods that you can use on this object. A
/// [MultiSearcher] is used to search multiple sub-searchers. The most
/// efficient way to do this would be to open up an IndexReader on multiple
/// directories and creating a [Searcher] with that. However, if you decide
/// to implement a [RemoteSearcher], the [MultiSearcher] can be used to search
/// multiple machines at once.
class MultiSearcher extends Searcher {
  /// Create a new [MultiSearcher] by passing a list of subsearchers to the
  /// constructor.
  factory MultiSearcher(Ferret ferret, List<Searcher> searchers) {
    int top = searchers.length;
    int p_seas =
        ferret.callMethod('_malloc', [Uint8List.BYTES_PER_ELEMENT * top]);
    for (int i = 0; i < top; i++) {
      ferret.callMethod('setValue', [
        p_seas + (i * Uint8List.BYTES_PER_ELEMENT),
        searchers[i].handle,
        'i8'
      ]);
    }
    int h = ferret.callMethod('_frt_msea_new', [p_seas, top, 0]);
    ferret.free(p_seas);
    return new MultiSearcher._(ferret, h);
  }

  MultiSearcher._(Ferret ferret, int h) : super._(ferret, h);
}
