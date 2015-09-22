library ferret.ext.query_parser;

import 'dart:typed_data' show Int32List;

import '../proxy.dart';
import 'search/search.dart';
import 'analysis/analysis.dart' show Analyzer;

/// The [QueryParser] is used to transform user submitted query strings into
/// QueryObjects. Ferret using its own Query Language known from now on as
/// Ferret Query Language or FQL.
///
/// ## Ferret Query Language
///
/// ### Preamble
///
/// The following characters are special characters in FQL:
///
///     :, (, ), [, ], {, }, !, +, ", ~, ^, -, |, <, >, =, *, ?, \
///
/// If you want to use one of these characters in one of your terms you need
/// to escape it with a \ character. \ escapes itself. The exception to this
/// rule is within Phrases which a strings surrounded by double quotes (and
/// will be explained further bellow in the section on PhraseQueries). In
/// Phrases, only ", | and <> have special meaning and need to be escaped if
/// you want the literal value. <> is escaped \<\>.
///
/// In the following examples I have only written the query string. This would
/// be parse like:
///
///     query = query_parser.parse("pet:(dog AND cat)");
///     print(query);    // => "+pet:dog +pet:cat"
///
/// ### TermQuery
///
/// A term query is the most basic query of all and is what most of the other
/// queries are built upon. The term consists of a single word. eg:
///
///     'term'
///
/// Note that the analyzer will be run on the term and if it splits the term
/// in two then it will be turned into a phrase query. For example, with the
/// plain [Analyzer], the following:
///
///     'dave12balmain'
///
/// is equivalent to:
///
///     '"dave balmain"'
///
/// Which we will explain now...
///
/// ### PhraseQuery
///
/// A phrase query is a string of terms surrounded by double quotes. For
/// example you could write:
///
///     '"quick brown fox"'
///
/// But if a "fast" fox is just as good as a quick one you could use the |
/// character to specify alternate terms.
///
///     '"quick|speedy|fast brown fox"'
///
/// What if we don't care what colour the fox is. We can use the <> to specify
/// a place setter. eg:
///
///     '"quick|speedy|fast <> fox"'
///
/// This will match any word in between quick and fox. Alternatively we could
/// set the "slop" for the phrase which allows a certain variation in the
/// match of the phrase. The slop for a phrase is an integer indicating how
/// many positions you are allowed to move the terms to get a match. Read more
/// about the slop factor in [PhraseQuery]. To set the slop factor for a
/// phrase you can type:
///
///     '"big house"~2'
///
/// This would match "big house", "big red house", "big red brick house" and
/// even "house big". That's right, you don't need to have th terms in order
/// if you allow some slop in your phrases. (See [Spans] if you need a phrase
/// type query with ordered terms.)
///
/// These basic queries will be run on the default field which is set when you
/// create the query_parser. But what if you want to search a different field.
/// You'll be needing a ...
///
/// ### FieldQuery
///
/// A field query is any field prefixed by `<fieldname>:`. For example, to
/// search for all instances of the term "ski" in field "sport", you'd write:
///
///     'sport:ski'
///
/// Or we can apply a field to phrase:
///
///     'sport:"skiing is fun"'
///
/// Now we have a few types of queries, we'll be needing to glue them together
/// with a ...
///
/// ### BooleanQuery
///
/// There are a couple of ways of writing boolean queries. Firstly you can
/// specify which terms are required, optional or required not to exist (not).
///
/// * '+' or "REQ" can be used to indicate a required query. "REQ" must be
///   surrounded by white space.
/// * '-', '!' or "NOT" are used to indicate query that is required to be
///   false. "NOT" must be surrounded by white space.
/// * all other queries are optional if the above symbols are used.
///
/// Some examples:
///
///     '+sport:ski -sport:snowboard sport:toboggan'
///     '+ingredient:chocolate +ingredient:strawberries -ingredient:wheat'
///
/// You may also use the boolean operators "AND", "&&", "OR" and "||". eg;
///
///     'sport:ski AND NOT sport:snowboard OR sport:toboggan'
///     'ingredient:chocolate AND ingredient:strawberries AND NOT ingredient:wheat'
///
/// You can set the default operator when you create the query parse.
///
/// ### RangeQuery
///
/// A range query finds all documents with terms between the two query terms.
/// This can be very useful in particular for dates. eg;
///
///     'date:[20050725 20050905]' # all dates >= 20050725 and <= 20050905
///     'date:[20050725 20050905}' # all dates >= 20050725 and <  20050905
///     'date:{20050725 20050905]' # all dates >  20050725 and <= 20050905
///     'date:{20050725 20050905}' # all dates >  20050725 and <  20050905
///
/// You can also do open ended queries like this:
///
///     'date:[20050725>' # all dates >= 20050725
///     'date:{20050725>' # all dates >  20050725
///     'date:<20050905]' # all dates <= 20050905
///     'date:<20050905}' # all dates <  20050905
///
/// Or like this:
///
///     'date: >= 20050725'
///     'date: >  20050725'
///     'date: <= 20050905'
///     'date: <  20050905'
///
/// If you prefer the above style you could use a boolean query but like this:
///
///     'date:( >= 20050725 AND <= 20050905)'
///
/// But [RangeQuery] only solution shown first will be faster.
///
/// ### WildcardQuery
///
/// A wildcard query is a query using the pattern matching characters
/// * and ?. * matches 0 or more characters while ? matches a single
/// character. This type of query can be really useful for matching
/// hierarchical categories for example. Let's say we had this structure:
///
///     /sport/skiing
///     /sport/cycling
///     /coding1/ruby
///     /coding1/c
///     /coding2/python
///     /coding2/perl
///
/// If you wanted all categories with programming languages you could use the
/// query:
///
///     'category:/coding?/?*'
///
/// Note that this query can be quite expensive if not used carefully. In the
/// example above there would be no problem but you should be careful not use
/// the wild characters at the beginning of the query as it'll have to iterate
/// through every term in that field. Having said that, some fields like the
/// category field above will only have a small number of distinct fields so
/// this could be okay.
///
/// ### FuzzyQuery
///
/// This is like the sloppy phrase query above, except you are now adding slop
/// to a term. Basically it measures the Levenshtein distance between two
/// terms and if the value is below the slop threshold the term is a match.
/// This time though the slop must be a float between 0 and 1.0, 1.0 being a
/// perfect match and 0 being far from a match. The default is set to 0.5 so
/// you don't need to give a slop value if you don't want to. You can set the
/// default in the [FuzzyQuery] class. Here are a couple of examples:
///
///     'content:ferret~'
///     'content:Ostralya~0.4'
///
/// Note that this query can be quite expensive. If you'd like to use this
/// query, you may want to set a minimum prefix length in the [FuzzyQuery]
/// class. This can substantially reduce the number of terms that the query
/// will iterate over.
class QueryParser extends JsProxy {
  /// Create a new [QueryParser]. The [QueryParser] is used to convert string
  /// queries into [Query] objects.
  ///
  /// [default_field] is the default field to search when no field is
  /// specified in the search string. It can also be an array of fields.
  /// [analyzer] is the [Analyzer] used by the query parser to parse query
  /// terms.
  /// [wild_card_downcase] specifies whether wild-card queries and range
  /// queries should be downcased or not since they are not passed through
  /// the parser.
  /// [fields] lets the query parser know what fields are available for
  /// searching, particularly when the "*" is specified as the search field.
  /// [tokenized_fields] lets the query parser know which fields are tokenized
  /// so it knows which fields to run the analyzer over.
  /// [validate_fields] set to true if you want an exception to be raised if
  /// there is an attempt to search a non-existent field.
  /// Set [or_default] to use "OR" as the default boolean operator.
  /// [default_slop] is the default slop to use in [PhraseQuery].
  /// set [handle_parse_errors] and [QueryParser] will quietly handle all
  /// parsing errors internally. If you'd like to handle them yourself, set
  /// this parameter to false.
  /// Set [clean_string] and [QueryParser] will do a quick once-over the
  /// query string make sure that quotes and brackets match up and special
  /// characters are escaped.
  /// [max_clauses] is the maximum number of clauses allowed in boolean
  /// queries and the maximum number of terms allowed in multi, prefix,
  /// wild-card or fuzzy queries when those queries are generated by rewriting
  /// other queries.
  /// Set [use_keywords] and AND, OR, NOT and REQ are keywords used by the
  /// query parser. Sometimes this is undesirable. For example, if your
  /// application allows searching for US states by their abbreviation, then
  /// OR will be a common query string. By setting [use_keywords] to false, OR
  /// will no longer be a keyword allowing searches for the state of Oregon.
  /// You will still be able to use boolean queries by using the + and -
  /// characters.
  /// Set [use_typed_range_query] to use [TypedRangeQuery] instead of
  /// the standard [RangeQuery] when parsing range queries. This is useful if
  /// you have number fields which you want to perform range queries on. You
  /// won't need to pad or normalize the data in the field in anyway to get
  /// correct results. However, performance will be a lot slower for large
  /// indexes, hence the default.
  QueryParser(
      {default_field: "*",
      Analyzer analyzer,
      List fields: const [],
      tokenized_fields,
      bool handle_parse_errors: true,
      bool validate_fields: false,
      bool wild_card_downcase: true,
      bool or_default: true,
      int default_slop: 0,
      bool clean_string: true,
      int max_clauses: 512,
      bool use_keywords: true,
      bool use_typed_range_query: false})
      : super() {
    int p_analyzer = analyzer != null ? analyzer.handle : 0;
    int p_all_fields = 0;
    if (fields != null) {
      p_all_fields = module.callMethod('_frt_hs_new_ptr', [0]);
      for (String field in fields) {
        int p_field = allocString(field);
        module.callMethod('_frt_hs_add', [p_all_fields, p_field]);
      }
    }
    int p_tkz_fields = 0;
    if (tokenized_fields != null) {
      p_tkz_fields = module.callMethod('_frt_hs_new_ptr', [0]);
      for (String field in fields) {
        int p_field = allocString(field);
        module.callMethod('_frt_hs_add', [p_tkz_fields, p_field]);
      }
    }
    int p_def_fields = 0;
    if (default_field != null) {
      p_def_fields = module.callMethod('_frt_hs_new_ptr', [0]);
      if (fields is List) {
        for (String field in fields) {
          int p_field = allocString(field);
          module.callMethod('_frt_hs_add', [p_def_fields, p_field]);
        }
      } else {
        int p_field = allocString(default_field.toString());
        module.callMethod('_frt_hs_add', [p_def_fields, p_field]);
      }
    }
    handle = module.callMethod('_frjs_qp_init', [
      p_analyzer,
      p_all_fields,
      p_tkz_fields,
      p_def_fields,
      handle_parse_errors ? 1 : 0,
      validate_fields ? 1 : 0,
      wild_card_downcase ? 1 : 0,
      or_default ? 1 : 0,
      default_slop,
      clean_string ? 1 : 0,
      max_clauses,
      use_keywords ? 1 : 0,
      use_typed_range_query ? 1 : 0
    ]);
  }

