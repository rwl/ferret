library ferret.test.index.reader;

class IndexReaderCommon {
  test_index_reader() {
    do_test_get_field_names();

    do_test_term_enum();

    do_test_term_doc_enum();

    do_test_term_vectors();

    do_test_get_doc();
  }

  do_test_get_field_names() {
    field_names = _ir.field_names;

    assert(field_names.include('body'));
    assert(field_names.include('changing_field'));
    assert(field_names.include('author'));
    assert(field_names.include('title'));
    assert(field_names.include('text'));
    assert(field_names.include('year'));
  }

  do_test_term_enum() {
    te = _ir.terms('author');

    assert_equal(
        '[{"term":"Leo","frequency":1},{"term":"Tolstoy","frequency":1}]',
        te.to_json);
    te.field = 'author';
    assert_equal('[["Leo",1],["Tolstoy",1]]', te.to_json('fast'));
    te.field = 'author';

    assert(te.next() != null);
    assert_equal("Leo", te.term);
    assert_equal(1, te.doc_freq);
    assert(te.next() != null);
    assert_equal("Tolstoy", te.term);
    assert_equal(1, te.doc_freq);
    assert(te.next == null);

    te.field = 'body';
    assert(te.next() != null);
    assert_equal("And", te.term);
    assert_equal(1, te.doc_freq);

    assert(te.skip_to("Not"));
    assert_equal("Not", te.term);
    assert_equal(1, te.doc_freq);
    assert(te.next != null);
    assert_equal("Random", te.term);
    assert_equal(16, te.doc_freq);

    te.field = 'text';
    assert(te.skip_to("which"));
    expect(te.term, equals("which"));
    assert_equal(1, te.doc_freq);
    assert(te.next == null);

    te.field = 'title';
    assert(te.next != null);
    assert_equal("War And Peace", te.term);
    assert_equal(1, te.doc_freq);
    assert(te.next == null);

    var expected; // = %w{is 1 more 1 not 1 skip 42 stored 1 text 1 which 1}
    te = _ir.terms('text');
    te.each((term, doc_freq) {
      assert_equal(expected.shift, term);
      assert_equal(expected.shift.to_i, doc_freq);
    });

    te = _ir.terms_from('body', "Not");
    assert_equal("Not", te.term);
    assert_equal(1, te.doc_freq);
    assert(te.next != null);
    assert_equal("Random", te.term);
    assert_equal(16, te.doc_freq);
  }

  do_test_term_doc_enum() {
    assert_equal(IndexTestHelper.INDEX_TEST_DOCS.size, _ir.num_docs());
    assert_equal(IndexTestHelper.INDEX_TEST_DOCS.size, _ir.max_doc());

    assert_equal(4, _ir.doc_freq('body', "Wally"));

    tde = _ir.term_docs_for('body', "Wally");

    [[0, 1], [5, 1], [18, 3], [20, 6]].each((doc, freq) {
      assert(tde.next != null);
      assert_equal(doc, tde.doc());
      assert_equal(freq, tde.freq());
    });
    assert(tde.next == null);

    tde = _ir.term_docs_for('body', "Wally");
    assert_equal(
        '[{"document":0,"frequency":1},{"document":5,"frequency":1},{"document":18,"frequency":3},{"document":20,"frequency":6}]',
        tde.to_json);
    tde = _ir.term_docs_for('body', "Wally");
    assert_equal('[[0,1],[5,1],[18,3],[20,6]]', tde.to_json('fast'));

    do_test_term_docpos_enum_skip_to(tde);

    // test term positions
    tde = _ir.term_positions_for('body', "read");
    [
      [false, 1, 1, [3]],
      [false, 2, 2, [1, 4]],
      [false, 6, 4, [3, 4]],
      [false, 9, 3, [0, 4]],
      [true, 16, 2, [2]],
      [true, 21, 6, [3, 4, 5, 8, 9, 10]]
    ].each((skip, doc, freq, positions) {
      if (skip) {
        assert(tde.skip_to(doc));
      } else {
        assert(tde.next != null);
      }
      assert_equal(doc, tde.doc());
      assert_equal(freq, tde.freq());
      positions.each((pos) => assert_equal(pos, tde.next_position()));
    });

    assert_nil(tde.next_position());
    assert(tde.next == null);

    tde = _ir.term_positions_for('body', "read");
    assert_equal('[' +
            '{"document":1,"frequency":1,"positions":[3]},' +
            '{"document":2,"frequency":2,"positions":[1,4]},' +
            '{"document":6,"frequency":4,"positions":[3,4,5,6]},' +
            '{"document":9,"frequency":3,"positions":[0,4,13]},' +
            '{"document":10,"frequency":1,"positions":[1]},' +
            '{"document":16,"frequency":2,"positions":[2,3]},' +
            '{"document":17,"frequency":1,"positions":[2]},' +
            '{"document":20,"frequency":1,"positions":[21]},' +
            '{"document":21,"frequency":6,"positions":[3,4,5,8,9,10]}]',
        tde.to_json());
    tde = _ir.term_positions_for('body', "read");
    assert_equal('[' +
        '[1,1,[3]],' +
        '[2,2,[1,4]],' +
        '[6,4,[3,4,5,6]],' +
        '[9,3,[0,4,13]],' +
        '[10,1,[1]],' +
        '[16,2,[2,3]],' +
        '[17,1,[2]],' +
        '[20,1,[21]],' +
        '[21,6,[3,4,5,8,9,10]]]', tde.to_json('fast'));

    tde = _ir.term_positions_for('body', "read");

    do_test_term_docpos_enum_skip_to(tde);
  }

