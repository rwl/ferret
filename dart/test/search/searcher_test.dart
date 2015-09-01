library ferret.test.search.searcher;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

abstract class SearcherTests {
//  include Ferret::Search
  Searcher _searcher;

  check_hits(query, expected, [b]);

  test_term_query() {
    var tq = new TermQuery('field', "word2");
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
    var top_docs = _searcher.search(tq);
    expect(_searcher.max_doc, equals(top_docs.total_hits));
    expect(10, equals(top_docs.hits.size));
    top_docs = _searcher.search(tq, limit: 20);
    expect(_searcher.max_doc, equals(top_docs.hits.size));

    expect([new Term('field', "word1")], equals(tq.terms(_searcher)));
  }

  check_docs(query, options, [expected = const []]) {
    var top_docs = _searcher.search(query, options);
    var docs = top_docs.hits;
    expect(expected.length, equals(docs.length));
    docs.length.times((i) {
      expect(expected[i], equals(docs[i].doc));
    });
    if (options['limit'] == 'all' && options['offset'] == null) {
      expect(expected.sort, equals(_searcher.scan(query)));
    }
  }

  test_offset() {
    var tq = new TermQuery('field', "word1");
    tq.boost = 100;
    var top_docs = _searcher.search(tq, limit: 100);
    var expected = [];
    top_docs.hits.each((sd) {
      expected.add(sd.doc);
    });

    expect(() => _searcher.search(tq, offset: -1), ArgumentError);
    expect(() => _searcher.search(tq, limit: 0), ArgumentError);
    expect(() => _searcher.search(tq, limit: -1), ArgumentError);

//    check_docs(tq, limit: 8, offset: 0, expected[0,8]);
//    check_docs(tq, limit: 3, offset: 1, expected[1,3]);
//    check_docs(tq, limit: 6, offset: 2, expected[2,6]);
//    check_docs(tq, limit: 2, offset: expected.length, []);
//    check_docs(tq, limit: 2, offset: expected.length + 100, []);
//    check_docs(tq, limit: 'all', expected);
//    check_docs(tq, limit: 'all', offset: 2, expected[2..-1]);
  }

  test_multi_term_query() {
    var mtq = new MultiTermQuery('field', max_terms: 4, min_score: 0.5);
    check_hits(mtq, []);
    expect('""', equals(mtq.to_s('field')));
    expect('field:""', equals(mtq.to_s));

    [
      ["brown", 1.0, '"brown"'],
      ["fox", 0.1, '"brown"'],
      ["fox", 0.6, '"fox^0.6|brown"'],
      ["fast", 50.0, '"fox^0.6|brown|fast^50.0"']
    ].forEach((row) {
      var term = row[0],
          boost = row[1],
          str = row[2];
      mtq.add_term(term, boost);
      expect(str, equals(mtq.to_s('field')));
      expect("field:#{str}", equals(mtq.to_s()));
    });

    mtq.boost = 80.1;
    expect('field:"fox^0.6|brown|fast^50.0"^80.1', equals(mtq.to_s()));
    mtq.add_term("word1");
    expect('field:"fox^0.6|brown|word1|fast^50.0"^80.1', equals(mtq.to_s()));
    mtq.add_term("word2");
    expect('field:"brown|word1|word2|fast^50.0"^80.1', equals(mtq.to_s()));
    mtq.add_term("word3");
    expect('field:"brown|word1|word2|fast^50.0"^80.1', equals(mtq.to_s()));

    var terms = mtq.terms(_searcher);
    expect(terms.index(new Term('field', "brown")), isTrue);
    expect(terms.index(new Term('field', "word1")), isTrue);
    expect(terms.index(new Term('field', "word2")), isTrue);
    expect(terms.index(new Term('field', "fast")), isTrue);
  }

