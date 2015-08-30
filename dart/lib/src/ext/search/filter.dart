library ferret.ext.search.filter;

/// A [Filter] is used to filter query results. It is usually passed to one of
/// [Searcher]'s search methods however it can also be used inside a
/// [ConstantScoreQuery] or a [FilteredQuery]. To implement your own [Filter]
/// you must implement the method `get_bitvector(index_reader)` which returns
/// a [BitVector] with set bits corresponding to documents that are allowed by
/// this [Filter].
///
/// TODO: add support for user implemented Filter.
/// TODO: add example of user implemented Filter.
class Filter {
  var _bits;

  /// Get the bit_vector used by this filter. This method will usually be used
  /// to group filters or apply filters to other filters.
  BitVector bits(index_reader) => frb_f_get_bits;

  /// Return a human readable string representing the [Filter] object that the
  /// method was called on.
  to_s() => frb_f_to_s;
}

/// RangeFilter filters a set of documents which contain a lexicographical
/// range of terms (ie "aaa", "aab", "aac", etc). See also [RangeQuery]
///
/// Find all documents created before 5th of September 2002.
///
///     var filter = new RangeFilter('created_on', le: "20020905");
///
/// See [RangeQuery] for notes on how to use the [RangeFilter] on a field
/// containing numbers.
class RangeFilter {
  /// Create a new [RangeFilter] on field [field]. There are two ways to build
  /// a range filter. With the old-style options; [lower], [upper],
  /// [include_lower] and [include_upper] or the new style options; [le],
  /// [leq], [ge] and [geq]. The options' names should speak for themselves.
  /// In the old-style options, limits are inclusive by default.
  ///
  ///     var f = new RangeFilter('date', lower: "200501", include_lower: false);
  ///     // is equivalent to
  ///     var f = new RangeFilter('date', le: "200501");
  ///     // is equivalent to
  ///     var f = new RangeFilter('date', lower_exclusive: "200501");
  ///
  ///     var f = new RangeFilter('date', lower: "200501", upper: 200502);
  ///     // is equivalent to
  ///     var f = new RangeFilter('date', geq: "200501", leq: 200502);
  RangeFilter(field, {lower, upper, bool include_lower, bool include_upper, le,
      leq, ge, geq}) {
    frb_rf_init;
  }
}

/// [TypedRangeFilter] filters a set of documents which contain a
/// lexicographical range of terms (ie "aaa", "aab", "aac", etc), unless the
/// range boundaries happen to be numbers (positive, negative, integer,
/// float), in which case a numerical filter is applied. See also
/// [TypedRangeQuery].
///
/// Find all products that cost less than  or equal to $50.00.
///
///     var filter = new TypedRangeFilter('created_on', leq: "50.00");
class TypedRangeFilter {
  /// Create a new [TypedRangeFilter] on field [field]. There are two ways to
  /// build a range filter. With the old-style options; [lower], [upper],
  /// [include_lower] and [include_upper] or the new style options; [le],
  /// [leq], [ge] and [geq]. The options' names should speak for themselves.
  /// In the old-style options, limits are inclusive by default.
  ///
  ///     var f = new TypedRangeFilter('date', lower: "0.1", include_lower: false);
  ///     // is equivalent to
  ///     var f = new TypedRangeFilter('date', le: "0.1");
  ///     // is equivalent to
  ///     var f = new TypedRangeFilter('date', lower_exclusive: "0.1");
  ///
  ///     // Note that you numbers can be strings or actual numbers
  ///     var f = new TypedRangeFilter('date', lower: "-132.2", upper: -1.4);
  ///     // is equivalent to
  ///     var f = new TypedRangeFilter('date', geq: "-132.2", leq: -1.4);
  TypedRangeFilter(field, {lower, upper, bool include_lower, bool include_upper,
      le, leq, ge, geq}) {
    frb_trf_init;
  }
}

/// [QueryFilter] can be used to restrict one queries results by another
/// queries results, basically "and"ing them together. Of course you could
/// easily use a [BooleanQuery] to do this. The reason you may choose to use
/// a [QueryFilter] is that [Filter] results are cached so if you have one
/// query that is often added to other queries you may want to use a
/// [QueryFilter] for performance reasons.
///
/// Let's say you have a field [approved] which you set to yes when a
/// document is approved for display. You'll probably want to add a [Filter]
/// which filters approved documents to display to your users. This is the
/// perfect use case for a [QueryFilter].
///
///     var filter = new QueryFilter(new TermQuery('approved', "yes"));
///
/// Just remember to use the same QueryFilter each time to take advantage of
/// caching. Don't create a new one for each request.
class QueryFilter {
  /// Create a new [QueryFilter] which applies the query [query].
  QueryFilter(query) {
    frb_qf_init;
  }
}
