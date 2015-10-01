library ferret.test.search.fuzzy_query;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

void fuzzyQueryTest() {
  Directory _dir;

  add_doc(String text, IndexWriter writer) {
    writer.add_document({'field': text});
  }

  setUp(() {
    _dir = new RAMDirectory();
  });

  tearDown(() {
    _dir.close();
  });

  do_test_top_docs(Searcher searcher, Query query, List expected) {
    var top_docs = searcher.search(query);
    expect(top_docs.total_hits, equals(expected.length),
        reason:
            "expected ${expected.length} hits but got ${top_docs.total_hits}");
    expect(top_docs.hits.length, equals(expected.length));
    range(top_docs.total_hits).forEach((i) {
      expect(expected[i], equals(top_docs.hits[i].doc));
    });
  }

  do_prefix_test(Searcher _is, String text, int prefix, List expected) {
    var fq = new FuzzyQuery('field', text, prefix_length: prefix);
    //puts is.explain(fq, 0);
    //puts is.explain(fq, 1);
    do_test_top_docs(_is, fq, expected);
  }

  test('fuzziness', () {
    var iw = new IndexWriter(
        dir: _dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    add_doc("aaaaa", iw);
    add_doc("aaaab", iw);
    add_doc("aaabb", iw);
    add_doc("aabbb", iw);
    add_doc("abbbb", iw);
    add_doc("bbbbb", iw);
    add_doc("ddddd", iw);
    add_doc("ddddddddddddddddddddd", iw); // test max_distances problem
    add_doc("aaaaaaaaaaaaaaaaaaaaaaa", iw); // test max_distances problem
    //iw.optimize();
    iw.close();

    var _is = new Searcher.store(_dir);

    var fq = new FuzzyQuery('field', "aaaaa", prefix_length: 5);

    do_prefix_test(_is, "aaaaaaaaaaaaaaaaaaaaaa", 1, [8]);
    do_prefix_test(_is, "aaaaa", 0, [0, 1, 2]);
    do_prefix_test(_is, "aaaaa", 1, [0, 1, 2]);
    do_prefix_test(_is, "aaaaa", 2, [0, 1, 2]);
    do_prefix_test(_is, "aaaaa", 3, [0, 1, 2]);
    do_prefix_test(_is, "aaaaa", 4, [0, 1]);
    do_prefix_test(_is, "aaaaa", 5, [0]);
    do_prefix_test(_is, "aaaaa", 6, [0]);

    do_prefix_test(_is, "xxxxx", 0, []);

    do_prefix_test(_is, "aaccc", 0, []);

    do_prefix_test(_is, "aaaac", 0, [0, 1, 2]);
    do_prefix_test(_is, "aaaac", 1, [0, 1, 2]);
    do_prefix_test(_is, "aaaac", 2, [0, 1, 2]);
    do_prefix_test(_is, "aaaac", 3, [0, 1, 2]);
    do_prefix_test(_is, "aaaac", 4, [0, 1]);
    do_prefix_test(_is, "aaaac", 5, []);

    do_prefix_test(_is, "ddddX", 0, [6]);
    do_prefix_test(_is, "ddddX", 1, [6]);
    do_prefix_test(_is, "ddddX", 2, [6]);
    do_prefix_test(_is, "ddddX", 3, [6]);
    do_prefix_test(_is, "ddddX", 4, [6]);
    do_prefix_test(_is, "ddddX", 5, []);

    fq = new FuzzyQuery('anotherfield', "ddddX", prefix_length: 0);
    var top_docs = _is.search(fq);
    expect(0, equals(top_docs.total_hits));

    _is.close();
  });

  test('fuzziness_long', () {
    var iw = new IndexWriter(
        dir: _dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    add_doc("aaaaaaa", iw);
    add_doc("segment", iw);
    iw.optimize();
    iw.close();
    var searcher = new Searcher.store(_dir);

    // not similar enough:
    do_prefix_test(searcher, "xxxxx", 0, []);

    // edit distance to "aaaaaaa" = 3, this matches because the string is longer than
    // in testDefaultFuzziness so a bigger difference is allowed:
    do_prefix_test(searcher, "aaaaccc", 0, [0]);

    // now with prefix
    do_prefix_test(searcher, "aaaaccc", 1, [0]);
    do_prefix_test(searcher, "aaaaccc", 4, [0]);
    do_prefix_test(searcher, "aaaaccc", 5, []);

    // no match, more than half of the characters is wrong:
    do_prefix_test(searcher, "aaacccc", 0, []);

    // now with prefix
    do_prefix_test(searcher, "aaacccc", 1, []);

    // "student" and "stellent" are indeed similar to "segment" by default:
    do_prefix_test(searcher, "student", 0, [1]);
    do_prefix_test(searcher, "stellent", 0, [1]);

    // now with prefix
    do_prefix_test(searcher, "student", 2, []);
    do_prefix_test(searcher, "stellent", 2, []);

    // "student" doesn't match anymore thanks to increased minimum similarity:
    var fq = new FuzzyQuery('field', "student",
        min_similarity: 0.6, prefix_length: 0);

    var top_docs = searcher.search(fq);
    expect(0, equals(top_docs.total_hits));

    expect(() {
      fq = new FuzzyQuery('f', "s", min_similarity: 1.1);
    }, throwsArgumentError);
    expect(() {
      fq = new FuzzyQuery('f', "s", min_similarity: -0.1);
    }, throwsArgumentError);

    searcher.close();
  });
}