  /// Parse a query string returning a [Query] object if parsing was
  /// successful. Will raise a [QueryParseException] if unsuccessful.
  Query parse(String query_string) {
    int p_str = allocString(query_string);

    int pp_msg = module.callMethod('_malloc', [Int32List.BYTES_PER_ELEMENT]);
    module.callMethod('setValue', [pp_msg, 0, 'i32']);

    int p_q = module.callMethod('_frjs_qp_parse', [handle, p_str, pp_msg]);
    free(p_str);
    if (p_q == 0) {
      int p_msg = module.callMethod('getValue', [pp_msg, 'i32']);
      var msg = stringify(p_msg);
      free(pp_msg);
      throw new QueryParseException(msg);
    }
    free(pp_msg);

    int qt_index = module.callMethod('_frjs_q_get_query_type', [p_q]);
    var qt = QueryType.values[qt_index];
    Query query;
    switch (qt) {
      case QueryType.TERM_QUERY:
        query = new TermQuery.handle(p_q);
        break;
      case QueryType.MULTI_TERM_QUERY:
        query = new MultiTermQuery.handle(p_q);
        break;
      case QueryType.BOOLEAN_QUERY:
        query = new BooleanQuery.handle(p_q);
        break;
      case QueryType.PHRASE_QUERY:
        query = new PhraseQuery.handle(p_q);
        break;
      case QueryType.CONSTANT_QUERY:
        query = new ConstantScoreQuery.handle(p_q);
        break;
      case QueryType.FILTERED_QUERY:
        query = new FilteredQuery.handle(p_q);
        break;
      case QueryType.MATCH_ALL_QUERY:
        query = new MatchAllQuery.handle(p_q);
        break;
      case QueryType.RANGE_QUERY:
        query = new RangeQuery.handle(p_q);
        break;
      case QueryType.TYPED_RANGE_QUERY:
        query = new TypedRangeQuery.handle(p_q);
        break;
      case QueryType.WILD_CARD_QUERY:
        query = new WildcardQuery.handle(p_q);
        break;
      case QueryType.FUZZY_QUERY:
        query = new FuzzyQuery.handle(p_q);
        break;
      case QueryType.PREFIX_QUERY:
        query = new PrefixQuery.handle(p_q);
        break;
      case QueryType.SPAN_TERM_QUERY:
        query = new SpanMultiTermQuery.handle(p_q);
        break;
      case QueryType.SPAN_MULTI_TERM_QUERY:
        query = new SpanPrefixQuery.handle(p_q);
        break;
      case QueryType.SPAN_PREFIX_QUERY:
        query = new SpanTermQuery.handle(p_q);
        break;
      case QueryType.SPAN_FIRST_QUERY:
        query = new SpanFirstQuery.handle(p_q);
        break;
      case QueryType.SPAN_OR_QUERY:
        query = new SpanOrQuery.handle(p_q);
        break;
      case QueryType.SPAN_NOT_QUERY:
        query = new SpanNotQuery.handle(p_q);
        break;
      case QueryType.SPAN_NEAR_QUERY:
        query = new SpanNearQuery.handle(p_q);
        break;
      default:
        throw new ArgumentError.value(qt_index, 'qt', "Unknown query type");
        break;
    }
    return query;
  }

