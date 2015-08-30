library ferret.test.search.span;

class SpansBasicTest {
  //< Test::Unit::TestCase

  def setup() {
    _dir = new RAMDirectory();
    iw = new IndexWriter(
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
    ].each((line) => iw.add({'field': line}));

    iw.close();

    _searcher = new Searcher(_dir);
  }

  teardown() {
    _searcher.close();
    _dir.close();
  }

  number_split(i) {
    if (i < 10) {
      return "<${i}>";
    } else if (i < 100) {
      return "<${((i/10)*10)}> <${i%10}>";
    } else {
      return "<${((i/100)*100)}> <${(((i%100)/10)*10)}> <${i%10}>";
    }
  }

  check_hits(query, expected, [test_explain = false, top = null]) {
    top_docs = _searcher.search(query, {'limit': expected.length + 1});
    assert_equal(expected.length, top_docs.hits.size);
    if (top) {
      assert_equal(top, top_docs.hits[0].doc);
    }
    assert_equal(expected.length, top_docs.total_hits);
    top_docs.hits.each((hit) {
      expect(expected.include(hit.doc), isTrue,
          "${hit.doc} was found unexpectedly");
      if (test_explain) {
        expect(hit.score.approx_eql(_searcher.explain(query, hit.doc).score),
            isTrue, "Scores(${hit.score} != " +
                "${_searcher.explain(query, hit.doc).score})");
      }
    });
  }

  test_span_term_query() {
    tq = new SpanTermQuery('field', "nine");
    check_hits(tq, [7, 23], true);
    tq = new SpanTermQuery('field', "eight");
    check_hits(tq, [6, 7, 8, 22, 23, 24]);
  }

  test_span_multi_term_query() {
    tq = new SpanMultiTermQuery('field', ["eight", "nine"]);
    check_hits(tq, [6, 7, 8, 22, 23, 24], true);
    tq = new SpanMultiTermQuery('field', ["flip", "flop", "toot", "nine"]);
    check_hits(tq, [2, 7, 12, 17, 23]);
  }

  test_span_prefix_query() {
    tq = new SpanPrefixQuery('field', "fl");
    check_hits(tq, [2, 12], true);
  }

  test_span_near_query() {
    tq1 = new SpanTermQuery('field', "start");
    tq2 = new SpanTermQuery('field', "finish");
    q = new SpanNearQuery(clauses: [tq1, tq2], in_order: true);
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
    q = new SpanNearQuery(
        clauses: [
      new SpanPrefixQuery('field', 'se'),
      new SpanPrefixQuery('field', 'fl')
    ],
        slop: 0);
    check_hits(q, [2, 12], true);
  }

  test_span_not_query() {
    tq1 = new SpanTermQuery('field', "start");
    tq2 = new SpanTermQuery('field', "finish");
    tq3 = new SpanTermQuery('field', "two");
    tq4 = new SpanTermQuery('field', "five");
    nearq1 = new SpanNearQuery(clauses: [tq1, tq2], slop: 4, in_order: true);
    nearq2 = new SpanNearQuery(clauses: [tq3, tq4], slop: 4, in_order: true);
    q = new SpanNotQuery(nearq1, nearq2);
    check_hits(q, [0, 1, 13, 14], true);
    nearq1 = new SpanNearQuery(clauses: [tq1, tq2], slop: 4);
    q = new SpanNotQuery(nearq1, nearq2);
    check_hits(q, [0, 1, 13, 14, 16, 17, 29, 30]);
    nearq1 = new SpanNearQuery(clauses: [tq1, tq3], slop: 4, in_order: true);
    nearq2 = new SpanNearQuery(clauses: [tq2, tq4], slop: 8);
    q = new SpanNotQuery(nearq1, nearq2);
    check_hits(q, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 15]);
  }

  test_span_first_query() {
    finish_first = [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30];
    tq = new SpanTermQuery('field', "finish");
    q = new SpanFirstQuery(tq, 1);
    check_hits(q, finish_first, true);
    q = new SpanFirstQuery(tq, 5);
    check_hits(q, [0, 1, 2, 3, 11, 12, 13, 14] + finish_first, false);
  }

  def test_span_or_query_query() {
    tq1 = new SpanTermQuery('field', "start");
    tq2 = new SpanTermQuery('field', "finish");
    tq3 = new SpanTermQuery('field', "five");
    nearq1 = new SpanNearQuery(clauses: [tq1, tq2], slop: 1, in_order: true);
    nearq2 = new SpanNearQuery(clauses: [tq2, tq3], slop: 0);
    q = new SpanOrQuery([nearq1, nearq2]);
    check_hits(q, [0, 1, 4, 5, 9, 10, 13, 14], false);
    nearq1 = new SpanNearQuery(clauses: [tq1, tq2], slop: 0);
    nearq2 = new SpanNearQuery(clauses: [tq2, tq3], slop: 1);
    q = new SpanOrQuery([nearq1, nearq2]);
    check_hits(q, [0, 3, 4, 5, 6, 8, 9, 10, 11, 14, 16, 30], false);
  }

  test_span_prefix_query_max_terms() {
    _dir = new RAMDirectory();
    iw = new IndexWriter(dir: _dir, analyzer: new WhiteSpaceAnalyzer());
    repeat(2000).times((i) => iw.add({'field': "prefix${i} term${i}"}));
    iw.close();
    _searcher = new Searcher(_dir);

    pq = new SpanPrefixQuery('field', "prefix");
    tq = new SpanTermQuery('field', "term1500");
    q = new SpanNearQuery(clauses: [pq, tq], in_order: true);
    check_hits(q, [], false);
    pq = new SpanPrefixQuery('field', "prefix", 2000);
    q = new SpanNearQuery(clauses: [pq, tq], in_order: true);
    check_hits(q, [1500], false);
  }
}