library ferret.test.search.search_and_sort;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

class SearchAndSortTest {
  //< Test.Unit.TestCase
  Directory _dir;

  setup() {
    _dir = new RAMDirectory();
    var iw = new IndexWriter(
        dir: _dir,
        analyzer: new WhiteSpaceAnalyzer(),
        create: true,
        min_merge_docs: 3);
    [
      // len mod
      {'x': "findall", 'string': "a", 'int': "6", 'float': "0.01"}, //     4   0
      {'x': "findall", 'string': "c", 'int': "5", 'float': "0.1"}, //      3   3
      {'x': "findall", 'string': "e", 'int': "2", 'float': "0.001"}, //    5   1
      {'x': "findall", 'string': "g", 'int': "1", 'float': "1.0"}, //      3   3
      {'x': "findall", 'string': null, 'int': "3", 'float': "0.0001"}, //  6   2
      {'x': "findall", 'string': "", 'int': "4", 'float': "10.0"}, //      4   0
      {'x': "findall", 'string': "h", 'int': "5", 'float': "0.00001"}, //  7   3
      {'x': "findall", 'string': "f", 'int': "2", 'float': "100.0"}, //    5   1
      {'x': "findall", 'string': "d", 'int': "3", 'float': "1000.0"}, //   6   2
      {'x': "findall", 'string': "b", 'int': "4", 'float': "0.000001"} //  8   0
    ].forEach((doc) {
      doc.extend(Ferret.BoostMixin);
      doc.boost = doc['float'].to_f();
      iw.add_document(doc);
    });
    iw.close();
  }

  teardown() {
    _dir.close();
  }

  do_test_top_docs(Searcher _is, query, expected, [sort = null]) {
    var top_docs = _is.search(query, sort: sort);
    top_docs.total_hits.times((i) {
      expect(expected[i], equals(top_docs.hits[i].doc));
    });

    // test sorting works for smaller ranged query
    var offset = 3;
    var limit = 3;
    top_docs = _is.search(query, sort: sort, offset: offset, limit: limit);
    limit.times((i) {
      expect(expected[offset + i], equals(top_docs.hits[i].doc));
    });
  }

  test_sort_field_to_s() {
    expect("<SCORE>", equals(SortField.SCORE.to_s));
    var sf = new SortField("MyScore", type: 'score', reverse: true);
    expect("MyScore:<SCORE>!", equals(sf.to_s));
    expect("<DOC>", equals(SortField.DOC_ID.to_s));
    sf = new SortField("MyDoc", type: 'doc_id', reverse: true);
    expect("MyDoc:<DOC>!", equals(sf.to_s));
    sf = new SortField('date', type: 'integer');
    expect("date:<integer>", equals(sf.to_s));
    sf = new SortField('date', type: 'integer', reverse: true);
    expect("date:<integer>!", equals(sf.to_s));
    sf = new SortField('price', type: 'float');
    expect("price:<float>", equals(sf.to_s));
    sf = new SortField('price', type: 'float', reverse: true);
    expect("price:<float>!", equals(sf.to_s));
    sf = new SortField('content', type: 'string');
    expect("content:<string>", equals(sf.to_s));
    sf = new SortField('content', type: 'string', reverse: true);
    expect("content:<string>!", equals(sf.to_s));
    sf = new SortField('auto_field', type: 'auto');
    expect("auto_field:<auto>", equals(sf.to_s));
    sf = new SortField('auto_field', type: 'auto', reverse: true);
    expect("auto_field:<auto>!", equals(sf.to_s));
  }

  test_sort_to_s() {
    var sort = new Sort();
    expect("Sort[<SCORE>, <DOC>]", equals(sort.to_s));
    var sf = new SortField('auto_field', type: 'auto', reverse: true);
    sort = new Sort(sort_fields: [sf, SortField.SCORE, SortField.DOC_ID]);
    expect("Sort[auto_field:<auto>!, <SCORE>, <DOC>]", equals(sort.to_s));
    sort = new Sort(sort_fields: ['one', 'two', SortField.DOC_ID]);
    expect("Sort[one:<auto>, two:<auto>, <DOC>]", equals(sort.to_s));
    sort = new Sort(sort_fields: ['one', 'two']);
    expect("Sort[one:<auto>, two:<auto>, <DOC>]", equals(sort.to_s));
  }

