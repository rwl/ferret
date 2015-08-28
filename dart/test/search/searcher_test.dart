library ferret.test.search.searcher;

class SearcherTests {
//  include Ferret::Search

  test_term_query() {
    tq = new TermQuery('field', "word2");
    tq.boost = 100;
    check_hits(tq, [1, 4, 8]);
    //puts _searcher.explain(tq, 1);
    //puts _searcher.explain(tq, 4);
    //puts _searcher.explain(tq, 8);

    tq = new TermQuery('field', "2342");
    check_hits(tq, []);

    tq = new TermQuery('field', "");
    check_hits(tq, []);

    tq = new TermQuery('field', "word1");
    top_docs = _searcher.search(tq);
    assert_equal(_searcher.max_doc, top_docs.total_hits);
    assert_equal(10, top_docs.hits.size);
    top_docs = _searcher.search(tq, {'limit': 20});
    assert_equal(_searcher.max_doc, top_docs.hits.size);

    assert_equal([new Term('field', "word1")], tq.terms(_searcher));
  }

  check_docs(query, options, [expected = const []]) {
    top_docs = _searcher.search(query, options);
    docs = top_docs.hits;
    assert_equal(expected.length, docs.length);
    docs.length.times((i) {
      assert_equal(expected[i], docs[i].doc);
    });
    if (options['limit'] == 'all' && options['offset'] == null) {
      assert_equal(expected.sort, _searcher.scan(query));
    }
  }

  test_offset() {
    tq = new TermQuery('field', "word1");
    tq.boost = 100;
    top_docs = _searcher.search(tq, {'limit': 100});
    expected = [];
    top_docs.hits.each((sd) {
      expected.add(sd.doc);
    });

    assert_raise(() => _searcher.search(tq, {'offset': -1}), ArgumentError);
    assert_raise(() => _searcher.search(tq, {'limit': 0}), ArgumentError);
    assert_raise(() => _searcher.search(tq, {'limit': -1}), ArgumentError);

//    check_docs(tq, {'limit': 8, 'offset': 0}, expected[0,8]);
//    check_docs(tq, {'limit': 3, 'offset': 1}, expected[1,3]);
//    check_docs(tq, {'limit': 6, 'offset': 2}, expected[2,6]);
//    check_docs(tq, {'limit': 2, 'offset': expected.length}, []);
//    check_docs(tq, {'limit': 2, 'offset': expected.length + 100}, []);
//    check_docs(tq, {'limit': 'all'}, expected);
//    check_docs(tq, {'limit': 'all', 'offset': 2}, expected[2..-1]);
  }

  test_multi_term_query() {
    mtq = new MultiTermQuery('field', max_terms: 4, min_score: 0.5);
    check_hits(mtq, []);
    assert_equal('""', mtq.to_s('field'));
    assert_equal('field:""', mtq.to_s);

    [
      ["brown", 1.0, '"brown"'],
      ["fox", 0.1, '"brown"'],
      ["fox", 0.6, '"fox^0.6|brown"'],
      ["fast", 50.0, '"fox^0.6|brown|fast^50.0"']
    ].each((term, boost, str) {
      mtq.add_term(term, boost);
      assert_equal(str, mtq.to_s('field'));
      assert_equal("field:#{str}", mtq.to_s());
    });

    mtq.boost = 80.1;
    assert_equal('field:"fox^0.6|brown|fast^50.0"^80.1', mtq.to_s());
    mtq.add("word1");
    assert_equal('field:"fox^0.6|brown|word1|fast^50.0"^80.1', mtq.to_s());
    mtq.add("word2");
    assert_equal('field:"brown|word1|word2|fast^50.0"^80.1', mtq.to_s());
    mtq.add("word3");
    assert_equal('field:"brown|word1|word2|fast^50.0"^80.1', mtq.to_s());

    terms = mtq.terms(_searcher);
    assert(terms.index(new Term('field', "brown")));
    assert(terms.index(new Term('field', "word1")));
    assert(terms.index(new Term('field', "word2")));
    assert(terms.index(new Term('field', "fast")));
  }