  test_boolean_query() {
    var bq = new BooleanQuery();
    var tq1 = new TermQuery('field', "word1");
    var tq2 = new TermQuery('field', "word3");
    bq.add_query(tq1, occur: 'must');
    bq.add_query(tq2, occur: 'must');
    check_hits(bq, [2, 3, 6, 8, 11, 14], 14);

    var tq3 = new TermQuery('field', "word2");
    bq.add_query(tq3, occur: 'should');
    check_hits(bq, [2, 3, 6, 8, 11, 14], 8);

    bq = new BooleanQuery();
    bq.add_query(tq2, occur: 'must');
    bq.add_query(tq3, occur: 'must_not');
    check_hits(bq, [2, 3, 6, 11, 14]);

    bq = new BooleanQuery();
    bq.add_query(tq2, occur: 'must_not');
    check_hits(bq, [0, 1, 4, 5, 7, 9, 10, 12, 13, 15, 16, 17]);

    bq = new BooleanQuery();
    bq.add_query(tq2, occur: 'should');
    bq.add_query(tq3, occur: 'should');
    check_hits(bq, [1, 2, 3, 4, 6, 8, 11, 14]);

    bq = new BooleanQuery();
    var bc1 = new BooleanClause(tq2, occur: 'should');
    var bc2 = new BooleanClause(tq3, occur: 'should');
    bq.add_query(bc1);
    bq.add_query(bc2);
    check_hits(bq, [1, 2, 3, 4, 6, 8, 11, 14]);
  }

  test_phrase_query() {
    var pq = new PhraseQuery('field');
    expect("\"\"", equals(pq.to_s('field')));
    expect("field:\"\"", equals(pq.to_s));

    pq..add_term("quick")..add_term("brown")..add_term("fox");
    check_hits(pq, [1]);

    pq = new PhraseQuery('field', slop: 1);
    pq..add_term("quick");
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
    var rq = new RangeQuery('date', lower: "20051006", upper: "20051010");
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
    var rq = new TypedRangeQuery('number', geq: "-1.0", leq: 1.0);
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
    var pq = new PrefixQuery('category', "cat1");
    check_hits(pq, [0, 1, 2, 3, 4, 13, 14, 15, 16, 17]);

    pq = new PrefixQuery('category', "cat1/sub2");
    check_hits(pq, [3, 4, 13, 15]);
  }

  test_wildcard_query() {
    var wq = new WildcardQuery('category', "cat1*");
    check_hits(wq, [0, 1, 2, 3, 4, 13, 14, 15, 16, 17]);

    wq = new WildcardQuery('category', "cat1*/su??ub2");
    check_hits(wq, [4, 16]);

    wq = new WildcardQuery('category', "*/sub2*");
    check_hits(wq, [3, 4, 13, 15]);
  }

  test_multi_phrase_query() {
    var mpq = new PhraseQuery('field');
    mpq.add_term(["quick", "fast"]);
    mpq.add_term(["brown", "red", "hairy"]);
    mpq.add_term("fox");
    check_hits(mpq, [1, 8, 11, 14]);

    mpq.slop = 4;
    check_hits(mpq, [1, 8, 11, 14, 16, 17]);
  }

