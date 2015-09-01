library ferret.test.search.multi_searcher;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

// make sure a MultiSearcher searching only one index
// passes all the Searcher tests
class SimpleMultiSearcherTest {
  Searcher _searcher;
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

  static final List DOCUMENTS1 = [
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

  static final List DOCUMENTS2 = [
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

  Searcher _searcher, _single;

  setup() {
    // create MultiSearcher from two seperate searchers
    var dir1 = new RAMDirectory();
    var iw1 = new IndexWriter(
        dir: dir1, analyzer: new WhiteSpaceAnalyzer(), create: true);
    DOCUMENTS1.forEach((doc) => iw1.add_document(doc));
    iw1.close();

    var dir2 = new RAMDirectory();
    var iw2 = new IndexWriter(
        dir: dir2, analyzer: new WhiteSpaceAnalyzer(), create: true);
    DOCUMENTS2.forEach((doc) => iw2.add_document(doc));
    iw2.close();
    _searcher = new MultiSearcher([new Searcher(dir1), new Searcher(dir2)]);

    // create single searcher
    var dir = new RAMDirectory();
    var iw = new IndexWriter(
        dir: dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    DOCUMENTS1.forEach((doc) => iw.add_document(doc));
    DOCUMENTS2.forEach((doc) => iw.add_document(doc));
    iw.close();
    _single = new Searcher(dir);

    //_query_parser = new QueryParser(['date', 'field', 'cat'], analyzer: new WhiteSpaceAnalyzer());
  }

  teardown() {
    _searcher.close();
    _single.close();
  }

  check_hits(query, ignore1, [ignore2 = null, ignore3 = null]) {
    var multi_docs = _searcher.search(query);
    var single_docs = _single.search(query);
    expect(single_docs.hits.size, equals(multi_docs.hits.size),
        reason: 'hit count');
    expect(single_docs.total_hits, equals(multi_docs.total_hits),
        reason: 'hit count');

    multi_docs.hits.each_with_index((sd, id) {
      expect(single_docs.hits[id].doc, equals(sd.doc));
      expect(single_docs.hits[id].score.approx_eql(sd.score), isTrue,
          reason: "${single_docs.hits[id]} != ${sd.score}");
    });
  }

  test_get_doc() {
    expect(18, equals(_searcher.max_doc));
    expect("20050930", equals(_searcher.get_document(0)['date']));
    expect("cat1/sub2/subsub2", equals(_searcher[4]['cat']));
    expect("20051012", equals(_searcher.get_document(12)['date']));
    expect(18, equals(_single.max_doc));
    expect("20050930", equals(_single.get_document(0)['date']));
    expect("cat1/sub2/subsub2", equals(_single[4]['cat']));
    expect("20051012", equals(_single.get_document(12)['date']));
  }
}
