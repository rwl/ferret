library ferret.test.search.multi_searcher;

// make sure a MultiSearcher searching only one index
// passes all the Searcher tests
class SimpleMultiSearcherTest {
  //extends SearcherTest {
  //alias :old_setup :setup
  setup() {
    old_setup();
    _searcher = new MultiSearcher([new Searcher(_dir)]);
  }
}

// checks query results of a multisearcher searching two indexes
// against those of a single indexsearcher searching the same
// set of documents
class MultiSearcherTest {
  //< Test::Unit::TestCase

  static final DOCUMENTS1 = [
    {"date": "20050930", 'field': "word1", "cat": "cat1/"},
    {
      "date": "20051001",
      'field': "word1 word2 the quick brown fox",
      "cat": "cat1/sub1"
    },
    {"date": "20051002", 'field': "word1 word3", "cat": "cat1/sub1/subsub1"},
    {"date": "20051003", 'field': "word1 word3", "cat": "cat1/sub2"},
    {"date": "20051004", 'field': "word1 word2", "cat": "cat1/sub2/subsub2"},
    {"date": "20051005", 'field': "word1", "cat": "cat2/sub1"},
    {"date": "20051006", 'field': "word1 word3", "cat": "cat2/sub1"},
    {"date": "20051007", 'field': "word1", "cat": "cat2/sub1"},
    {
      "date": "20051008",
      'field': "word1 word2 word3 the fast brown fox",
      "cat": "cat2/sub1"
    }
  ];

  static final DOCUMENTS2 = [
    {"date": "20051009", 'field': "word1", "cat": "cat3/sub1"},
    {"date": "20051010", 'field': "word1", "cat": "cat3/sub1"},
    {
      "date": "20051011",
      'field': "word1 word3 the quick red fox",
      "cat": "cat3/sub1"
    },
    {"date": "20051012", 'field': "word1", "cat": "cat3/sub1"},
    {"date": "20051013", 'field': "word1", "cat": "cat1/sub2"},
    {
      "date": "20051014",
      'field': "word1 word3 the quick hairy fox",
      "cat": "cat1/sub1"
    },
    {"date": "20051015", 'field': "word1", "cat": "cat1/sub2/subsub1"},
    {
      "date": "20051016",
      'field': "word1 the quick fox is brown and hairy and a little red",
      "cat": "cat1/sub1/subsub2"
    },
    {
      "date": "20051017",
      'field': "word1 the brown fox is quick and red",
      "cat": "cat1/"
    }
  ];

  setup() {
    // create MultiSearcher from two seperate searchers
    dir1 = new RAMDirectory();
    iw1 = new IndexWriter(
        dir: dir1, analyzer: new WhiteSpaceAnalyzer(), create: true);
    DOCUMENTS1.each((doc) => iw1.add(doc));
    iw1.close();

    dir2 = new RAMDirectory();
    iw2 = new IndexWriter(
        dir: dir2, analyzer: new WhiteSpaceAnalyzer(), create: true);
    DOCUMENTS2.each((doc) => iw2.add(doc));
    iw2.close();
    _searcher = new MultiSearcher([new Searcher(dir1), new Searcher(dir2)]);

    // create single searcher
    dir = new RAMDirectory();
    iw = new IndexWriter(
        dir: dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    DOCUMENTS1.each((doc) => iw.add(doc));
    DOCUMENTS2.each((doc) => iw.add(doc));
    iw.close();
    _single = new Searcher(dir);

    //_query_parser = new QueryParser(['date', 'field', 'cat'], analyzer: new WhiteSpaceAnalyzer());
  }

  teardown() {
    _searcher.close();
    _single.close();
  }

  check_hits(query, ignore1, [ignore2 = null, ignore3 = null]) {
    multi_docs = _searcher.search(query);
    single_docs = _single.search(query);
    assert_equal(single_docs.hits.size, multi_docs.hits.size, 'hit count');
    assert_equal(single_docs.total_hits, multi_docs.total_hits, 'hit count');

    multi_docs.hits.each_with_index((sd, id) {
      assert_equal(single_docs.hits[id].doc, sd.doc);
      expect(single_docs.hits[id].score.approx_eql(sd.score), isTrue,
          "#{single_docs.hits[id]} != #{sd.score}");
    });
  }

  test_get_doc() {
    assert_equal(18, _searcher.max_doc);
    assert_equal("20050930", _searcher.get_document(0)['date']);
    assert_equal("cat1/sub2/subsub2", _searcher[4]['cat']);
    assert_equal("20051012", _searcher.get_document(12)['date']);
    assert_equal(18, _single.max_doc);
    assert_equal("20050930", _single.get_document(0)['date']);
    assert_equal("cat1/sub2/subsub2", _single[4]['cat']);
    assert_equal("20051012", _single.get_document(12)['date']);
  }
}
