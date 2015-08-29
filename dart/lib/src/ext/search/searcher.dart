library ferret.ext.search.searcher;

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
  var _offset;
  var _limit;
  var _start_doc;
  var _all;
  var _filter;
  var _filter_proc;
  var _c_filter_proc;
  var _sort;

  var _excerpt_length;
  var _num_excerpts;
  var _pre_tag;
  var _post_tag;
  var _ellipsis;

  Searcher() {
    frb_sea_init;
  }

  close() => frb_sea_close;
  reader() => frb_sea_get_reader;
  doc_freq() => frb_sea_doc_freq;
  get_document() => frb_sea_doc;
  operator []() => frb_sea_doc;
  max_doc() => frb_sea_max_doc;
  search() => frb_sea_search;
  search_each() => frb_sea_search_each;
  scan() => frb_sea_scan;
  explain() => frb_sea_explain;
  highlight() => frb_sea_highlight;
}

/// See [Searcher] for the methods that you can use on this object. A
/// [MultiSearcher] is used to search multiple sub-searchers. The most
/// efficient way to do this would be to open up an IndexReader on multiple
/// directories and creating a [Searcher] with that. However, if you decide
/// to implement a [RemoteSearcher], the [MultiSearcher] can be used to search
/// multiple machines at once.
class MultiSearcher extends Searcher {
  MultiSearcher() {
    frb_ms_init;
  }
}
