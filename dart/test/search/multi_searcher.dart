library ferret.test.search.multi_searcher;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'index_searcher_test.dart';

/// Make sure a [MultiSearcher] searching only one index
/// passes all the [Searcher] tests.
class SimpleMultiSearcherTest extends SearcherTest {
  Searcher _searcher;

  setUp() {
    super.setUp();
    _searcher = new MultiSearcher(ferret, [new Searcher.store(ferret, dir)]);
  }
}

/// Checks query results of a [MultiSearcher] searching two indexes
/// against those of a single [Searcher] searching the same
/// set of documents.
multiSearcherTest(Ferret ferret) {
  final List DOCUMENTS1 = [
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

  final List DOCUMENTS2 = [
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

  MultiSearcher _searcher;
  Searcher _single;

  setUp(() {
    // create MultiSearcher from two seperate searchers
    var dir1 = new RAMDirectory(ferret);
    var iw1 = new IndexWriter(ferret,
        dir: dir1, analyzer: new WhiteSpaceAnalyzer(ferret), create: true);
    DOCUMENTS1.forEach((doc) => iw1.add_document(doc));
    iw1.close();

    var dir2 = new RAMDirectory(ferret);
    var iw2 = new IndexWriter(ferret,
        dir: dir2, analyzer: new WhiteSpaceAnalyzer(ferret), create: true);
    DOCUMENTS2.forEach((doc) => iw2.add_document(doc));
    iw2.close();
    _searcher = new MultiSearcher(ferret,
        [new Searcher.store(ferret, dir1), new Searcher.store(ferret, dir2)]);

    // create single searcher
    var dir = new RAMDirectory(ferret);
    var iw = new IndexWriter(ferret,
        dir: dir, analyzer: new WhiteSpaceAnalyzer(ferret), create: true);
    DOCUMENTS1.forEach((doc) => iw.add_document(doc));
    DOCUMENTS2.forEach((doc) => iw.add_document(doc));
    iw.close();
    _single = new Searcher.store(ferret, dir);

    //_query_parser = new QueryParser(['date', 'field', 'cat'], analyzer: new WhiteSpaceAnalyzer());
  });

  tearDown(() {
    _searcher.close();
    _single.close();
  });

  check_hits(Query query, ignore1, [ignore2 = null, ignore3 = null]) {
    var multi_docs = _searcher.search(query);
    var single_docs = _single.search(query);
    expect(single_docs.hits.length, equals(multi_docs.hits.length),
        reason: 'hit count');
    expect(single_docs.total_hits, equals(multi_docs.total_hits),
        reason: 'hit count');

    int id = 0;
    multi_docs.hits.forEach((sd) {
      expect(sd.doc, equals(single_docs.hits[id].doc));
      expect(sd.score, closeTo(single_docs.hits[id].score, 0.0001),
          reason: "${single_docs.hits[id]} != ${sd.score}");
      id++;
    });
  }

  test('get_doc', () {
    expect(_searcher.max_doc, equals(18));
    expect(_searcher.get_document(0)['date'], equals("20050930"));
    expect(_searcher[4]['cat'], equals("cat1/sub2/subsub2"));
    expect(_searcher.get_document(12)['date'], equals("20051012"));
    expect(_single.max_doc, equals(18));
    expect(_single.get_document(0)['date'], equals("20050930"));
    expect(_single[4]['cat'], equals("cat1/sub2/subsub2"));
    expect(_single.get_document(12)['date'], equals("20051012"));
  });
}