  do_test_term_docpos_enum_skip_to(tde) {
    tde.seek('text', "skip");

    [
      [10, 22],
      [44, 44],
      [60, 60],
      [62, 62],
      [63, 63],
    ].each((skip_doc, doc_and_freq) {
      assert(tde.skip_to(skip_doc));
      assert_equal(doc_and_freq, tde.doc());
      assert_equal(doc_and_freq, tde.freq());
    });

    assert(!tde.skip_to(IndexTestHelper.INDEX_TEST_DOC_COUNT));
    assert(!tde.skip_to(IndexTestHelper.INDEX_TEST_DOC_COUNT));
    assert(!tde.skip_to(IndexTestHelper.INDEX_TEST_DOC_COUNT + 100));

    tde.seek('text', "skip");
    assert(!tde.skip_to(IndexTestHelper.INDEX_TEST_DOC_COUNT));
  }

  do_test_term_vectors() {
    expected_tv = new TermVector('body', [
      new TVTerm("word1", 3, [2, 4, 7]),
      new TVTerm("word2", 1, [3]),
      new TVTerm("word3", 4, [0, 5, 8, 9]),
      new TVTerm("word4", 2, [1, 6])
    ], [range(0, 10)].collect((i) => new TVOffsets(i * 6, (i + 1) * 6 - 1)));

    tv = _ir.term_vector(3, 'body');

    assert_equal(expected_tv, tv);

    tvs = _ir.term_vectors(3);
    assert_equal(3, tvs.size);

    assert_equal(expected_tv, tvs['body']);

    tv = tvs['author'];
    assert_equal('author', tv.field);
    assert_equal(
        [new TVTerm("Leo", 1, [0]), new TVTerm("Tolstoy", 1, [1])], tv.terms);
    assert(tv.offsets == null);

    tv = tvs['title'];
    assert_equal('title', tv.field);
    assert_equal([new TVTerm("War And Peace", 1, null)], tv.terms);
    assert_equal([new TVOffsets(0, 13)], tv.offsets);
  }

  do_test_get_doc() {
    doc = _ir.get_document(3);
    ['author', 'body', 'title', 'year'].each((fn) {
      assert(doc.fields.include(fn));
    });
    assert_equal(4, doc.fields.size);
    assert_equal(0, doc.size);
    assert_equal([], doc.keys);

    assert_equal("Leo Tolstoy", doc['author']);
    assert_equal("word3 word4 word1 word2 word1 word3 word4 word1 word3 word3",
        doc['body']);
    assert_equal("War And Peace", doc['title']);
    assert_equal("1865", doc['year']);
    assert_nil(doc['text']);

    assert_equal(4, doc.size);
    ['author', 'body', 'title', 'year'].each((fn) {
      assert(doc.keys.include(fn));
    });
//    assert_equal([_ir[0].load, _ir[1].load, _ir[2].load], _ir[0, 3].collect((d) => d.load());
//    assert_equal([_ir[61].load, _ir[62].load, _ir[63].load], _ir[61, 100].collect((d) => d.load());
//    assert_equal([_ir[0].load, _ir[1].load, _ir[2].load], _ir[0..2].collect((d) => d.load());
//    assert_equal([_ir[61].load, _ir[62].load, _ir[63].load], _ir[range(61, 100)].collect((d) => d.load));
    assert_equal(_ir[-60], _ir[4]);
  }