  test_boolean_query() {
    bq = new BooleanQuery();
    tq1 = new TermQuery('field', "word1");
    tq2 = new TermQuery('field', "word3");
    bq.add_query(tq1, 'must');
    bq.add_query(tq2, 'must');
    check_hits(bq, [2, 3, 6, 8, 11, 14], 14);

    tq3 = new TermQuery('field', "word2");
    bq.add_query(tq3, 'should');
    check_hits(bq, [2, 3, 6, 8, 11, 14], 8);

    bq = new BooleanQuery();
    bq.add_query(tq2, 'must');
    bq.add_query(tq3, 'must_not');
    check_hits(bq, [2, 3, 6, 11, 14]);

    bq = new BooleanQuery();
    bq.add_query(tq2, 'must_not');
    check_hits(bq, [0, 1, 4, 5, 7, 9, 10, 12, 13, 15, 16, 17]);

    bq = new BooleanQuery();
    bq.add_query(tq2, 'should');
    bq.add_query(tq3, 'should');
    check_hits(bq, [1, 2, 3, 4, 6, 8, 11, 14]);

    bq = new BooleanQuery();
    bc1 = new BooleanClause(tq2, 'should');
    bc2 = new BooleanClause(tq3, 'should');
    bq.add(bc1);
    bq.add(bc2);
    check_hits(bq, [1, 2, 3, 4, 6, 8, 11, 14]);
  }

  test_phrase_query() {
    pq = new PhraseQuery('field');
    assert_equal("\"\"", pq.to_s('field'));
    assert_equal("field:\"\"", pq.to_s);

    pq..add("quick")..add("brown")..add("fox");
    check_hits(pq, [1]);

    pq = new PhraseQuery('field', 1);
    pq..add("quick");
    pq.add_term("fox", 2);
    check_hits(pq, [1, 11, 14, 16]);

    pq.slop = 0;
    check_hits(pq, [1, 11, 14]);

    pq.slop = 1;
    check_hits(pq, [1, 11, 14, 16]);

    pq.slop = 4;
    check_hits(pq, [1, 11, 14, 16, 17]);
  }

  test_range_query() {
    rq = new RangeQuery('date', lower: "20051006", upper: "20051010");
    check_hits(rq, [6, 7, 8, 9, 10]);

    rq = new RangeQuery('date', geq: "20051006", leq: "20051010");
    check_hits(rq, [6, 7, 8, 9, 10]);

    rq = new RangeQuery('date',
        lower: "20051006", upper: "20051010", include_lower: false);
    check_hits(rq, [7, 8, 9, 10]);

    rq = new RangeQuery('date', ge: "20051006", leq: "20051010");
    check_hits(rq, [7, 8, 9, 10]);

    rq = new RangeQuery('date',
        lower: "20051006", upper: "20051010", include_upper: false);
    check_hits(rq, [6, 7, 8, 9]);

    rq = new RangeQuery('date', geq: "20051006", le: "20051010");
    check_hits(rq, [6, 7, 8, 9]);

    rq = new RangeQuery('date',
        lower: "20051006",
        upper: "20051010",
        include_lower: false,
        include_upper: false);
    check_hits(rq, [7, 8, 9]);

    rq = new RangeQuery('date', ge: "20051006", le: "20051010");
    check_hits(rq, [7, 8, 9]);

    rq = new RangeQuery('date', upper: "20051003");
    check_hits(rq, [0, 1, 2, 3]);

    rq = new RangeQuery('date', leq: "20051003");
    check_hits(rq, [0, 1, 2, 3]);

    rq = new RangeQuery('date', upper: "20051003", include_upper: false);
    check_hits(rq, [0, 1, 2]);

    rq = new RangeQuery('date', le: "20051003");
    check_hits(rq, [0, 1, 2]);

    rq = new RangeQuery('date', lower: "20051014");
    check_hits(rq, [14, 15, 16, 17]);

    rq = new RangeQuery('date', geq: "20051014");
    check_hits(rq, [14, 15, 16, 17]);

    rq = new RangeQuery('date', lower: "20051014", include_lower: false);
    check_hits(rq, [15, 16, 17]);

    rq = new RangeQuery('date', ge: "20051014");
    check_hits(rq, [15, 16, 17]);
  }

