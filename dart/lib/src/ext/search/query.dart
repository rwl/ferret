library ferret.ext.search.query;

/// Abstract class representing a query to the index. There are a number of
/// concrete [Query] implementations:
///
/// * [TermQuery]
/// * [MultiTermQuery]
/// * [BooleanQuery]
/// * [PhraseQuery]
/// * [ConstantScoreQuery]
/// * [FilteredQuery]
/// * [MatchAllQuery]
/// * [RangeQuery]
/// * [WildcardQuery]
/// * [FuzzyQuery]
/// * [PrefixQuery]
/// * [SpanTermQuery]
/// * [SpanFirstQuery]
/// * [SpanOrQuery]
/// * [SpanNotQuery]
/// * [SpanNearQuery]
///
/// Explore these classes for the query right for you. The queries are passed
/// to the [Searcher.search]* methods.
///
/// Queries have a boost value so that you can make the results of one query
/// more important than the results of another query when combining them in a
/// [BooleanQuery]. For example, documents on Rails. To avoid getting results
/// for train rails you might also add the tern Ruby but Rails is the more
/// important term so you'd give it a boost.
class Query {
  to_s() => frb_q_to_s;
  get boost() => frb_q_get_boost;
  set boost() => frb_q_set_boost;
  bool eql() => frb_q_eql;
  operator ==() => frb_q_eql;
  hash() => frb_q_hash;
  terms() => frb_q_get_terms;
}

/// [TermQuery] is the most basic query and it is the building block for most
/// other queries. It basically matches documents that contain a specific term
/// in a specific field.
///
///     var query = new TermQuery('content', "rails");
///
///     // untokenized fields can also be searched with this query
///     var query = new new TermQuery('title', "Shawshank Redemption");
///
/// Notice the all lowercase term `Rails`. This is important as most analyzers
/// will downcase all text added to the index. The title in this case was not
/// tokenized so the case would have been left as is.
class TermQuery extends Query {
  TermQuery() {
    frb_tq_init;
  }
}

/// [MultiTermQuery] matches documents that contain one of a list of terms in
/// a specific field. This is the basic building block for queries such as:
///
/// * [PrefixQuery]
/// * [WildcardQuery]
/// * [FuzzyQuery]
///
/// [MultiTermQuery] is very similar to a boolean "Or" query. It is highly
/// optimized though as it focuses on a single field.
///
///     var multi_term_query = new MultiTermQuery('content', max_term: 10);
///
///     multi_term_query
///       ..add("Ruby")
///       ..add("Ferret")
///       ..add("Rails")
///       ..add("Search");
class MultiTermQuery extends Query {
  static int default_max_terms = 512;

  int _max_terms, _min_score;

  MultiTermQuery() {
    frb_mtq_init;
  }

  static get default_max_terms() => frb_mtq_get_dmt;

  static set default_max_terms() => frb_mtq_set_dmt;

  add_term() => frb_mtq_add_term;

  operator <<() => frb_mtq_add_term;
}

/// A [BooleanClause] holes a single query within a [BooleanQuery] specifying
/// wither the query `must` match, `should` match or `must_not` match.
/// [BooleanClause]s can be used to pass a clause from one [BooleanQuery] to
/// another although it is generally easier just to add a query directly to a
/// [BooleanQuery] using the [BooleanQuery.add_query] method.
///
///     var clause1 = new BooleanClause(query1, 'should');
///     var clause2 = new BooleanClause(query2, 'should');
///
///     var query = new BooleanQuery();
///     query..add(clause1)..add(clause2);
class BooleanClause {
  var should;
  var must;
  var must_not;

  BooleanClause() {
    frb_bc_init;
  }

  get query() => frb_bc_get_query;
  set query() => frb_bc_set_query;
  bool required() => frb_bc_is_required;
  bool prohibited() => frb_bc_is_prohibited;
  set occur() => frb_bc_set_occur;
  to_s() => frb_bc_to_s;
}

/// A [BooleanQuery] is used for combining many queries into one. This is best
/// illustrated with an example.
///
/// Lets say we wanted to find all documents with the term "Ruby" in the
/// title` and the term "Ferret" in the `content` field or the `title`
/// field written before January 2006. You could build the query like this.
///
///     var tq1 = new TermQuery('title', "ruby");
///     var tq21 = new TermQuery('title', "ferret");
///     var tq22 = new TermQuery('content', "ferret");
///     var bq2 = new BooleanQuery();
///     bq2..add(tq21)..add(tq22);
///
///     var rq3 = RangeQuery.new('written', le: "200601");
///
///     var query = new BooleanQuery();
///     query.add_query(tq1, 'must')
///       ..add_query(bq2, 'must')
///       ..add_query(rq3, 'must');
class BooleanQuery extends Query {
  BooleanQuery() {
    frb_bq_init;
  }

