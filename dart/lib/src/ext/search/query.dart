part of ferret.ext.search;

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
class Query extends JsProxy {
  /// Return a string representation of the query. Most of the time, passing
  /// this string through the [Query] parser will give you the exact [Query]
  /// you began with. This can be a good way to explore how the [QueryParser]
  /// works.
  to_s() => frb_q_to_s;

  /// Returns the queries boost value. See the [Query] description for more
  /// information on [Query] boosts.
  get boost => frb_q_get_boost;

  /// Set the boost for a query. See the [Query] description for more
  /// information on [Query] boosts.
  set boost(b) => frb_q_set_boost;

  /// Return true if query equals [other_query]. Theoretically, two queries
  /// are equal if the always return the same results, no matter what the
  /// contents of the index. Practically, however, this is difficult to
  /// implement efficiently for queries like [BooleanQuery] since the ordering
  /// of clauses unspecified. "Ruby AND Rails" will not match "Rails AND Ruby"
  /// for example, although their result sets will be identical. Most queries
  /// should match as expected however.
  bool eql(other_query) => frb_q_eql;

  /// Alias for [eql].
  operator ==(other_query) => frb_q_eql;

  /// Return a hash value for the query. This is used for caching query results
  /// in a hash object.
  hash() => frb_q_hash;

