library ferret.ext.search;

part 'filter.dart';
part 'query.dart';
part 'searcher.dart';
part 'sorting.dart';
part 'span.dart';

/// A hit represents a single document match for a search. It holds the
/// document id of the document that matches along with the score for the
/// match. The score is a positive Float value. The score contained in a hit
/// is not normalized so it can be greater than 1.0. To normalize scores to
/// the range 0.0..1.0 divide the scores by [TopDocs.max_score].
class Hit {
  var doc, score;
}

/// A [TopDocs] object holds a result set for a search. The number of
/// documents that matched the query his held in [TopDocs.total_hits]. The
/// actual results are in the [List] [TopDocs.hits]. The number of hits
/// returned is limited by the [limit] option so the size of the [hits] array
/// will not always be equal to the value of [total_hits]. Finally
/// [TopDocs.max_score] holds the maximum score of any match (not necessarily
/// the maximum score contained in the [hits] array) so it can be used to
/// normalize scores. For example, to print doc ids with scores out of 100.0
/// you could do this:
///
///     top_docs.hits.each((hit) {
///       print("${hit.doc} scored ${hit.score * 100.0 / top_docs.max_score}");
///     });
class TopDocs {
  var total_hits, hits, max_score, searcher;

  /// Returns a string representation of the top_doc in readable format.
  to_s() => frb_td_to_s;

  /// Returns a json representation of the top_doc.
  to_json() => frb_td_to_json;
}

/// Explanation is used to give a description of why a document matched with
/// the score that it did. Use the [Explanation.to_s] or [Explanation.to_html]
/// methods to display the explanation in a human readable format. Creating
/// explanations is an expensive operation so it should only be used for
/// debugging purposes. To create an explanation use the [Searcher.explain]
/// method.
///
///     print(searcher.explain(query, doc_id).to_s);
class Explanation {
  /// Returns a string representation of the explanation in readable format.
  to_s() => frb_expl_to_s;

  /// Returns an html representation of the explanation in readable format.
  to_html() => frb_expl_to_html;

  /// Returns the score represented by the query. This can be used for
  /// debugging purposes mainly to check that the score returned by the
  /// explanation matches that of the score for the document in the original
  /// query.
  double score() => frb_expl_score;
}
