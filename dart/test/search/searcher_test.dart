library ferret.test.search.searcher;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

abstract class SearcherTests {
//  include Ferret::Search
  Ferret ferret;
  Searcher _searcher;

  check_hits(query, expected, [b]);

  test_term_query() {
    var tq = new TermQuery(ferret, 'field', "word2");
    tq.boost = 100;
    check_hits(tq, [1, 4, 8]);
    //puts _searcher.explain(tq, 1);
    //puts _searcher.explain(tq, 4);
    //puts _searcher.explain(tq, 8);

    tq = new TermQuery(ferret, 'field', "2342");
    check_hits(tq, []);

    tq = new TermQuery(ferret, 'field', "");
    check_hits(tq, []);

    tq = new TermQuery(ferret, 'field', "word1");
    var top_docs = _searcher.search(tq);
    expect(_searcher.max_doc, equals(top_docs.total_hits));
    expect(10, equals(top_docs.hits.length));
    top_docs = _searcher.search(tq, limit: 20);
    expect(_searcher.max_doc, equals(top_docs.hits.length));

    expect(tq.terms(_searcher), equals([newTerm('field', "word1")]));
  }

  check_docs(Query query, Map options, [List expected = const []]) {
    var top_docs = _searcher.search(query, options);
    var docs = top_docs.hits;
    expect(expected.length, equals(docs.length));
    range(docs.length).forEach((i) {
      expect(docs[i].doc, equals(expected[i]));
    });
    if (options['limit'] == 'all' && options['offset'] == null) {
      expect(expected.sort, equals(_searcher.scan(query)));
    }
  }

  test_offset() {
    var tq = new TermQuery(ferret, 'field', "word1");
    tq.boost = 100;
    var top_docs = _searcher.search(tq, limit: 100);
    var expected = [];
    top_docs.hits.forEach((sd) {
      expected.add(sd.doc);
    });

    expect(() => _searcher.search(tq, offset: -1), throwsArgumentError);
    expect(() => _searcher.search(tq, limit: 0), throwsArgumentError);
    expect(() => _searcher.search(tq, limit: -1), throwsArgumentError);

//    check_docs(tq, limit: 8, offset: 0, expected[0,8]);
//    check_docs(tq, limit: 3, offset: 1, expected[1,3]);
//    check_docs(tq, limit: 6, offset: 2, expected[2,6]);
//    check_docs(tq, limit: 2, offset: expected.length, []);
//    check_docs(tq, limit: 2, offset: expected.length + 100, []);
//    check_docs(tq, limit: 'all', expected);
//    check_docs(tq, limit: 'all', offset: 2, expected[2..-1]);
  }