  test_ir_norms() {
    _ir.set_norm(3, 'title', 1);
    _ir.set_norm(3, 'body', 12);
    _ir.set_norm(3, 'author', 145);
    _ir.set_norm(3, 'year', 31);
    _ir.set_norm(3, 'text', 202);
    _ir.set_norm(25, 'text', 20);
    _ir.set_norm(50, 'text', 200);
    _ir.set_norm(63, 'text', 155);

    norms = _ir.norms('text');

    assert_equal(202, norms.bytes.to_a[3]);
    assert_equal(20, norms.bytes.to_a[25]);
    assert_equal(200, norms.bytes.to_a[50]);
    assert_equal(155, norms.bytes.to_a[63]);

    norms = _ir.norms('title');
    assert_equal(1, norms.bytes.to_a[3]);

    norms = _ir.norms('body');
    assert_equal(12, norms.bytes.to_a[3]);

    norms = _ir.norms('author');
    assert_equal(145, norms.bytes.to_a[3]);

    norms = _ir.norms('year');
    // TODO: this returns two possible results depending on whether it is
    // a multi reader or a segment reader. If it is a multi reader it will
    // always return an empty set of norms, otherwise it will return nil.
    // I'm not sure what to do here just yet or if this is even an issue.
    //assert(norms.nil?);

    norms = " " * 164;
    _ir.get_norms_into('text', norms, 100);
    assert_equal(202, norms.bytes.to_a[103]);
    assert_equal(20, norms.bytes.to_a[125]);
    assert_equal(200, norms.bytes.to_a[150]);
    assert_equal(155, norms.bytes.to_a[163]);

    _ir.commit();

    iw_optimize();

    ir2 = ir_new();

    norms = " " * 164;
    ir2.get_norms_into('text', norms, 100);
    assert_equal(202, norms.bytes.to_a[103]);
    assert_equal(20, norms.bytes.to_a[125]);
    assert_equal(200, norms.bytes.to_a[150]);
    assert_equal(155, norms.bytes.to_a[163]);
    ir2.close();
  }

  test_ir_delete() {
    doc_count = IndexTestHelper.INDEX_TEST_DOCS.size;
    _ir.delete(1000); // non existant doc_num
    assert(!_ir.has_deletions());
    assert_equal(doc_count, _ir.max_doc());
    assert_equal(doc_count, _ir.num_docs());
    assert(!_ir.deleted(10));

    [
      [10, doc_count - 1],
      [10, doc_count - 1],
      [doc_count - 1, doc_count - 2],
      [doc_count - 2, doc_count - 3],
    ].each((del_num, num_docs) {
      _ir.delete(del_num);
      assert(_ir.has_deletions());
      assert_equal(doc_count, _ir.max_doc());
      assert_equal(num_docs, _ir.num_docs());
      assert(_ir.deleted(del_num));
    });

    _ir.undelete_all();
    assert(!_ir.has_deletions());
    assert_equal(doc_count, _ir.max_doc());
    assert_equal(doc_count, _ir.num_docs());
    assert(!_ir.deleted(10));
    assert(!_ir.deleted(doc_count - 2));
    assert(!_ir.deleted(doc_count - 1));

    del_list = [10, 20, 30, 40, 50, doc_count - 1];

    del_list.each((doc_num) => _ir.delete(doc_num));
    assert(_ir.has_deletions());
    assert_equal(doc_count, _ir.max_doc());
    assert_equal(doc_count - del_list.size, _ir.num_docs());
    del_list.each((doc_num) {
      assert(_ir.deleted(doc_num));
    });

    ir2 = ir_new();
    assert(!ir2.has_deletions());
    assert_equal(doc_count, ir2.max_doc());
    assert_equal(doc_count, ir2.num_docs());

    _ir.commit();

    assert(!ir2.has_deletions());
    assert_equal(doc_count, ir2.max_doc());
    assert_equal(doc_count, ir2.num_docs());

    ir2.close();
    ir2 = ir_new();
    assert(ir2.has_deletions());
    assert_equal(doc_count, ir2.max_doc());
    assert_equal(doc_count - 6, ir2.num_docs());
    del_list.each((doc_num) {
      assert(ir2.deleted(doc_num));
    });

    ir2.undelete_all();
    assert(!ir2.has_deletions());
    assert_equal(doc_count, ir2.max_doc());
    assert_equal(doc_count, ir2.num_docs());
    del_list.each((doc_num) {
      assert(!ir2.deleted(doc_num));
    });

    del_list.each((doc_num) {
      assert(_ir.deleted(doc_num));
    });

    ir2.commit();

    del_list.each((doc_num) {
      assert(_ir.deleted(doc_num));
    });

    del_list.each((doc_num) => ir2.delete(doc_num));
    ir2.commit();

    iw_optimize();

    ir3 = ir_new();

    assert(!ir3.has_deletions());
    assert_equal(doc_count - 6, ir3.max_doc());
    assert_equal(doc_count - 6, ir3.num_docs());

    ir2.close();
    ir3.close();
  }