  test_sorts() {
    var _is = new Searcher(_dir);
    var q = new TermQuery('x', "findall");
    do_test_top_docs(_is, q, [8, 7, 5, 3, 1, 0, 2, 4, 6, 9]);
    do_test_top_docs(_is, q, [8, 7, 5, 3, 1, 0, 2, 4, 6, 9], Sort.RELEVANCE);
    do_test_top_docs(_is, q, [8, 7, 5, 3, 1, 0, 2, 4, 6, 9], [SortField.SCORE]);
    do_test_top_docs(_is, q, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], Sort.INDEX_ORDER);
    do_test_top_docs(
        _is, q, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], [SortField.DOC_ID]);

    // int
    var sf_int = new SortField('int', type: 'integer', reverse: true);
    do_test_top_docs(_is, q, [0, 1, 6, 5, 9, 4, 8, 2, 7, 3], [sf_int]);
    do_test_top_docs(_is, q, [0, 1, 6, 5, 9, 4, 8, 2, 7, 3], "int DESC");
    do_test_top_docs(
        _is, q, [0, 1, 6, 5, 9, 8, 4, 7, 2, 3], [sf_int, SortField.SCORE]);
    do_test_top_docs(_is, q, [0, 1, 6, 5, 9, 8, 4, 7, 2, 3], "int DESC, SCORE");
    sf_int = new SortField('int', type: 'integer');
    do_test_top_docs(_is, q, [3, 2, 7, 4, 8, 5, 9, 1, 6, 0], [sf_int]);
    do_test_top_docs(_is, q, [3, 2, 7, 4, 8, 5, 9, 1, 6, 0], "int");

    // byte
    do_test_top_docs(_is, q, [
      3,
      2,
      7,
      4,
      8,
      5,
      9,
      1,
      6,
      0
    ], new SortField('int', type: 'byte'));
    do_test_top_docs(_is, q, [
      0,
      1,
      6,
      5,
      9,
      4,
      8,
      2,
      7,
      3
    ], [new SortField('int', type: 'byte', reverse: true)]);

    // float
    var sf_float = new SortField('float', type: 'float', reverse: true);
    do_test_top_docs(_is, q, [
      8,
      7,
      5,
      3,
      1,
      0,
      2,
      4,
      6,
      9
    ], new Sort(sort_fields: [sf_float, SortField.SCORE]));
    do_test_top_docs(
        _is, q, [8, 7, 5, 3, 1, 0, 2, 4, 6, 9], "float DESC, SCORE");
    sf_float = new SortField('float', type: 'float');
    do_test_top_docs(_is, q, [
      9,
      6,
      4,
      2,
      0,
      1,
      3,
      5,
      7,
      8
    ], new Sort(sort_fields: [sf_float, SortField.SCORE]));
    do_test_top_docs(_is, q, [9, 6, 4, 2, 0, 1, 3, 5, 7, 8], "float, SCORE");

    // str
    var sf_str = new SortField('string', type: 'string');
    do_test_top_docs(
        _is, q, [0, 9, 1, 8, 2, 7, 3, 6, 5, 4], [sf_str, SortField.SCORE]);
    do_test_top_docs(_is, q, [0, 9, 1, 8, 2, 7, 3, 6, 4, 5], "string");

    // auto
    do_test_top_docs(_is, q, [
      0,
      9,
      1,
      8,
      2,
      7,
      3,
      6,
      4,
      5
    ], new Sort(sort_fields: 'string'));
    do_test_top_docs(
        _is, q, [3, 2, 7, 4, 8, 5, 9, 1, 6, 0], new Sort(sort_fields: ['int']));
    do_test_top_docs(
        _is, q, [9, 6, 4, 2, 0, 1, 3, 5, 7, 8], new Sort(sort_fields: 'float'));
    do_test_top_docs(_is, q, [9, 6, 4, 2, 0, 1, 3, 5, 7, 8], 'float');
    do_test_top_docs(_is, q, [
      8,
      7,
      5,
      3,
      1,
      0,
      2,
      4,
      6,
      9
    ], new Sort(sort_fields: 'float', reverse: true));
    do_test_top_docs(_is, q, [
      0,
      6,
      1,
      5,
      9,
      4,
      8,
      7,
      2,
      3
    ], new Sort(sort_fields: ['int', 'string'], reverse: true));
    do_test_top_docs(
        _is, q, [0, 6, 1, 5, 9, 4, 8, 7, 2, 3], "int DESC, string DESC");
    do_test_top_docs(_is, q, [
      3,
      2,
      7,
      8,
      4,
      9,
      5,
      1,
      6,
      0
    ], new Sort(sort_fields: ['int', 'string']));
    do_test_top_docs(_is, q, [3, 2, 7, 8, 4, 9, 5, 1, 6, 0], ['int', 'string']);
    do_test_top_docs(_is, q, [3, 2, 7, 8, 4, 9, 5, 1, 6, 0], "int, string");
  }

  //LENGTH = SortField.SortType.new("length", lambda{|str| str.length});
  //LENGTH_MODULO = SortField.SortType.new("length_mod", lambda{|str| str.length},
  //                                        lambda{|i, j| (i%4) <=> (j%4)});
  //def test_special_sorts
  //  is = IndexSearcher.new(_dir);
  //  q = TermQuery.new(Term.new(:x, "findall"));
  //  sf = new SortField('float', {'type': LENGTH, 'reverse': true});
  //  do_test_top_docs(is, q, [9,6,4,8,2,7,0,5,1,3], [sf]);
  //  sf = new SortField('float', {'type': LENGTH_MODULO, 'reverse': true});
  //  do_test_top_docs(is, q, [1,3,6,4,8,2,7,0,5,9], [sf]);
  //  sf = new SortField('float', {'type': LENGTH,
  //                               'reverse': true,
  //                               :comparator: lambda{|i,j| (j%4) <=> (i%4)}});
  //  do_test_top_docs(is, q, [0,5,9,2,7,4,8,1,3,6], [sf]);
  //}
}