  test_typed_range_query() {
    rq = new TypedRangeQuery('number', geq: "-1.0", leq: 1.0);
    check_hits(rq, [0, 1, 4, 10, 15, 17]);

    rq = new TypedRangeQuery('number', ge: "-1.0", le: 1.0);
    check_hits(rq, [0, 1, 4, 15]);

    if (ENV['FERRET_DEV']) {
      // text hexadecimal
      rq = new TypedRangeQuery('number', ge: "1.0", leq: "0xa");
      check_hits(rq, [6, 7, 9, 12]);
    }

    // test single bound
    rq = new TypedRangeQuery('number', leq: "0.0");
    check_hits(rq, [5, 11, 15, 16, 17]);

    // test single bound
    rq = new TypedRangeQuery('number', ge: "0.0");
    check_hits(rq, [0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 12, 13, 14]);

    // below range - no results
    rq = new TypedRangeQuery('number', ge: "10051006", le: "10051010");
    check_hits(rq, []);

    // above range - no results
    rq = new TypedRangeQuery('number', ge: "-12518421", le: "-12518420");
    check_hits(rq, []);
  }

  test_prefix_query() {
    pq = new PrefixQuery('category', "cat1");
    check_hits(pq, [0, 1, 2, 3, 4, 13, 14, 15, 16, 17]);

    pq = new PrefixQuery('category', "cat1/sub2");
    check_hits(pq, [3, 4, 13, 15]);
  }

  test_wildcard_query() {
    wq = new WildcardQuery('category', "cat1*");
    check_hits(wq, [0, 1, 2, 3, 4, 13, 14, 15, 16, 17]);

    wq = new WildcardQuery('category', "cat1*/su??ub2");
    check_hits(wq, [4, 16]);

    wq = new WildcardQuery('category', "*/sub2*");
    check_hits(wq, [3, 4, 13, 15]);
  }

  test_multi_phrase_query() {
    mpq = new PhraseQuery('field');
    mpq.add(["quick", "fast"]);
    mpq.add(["brown", "red", "hairy"]);
    mpq.add("fox");
    check_hits(mpq, [1, 8, 11, 14]);

    mpq.slop = 4;
    check_hits(mpq, [1, 8, 11, 14, 16, 17]);
  }

