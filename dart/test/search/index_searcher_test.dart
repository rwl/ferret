library ferret.test.search.index_searcher;

class SearcherTest {
  //< Test::Unit::TestCase
  //include SearcherTests

  setup() {
    _dir = new RAMDirectory();
    iw = new IndexWriter(
        dir: _dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    _documents = IndexTestHelper.SEARCH_TEST_DOCS;
    _documents.each((doc) => iw.add(doc));
    iw.close();
    _searcher = new Searcher(_dir);
  }

  teardown() {
    _searcher.close();
    _dir.close();
  }

  get_docs(hits) {
    docs = [];
    hits.each((hit) {
      docs.add(hit.doc);
    });
    return docs;
  }

  check_hits(query, expected, [top = null, total_hits = null]) {
    options = {};
    if (expected.size > 10) {
      options['limit'] = expected.size + 1;
    }
    top_docs = _searcher.search(query, options);
    assert_equal(expected.length, top_docs.hits.size);
    if (top != null) {
      assert_equal(top, top_docs.hits[0].doc);
    }
    if (total_hits != null) {
      assert_equal(total_hits, top_docs.total_hits);
    } else {
      assert_equal(expected.length, top_docs.total_hits);
    }
    top_docs.hits.each((score_doc) {
      expect(expected.include(score_doc.doc), isTrue,
          "${score_doc.doc} was found unexpectedly");
      expect(score_doc.score
              .approx_eql(_searcher.explain(query, score_doc.doc).score),
          isTrue,
          "Scores(${score_doc.score} != ${_searcher.explain(query, score_doc.doc).score})");
    });

    assert_equal(expected.sort, _searcher.scan(query));
    if (expected.size > 5) {
      //assert_equal(expected[0...5], _searcher.scan(query, limit: 5));
      //assert_equal(expected[5..-1], _searcher.scan(query, start_doc: expected[5]));
    }
  }

  test_get_doc() {
    assert_equal(18, _searcher.max_doc);
    assert_equal("20050930", _searcher.get_document(0)['date']);
    assert_equal("cat1/sub2/subsub2", _searcher.get_document(4)['category']);
    assert_equal("20051012", _searcher.get_document(12)['date']);
  }
}