  test_latest() {
    assert(_ir.latest);
    ir2 = ir_new();
    assert(ir2.latest);

    ir2.delete(0);
    ir2.commit();
    assert(ir2.latest);
    assert(!_ir.latest);

    ir2.close();
  }
}

class MultiReaderTest {
  //< Test::Unit::TestCase
  //include IndexReaderCommon

  ir_new() {
    new IndexReader(_dir);
  }

  iw_optimize() {
    iw = new IndexWriter(dir: _dir, analyzer: new WhiteSpaceAnalyzer());
    iw.optimize();
    iw.close();
  }

  setup() {
    _dir = new RAMDirectory();

    iw = new IndexWriter(
        dir: _dir,
        analyzer: new WhiteSpaceAnalyzer(),
        create: true,
        field_infos: IndexTestHelper.INDEX_TEST_FIS,
        max_buffered_docs: 15);
    IndexTestHelper.INDEX_TEST_DOCS.each((doc) => iw.add(doc));

    // we mustn't optimize here so that MultiReader is used.
    //iw.optimize() unless self.class == MultiReaderTest
    iw.close();
    _ir = ir_new();
  }

  teardown() {
    _ir.close();
    _dir.close();
  }
}

class SegmentReaderTest extends MultiReaderTest {}

class MultiExternalReaderTest {
  //< Test::Unit::TestCase
  //include IndexReaderCommon

  ir_new() {
    readers = _dirs.collect((dir) => new IndexReader(dir));
    new IndexReader(readers);
  }

  iw_optimize() {
    _dirs.each((dir) {
      iw = new IndexWriter(dir: dir, analyzer: new WhiteSpaceAnalyzer());
      iw.optimize();
      iw.close();
    });
  }

  setup() {
    _dirs = [];

    [
      [0, 10],
      [10, 30],
      [30, IndexTestHelper.INDEX_TEST_DOCS.size]
    ].each((start, finish) {
      dir = new RAMDirectory();
      _dirs.add(dir);

      iw = new IndexWriter(
          dir: dir,
          analyzer: new WhiteSpaceAnalyzer(),
          create: true,
          field_infos: IndexTestHelper.INDEX_TEST_FIS);
      range(start, finish).each((doc_id) {
        iw.add(IndexTestHelper.INDEX_TEST_DOCS[doc_id]);
      });
      iw.close();
    });
    _ir = ir_new;
  }

  teardown() {
    _ir.close();
    _dirs.each((dir) => dir.close());
  }
}

class MultiExternalReaderDirTest {
  //< Test::Unit::TestCase
  //include IndexReaderCommon

  ir_new() {
    new IndexReader(_dirs);
  }

  iw_optimize() {
    _dirs.each((dir) {
      iw = new IndexWriter(dir: dir, analyzer: new WhiteSpaceAnalyzer());
      iw.optimize();
      iw.close();
    });
  }

  setup() {
    _dirs = [];

    [
      [0, 10],
      [10, 30],
      [30, IndexTestHelper.INDEX_TEST_DOCS.size]
    ].each((start, finish) {
      dir = new RAMDirectory();
      _dirs.add(dir);

      iw = new IndexWriter(
          dir: dir,
          analyzer: new WhiteSpaceAnalyzer(),
          create: true,
          field_infos: IndexTestHelper.INDEX_TEST_FIS);
      range(start, finish).each((doc_id) {
        iw.add(IndexTestHelper.INDEX_TEST_DOCS[doc_id]);
      });
      iw.close();
    });
    _ir = ir_new;
  }

  teardown() {
    _ir.close();
    _dirs.each((dir) => dir.close());
  }
}

class MultiExternalReaderPathTest {
  //< Test::Unit::TestCase
  //include IndexReaderCommon

  ir_new() {
    new IndexReader(_paths);
  }

  iw_optimize() {
    _paths.each((path) {
      iw = new IndexWriter(path: path, analyzer: new WhiteSpaceAnalyzer());
      iw.optimize();
      iw.close();
    });
  }

