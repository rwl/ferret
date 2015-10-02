library ferret.test.search.filter;

import 'dart:math' show pow;
import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

void filterTest() {
  Directory _dir;

  setUp(() {
    _dir = new RAMDirectory();
    var iw = new IndexWriter(
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
    ].forEach((doc) => iw.add_document(doc));
    iw.close();
  });

  tearDown(() {
    _dir.close();
  });

  do_test_top_docs(
      Searcher searcher, Query query, List expected, Filter filter) {
    var top_docs = searcher.search(query, filter: filter);
    print(top_docs);
    expect(top_docs.hits.length, equals(expected.length));
    range(top_docs.total_hits).forEach((i) {
      expect(top_docs.hits[i].doc, equals(expected[i]));
    });
  }

  test('range_filter', () {
    var searcher = new Searcher.store(_dir);
    var q = new MatchAllQuery();
    var rf = new RangeFilter('int', geq: "2", leq: "6");
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

    var bits = rf.bits(searcher.reader);
    expect(bits[0], isTrue);
    expect(bits[1], isTrue);
    expect(bits[2], isFalse);
    expect(bits[3], isFalse);
    expect(bits[4], isFalse);
  });

  test('range_filter_errors', () {
    expect(() {
      new RangeFilter('f', ge: "b", le: "a");
    }, throwsArgumentError);
    expect(() {
      new RangeFilter('f', include_lower: true);
    }, throwsArgumentError);
    expect(() {
      new RangeFilter('f', include_upper: true);
    }, throwsArgumentError);
  });

  test('query_filter', () {
    var searcher = new Searcher.store(_dir);
    var q = new MatchAllQuery();
    var qf = new QueryFilter(new TermQuery('switch', "on"));
    do_test_top_docs(searcher, q, [0, 2, 4, 6, 8], qf);
    // test again to test caching doesn't break it
    do_test_top_docs(searcher, q, [0, 2, 4, 6, 8], qf);
    qf = new QueryFilter(new TermQuery('switch', "off"));
    do_test_top_docs(searcher, q, [1, 3, 5, 7, 9], qf);

    var bits = qf.bits(searcher.reader);
    expect(bits[1], isTrue);
    expect(bits[3], isTrue);
    expect(bits[5], isTrue);
    expect(bits[7], isTrue);
    expect(bits[9], isTrue);
    expect(bits[0], isFalse);
    expect(bits[2], isFalse);
    expect(bits[4], isFalse);
    expect(bits[6], isFalse);
    expect(bits[8], isFalse);
  });

  test('filtered_query', () {
    var searcher = new Searcher.store(_dir);
    var q = new MatchAllQuery();
    var rf = new RangeFilter('int', geq: "2", leq: "6");
    var rq = new FilteredQuery(q, rf);
    var qf = new QueryFilter(new TermQuery('switch', "on"));
    do_test_top_docs(searcher, rq, [2, 4, 6], qf);
    var query = new FilteredQuery(rq, qf);
    var rf2 = new RangeFilter('int', geq: "3");
    do_test_top_docs(searcher, query, [4, 6], rf2);
  });

  test('custom_filter', () {
    var searcher = new Searcher.store(_dir);
    var q = new MatchAllQuery();
    var filt = new CustomFilter();
    do_test_top_docs(searcher, q, [0, 2, 4], filt);
  });

  /*test('filter_proc', () {
    var searcher = new Searcher.store(_dir);
    var q = new MatchAllQuery();
    filter_proc(doc, score, s) => (s[doc]['int'] % 2) == 0;
    var top_docs = searcher.search(q, filter_proc: filter_proc);
    top_docs.hits.forEach((hit) {
      expect(0, equals(searcher[hit.doc]['int'] % 2));
    });
  });

  test('score_modifying_filter_proc', () {
    var searcher = new Searcher.store(_dir);
    var q = new MatchAllQuery();
    var start_date = DateTime.parse('2008-02-08');
    date_half_life_50(doc, score, s) {
      var days = (start_date - DateTime.parse(s[doc]['date'], '%Y%m%d')).to_i();
      1.0 / (pow(2.0, (days.to_f / 50.0)));
    }
    var top_docs = searcher.search(q, filter_proc: date_half_life_50);
    var docs = top_docs.hits.map((hit) => hit.doc);
    expect(docs, equals([2, 4, 9, 8, 6, 3, 5, 1, 7, 0]));
    rev_date_half_life_50(doc, score, s) {
      var days = (start_date - DateTime.parse(s[doc]['date'], '%Y%m%d')).to_i();
      1.0 - 1.0 / (pow(2.0, (days.to_f / 50.0)));
    }
    top_docs = searcher.search(q, filter_proc: rev_date_half_life_50);
    docs = top_docs.hits.map((hit) => hit.doc);
    expect(docs, equals([0, 7, 1, 3, 5, 6, 8, 9, 2, 4]));
  });*/
}

class CustomFilter extends Filter {
  CustomFilter() : super.wrap(ferret, h);
  BitVector bits(IndexReader index_reader) {
    var bv = new BitVector();
    bv[0] = true;
    bv[2] = true;
    bv[4] = true;
    return bv;
  }
}