  /// Returns the list of all fields that the [QueryParser] knows about.
  List get fields {
    int p_fields = module.callMethod('_frjs_qp_all_fields', [handle]);
    var a = [];
    int p_hse = module.callMethod('_frjs_hash_set_first', [p_fields]);
    while (p_hse != 0) {
      int p_elem = module.callMethod('_frjs_hash_set_entry_elem', [p_hse]);
      a.add(stringify(p_elem));
      p_hse = module.callMethod('_frjs_hash_set_entry_next', [p_hse]);
    }
    return a;
  }

  /// Set the list of fields. These fields are expanded for searches on "*".
  void set fields(List flds) {
    int p_fields = module.callMethod('_frt_hs_new_ptr', [0]);
    for (String field in flds) {
      int p_field = allocString(field);
      module.callMethod('_frt_hs_add', [p_fields, p_field]);
    }
    module.callMethod('_frjs_qp_set_fields', [handle, p_fields]);
  }

  /// Returns the list of all tokenized_fields that the [QueryParser] knows
  /// about.
  List get tokenized_fields {
    int p_fields = module.callMethod('_frjs_qp_tokenized_fields', [handle]);
    var a = [];
    if (p_fields != 0) {
      int p_hse = module.callMethod('_frjs_hash_set_first', [p_fields]);
      while (p_hse != 0) {
        int p_elem = module.callMethod('_frjs_hash_set_entry_elem', [p_hse]);
        a.add(stringify(p_elem));
        p_hse = module.callMethod('_frjs_hash_set_entry_next', [p_hse]);
      }
    }
    return a;
  }