  test_highlighter() {
    dir = new RAMDirectory();
    iw = new IndexWriter(dir: dir, analyzer: new WhiteSpaceAnalyzer());
    long_text = "big " + "between " * 2000 + 'house';
    [
      {
        'field': "the words we are searching for are one and two also " +
            "sometimes looking for them as a phrase like this; one " +
            "two lets see how it goes"
      },
      {'long': 'before ' * 1000 + long_text + ' after' * 1000},
      {'dates': '20070505 20071230 20060920 20081111'},
    ].each((doc) => iw.add(doc));
    iw.close();

    searcher = new Searcher(dir);

    q = new TermQuery('field', "one");
    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 1);
    assert_equal(1, highlights.size);
    assert_equal("...are <b>one</b>...", highlights[0]);

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 2);
    assert_equal(2, highlights.size);
    assert_equal("...are <b>one</b>...", highlights[0]);
    assert_equal("...this; <b>one</b>...", highlights[1]);

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 3);
    assert_equal(3, highlights.size);
    assert_equal("the words...", highlights[0]);
    assert_equal("...are <b>one</b>...", highlights[1]);
    assert_equal("...this; <b>one</b>...", highlights[2]);

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 4);
    assert_equal(3, highlights.size);
    assert_equal("the words we are...", highlights[0]);
    assert_equal("...are <b>one</b>...", highlights[1]);
    assert_equal("...this; <b>one</b>...", highlights[2]);

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 5);
    assert_equal(2, highlights.size);
    assert_equal(
        "the words we are searching for are <b>one</b>...", highlights[0]);
    assert_equal("...this; <b>one</b>...", highlights[1]);

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 20);
    assert_equal(1, highlights.size);
    assert_equal("the words we are searching for are <b>one</b> and two also " +
        "sometimes looking for them as a phrase like this; <b>one</b> " +
        "two lets see how it goes", highlights[0]);

    highlights = searcher.highlight(q, 0, 'field',
        excerpt_length: 1000, num_excerpts: 1);
    assert_equal(1, highlights.size);
    assert_equal("the words we are searching for are <b>one</b> and two also " +
        "sometimes looking for them as a phrase like this; <b>one</b> " +
        "two lets see how it goes", highlights[0]);

    q = new BooleanQuery(false);
    q << new TermQuery('field', "one");
    q << new TermQuery('field', "two");

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 15, num_excerpts: 2);
    assert_equal(2, highlights.size);
    assert_equal("...<b>one</b> and <b>two</b>...", highlights[0]);
    assert_equal("...this; <b>one</b> <b>two</b>...", highlights[1]);

    q << (new PhraseQuery('field') << "one" << "two");

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 15, num_excerpts: 2);
    assert_equal(2, highlights.size);
    assert_equal("...<b>one</b> and <b>two</b>...", highlights[0]);
    assert_equal("...this; <b>one two</b>...", highlights[1]);

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 15, num_excerpts: 1);
    assert_equal(1, highlights.size);
    // should have a higher priority since it the merger of three matches
    assert_equal("...this; <b>one two</b>...", highlights[0]);

    highlights = searcher.highlight(q, 0, 'not_a_field',
        excerpt_length: 15, num_excerpts: 1);
    assert_nil(highlights);

    q = new TermQuery('wrong_field', "one");
    highlights = searcher.highlight(q, 0, 'wrong_field',
        excerpt_length: 15, num_excerpts: 1);
    assert_nil(highlights);

    q = new BooleanQuery(false);
    q.add(new PhraseQuery('field') << "the" << "words");
    q.add(
        new PhraseQuery('field') << "for" << "are" << "one" << "and" << "two");
    q.add(new TermQuery('field', "words"));
    q.add(new TermQuery('field', "one"));
    q.add(new TermQuery('field', "two"));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 1);
    assert_equal(1, highlights.size);
    assert_equal("<b>the words</b>...", highlights[0]);

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 2);
    assert_equal(2, highlights.size);
    assert_equal("<b>the words</b>...", highlights[0]);
    assert_equal("...<b>one</b> <b>two</b>...", highlights[1]);

    [
      [
        new RangeQuery('dates', geq: '20081111'),
        '20070505 20071230 20060920 <b>20081111</b>'
      ],
      [
        new RangeQuery('dates', geq: '20070101'),
        '<b>20070505</b> <b>20071230</b> 20060920 <b>20081111</b>'
      ],
      [
        new PrefixQuery('dates', '2007'),
        '<b>20070505</b> <b>20071230</b> 20060920 20081111'
      ],
    ].each((query, expected) {
      assert_equal([expected], searcher.highlight(query, 2, 'dates'));
    });

    //q = new PhraseQuery('long')..add('big')..add('house');
    //q.slop = 4000
    //highlights = searcher.highlight(q, 1, :long,
    //                                excerpt_length: 400,
    //                                num_excerpts: 2);
    //assert_equal(1, highlights.size);
    //print(highlights[0]);
    //assert_equal("<b>the words</b>...", highlights[0]);
    //assert_equal("...<b>one</b> <b>two</b>...", highlights[1]);
  }

  test_highlighter_with_standard_analyzer() {
    dir = new RAMDirectory();
    iw = new IndexWriter(dir: dir, analyzer: new StandardAnalyzer());
    [{'field': "field has a url http://ferret.davebalmain.com/trac/ end"},]
        .each((doc) => iw.add(doc));
    iw.close();

    searcher = new Searcher(dir);

    q = new TermQuery('field', "ferret.davebalmain.com/trac");
    highlights = searcher.highlight(q, 0, 'field',
        excerpt_length: 1000, num_excerpts: 1);
    assert_equal(1, highlights.size);
    assert_equal(
        "field has a url <b>http://ferret.davebalmain.com/trac/</b> end",
        highlights[0]);
  }
}