  setup() {
    base_dir = File
        .expand_path(File.join(File.dirname(__FILE__), '../../temp/multidir'));
    FileUtils.mkdir_p(base_dir);
    _paths = [
      File.join(base_dir, "i1"),
      File.join(base_dir, "i2"),
      File.join(base_dir, "i3")
    ];

    [
      [0, 10],
      [10, 30],
      [30, IndexTestHelper.INDEX_TEST_DOCS.size]
    ].each_with_index((start, finish, i) {
      path = _paths[i];

      iw = new IndexWriter(
          path: path,
          analyzer: new WhiteSpaceAnalyzer(),
          create: true,
          field_infos: IndexTestHelper.INDEX_TEST_FIS);
      range(start, finish).each((doc_id) {
        iw.add(IndexTestHelper.INDEX_TEST_DOCS[doc_id]);
      });
      iw.close();
    });
    _ir = ir_new;
  }

  teardown() {
    _ir.close();
  }
}

class IndexReaderTest {
  //< Test::Unit::TestCase
  //include Ferret::Index
  //include Ferret::Analysis

  setup() {
    _dir = new RAMDirectory();
  }

  teardown() {
    _dir.close();
  }

  test_ir_multivalue_fields() {
    _fs_dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    _fs_dir = new FSDirectory(_fs_dpath, true);

    iw = new IndexWriter(
        dir: _fs_dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    doc = {
      'tag': ["Ruby", "C", "Lucene", "Ferret"],
      'body': "this is the body Document Field",
      'title': "this is the title DocField",
      'author': "this is the author field"
    };
    iw.add(doc);

    iw.close();

    _dir = new RAMDirectory(_fs_dir);
    ir = new IndexReader(_dir);
    assert_equal(doc, ir.get_document(0).load);
    ir.close();
  }

  do_test_term_vectors(ir) {
    expected_tv = new TermVector('body', [
      new TVTerm("word1", 3, [2, 4, 7]),
      new TVTerm("word2", 1, [3]),
      new TVTerm("word3", 4, [0, 5, 8, 9]),
      new TVTerm("word4", 2, [1, 6])
    ], [range(0, 10)].collect((i) => new TVOffsets(i * 6, (i + 1) * 6 - 1)));

    tv = ir.term_vector(3, 'body');

    assert_equal(expected_tv, tv);

    tvs = ir.term_vectors(3);
    assert_equal(3, tvs.size);

    assert_equal(expected_tv, tvs['body']);

    tv = tvs['author'];
    assert_equal('author', tv.field);
    assert_equal(
        [new TVTerm("Leo", 1, [0]), new TVTerm("Tolstoy", 1, [1])], tv.terms);
    assert(tv.offsets == null);

    tv = tvs['title'];
    assert_equal('title', tv.field);
    assert_equal([new TVTerm("War And Peace", 1, null)], tv.terms);
    assert_equal([new TVOffsets(0, 13)], tv.offsets);
  }

  do_test_ir_read_while_optimizing(dir) {
    iw = new IndexWriter(
        dir: dir,
        analyzer: new WhiteSpaceAnalyzer(),
        create: true,
        field_infos: IndexTestHelper.INDEX_TEST_FIS);

    IndexTestHelper.INDEX_TEST_DOCS.each((doc) => iw.add(doc));

    iw.close();

    ir = new IndexReader(dir);
    do_test_term_vectors(ir);

    iw = new IndexWriter(dir: dir, analyzer: new WhiteSpaceAnalyzer());
    iw.optimize();
    iw.close();

    do_test_term_vectors(ir);

    ir.close();
  }

  test_ir_read_while_optimizing() {
    do_test_ir_read_while_optimizing(_dir);
  }

  test_ir_read_while_optimizing_on_disk() {
    dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    fs_dir = new FSDirectory(dpath, true);
    do_test_ir_read_while_optimizing(fs_dir);
    fs_dir.close();
  }

  test_latest() {
    dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    fs_dir = new FSDirectory(dpath, true);

    iw = new IndexWriter(
        dir: fs_dir, analyzer: new WhiteSpaceAnalyzer(), create: true);
    iw.add({'field': "content"});
    iw.close();

    ir = new IndexReader(fs_dir);
    assert(ir.latest);

    iw = new IndexWriter(dir: fs_dir, analyzer: new WhiteSpaceAnalyzer());
    iw.add({'field': "content2"});
    iw.close();

    assert(!ir.latest);

    ir.close();
    ir = new IndexReader(fs_dir);
    assert(ir.latest);
    ir.close();
  }
}
