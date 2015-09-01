library ferret.test.search.index_searcher;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

import '../index/index_test_helper.dart';

class SearcherTest {
  //< Test::Unit::TestCase
  //include SearcherTests
  Directory _dir;
  Searcher _searcher;
  List _documents;

  setup() {
    _dir = new RAMDirectory();
    var iw = new IndexWriter(
        dir: _dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    _documents = IndexTestHelper.SEARCH_TEST_DOCS;
    _documents.forEach((doc) => iw.add_document(doc));
    iw.close();
    _searcher = new Searcher(_dir);
  }

  teardown() {
    _searcher.close();
    _dir.close();
  }

  get_docs(List<Hit> hits) {
    var docs = [];
    hits.forEach((hit) {
      docs.add(hit.doc);
    });
    return docs;
  }

  check_hits(query, expected, [top = null, total_hits = null]) {
    var limit = 10;
    if (expected.size > 10) {
      limit = expected.size + 1;
    }
    var top_docs = _searcher.search(query, limit: limit);
    expect(expected.length, equals(top_docs.hits.size));
    if (top != null) {
      expect(top, equals(top_docs.hits[0].doc));
    }
    if (total_hits != null) {
      expect(total_hits, equals(top_docs.total_hits));
    } else {
      expect(expected.length, equals(top_docs.total_hits));
    }
    top_docs.hits.forEach((score_doc) {
      expect(expected.contains(score_doc.doc), isTrue,
          reason: "${score_doc.doc} was found unexpectedly");
      expect(score_doc.score
              .approx_eql(_searcher.explain(query, score_doc.doc).score),
          isTrue,
          reason: "Scores(${score_doc.score} != ${_searcher.explain(query, score_doc.doc).score})");
    });

    expect(expected.sort, equals(_searcher.scan(query)));
    if (expected.size > 5) {
      //expect(expected[0...5], _searcher.scan(query, limit: 5));
      //expect(expected[5..-1], _searcher.scan(query, start_doc: expected[5]));
    }
  }

  test_get_doc() {
    expect(18, equals(_searcher.max_doc));
    expect("20050930", equals(_searcher.get_document(0)['date']));
    expect("cat1/sub2/subsub2", equals(_searcher.get_document(4)['category']));
    expect("20051012", equals(_searcher.get_document(12)['date']));
  }
}