  /// Returns an array of terms searched for by this query. This can be used
  /// for implementing an external query highlighter for example. You must
  /// supply a searcher so that the query can be rewritten and optimized like
  /// it would be in a real search.
  List terms(searcher) => frb_q_get_terms;
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
  TermQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a new [TermQuery] object which will match all documents with the
  /// term [term] in the field [field].
  TermQuery(field, term) : super() {
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
  static int _default_max_terms = 512;

  int _max_terms, _min_score;

  MultiTermQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a new [MultiTermQuery] on field [field]. You will also need to
  /// add terms to the query using the [add_term] method.
  ///
  /// You can specify the maximum number of terms that can be added to the
  /// query using [max_terms]. This is to prevent memory usage overflow,
  /// particularly when don't directly control the addition of terms to the
  /// [Query] object like when you create Wildcard queries. For example,
  /// searching for "content:*" would cause problems without this limit.
  /// [min_score] is the minimum score a term must have to be added to the
  /// query. For example you could implement your own wild-card queries
  /// that gives matches a score. To limit the number of terms added to the
  /// query you could set a lower limit to this score. [FuzzyQuery] in
  /// particular makes use of this parameter.
  MultiTermQuery(field, {max_terms, min_score}) {
    frb_mtq_init;
  }

  /// Get the default value for [max_terms] in a [MultiTermQuery]. This value
  /// is also used by [PrefixQuery], [FuzzyQuery] and [WildcardQuery].
  static double get default_max_terms => frb_mtq_get_dmt;

  /// Set the default value for [max_terms] in a [MultiTermQuery]. This value
  /// is also used by [PrefixQuery], [FuzzyQuery] and [WildcardQuery].
  static set default_max_terms(max_terms) => frb_mtq_set_dmt;

  /// Add a term to the [MultiTermQuery] with the score 1.0 unless specified
  /// otherwise.
  add_term(term, [score = 1.0]) => frb_mtq_add_term;

  /// Alias for [add_term].
  operator <<(term) => frb_mtq_add_term;
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

  ///
  BooleanClause(query, {occur: 'should'}) {
    frb_bc_init;
  }

  /// Return the query object wrapped by this [BooleanClause].
  Query get query => frb_bc_get_query;

  /// Set the [query] wrapped by this [BooleanClause].
  set query(Query query) => frb_bc_set_query;

  /// Return `true` if this clause is required. ie, this will be true if occur
  /// was equal to `must`.
  bool required() => frb_bc_is_required;

  /// Return `true` if this clause is prohibited. ie, this will be true if
  /// occur was equal to `must_not`.
  bool prohibited() => frb_bc_is_prohibited;

  /// Set the [occur] value for this [BooleanClause]. [occur] must be one of
  /// `must`, `should` or `must_not`.
  set occur(String val) => frb_bc_set_occur;

  /// Return a string representation of this clause. This will not be used by
  /// [BooleanQuery.to_s]. It is only used by [BooleanClause.to_s] and will
  /// specify whether the clause is `must`, `should` or `must_not`.
  String to_s() => frb_bc_to_s;
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
  BooleanQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a new [BooleanQuery]. If you don't care about the scores of the
  /// sub-queries added to the query (as would be the case for many
  /// automatically generated queries) you can disable the coord_factor of the
  /// score. This will slightly improve performance for the query. Usually you
  /// should leave this parameter as is.
  BooleanQuery({coord_disable: false}) {
    frb_bq_init;
  }

  /// Us this method to add sub-queries to a [BooleanQuery]. You can either
  /// add a straight [Query] or a [BooleanClause]. When adding a [Query], the
  /// default occurrence requirement is `should`. That is the [Query]'s match
  /// will be scored but it isn't essential for a match. If the query should
  /// be essential, use `must`. For exclusive queries use `must_not`.
  ///
  /// When adding a [BooleanClause] to a [BooleanQuery] there is no need to
  /// set the occurrence property because it is already set in the
  /// [BooleanClause].  Therefor the [occur] parameter will be ignored in this
  /// case.
  BooleanClause add_query(query, {occur: 'should'}) => frb_bq_add_query;

  /// Alias for [add_query].
  operator <<(query) => frb_bq_add_query;
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

  RangeQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a new [RangeQuery] on field [field]. There are two ways to build
  /// a range query. With the old-style options; [lower], [upper],
  /// [include_lower] and [include_upper] or the new style options; [le],
  /// [leq], [ge] and [geq].
  ///
  ///     var q = new RangeQuery('date', lower: "200501", include_lower: false);
  ///     // is equivalent to
  ///     var q = new RangeQuery('date', le: "200501");
  ///     // is equivalent to
  ///     var q = new RangeQuery('date', lower_exclusive: "200501");
  ///
  ///     var q = new RangeQuery('date', lower: "200501", upper: 200502);
  ///     // is equivalent to
  ///     var q = new RangeQuery('date', geq: "200501", leq: 200502);
  RangeQuery(field,
      {lower,
      upper,
      bool include_lower,
      bool include_upper,
      le,
      leq,
      ge,
      geq}) {
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
  TypedRangeQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a new [TypedRangeQuery] on field [field]. This differs from the
  /// standard [RangeQuery] in that it allows range queries with unpadded
  /// numbers, both positive and negative, integer and float. You can even use
  /// hexadecimal numbers. However it could be a lot slower than the standard
  /// [RangeQuery] on large indexes.
  ///
  /// There are two ways to build a range query. With the old-style options;
  /// [lower], [upper], [include_lower] and [include_upper] or the new style
  /// options; [le], [leq], [ge] and [geq]. The options' names should speak
  /// for themselves. In the old-style options, limits are inclusive by
  /// default.
  ///
  ///      var q = new TypedRangeQuery('date', lower: "0.1", include_lower: false);
  ///      // is equivalent to
  ///      var q = new TypedRangeQuery('date', le: "0.1");
  ///      // is equivalent to
  ///      var q = new TypedRangeQuery('date', lower_exclusive: "0.1")
  ///
  ///      // Note that you numbers can be strings or actual numbers
  ///      var q = new TypedRangeQuery('date', lower: "-12.32", upper: 0.21);
  ///      // is equivalent to
  ///      var q = new TypedRangeQuery('date', geq: "-12.32", leq: 0.21);
  TypedRangeQuery(field,
      {lower,
      upper,
      bool include_lower,
      bool include_upper,
      le,
      leq,
      ge,
      geq}) {
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
  PhraseQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a new [PhraseQuery] on the field [field]. You need to add terms
  /// to the query it will do anything of value. See [add_term].
  PhraseQuery(field, {slop: 0}) {
    frb_phq_init;
  }

  /// Add a term to the phrase query. By default the position_increment is set
  /// to 1 so each term you add is expected to come directly after the
  /// previous term. By setting position_increment to 2 you are specifying
  /// that the term you just added should occur two terms after the previous
  /// term. For example:
  ///
  ///     phrase_query..add_term("big")..add_term("house", 2);
  ///     // matches => "big brick house"
  ///     // matches => "big red house"
  ///     // doesn't match => "big house"
  add_term(term, [int position_increment = 1]) => frb_phq_add;

  /// Alias for [add_term].
  operator <<(term) => frb_phq_add;

  /// Return the slop set for this phrase query. See the [PhraseQuery]
  /// description for more information on slop.
  int get slop => frb_phq_get_slop;

  /// Set the slop set for this phrase query. See the [PhraseQuery]
  /// description for more information on slop.
  set slop(int s) => frb_phq_set_slop;
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
  PrefixQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a new [PrefixQuery] to search for all terms with the prefix
  /// [prefix] in the field [field]. There is one option that you can set to
  /// change the behaviour of this query. [max_terms] specifies the maximum
  /// number of terms to be added to the query when it is expanded into a
  /// [MultiTermQuery].
  /// Let's say for example you search an index with a million terms for all
  /// terms beginning with the letter "s". You would end up with a very large
  /// query which would use a lot of memory and take a long time to get
  /// results, not to mention that it would probably match every document in
  /// the index.
  /// To prevent queries like this crashing your application you can set
  /// [max_terms] which limits the number of terms that get added to the
  /// query. By default it is set to 512.
  PrefixQuery(field, prefix, {max_terms: 512}) {
    frb_prq_init;
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
  WildcardQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a new [WildcardQuery] to search for all terms where the pattern
  /// [pattern] matches in the field [field].
  ///
  /// There is one option that you can set to change the behaviour of this
  /// query. [max_terms] specifies the maximum number of terms to be added to
  /// the query when it is expanded into a [MultiTermQuery]. Let's say for
  /// example you have a million terms in your index and you let your users do
  /// wild-card queries and one runs a search for "*". You would end up with a
  /// very large query which would use a lot of memory and take a long time to
  /// get results, not to mention that it would probably match every document
  /// in the index. To prevent queries like this crashing your application you
  /// can set [max_terms] which limits the number of terms that get added to
  /// the query. By default it is set to 512.
  WildcardQuery(field, pattern, {max_terms: 512}) {
    frb_wcq_init;
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
  FuzzyQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  static double _default_min_similarity = 0.5;
  static int _default_prefix_length = 0;

  /// Get the default value for [min_similarity].
  get default_min_similarity => frb_fq_get_dms;

  /// Set the default value for [min_similarity].
  set default_min_similarity(dms) => frb_fq_set_dms;

  /// Get the default value for [prefix_length].
  get default_prefix_length => frb_fq_get_dpl;

  /// Set the default value for [prefix_length].
  set default_prefix_length(dpl) => frb_fq_set_dpl;

  var _min_similarity;
  var _prefix_length;

  /// Create a new [FuzzyQuery] that will match terms with a similarity of at
  /// least [min_similarity] to [term]. Similarity is scored using the
  /// Levenshtein edit distance formula. See
  ///
  ///     http://en.wikipedia.org/wiki/Levenshtein_distance
  ///
  /// If a [prefix_length] > 0 is specified, a common prefix of that length is
  /// also required.
  ///
  /// You can also set [max_terms] to prevent memory overflow problems. By
  /// default it is set to 512.
  ///
  ///     new FuzzyQuery('content', "levenshtein",
  ///       min_similarity: 0.8,
  ///       prefix_length: 5,
  ///       max_terms: 1024);
  ///
  /// [min_similarity] is the minimum levenshtein distance score for a match.
  /// [prefix_length] is the minimum prefix_match before levenshtein
  /// distance is measured. This parameter is used to improve performance.
  /// With a [prefix_length] of 0, all terms in the index must be checked
  /// which can be quite a performance hit. By setting the prefix length to a
  /// larger number you minimize the number of terms that need to be checked.
  /// Even 1 will cut down the work by a factor of about 26 depending on your
  /// character set and the first letter.
  /// [max_terms] limits the number of terms that can be added to the query
  /// when it is expanded as a [MultiTermQuery]. This is not usually a problem
  /// with FuzzyQueries unless you set [min_similarity] to a very low value.
  FuzzyQuery(field, term,
      {min_similarity: 0.5, prefix_length: 0, max_terms: 512}) {
    frb_fq_init;
  }

  /// Get the [prefix_length] for the query.
  get prefix_length => frb_fq_pre_len;

  /// Get the [min_similarity] for the query.
  min_similarity() => frb_fq_min_sim;
}

/// [MatchAllQuery] matches all documents in the index. You might want use
/// this query in combination with a filter, however, [ConstantScoreQuery] is
/// probably better in that circumstance.
class MatchAllQuery extends Query {
  MatchAllQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a query which matches all documents.
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
  ConstantScoreQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a [ConstantScoreQuery] which uses [filter] to match documents
  /// giving each document a constant score.
  ConstantScoreQuery(filter) {
    frb_csq_init;
  }
}

/// [FilteredQuery] offers you a way to apply a filter to a specific query.
/// The [FilteredQuery] would then by added to a [BooleanQuery] to be combined
/// with other queries. There is not much point in passing a [FilteredQuery]
/// directly to a [Searcher.search] method unless you are applying more than
/// one filter since the search method also takes a filter as a parameter.
class FilteredQuery extends Query {
  FilteredQuery.handle(int hquery) : super() {
    handle = hquery;
  }

  /// Create a new FilteredQuery which filters [query] with [filter].
  FilteredQuery(query, filter) {
    frb_fqq_init;
  }
}
