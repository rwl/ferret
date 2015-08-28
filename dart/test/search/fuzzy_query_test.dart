library ferret.test.search.fuzzy_query;

class FuzzyQueryTest {
  //< Test::Unit::TestCase

  add_doc(text, writer) {
    writer.add({'field': text});
  }

  setup() {
    _dir = new RAMDirectory();
  }

  teardown() {
    _dir.close();
  }

  do_test_top_docs(_is, query, expected) {
    top_docs = _is.search(query);
    assert_equal(expected.length, top_docs.total_hits,
        "expected ${expected.length} hits but got ${top_docs.total_hits}");
    assert_equal(expected.length, top_docs.hits.size);
    top_docs.total_hits.times((i) {
      assert_equal(expected[i], top_docs.hits[i].doc);
    });
  }

  do_prefix_test(_is, text, prefix, expected) {
    fq = new FuzzyQuery('field', text, prefix_length: prefix);
    //puts is.explain(fq, 0);
    //puts is.explain(fq, 1);
    do_test_top_docs(_is, fq, expected);
  }

  test_fuzziness() {
    iw = new IndexWriter(
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

    _is = new Searcher(_dir);

    fq = new FuzzyQuery('field', "aaaaa", prefix_length: 5);

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
    top_docs = _is.search(fq);
    assert_equal(0, top_docs.total_hits);

    _is.close();
  }

  test_fuzziness_long() {
    iw = new IndexWriter(
        dir: _dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    add_doc("aaaaaaa", iw);
    add_doc("segment", iw);
    iw.optimize();
    iw.close();
    _is = new Searcher(_dir);

    // not similar enough:
    do_prefix_test(_is, "xxxxx", 0, []);

    // edit distance to "aaaaaaa" = 3, this matches because the string is longer than
    // in testDefaultFuzziness so a bigger difference is allowed:
    do_prefix_test(_is, "aaaaccc", 0, [0]);

    // now with prefix
    do_prefix_test(_is, "aaaaccc", 1, [0]);
    do_prefix_test(_is, "aaaaccc", 4, [0]);
    do_prefix_test(_is, "aaaaccc", 5, []);

    // no match, more than half of the characters is wrong:
    do_prefix_test(_is, "aaacccc", 0, []);

    // now with prefix
    do_prefix_test(_is, "aaacccc", 1, []);

    // "student" and "stellent" are indeed similar to "segment" by default:
    do_prefix_test(_is, "student", 0, [1]);
    do_prefix_test(_is, "stellent", 0, [1]);

    // now with prefix
    do_prefix_test(_is, "student", 2, []);
    do_prefix_test(_is, "stellent", 2, []);

    // "student" doesn't match anymore thanks to increased minimum similarity:
    fq = new FuzzyQuery('field', "student",
        min_similarity: 0.6, prefix_length: 0);

    top_docs = _is.search(fq);
    assert_equal(0, top_docs.total_hits);

    assert_raise(() {
      fq = new FuzzyQuery('f', "s", min_similarity: 1.1);
    }, ArgumentError);
    assert_raise(() {
      fq = new FuzzyQuery('f', "s", min_similarity: -0.1);
    }, ArgumentError);

    _is.close();
  }
}
