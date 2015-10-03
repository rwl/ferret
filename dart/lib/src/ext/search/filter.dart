part of ferret.ext.search;

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
  final Ferret _ferret;
  final int handle;

  Filter.wrap(this._ferret, this.handle);

  /// Get the bit_vector used by this filter. This method will usually be used
  /// to group filters or apply filters to other filters.
  BitVector bits(IndexReader index_reader) {
    int p_bv =
        _ferret.callMethod('_frt_filt_get_bv', [handle, index_reader.handle]);
    return new BitVector.wrap(_ferret, p_bv);
  }

  /// Return a human readable string representing the [Filter] object that the
  /// method was called on.
  String to_s() {
    int p_s = _ferret.callMethod('_frjs_f_to_s', [handle]);
    var s = _ferret.stringify(p_s);
    _ferret.free(p_s);
    return s;
  }
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
class RangeFilter extends Filter {
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
  factory RangeFilter(Ferret ferret, String field,
      {lower,
      upper,
      lower_exclusive,
      upper_exclusive,
      bool include_lower: false,
      bool include_upper: false,
      le,
      leq,
      ge,
      geq}) {
    int p_field = ferret.allocString(field);
    int symbol = ferret.callMethod('_frt_internal', [p_field]);
    ferret.free(p_field);

    RangeParams params = _range_params(lower, upper, lower_exclusive,
        upper_exclusive, include_lower, include_upper, le, leq, ge, geq);

    int lterm = 0;
    int uterm = 0;
    if (params.lterm != null) {
      lterm = ferret.allocString(params.lterm);
    }
    if (params.uterm != null) {
      uterm = ferret.allocString(params.uterm);
    }

    int h = ferret.callMethod('_frt_rfilt_new', [
      symbol,
      lterm,
      uterm,
      params.include_lower ? 1 : 0,
      params.include_upper ? 1 : 0
    ]);
    ferret.free(lterm);
    ferret.free(uterm);
    return new RangeFilter._(ferret, h);
  }

  RangeFilter._(Ferret ferret, int handle) : super.wrap(ferret, handle);
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
class TypedRangeFilter extends Filter {
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
  factory TypedRangeFilter(Ferret ferret, String field,
      {lower,
      upper,
      lower_exclusive,
      upper_exclusive,
      bool include_lower: false,
      bool include_upper: false,
      le,
      leq,
      ge,
      geq}) {
    int p_field = ferret.allocString(field);
    int symbol = ferret.callMethod('_frt_internal', [p_field]);
    ferret.free(p_field);

    RangeParams params = _range_params(lower, upper, lower_exclusive,
        upper_exclusive, include_lower, include_upper, le, leq, ge, geq);

    int lterm = 0;
    int uterm = 0;
    if (params.lterm != null) {
      lterm = ferret.allocString(params.lterm);
    }
    if (params.uterm != null) {
      uterm = ferret.allocString(params.uterm);
    }

    int h = ferret.callMethod('_frt_trfilt_new', [
      symbol,
      lterm,
      uterm,
      params.include_lower ? 1 : 0,
      params.include_upper ? 1 : 0
    ]);
    ferret.free(lterm);
    ferret.free(uterm);
    return new TypedRangeFilter._(ferret, h);
  }

  TypedRangeFilter._(Ferret ferret, int handle) : super.wrap(ferret, handle);
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
class QueryFilter extends Filter {
  /// Create a new [QueryFilter] which applies the query [query].
  QueryFilter(Ferret ferret, Query query)
      : super.wrap(ferret, ferret.callMethod('_frt_qfilt_new', [query.handle]));
}
