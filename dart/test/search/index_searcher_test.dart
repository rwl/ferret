library ferret.test.search.index_searcher;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

import '../index/index_test_helper.dart';

class SearcherTest {
  Directory dir;
  Searcher _searcher;
  List _documents;

  setUp() {
    dir = new RAMDirectory();
    var iw = new IndexWriter(
        dir: dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    _documents = IndexTestHelper.SEARCH_TEST_DOCS;
    _documents.forEach((doc) => iw.add_document(doc));
    iw.close();
    _searcher = new Searcher.store(dir);
  }

  tearDown() {
    _searcher.close();
    dir.close();
  }

  List get_docs(List<Hit> hits) {
    var docs = [];
    hits.forEach((hit) {
      docs.add(hit.doc);
    });
    return docs;
  }

  check_hits(Query query, List expected,
      [int top = null, int total_hits = null]) {
    var limit = 10;
    if (expected.length > 10) {
      limit = expected.length + 1;
    }
    var top_docs = _searcher.search(query, limit: limit);
    expect(expected.length, equals(top_docs.hits.length));
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
      expect(_searcher.explain(query, score_doc.doc).score(),
          closeTo(score_doc.score, 0.0001),
          reason:
              "Scores(${score_doc.score} != ${_searcher.explain(query, score_doc.doc).score})");
    });

    expect(expected.sort, equals(_searcher.scan(query)));
    if (expected.length > 5) {
      //expect(expected[0...5], _searcher.scan(query, limit: 5));
      //expect(expected[5..-1], _searcher.scan(query, start_doc: expected[5]));
    }
  }

  test_get_doc() {
    expect(_searcher.max_doc, equals(18));
    expect(_searcher.get_document(0)['date'], equals("20050930"));
    expect(_searcher.get_document(4)['category'], equals("cat1/sub2/subsub2"));
    expect(_searcher.get_document(12)['date'], equals("20051012"));
  }
}