  /// Set the list of tokenized_fields. These tokenized_fields are tokenized
  /// in the queries. If this is set to null then all fields will be
  /// tokenized.
  set tokenized_fields(List flds) {
    int p_fields = module.callMethod('_frt_hs_new_ptr', [0]);
    for (String field in flds) {
      int p_field = allocString(field);
      module.callMethod('_frt_hs_add', [p_fields, p_field]);
    }
    module.callMethod('_frjs_qp_set_tkz_fields', [handle, p_fields]);
  }
}

/// Exception raised when there is an error parsing the query string passed to
/// [QueryParser].
class QueryParseException implements Exception {
  factory QueryParseException(String msg) => new Exception(msg);
}

enum QueryType {
  TERM_QUERY,
  MULTI_TERM_QUERY,
  BOOLEAN_QUERY,
  PHRASE_QUERY,
  CONSTANT_QUERY,
  FILTERED_QUERY,
  MATCH_ALL_QUERY,
  RANGE_QUERY,
  TYPED_RANGE_QUERY,
  WILD_CARD_QUERY,
  FUZZY_QUERY,
  PREFIX_QUERY,
  SPAN_TERM_QUERY,
  SPAN_MULTI_TERM_QUERY,
  SPAN_PREFIX_QUERY,
  SPAN_FIRST_QUERY,
  SPAN_OR_QUERY,
  SPAN_NOT_QUERY,
  SPAN_NEAR_QUERY
}
