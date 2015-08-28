library ferret.test.search.filter;

class FilterTest {
  //< Test::Unit::TestCase

  setup() {
    _dir = new RAMDirectory();
    iw = new IndexWriter(
        dir: _dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    [
      {'int': "0", 'date': "20040601", 'switch': "on"},
      {'int': "1", 'date': "20041001", 'switch': "off"},
      {'int': "2", 'date': "20051101", 'switch': "on"},
      {'int': "3", 'date': "20041201", 'switch': "off"},
      {'int': "4", 'date': "20051101", 'switch': "on"},
      {'int': "5", 'date': "20041201", 'switch': "off"},
      {'int': "6", 'date': "20050101", 'switch': "on"},
      {'int': "7", 'date': "20040701", 'switch': "off"},
      {'int': "8", 'date': "20050301", 'switch': "on"},
      {'int': "9", 'date': "20050401", 'switch': "off"}
    ].each((doc) => iw.add(doc));
    iw.close();
  }

  def teardown() {
    _dir.close();
  }

  do_test_top_docs(searcher, query, expected, filter) {
    top_docs = searcher.search(query, {'filter': filter});
    print(top_docs);
    assert_equal(expected.size, top_docs.hits.size);
    top_docs.total_hits.times((i) {
      assert_equal(expected[i], top_docs.hits[i].doc);
    });
  }

  test_range_filter() {
    var searcher = new Searcher(_dir);
    q = new MatchAllQuery();
    rf = new RangeFilter('int', geq: "2", leq: "6");
    do_test_top_docs(searcher, q, [2, 3, 4, 5, 6], rf);
    rf = new RangeFilter('int', geq: "2", le: "6");
    do_test_top_docs(searcher, q, [2, 3, 4, 5], rf);
    rf = new RangeFilter('int', ge: "2", leq: "6");
    do_test_top_docs(searcher, q, [3, 4, 5, 6], rf);
    rf = new RangeFilter('int', ge: "2", le: "6");
    do_test_top_docs(searcher, q, [3, 4, 5], rf);
    rf = new RangeFilter('int', geq: "6");
    do_test_top_docs(searcher, q, [6, 7, 8, 9], rf);
    rf = new RangeFilter('int', ge: "6");
    do_test_top_docs(searcher, q, [7, 8, 9], rf);
    rf = new RangeFilter('int', leq: "2");
    do_test_top_docs(searcher, q, [0, 1, 2], rf);
    rf = new RangeFilter('int', le: "2");
    do_test_top_docs(searcher, q, [0, 1], rf);

    bits = rf.bits(searcher.reader);
    assert(bits[0]);
    assert(bits[1]);
    assert(!bits[2]);
    assert(!bits[3]);
    assert(!bits[4]);
  }

  test_range_filter_errors() {
    assert_raise(() {
      f = new RangeFilter('f', ge: "b", le: "a");
    }, ArgumentError);
    assert_raise(() {
      f = new RangeFilter('f', include_lower: true);
    }, ArgumentError);
    assert_raise(() {
      f = new RangeFilter('f', include_upper: true);
    }, ArgumentError);
  }

  test_query_filter() {
    var searcher = new Searcher(_dir);
    q = new MatchAllQuery();
    qf = new QueryFilter(new TermQuery('switch', "on"));
    do_test_top_docs(searcher, q, [0, 2, 4, 6, 8], qf);
    // test again to test caching doesn't break it
    do_test_top_docs(searcher, q, [0, 2, 4, 6, 8], qf);
    qf = new QueryFilter(new TermQuery('switch', "off"));
    do_test_top_docs(searcher, q, [1, 3, 5, 7, 9], qf);

    bits = qf.bits(searcher.reader);
    assert(bits[1]);
    assert(bits[3]);
    assert(bits[5]);
    assert(bits[7]);
    assert(bits[9]);
    assert(!bits[0]);
    assert(!bits[2]);
    assert(!bits[4]);
    assert(!bits[6]);
    assert(!bits[8]);
  }

  test_filtered_query() {
    var searcher = new Searcher(_dir);
    q = new MatchAllQuery();
    rf = new RangeFilter('int', geq: "2", leq: "6");
    rq = new FilteredQuery(q, rf);
    qf = new QueryFilter(new TermQuery('switch', "on"));
    do_test_top_docs(searcher, rq, [2, 4, 6], qf);
    query = new FilteredQuery(rq, qf);
    rf2 = new RangeFilter('int', geq: "3");
    do_test_top_docs(searcher, query, [4, 6], rf2);
  }

  test_custom_filter() {
    var searcher = new Searcher(_dir);
    q = new MatchAllQuery();
    filt = new CustomFilter();
    do_test_top_docs(searcher, q, [0, 2, 4], filt);
  }

  test_filter_proc() {
    var searcher = new Searcher(_dir);
    q = new MatchAllQuery();
    filter_proc(doc, score, s) => (s[doc]['int'] % 2) == 0;
    top_docs = searcher.search(q, filter_proc: filter_proc);
    top_docs.hits.each((hit) {
      assert_equal(0, searcher[hit.doc]['int'] % 2);
    });
  }

  test_score_modifying_filter_proc() {
    var searcher = new Searcher(_dir);
    q = new MatchAllQuery();
    start_date = Date.parse('2008-02-08');
    date_half_life_50(doc, score, s) {
      days = (start_date - Date.parse(s[doc]['date'], '%Y%m%d')).to_i();
      1.0 / (pow(2.0, (days.to_f / 50.0)));
    }
    top_docs = searcher.search(q, filter_proc: date_half_life_50);
    docs = top_docs.hits.collect((hit) => hit.doc);
    assert_equal(docs, [2, 4, 9, 8, 6, 3, 5, 1, 7, 0]);
    rev_date_half_life_50(doc, score, s) {
      days = (start_date - Date.parse(s[doc]['date'], '%Y%m%d')).to_i();
      1.0 - 1.0 / (pow(2.0, (days.to_f / 50.0)));
    }
    top_docs = searcher.search(q, filter_proc: rev_date_half_life_50);
    docs = top_docs.hits.collect((hit) => hit.doc);
    assert_equal(docs, [0, 7, 1, 3, 5, 6, 8, 9, 2, 4]);
  }
}

class CustomFilter {
  bits(ir) {
    bv = new BitVector();
    bv[0] = bv[2] = bv[4] = true;
    bv;
  }
}
