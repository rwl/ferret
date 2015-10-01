library ferret.test.search.span;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

void spansBasicTest() {
  Directory _dir;
  Searcher _searcher;

  setUp(() {
    _dir = new RAMDirectory();
    var iw = new IndexWriter(
        dir: _dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    [
      "start finish one two three four five six seven",
      "start one finish two three four five six seven",
      "start one two finish three four five six seven flip",
      "start one two three finish four five six seven",
      "start one two three four finish five six seven",
      "start one two three four five finish six seven",
      "start one two three four five six finish seven eight",
      "start one two three four five six seven finish eight nine",
      "start one two three four five six finish seven eight",
      "start one two three four five finish six seven",
      "start one two three four finish five six seven",
      "start one two three finish four five six seven",
      "start one two finish three four five six seven flop",
      "start one finish two three four five six seven",
      "start finish one two three four five six seven",
      "start start  one two three four five six seven",
      "finish start one two three four five six seven",
      "finish one start two three four five six seven toot",
      "finish one two start three four five six seven",
      "finish one two three start four five six seven",
      "finish one two three four start five six seven",
      "finish one two three four five start six seven",
      "finish one two three four five six start seven eight",
      "finish one two three four five six seven start eight nine",
      "finish one two three four five six start seven eight",
      "finish one two three four five start six seven",
      "finish one two three four start five six seven",
      "finish one two three start four five six seven",
      "finish one two start three four five six seven",
      "finish one start two three four five six seven",
      "finish start one two three four five six seven"
    ].forEach((line) => iw.add_document({'field': line}));

    iw.close();

    _searcher = new Searcher.store(_dir);
  });

  tearDown(() {
    _searcher.close();
    _dir.close();
  });

  String number_split(num i) {
    if (i < 10) {
      return "<${i}>";
    } else if (i < 100) {
      return "<${((i/10)*10)}> <${i%10}>";
    } else {
      return "<${((i/100)*100)}> <${(((i%100)/10)*10)}> <${i%10}>";
    }
  }

  check_hits(Query query, List expected, [bool test_explain = false, int top]) {
    var top_docs = _searcher.search(query, limit: expected.length + 1);
    expect(top_docs.hits.length, equals(expected.length));
    if (top != null) {
      expect(top_docs.hits[0].doc, equals(top));
    }
    expect(top_docs.total_hits, equals(expected.length));
    top_docs.hits.forEach((hit) {
      expect(expected.contains(hit.doc), isTrue,
          reason: "${hit.doc} was found unexpectedly");
      if (test_explain) {
        expect(
            _searcher.explain(query, hit.doc).score, closeTo(hit.score, 0.0001),
            reason: "Scores(${hit.score} != " +
                "${_searcher.explain(query, hit.doc).score})");
      }
    });
  }

  test('span_term_query', () {
    var tq = new SpanTermQuery('field', "nine");
    check_hits(tq, [7, 23], true);
    tq = new SpanTermQuery('field', "eight");
    check_hits(tq, [6, 7, 8, 22, 23, 24]);
  });

  test('span_multi_term_query', () {
    var tq = new SpanMultiTermQuery('field', ["eight", "nine"]);
    check_hits(tq, [6, 7, 8, 22, 23, 24], true);
    tq = new SpanMultiTermQuery('field', ["flip", "flop", "toot", "nine"]);
    check_hits(tq, [2, 7, 12, 17, 23]);
  });

  test('span_prefix_query', () {
    var tq = new SpanPrefixQuery('field', "fl");
    check_hits(tq, [2, 12], true);
  });

  test('span_near_query', () {
    var tq1 = new SpanTermQuery('field', "start");
    var tq2 = new SpanTermQuery('field', "finish");
    var q = new SpanNearQuery(clauses: [tq1, tq2], in_order: true);
    check_hits(q, [0, 14], true);
    q = new SpanNearQuery();
    q.add(tq1);
    q.add(tq2);
    check_hits(q, [0, 14, 16, 30], true);
    q = new SpanNearQuery(clauses: [tq1, tq2], slop: 1, in_order: true);
    check_hits(q, [0, 1, 13, 14]);
    q = new SpanNearQuery(clauses: [tq1, tq2], slop: 1);
    check_hits(q, [0, 1, 13, 14, 16, 17, 29, 30]);
    q = new SpanNearQuery(clauses: [tq1, tq2], slop: 4, in_order: true);
    check_hits(q, [0, 1, 2, 3, 4, 10, 11, 12, 13, 14]);
    q = new SpanNearQuery(clauses: [tq1, tq2], slop: 4);
    check_hits(q, [
      0,
      1,
      2,
      3,
      4,
      10,
      11,
      12,
      13,
      14,
      16,
      17,
      18,
      19,
      20,
      26,
      27,
      28,
      29,
      30
    ]);
    q = new SpanNearQuery(clauses: [
      new SpanPrefixQuery('field', 'se'),
      new SpanPrefixQuery('field', 'fl')
    ], slop: 0);
    check_hits(q, [2, 12], true);
  });

  test('span_not_query', () {
    var tq1 = new SpanTermQuery('field', "start");
    var tq2 = new SpanTermQuery('field', "finish");
    var tq3 = new SpanTermQuery('field', "two");
    var tq4 = new SpanTermQuery('field', "five");
    var nearq1 =
        new SpanNearQuery(clauses: [tq1, tq2], slop: 4, in_order: true);
    var nearq2 =
        new SpanNearQuery(clauses: [tq3, tq4], slop: 4, in_order: true);
    var q = new SpanNotQuery(nearq1, nearq2);
    check_hits(q, [0, 1, 13, 14], true);
    nearq1 = new SpanNearQuery(clauses: [tq1, tq2], slop: 4);
    q = new SpanNotQuery(nearq1, nearq2);
    check_hits(q, [0, 1, 13, 14, 16, 17, 29, 30]);
    nearq1 = new SpanNearQuery(clauses: [tq1, tq3], slop: 4, in_order: true);
    nearq2 = new SpanNearQuery(clauses: [tq2, tq4], slop: 8);
    q = new SpanNotQuery(nearq1, nearq2);
    check_hits(q, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15]);
  });

  test('span_first_query', () {
    var finish_first = [
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30
    ];
    var tq = new SpanTermQuery('field', "finish");
    var q = new SpanFirstQuery(tq, 1);
    check_hits(q, finish_first, true);
    q = new SpanFirstQuery(tq, 5);
    check_hits(q, [0, 1, 2, 3, 11, 12, 13, 14]..addAll(finish_first), false);
  });

  test('span_or_query_query', () {
    var tq1 = new SpanTermQuery('field', "start");
    var tq2 = new SpanTermQuery('field', "finish");
    var tq3 = new SpanTermQuery('field', "five");
    var nearq1 =
        new SpanNearQuery(clauses: [tq1, tq2], slop: 1, in_order: true);
    var nearq2 = new SpanNearQuery(clauses: [tq2, tq3], slop: 0);
    var q = new SpanOrQuery([nearq1, nearq2]);
    check_hits(q, [0, 1, 4, 5, 9, 10, 13, 14], false);
    nearq1 = new SpanNearQuery(clauses: [tq1, tq2], slop: 0);
    nearq2 = new SpanNearQuery(clauses: [tq2, tq3], slop: 1);
    q = new SpanOrQuery([nearq1, nearq2]);
    check_hits(q, [0, 3, 4, 5, 6, 8, 9, 10, 11, 14, 16, 30], false);
  });

  test('span_prefix_query_max_terms', () {
    _dir = new RAMDirectory();
    var iw = new IndexWriter(dir: _dir, analyzer: new WhiteSpaceAnalyzer());
    range(2000)
        .forEach((i) => iw.add_document({'field': "prefix${i} term${i}"}));
    iw.close();
    _searcher = new Searcher.store(_dir);

    var pq = new SpanPrefixQuery('field', "prefix");
    var tq = new SpanTermQuery('field', "term1500");
    var q = new SpanNearQuery(clauses: [pq, tq], in_order: true);
    check_hits(q, [], false);
    pq = new SpanPrefixQuery('field', "prefix", max_terms: 2000);
    q = new SpanNearQuery(clauses: [pq, tq], in_order: true);
    check_hits(q, [1500], false);
  });
}
