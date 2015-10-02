/// The Spans library contains a number of SpanQueries. SpanQueries, unlike
/// regular queries, also return the start and end offsets of all of their
/// matches so they can be used to limit queries to a certain position in the
/// field. They are often used in combination to perform special types of
/// [PhraseQuery].
part of ferret.ext.search;

/// A [SpanTermQuery] is the Spans version of [TermQuery], the only difference
/// being that it returns the start and end offset of all of its matches for
/// use by enclosing SpanQueries.
class SpanTermQuery extends Query {
  SpanTermQuery.handle(Ferret ferret, int h) : super._(ferret, h);

  /// Create a new [SpanTermQuery] which matches all documents with the term
  /// [term] in the field [field].
  factory SpanTermQuery(Ferret ferret, field, term) {
    int p_field = ferret.allocString(field);
    int symbol = ferret.callMethod('_frt_intern', [p_field]);
    int p_term = ferret.allocString(term);
    int h = ferret.callMethod('_frt_spantq_new', [symbol, p_term]);
    ferret.free(p_field);
    ferret.free(p_term);
    return new SpanTermQuery.handle(ferret, h);
  }
}

/// A [SpanMultiTermQuery] is the Spans version of [MultiTermQuery], the only
/// difference being that it returns the start and end offset of all of its
/// matches for use by enclosing SpanQueries.
class SpanMultiTermQuery extends Query {
  SpanMultiTermQuery.handle(Ferret ferret, int h) : super._(ferret, h);

  /// Create a new [SpanMultiTermQuery] which matches all documents with the
  /// terms [terms] in the field [field].
  factory SpanMultiTermQuery(Ferret ferret, field, List<String> terms) {
    int p_field = ferret.allocString(field);
    int symbol = ferret.callMethod('_frt_intern', [p_field]);
    int h = ferret.callMethod('_frt_spanmtq_new', [symbol]);
    ferret.free(p_field);
    for (var term in terms) {
      int p_term = ferret.allocString(term);
      ferret.callMethod('_frt_spanmtq_add_term', [h, p_term]);
      ferret.free(p_term);
    }
    return new SpanMultiTermQuery.handle(ferret, h);
  }
}

/// A [SpanPrefixQuery] is the Spans version of [PrefixQuery], the only
/// difference being that it returns the start and end offset of all of its
/// matches for use by enclosing SpanQueries.
class SpanPrefixQuery extends Query {
  SpanPrefixQuery.handle(Ferret ferret, int h) : super._(ferret, h);

  /// Create a new [SpanPrefixQuery] which matches all documents with the
  /// prefix [prefix] in the field [field].
  factory SpanPrefixQuery(Ferret ferret, String field, String prefix,
      {int max_terms: 256}) {
    int p_field = ferret.allocString(field);
    int symbol = ferret.callMethod('_frt_intern', [p_field]);
    int p_prefix = ferret.allocString(prefix);
    int h = ferret.callMethod('_frt_spanprq_new', [symbol, p_prefix]);
    ferret.callMethod('_frjs_spq_set_max_terms', [h, max_terms]);
    ferret.free(p_field);
    ferret.free(p_prefix);
    return new SpanPrefixQuery.handle(ferret, h);
  }
}

/// A [SpanFirstQuery] restricts a query to search in the first [end] bytes
/// of a field. This is useful since often the most important information in
/// a document is at the start of the document.
///
/// To find all documents where "ferret" is within the first 100 characters
/// (really bytes):
///
///     var query = new SpanFirstQuery(new SpanTermQuery('content', "ferret"), 100);
///
/// NOTE: [SpanFirstQuery] only works with other SpanQueries.
class SpanFirstQuery extends Query {
  SpanFirstQuery.handle(Ferret ferret, int h) : super._(ferret, h);

  /// Create a new [SpanFirstQuery] which matches all documents where
  /// [span_query] matches before [end] where [end] is a byte-offset from the
  /// start of the field.
  SpanFirstQuery(Ferret ferret, Query span_query, int end)
      : super._(ferret,
            ferret.callMethod('_frt_spanfq_new', [span_query.handle, end]));
}

/// A [SpanNearQuery] is like a combination between a [PhraseQuery] and a
/// [BooleanQuery]. It matches sub-SpanQueries which are added as clauses but
/// those clauses must occur within a [slop] edit distance of each other. You
/// can also specify that clauses must occur [in_order].
///
///     var query = new SpanNearQuery(slop: 2);
///     query.add(new SpanTermQuery('field', "quick");
///     query.add(new SpanTermQuery('field', "brown");
///     query.add(new SpanTermQuery('field', "fox");
///     // matches => "quick brown speckled sleepy fox"
///                                   |______2______^
///     // matches => "quick brown speckled fox"
///                                    |__1__^
///     // matches => "brown quick _____ fox"
///                      ^_____2_____|
///
///     var query = new SpanNearQuery(slop: 2, in_order: true);
///     query.add(new SpanTermQuery('field', "quick");
///     query.add(new SpanTermQuery('field', "brown");
///     query.add(new SpanTermQuery('field', "fox");
///     // matches => "quick brown speckled sleepy fox"
///                                   |______2______^
///     // matches => "quick brown speckled fox"
///                                    |__1__^
///     // doesn't match => "brown quick _____ fox"
///     //  not in order       ^_____2_____|
///
/// NOTE: [SpanNearQuery] only works with other SpanQueries.
class SpanNearQuery extends Query {
  // var _slop, _in_order, _clauses;

