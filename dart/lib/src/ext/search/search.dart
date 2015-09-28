library ferret.ext.search;

import 'dart:js' as js;

import '../../proxy.dart';
import '../utils.dart' show BitVector;
import '../index/index.dart' show IndexReader, LazyDoc;
import '../store.dart' show Directory;

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
  final int doc;
  final double score;
  Hit._handle(js.JsObject module, int handle)
      : doc = module.callMethod('_frjs_hit_get_doc', [handle]),
        score = module.callMethod('_frjs_hit_get_score', [handle]);
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
  int total_hits;
  List<Hit> hits;
  int max_score;
  Searcher searcher;

  TopDocs._module(js.JsObject module, int handle, this.searcher) {
    int sz = module.callMethod('_frjs_td_get_size', [handle]);
    hits = new List<Hit>(sz);
    for (var i = 0; i < sz; i++) {
      int p_hit = module.callMethod('_frjs_td_get_hit', [handle, i]);
      hits[i] = new Hit._handle(module, p_hit);
    }
    total_hits = module.callMethod('_frjs_td_get_total_hits', [handle]);
    max_score = module.callMethod('_frjs_td_get_max_score', [handle]);
  }

  /// Returns a string representation of the top_doc in readable format.
  String to_s(String field) {
    var sb = new StringBuffer(
        "TopDocs: total_hits = $total_hits, max_score = $max_score [\n");
    for (var hit in hits) {
      var value = '';
      var ld = searcher.get_document(hit.doc);
      if (ld.containsKey(field)) {
        value = ld[field];
      }
      sb.write('\t${hit.doc} "$value": ${hit.score}\n');
    }
    sb.write("]\n");
    return sb.toString();
  }

  /// Returns a json representation of the top_doc.
  String to_json() {
    var sb = new StringBuffer('[');
    for (var i = 0; i < hits.length; i++) {
      var hit = hits[i];
      if (i != 0) {
        sb.write(',');
      }
      var ld = searcher.get_document(hit.doc);
      int j = 0;
      ld.forEach((String name, value) {
        if (j != 0) {
          sb.write(',');
        }
        sb.write('"$name":');
        if (value is Iterable) {
          sb.write('[');
          sb.write(value.join(','));
          sb.write(']');
        } else {
          sb.write(value.toString());
        }
        j++;
      });
    }
    sb.write(']');
    return sb.toString();
  }
}

/// Explanation is used to give a description of why a document matched with
/// the score that it did. Use the [Explanation.to_s] or [Explanation.to_html]
/// methods to display the explanation in a human readable format. Creating
/// explanations is an expensive operation so it should only be used for
/// debugging purposes. To create an explanation use the [Searcher.explain]
/// method.
///
///     print(searcher.explain(query, doc_id).to_s);
class Explanation extends JsProxy {
  Explanation._handle(int p_expl) : super() {
    handle = p_expl;
  }

  /// Returns a string representation of the explanation in readable format.
  String to_s() {
    int p_s = module.callMethod('_frt_expl_to_s', [handle]);
    var s = stringify(p_s);
    free(p_s);
    return s;
  }

  /// Returns an html representation of the explanation in readable format.
  String to_html() {
    int p_html = module.callMethod('_frt_expl_to_html', [handle]);
    var html = stringify(p_html);
    free(p_html);
    return html;
  }

  /// Returns the score represented by the query. This can be used for
  /// debugging purposes mainly to check that the score returned by the
  /// explanation matches that of the score for the document in the original
  /// query.
  double score() => module.callMethod('_frjs_expl_get_score', [handle]);
}