  add_query() => frb_bq_add_query;

  operator <<() => frb_bq_add_query;
}

/// [RangeQuery] is used to find documents with terms in a range.
/// [RangeQuery]s are usually used on untokenized fields like date fields or
/// number fields.
///
/// To find all documents written between January 1st 2006 and January 26th
/// 2006 inclusive you would write the query like this:
///
///    var query = new RangeQuery('create_date', geq: "20060101", leq: "20060126");
///
/// There is now a new query called [TypedRangeQuery] which detects the type
/// of the range and if the range is numerical it will find a numerical range.
/// This allows you to do range queries with negative numbers and without
/// having to pad the field. However, [RangeQuery] will perform a lot faster
/// on large indexes so if you are working with a very large index you will
/// need to normalize your number fields so that they are a fixed width and
/// always positive. That way the standard String range query will do fine.
///
/// For example, if you have the numbers:
///
///     [10, -999, -90, 100, 534]
///
/// Then the can be normalized to:
///
///     // note that we have added 1000 to all numbers to make them all positive
///     [1010, 0001, 0910, 1100, 1534]
class RangeQuery extends Query {
  var upper;
  var lower;
  var upper_exclusive;
  var lower_exclusive;
  var include_upper;
  var include_lower;

  var le, leq, ge, geq;

  RangeQuery() {
    frb_rq_init;
  }
}

/// [TypedRangeQuery] is used to find documents with terms in a range.
/// [RangeQuery]s are usually used on untokenized fields like date fields or
/// number fields. [TypedRangeQuery] is particularly useful for fields with
/// unnormalized numbers, both positive and negative, integer and float.
///
/// To find all documents written between January 1st 2006 and January 26th
/// 2006 inclusive you would write the query like this;
///
///     var query = new RangeQuery('create_date', geq: "-1.0", leq: "10.0");
///
/// [TypedRangeQuery] works by converting all the terms in a field to numbers
/// and then comparing those numbers with the range bondaries. This can have
/// quite an impact on performance on large indexes so in those cases it is
/// usually better to use a standard [RangeQuery]. This will require a little
/// work on your behalf. See [RangeQuery] for notes on how to do this.
class TypedRangeQuery extends Query {
  TypedRangeQuery() {
    frb_trq_init;
  }
}

/// [PhraseQuery] matches phrases like "the quick brown fox". Most people are
/// familiar with phrase queries having used them in most internet search
/// engines.
///
/// Ferret's phrase queries a slightly more advanced. You can match phrases
/// with a slop, ie the match isn't exact but it is good enough. The slop is
/// basically the word edit distance of the phrase. For example, "the quick
/// brown fox" with a slop of 1 would match "the quick little brown fox". With
/// a slop of 2 it would match "the brown quick fox".
///
///     var query = new PhraseQuery('content')
///       ..add("the")
///       ..add("quick")
///       ..add("brown")
///       ..add("fox");
///
///     // matches => "the quick brown fox"
///
///     query.slop = 1;
///     // matches => "the quick little brown fox"
///                                 |__1__^
///
///     query.slop = 2;
///     // matches => "the brown quick _____ fox"
///                          ^_____2_____|
///
/// Phrase queries can also have multiple terms in a single position. Let's
/// say for example that we want to match synonyms for quick like "fast" and
/// "speedy". You could the query like this:
///
///     var query = new PhraseQuery('content')
///       ..add("the")
///       ..addAll(["quick", "fast", "speed"])
///       ..addAll(["brown", "red"])
///       ..add("fox");
///     // matches => "the quick red fox"
///     // matches => "the fast brown fox"
///
///     query.slop = 1;
///     // matches => "the speedy little red fox"
///
/// You can also leave positions blank. Lets say you wanted to match "the
/// quick <> fox" where "<>" could match anything (but not nothing). You'd
/// build this query like this:
///
///     var query = new PhraseQuery('content');
///     query..add_term("the")..add_term("quick")..add_term("fox", 2);
///     // matches => "the quick yellow fox"
///     // matches => "the quick alkgdhaskghaskjdh fox"
///
/// The second parameter to [PhraseQuery.add_term] is the position increment
/// for the term. It is one by default meaning that every time you add a term
/// it is expected to follow the previous term. But setting it to 2 or greater
/// you are leaving empty spaces in the term.
///
/// There are also so tricks you can do by setting the position increment to
/// 0. With a little help from your analyzer you can actually tag bold or
/// italic text for example.
class PhraseQuery extends Query {
  PhraseQuery() {
    frb_phq_init;
  }