  SpanNearQuery.handle(Ferret ferret, int h) : super._(ferret, h);

  /// Create a new [SpanNearQuery]. You can add an array of clauses with the
  /// [clause] parameter or you can add clauses individually using the
  /// [add] method.
  ///
  ///     var query = new SpanNearQuery(clauses: [spanq1, spanq2, spanq3]);
  ///     // is equivalent to
  ///     var query = new SpanNearQuery()
  ///       ..add(spanq1)
  ///       ..add(spanq2)
  ///       ..add(spanq3);
  ///
  /// [slop] works exactly like a [PhraseQuery] slop. It is the amount of slop
  /// allowed in the match (the term edit distance allowed in the match).
  /// [in_order] specifies whether or not the matches have to occur in the
  /// order they were added to the query. When slop is set to 0, this
  /// parameter will make no difference.
  SpanNearQuery(Ferret ferret,
      {List<Query> clauses, int slop: 0, bool in_order: false})
      : super._(ferret,
            ferret.callMethod('_frt_spannq_new', [slop, in_order ? 1 : 0])) {
    for (var clause in clauses) {
      this.add(clause);
    }
  }

  /// Add a clause to the [SpanNearQuery]. Clauses are stored in the order
  /// they are added to the query which is important for matching. Note that
  /// clauses must be SpanQueries, not other types of query.
  void add(Query span_query) {
    _ferret.callMethod('_frt_spannq_add_clause', [handle, span_query.handle]);
  }

  /// Alias for [add].
  void operator <<(Query span_query) => this.add(span_query);
}

/// [SpanOrQuery] is just like a [BooleanQuery] with all `should` clauses.
/// However, the difference is that all sub-clauses must be SpanQueries and
/// the resulting query can then be used within other SpanQueries like
/// [SpanNearQuery].
///
/// Combined with SpanNearQuery we can create a multi-PhraseQuery like query:
///
///     var quick_query = new SpanOrQuery();
///     quick_query.add(new SpanTermQuery('field', "quick");
///     quick_query.add(new SpanTermQuery('field', "fast");
///     quick_query.add(new SpanTermQuery('field', "speedy");
///
///     var colour_query = new SpanOrQuery();
///     colour_query.add(new SpanTermQuery('field', "red");
///     colour_query.add(new SpanTermQuery('field', "brown");
///
///     var query = new SpanNearQuery(slop: 2, in_order: true);
///     query.add(quick_query);
///     query.add(colour_query);
///     query.add(new SpanTermQuery('field', "fox");
///     // matches => "quick red speckled sleepy fox"
///                                |______2______^
///     // matches => "speedy brown speckled fox"
///                                    |__1__^
///     // doesn't match => "brown fast _____ fox"
///     //  not in order       ^_____2____|
///
/// NOTE: [SpanOrQuery] only works with other SpanQueries.
class SpanOrQuery extends Query {
  SpanOrQuery.handle(Ferret ferret, int h) : super._(ferret, h);

  /// Create a new [SpanOrQuery]. This is just like a [BooleanQuery] with all
  /// clauses with the occur value of `should`. The difference is that it can
  /// be passed to other SpanQuerys like [SpanNearQuery].
  SpanOrQuery(Ferret ferret, [List<Query> clauses])
      : super._(ferret, ferret.callMethod('_frt_spanoq_new')) {
    for (var clause in clauses) {
      this.add(clause);
    }
  }

  /// Add a clause to the [SpanOrQuery]. Note that clauses must be SpanQueries,
  /// not other types of query.
  void add(Query span_query) {
    _ferret.callMethod('_frt_spanoq_add_clause', [handle, span_query.handle]);
  }

  /// Alias for [add].
  void operator <<(Query span_query) => this.add(span_query);
}

/// [SpanNotQuery] is like a [BooleanQuery] with a `must_not` clause. The
/// difference being that the resulting query can be used in another
/// SpanQuery.
///
/// Let's say you wanted to search for all documents with the term "rails"
/// near the start but without the term "train" near the start. This would
/// allow the term "train" to occur later on in the document.
///
///     var rails_query = new SpanFirstQuery(new SpanTermQuery('content', "rails"), 100);
///     var train_query = new SpanFirstQuery(new SpanTermQuery('content', "train"), 100);
///     var query = new SpanNotQuery(rails_query, train_query);
///
/// NOTE: [SpanOrQuery] only works with other SpanQueries.
class SpanNotQuery extends Query {
  SpanNotQuery.handle(Ferret ferret, int h) : super._(ferret, h);

  /// Create a new [SpanNotQuery] which matches all documents which match
  /// [include_query] and don't match [exclude_query].
  SpanNotQuery(Ferret ferret, Query include_query, Query exclude_query)
      : super._(
            ferret,
            ferret.callMethod('_frt_spanxq_new',
                [include_query.handle, exclude_query.handle]));
}