  test_highlighter() {
    var dir = new RAMDirectory();
    var iw = new IndexWriter(dir: dir, analyzer: new WhiteSpaceAnalyzer());
    var long_text = "big " + "between " * 2000 + 'house';
    [
      {
        'field': "the words we are searching for are one and two also " +
            "sometimes looking for them as a phrase like this; one " +
            "two lets see how it goes"
      },
      {'long': 'before ' * 1000 + long_text + ' after' * 1000},
      {'dates': '20070505 20071230 20060920 20081111'},
    ].forEach((doc) => iw.add_document(doc));
    iw.close();

    var searcher = new Searcher(dir);

    var q = new TermQuery('field', "one");
    var highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 1);
    expect(1, equals(highlights.length));
    expect("...are <b>one</b>...", equals(highlights[0]));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 2);
    expect(2, equals(highlights.length));
    expect("...are <b>one</b>...", equals(highlights[0]));
    expect("...this; <b>one</b>...", equals(highlights[1]));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 3);
    expect(3, equals(highlights.length));
    expect("the words...", equals(highlights[0]));
    expect("...are <b>one</b>...", equals(highlights[1]));
    expect("...this; <b>one</b>...", equals(highlights[2]));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 4);
    expect(3, equals(highlights.length));
    expect("the words we are...", equals(highlights[0]));
    expect("...are <b>one</b>...", equals(highlights[1]));
    expect("...this; <b>one</b>...", equals(highlights[2]));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 5);
    expect(2, equals(highlights.length));
    expect("the words we are searching for are <b>one</b>...",
        equals(highlights[0]));
    expect("...this; <b>one</b>...", equals(highlights[1]));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 20);
    expect(1, equals(highlights.length));
    expect("the words we are searching for are <b>one</b> and two also " +
        "sometimes looking for them as a phrase like this; <b>one</b> " +
        "two lets see how it goes", equals(highlights[0]));

    highlights = searcher.highlight(q, 0, 'field',
        excerpt_length: 1000, num_excerpts: 1);
    expect(1, equals(highlights.length));
    expect("the words we are searching for are <b>one</b> and two also " +
        "sometimes looking for them as a phrase like this; <b>one</b> " +
        "two lets see how it goes", equals(highlights[0]));

    q = new BooleanQuery(coord_disable: false);
    q.add_query(new TermQuery('field', "one"));
    q.add_query(new TermQuery('field', "two"));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 15, num_excerpts: 2);
    expect(2, equals(highlights.length));
    expect("...<b>one</b> and <b>two</b>...", equals(highlights[0]));
    expect("...this; <b>one</b> <b>two</b>...", equals(highlights[1]));

    q.add_query(new PhraseQuery('field')..add_term("one")..add_term("two"));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 15, num_excerpts: 2);
    expect(2, equals(highlights.length));
    expect("...<b>one</b> and <b>two</b>...", equals(highlights[0]));
    expect("...this; <b>one two</b>...", equals(highlights[1]));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 15, num_excerpts: 1);
    expect(1, equals(highlights.length));
    // should have a higher priority since it the merger of three matches
    expect("...this; <b>one two</b>...", equals(highlights[0]));

    highlights = searcher.highlight(q, 0, 'not_a_field',
        excerpt_length: 15, num_excerpts: 1);
    expect(highlights, isNull);

    q = new TermQuery('wrong_field', "one");
    highlights = searcher.highlight(q, 0, 'wrong_field',
        excerpt_length: 15, num_excerpts: 1);
    expect(highlights, isNull);

    q = new BooleanQuery(coord_disable: false);
    q.add_query(new PhraseQuery('field')..add_term("the")..add_term("words"));
    q.add_query(new PhraseQuery('field')
      ..add_term("for")
      ..add_term("are")
      ..add_term("one")
      ..add_term("and")
      ..add_term("two"));
    q.add_query(new TermQuery('field', "words"));
    q.add_query(new TermQuery('field', "one"));
    q.add_query(new TermQuery('field', "two"));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 1);
    expect(1, equals(highlights.length));
    expect("<b>the words</b>...", equals(highlights[0]));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 2);
    expect(2, equals(highlights.length));
    expect("<b>the words</b>...", equals(highlights[0]));
    expect("...<b>one</b> <b>two</b>...", equals(highlights[1]));

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
    ].forEach((row) {
      var query = row[0],
          expected = row[1];
      expect([expected], equals(searcher.highlight(query, 2, 'dates')));
    });

    //q = new PhraseQuery('long')..add('big')..add('house');
    //q.slop = 4000
    //highlights = searcher.highlight(q, 1, :long,
    //                                excerpt_length: 400,
    //                                num_excerpts: 2);
    //expect(1, highlights.size);
    //print(highlights[0]);
    //expect("<b>the words</b>...", equals(highlights[0]));
    //expect("...<b>one</b> <b>two</b>...", equals(highlights[1]));
  }

  test_highlighter_with_standard_analyzer() {
    var dir = new RAMDirectory();
    var iw = new IndexWriter(dir: dir, analyzer: new StandardAnalyzer());
    [{'field': "field has a url http://ferret.davebalmain.com/trac/ end"},]
        .forEach((doc) => iw.add_document(doc));
    iw.close();

    var searcher = new Searcher(dir);

    var q = new TermQuery('field', "ferret.davebalmain.com/trac");
    var highlights = searcher.highlight(q, 0, 'field',
        excerpt_length: 1000, num_excerpts: 1);
    expect(1, equals(highlights.length));
    expect("field has a url <b>http://ferret.davebalmain.com/trac/</b> end",
        equals(highlights[0]));
  }
}