  test_multi_term_query() {
    var mtq = new MultiTermQuery(ferret, 'field', max_terms: 4, min_score: 0.5);
    check_hits(mtq, []);
    expect('""', equals(mtq.to_s('field')));
    expect('field:""', equals(mtq.to_s));

    [
      ["brown", 1.0, '"brown"'],
      ["fox", 0.1, '"brown"'],
      ["fox", 0.6, '"fox^0.6|brown"'],
      ["fast", 50.0, '"fox^0.6|brown|fast^50.0"']
    ].forEach((row) {
      var term = row[0], boost = row[1], str = row[2];
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
    expect(terms.index(newTerm('field', "brown")), isTrue);
    expect(terms.index(newTerm('field', "word1")), isTrue);
    expect(terms.index(newTerm('field', "word2")), isTrue);
    expect(terms.index(newTerm('field', "fast")), isTrue);
  }

  test_boolean_query() {
    var bq = new BooleanQuery(ferret);
    var tq1 = new TermQuery(ferret, 'field', "word1");
    var tq2 = new TermQuery(ferret, 'field', "word3");
    bq.add_query(tq1, occur: BCType.MUST);
    bq.add_query(tq2, occur: BCType.MUST);
    check_hits(bq, [2, 3, 6, 8, 11, 14], 14);

    var tq3 = new TermQuery(ferret, 'field', "word2");
    bq.add_query(tq3, occur: BCType.SHOULD);
    check_hits(bq, [2, 3, 6, 8, 11, 14], 8);

    bq = new BooleanQuery(ferret);
    bq.add_query(tq2, occur: BCType.MUST);
    bq.add_query(tq3, occur: BCType.MUST_NOT);
    check_hits(bq, [2, 3, 6, 11, 14]);

    bq = new BooleanQuery(ferret);
    bq.add_query(tq2, occur: BCType.MUST_NOT);
    check_hits(bq, [0, 1, 4, 5, 7, 9, 10, 12, 13, 15, 16, 17]);

    bq = new BooleanQuery(ferret);
    bq.add_query(tq2, occur: BCType.SHOULD);
    bq.add_query(tq3, occur: BCType.SHOULD);
    check_hits(bq, [1, 2, 3, 4, 6, 8, 11, 14]);

    bq = new BooleanQuery(ferret);
    var bc1 = new BooleanClause(ferret, tq2, occur: BCType.SHOULD);
    var bc2 = new BooleanClause(ferret, tq3, occur: BCType.SHOULD);
    bq.add_query(bc1);
    bq.add_query(bc2);
    check_hits(bq, [1, 2, 3, 4, 6, 8, 11, 14]);
  }

  test_phrase_query() {
    var pq = new PhraseQuery(ferret, 'field');
    expect("\"\"", equals(pq.to_s('field')));
    expect("field:\"\"", equals(pq.to_s));

    pq..add_term("quick")..add_term("brown")..add_term("fox");
    check_hits(pq, [1]);

    pq = new PhraseQuery(ferret, 'field', slop: 1);
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
    var rq =
        new RangeQuery(ferret, 'date', lower: "20051006", upper: "20051010");
    check_hits(rq, [6, 7, 8, 9, 10]);

    rq = new RangeQuery(ferret, 'date', geq: "20051006", leq: "20051010");
    check_hits(rq, [6, 7, 8, 9, 10]);

    rq = new RangeQuery(ferret, 'date',
        lower: "20051006", upper: "20051010", include_lower: false);
    check_hits(rq, [7, 8, 9, 10]);

    rq = new RangeQuery(ferret, 'date', ge: "20051006", leq: "20051010");
    check_hits(rq, [7, 8, 9, 10]);

    rq = new RangeQuery(ferret, 'date',
        lower: "20051006", upper: "20051010", include_upper: false);
    check_hits(rq, [6, 7, 8, 9]);

    rq = new RangeQuery(ferret, 'date', geq: "20051006", le: "20051010");
    check_hits(rq, [6, 7, 8, 9]);

    rq = new RangeQuery(ferret, 'date',
        lower: "20051006",
        upper: "20051010",
        include_lower: false,
        include_upper: false);
    check_hits(rq, [7, 8, 9]);

    rq = new RangeQuery(ferret, 'date', ge: "20051006", le: "20051010");
    check_hits(rq, [7, 8, 9]);

    rq = new RangeQuery(ferret, 'date', upper: "20051003");
    check_hits(rq, [0, 1, 2, 3]);

    rq = new RangeQuery(ferret, 'date', leq: "20051003");
    check_hits(rq, [0, 1, 2, 3]);

    rq =
        new RangeQuery(ferret, 'date', upper: "20051003", include_upper: false);
    check_hits(rq, [0, 1, 2]);

    rq = new RangeQuery(ferret, 'date', le: "20051003");
    check_hits(rq, [0, 1, 2]);

    rq = new RangeQuery(ferret, 'date', lower: "20051014");
    check_hits(rq, [14, 15, 16, 17]);

    rq = new RangeQuery(ferret, 'date', geq: "20051014");
    check_hits(rq, [14, 15, 16, 17]);

    rq =
        new RangeQuery(ferret, 'date', lower: "20051014", include_lower: false);
    check_hits(rq, [15, 16, 17]);

    rq = new RangeQuery(ferret, 'date', ge: "20051014");
    check_hits(rq, [15, 16, 17]);
  }

  test_typed_range_query() {
    var rq = new TypedRangeQuery(ferret, 'number', geq: "-1.0", leq: 1.0);
    check_hits(rq, [0, 1, 4, 10, 15, 17]);

    rq = new TypedRangeQuery(ferret, 'number', ge: "-1.0", le: 1.0);
    check_hits(rq, [0, 1, 4, 15]);

    if (ENV['FERRET_DEV']) {
      // text hexadecimal
      rq = new TypedRangeQuery(ferret, 'number', ge: "1.0", leq: "0xa");
      check_hits(rq, [6, 7, 9, 12]);
    }

    // test single bound
    rq = new TypedRangeQuery(ferret, 'number', leq: "0.0");
    check_hits(rq, [5, 11, 15, 16, 17]);

    // test single bound
    rq = new TypedRangeQuery(ferret, 'number', ge: "0.0");
    check_hits(rq, [0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 12, 13, 14]);

    // below range - no results
    rq = new TypedRangeQuery(ferret, 'number', ge: "10051006", le: "10051010");
    check_hits(rq, []);

    // above range - no results
    rq =
        new TypedRangeQuery(ferret, 'number', ge: "-12518421", le: "-12518420");
    check_hits(rq, []);
  }

  test_prefix_query() {
    var pq = new PrefixQuery(ferret, 'category', "cat1");
    check_hits(pq, [0, 1, 2, 3, 4, 13, 14, 15, 16, 17]);

    pq = new PrefixQuery(ferret, 'category', "cat1/sub2");
    check_hits(pq, [3, 4, 13, 15]);
  }

  test_wildcard_query() {
    var wq = new WildcardQuery(ferret, 'category', "cat1*");
    check_hits(wq, [0, 1, 2, 3, 4, 13, 14, 15, 16, 17]);

    wq = new WildcardQuery(ferret, 'category', "cat1*/su??ub2");
    check_hits(wq, [4, 16]);

    wq = new WildcardQuery(ferret, 'category', "*/sub2*");
    check_hits(wq, [3, 4, 13, 15]);
  }

  test_multi_phrase_query() {
    var mpq = new PhraseQuery(ferret, 'field');
    mpq.add_term(["quick", "fast"]);
    mpq.add_term(["brown", "red", "hairy"]);
    mpq.add_term("fox");
    check_hits(mpq, [1, 8, 11, 14]);

    mpq.slop = 4;
    check_hits(mpq, [1, 8, 11, 14, 16, 17]);
  }

  test_highlighter() {
    var dir = new RAMDirectory(ferret);
    var iw = new IndexWriter(ferret,
        dir: dir, analyzer: new WhiteSpaceAnalyzer(ferret));
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

    var searcher = new Searcher.store(ferret, dir);

    var q = new TermQuery(ferret, 'field', "one");
    var highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 1);
    expect(highlights.length, equals(1));
    expect(highlights[0], equals("...are <b>one</b>..."));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 2);
    expect(highlights.length, equals(2));
    expect(highlights[0], equals("...are <b>one</b>..."));
    expect(highlights[1], equals("...this; <b>one</b>..."));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 3);
    expect(highlights.length, equals(3));
    expect(highlights[0], equals("the words..."));
    expect(highlights[1], equals("...are <b>one</b>..."));
    expect(highlights[2], equals("...this; <b>one</b>..."));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 4);
    expect(highlights.length, equals(3));
    expect(highlights[0], equals("the words we are..."));
    expect(highlights[1], equals("...are <b>one</b>..."));
    expect(highlights[2], equals("...this; <b>one</b>..."));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 5);
    expect(highlights.length, equals(2));
    expect(highlights[0],
        equals("the words we are searching for are <b>one</b>..."));
    expect(highlights[1], equals("...this; <b>one</b>..."));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 20);
    expect(highlights.length, equals(1));
    expect(
        highlights[0],
        equals("the words we are searching for are <b>one</b> and two also " +
            "sometimes looking for them as a phrase like this; <b>one</b> " +
            "two lets see how it goes"));

    highlights = searcher.highlight(q, 0, 'field',
        excerpt_length: 1000, num_excerpts: 1);
    expect(highlights.length, equals(1));
    expect(
        highlights[0],
        equals("the words we are searching for are <b>one</b> and two also " +
            "sometimes looking for them as a phrase like this; <b>one</b> " +
            "two lets see how it goes"));

    q = new BooleanQuery(ferret, coord_disable: false);
    q.add_query(new TermQuery(ferret, 'field', "one"));
    q.add_query(new TermQuery(ferret, 'field', "two"));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 15, num_excerpts: 2);
    expect(highlights.length, equals(2));
    expect(highlights[0], equals("...<b>one</b> and <b>two</b>..."));
    expect(highlights[1], equals("...this; <b>one</b> <b>two</b>..."));

    q.add_query(
        new PhraseQuery(ferret, 'field')..add_term("one")..add_term("two"));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 15, num_excerpts: 2);
    expect(highlights.length, equals(2));
    expect(highlights[0], equals("...<b>one</b> and <b>two</b>..."));
    expect(highlights[1], equals("...this; <b>one two</b>..."));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 15, num_excerpts: 1);
    expect(highlights.length, equals(1));
    // should have a higher priority since it the merger of three matches
    expect(highlights[0], equals("...this; <b>one two</b>..."));

    highlights = searcher.highlight(q, 0, 'not_a_field',
        excerpt_length: 15, num_excerpts: 1);
    expect(highlights, isNull);

    q = new TermQuery(ferret, 'wrong_field', "one");
    highlights = searcher.highlight(q, 0, 'wrong_field',
        excerpt_length: 15, num_excerpts: 1);
    expect(highlights, isNull);

    q = new BooleanQuery(ferret, coord_disable: false);
    q.add_query(
        new PhraseQuery(ferret, 'field')..add_term("the")..add_term("words"));
    q.add_query(new PhraseQuery(ferret, 'field')
      ..add_term("for")
      ..add_term("are")
      ..add_term("one")
      ..add_term("and")
      ..add_term("two"));
    q.add_query(new TermQuery(ferret, 'field', "words"));
    q.add_query(new TermQuery(ferret, 'field', "one"));
    q.add_query(new TermQuery(ferret, 'field', "two"));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 1);
    expect(highlights.length, equals(1));
    expect(highlights[0], equals("<b>the words</b>..."));

    highlights =
        searcher.highlight(q, 0, 'field', excerpt_length: 10, num_excerpts: 2);
    expect(highlights.length, equals(2));
    expect(highlights[0], equals("<b>the words</b>..."));
    expect(highlights[1], equals("...<b>one</b> <b>two</b>..."));

    [
      [
        new RangeQuery(ferret, 'dates', geq: '20081111'),
        '20070505 20071230 20060920 <b>20081111</b>'
      ],
      [
        new RangeQuery(ferret, 'dates', geq: '20070101'),
        '<b>20070505</b> <b>20071230</b> 20060920 <b>20081111</b>'
      ],
      [
        new PrefixQuery(ferret, 'dates', '2007'),
        '<b>20070505</b> <b>20071230</b> 20060920 20081111'
      ],
    ].forEach((row) {
      var query = row[0], expected = row[1];
      expect(searcher.highlight(query, 2, 'dates'), equals([expected]));
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
    var dir = new RAMDirectory(ferret);
    var iw = new IndexWriter(ferret,
        dir: dir, analyzer: new StandardAnalyzer(ferret));
    [
      {'field': "field has a url http://ferret.davebalmain.com/trac/ end"},
    ].forEach((doc) => iw.add_document(doc));
    iw.close();

    var searcher = new Searcher.store(ferret, dir);

    var q = new TermQuery(ferret, 'field', "ferret.davebalmain.com/trac");
    var highlights = searcher.highlight(q, 0, 'field',
        excerpt_length: 1000, num_excerpts: 1);
    expect(highlights.length, equals(1));
    expect(
        highlights[0],
        equals(
            "field has a url <b>http://ferret.davebalmain.com/trac/</b> end"));
  }
}
