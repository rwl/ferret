/// The Spans library contains a number of SpanQueries. SpanQueries, unlike
/// regular queries, also return the start and end offsets of all of their
/// matches so they can be used to limit queries to a certain position in the
/// field. They are often used in combination to perform special types of
/// [PhraseQuery].
library ferret.ext.search.span;

/// A [SpanTermQuery] is the Spans version of [TermQuery], the only difference
/// being that it returns the start and end offset of all of its matches for
/// use by enclosing SpanQueries.
class SpanTermQuery extends Query {
  SpanTermQuery() {
    frb_spantq_init;
  }
}

/// A [SpanMultiTermQuery] is the Spans version of [MultiTermQuery], the only
/// difference being that it returns the start and end offset of all of its
/// matches for use by enclosing SpanQueries.
class SpanMultiTermQuery extends Query {
  SpanMultiTermQuery() {
    frb_spanmtq_init
  }
}

/// A [SpanPrefixQuery] is the Spans version of [PrefixQuery], the only
/// difference being that it returns the start and end offset of all of its
/// matches for use by enclosing SpanQueries.
class SpanPrefixQuery extends Query {
  SpanPrefixQuery() {
    frb_spanprq_init;
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
  SpanFirstQuery() {
    frb_spanfq_init;
  }
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
  var _slop, _in_order, _clauses;

  SpanNearQuery() {
    frb_spannq_init;
  }

  add() => frb_spannq_add;
  operator <<() => frb_spannq_add;
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
  SpanOrQuery() {
    frb_spanoq_init;
  }
  add() => frb_spanoq_add;
  operator <<() => frb_spanoq_add;
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
  SpanNotQuery() {
    frb_spanxq_init;
  }
}