  add_term() => frb_phq_add;
  operator <<() frb_phq_add;
  get slop() => frb_phq_get_slop;
  set slop() => frb_phq_set_slop;
}

/// A prefix query is like a [TermQuery] except that it matches any term with
/// a specific prefix. [PrefixQuery] is expanded into a [MultiTermQuery] when
/// submitted in a search.
///
/// [PrefixQuery] is very useful for matching a tree structure category
/// hierarchy. For example, let's say you have the categories:
///
///     "cat1/"
///     "cat1/sub_cat1"
///     "cat1/sub_cat2"
///     "cat2"
///     "cat2/sub_cat1"
///     "cat2/sub_cat2"
///
/// Lets say you want to match everything in category 2. You'd build the query
/// like this:
///
///     var query = new PrefixQuery('category', "cat2");
///     // matches => "cat2"
///     // matches => "cat2/sub_cat1"
///     // matches => "cat2/sub_cat2"
class PrefixQuery extends Query {
  PrefixQuery() {
    frb_prq_init
  }
}

/// [WildcardQuery] is a simple pattern matching query. There are two
/// wild-card characters.
///
/// * "*" which matches 0 or more characters
/// * "?" which matches a single character
///
///     var query = new WildcardQuery('field', "h*og");
///     // matches => "hog";
///     // matches => "hot dog"
///
///     var query = new WildcardQuery('field', "fe?t");
///     // matches => "feat"
///     // matches => "feet"
///
///     var query = new WildcardQuery('field', "f?ll*");
///     // matches => "fill"
///     // matches => "falling"
///     // matches => "folly"
class WildcardQuery extends Query {
  WildcardQuery() {
    frb_wcq_init
  }
}

/// [FuzzyQuery] uses the Levenshtein distance formula for measuring the
/// similarity between two terms. For example, weak and week have one letter
/// difference and they are four characters long so the simlarity is 75% or
/// 0.75. You can use this query to match terms that are very close to the
/// search term.
///
/// [FuzzyQuery] can be quite useful for find documents that wouldn't normally
/// be found because of typos.
///
///     new FuzzyQuery('field', "google",
///       min_similarity: 0.6,
///       prefix_length: 2);
///     // matches => "gogle", "goggle", "googol", "googel"
class FuzzyQuery extends Query {
  static double _default_min_similarity = 0.5;
  static int _default_prefix_length = 0;

  get default_min_similarity() => frb_fq_get_dms;
  set default_min_similarity() => frb_fq_set_dms;

  get default_prefix_length() => frb_fq_get_dpl;
  set default_prefix_length() => frb_fq_set_dpl;

  var _min_similarity;
  var _prefix_length;

  FuzzyQuery() {
    frb_fq_init;
  }

  prefix_length() => frb_fq_pre_len;
  min_similarity() => frb_fq_min_sim;
}

/// [MatchAllQuery] matches all documents in the index. You might want use
/// this query in combination with a filter, however, [ConstantScoreQuery] is
/// probably better in that circumstance.
class MatchAllQuery extends Query {
  MatchAllQuery() {
    frb_maq_init;
  }
}

/// [ConstantScoreQuery] is a way to turn a Filter into a [Query]. It matches
/// all documents that its filter matches with a constant score. This is a
/// very fast query, particularly when run more than once (since filters are
/// cached). It is also used internally be [RangeQuery].
///
/// Let's say for example that you often need to display all documents created
/// on or after June 1st. You could create a [ConstantScoreQuery] like this:
///
///     var query = new ConstantScoreQuery(new RangeFilter('created_on', geq: "200606"));
///
/// Once this is run once the results are cached and will be returned very
/// quickly in future requests.
class ConstantScoreQuery extends Query {
  ConstantScoreQuery() {
    frb_csq_init;
  }
}

/// [FilteredQuery] offers you a way to apply a filter to a specific query.
/// The [FilteredQuery] would then by added to a [BooleanQuery] to be combined
/// with other queries. There is not much point in passing a [FilteredQuery]
/// directly to a [Searcher.search] method unless you are applying more than
/// one filter since the search method also takes a filter as a parameter.
class FilteredQuery extends Query {
  FilteredQuery() {
    frb_fqq_init;
  }
}
