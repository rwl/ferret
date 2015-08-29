library ferret.ext.query_parser;

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
class QueryParser {
  var wild_card_downcase;
  var fields;
  var all_fields;
  var tokenized_fields;
  var default_field;
  var validate_fields;
  var or_default;
  var default_slop;
  var handle_parse_errors;
  var clean_string;
  var max_clauses;
  var use_keywords;
  var use_typed_range_query;

  QueryParser() {
    frb_qp_init;
  }

  parse() => frb_qp_parse;
  get fields() => frb_qp_get_fields;
  set fields() => frb_qp_set_fields;
  get tokenized_fields() => frb_qp_get_tkz_fields;
  set tokenized_fields() => frb_qp_set_tkz_fields;
}

/// Exception raised when there is an error parsing the query string passed to
/// [QueryParser].
class QueryParseException implements Exception {
  QueryParseException();
}
