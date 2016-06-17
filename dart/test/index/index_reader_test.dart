library ferret.test.index.reader;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

import 'index_test_helper.dart';

abstract class IndexReaderCommon {
  Ferret _ferret;
  IndexReader _ir;

  test_index_reader() {
    do_test_get_field_names();
    do_test_term_enum();
    do_test_term_doc_enum();
    do_test_term_vectors();
    do_test_get_doc();
  }

  do_test_get_field_names() {
    var field_names = _ir.field_names();

    expect(field_names.contains('body'), isTrue);
    expect(field_names.contains('changing_field'), isTrue);
    expect(field_names.contains('author'), isTrue);
    expect(field_names.contains('title'), isTrue);
    expect(field_names.contains('text'), isTrue);
    expect(field_names.contains('year'), isTrue);
  }

  do_test_term_enum() {
    TermEnum te = _ir.terms('author');

    expect('[{"term":"Leo","frequency":1},{"term":"Tolstoy","frequency":1}]',
        equals(te.to_json));
    te.field = 'author';
    expect('[["Leo",1],["Tolstoy",1]]', equals(te.to_json(fast: true)));
    te.field = 'author';

    expect(te.next(), isNotNull);
    expect(te.term, equals("Leo"));
    expect(te.doc_freq, equals(1));
    expect(te.next(), isNotNull);
    expect(te.term, equals("Tolstoy"));
    expect(te.doc_freq, equals(1));
    expect(te.next(), isNull);

    te.field = 'body';
    expect(te.next(), isNotNull);
    expect(te.term, equals("And"));
    expect(te.doc_freq, equals(1));

    expect(te.skip_to("Not"), isTrue);
    expect(te.term, equals("Not"));
    expect(te.doc_freq, equals(1));
    expect(te.next(), isNotNull);
    expect(te.term, equals("Random"));
    expect(te.doc_freq, equals(16));

    te.field = 'text';
    expect(te.skip_to("which"), isTrue);
    expect(te.term, equals("which"));
    expect(te.doc_freq, equals(1));
    expect(te.next(), isNull);

    te.field = 'title';
    expect(te.next(), isNotNull);
    expect(te.term, equals("War And Peace"));
    expect(te.doc_freq, equals(1));
    expect(te.next(), isNull);

    var expected; // = %w{is 1 more 1 not 1 skip 42 stored 1 text 1 which 1}
    te = _ir.terms('text');
    te.each((term, doc_freq) {
      expect(expected.shift, equals(term));
      expect(expected.shift.to_i, equals(doc_freq));
    });

    te = _ir.terms_from('body', "Not");
    expect(te.term, equals("Not"));
    expect(te.doc_freq, equals(1));
    expect(te.next, isNotNull);
    expect(te.term, equals("Random"));
    expect(te.doc_freq, equals(16));
  }

  do_test_term_doc_enum() {
    expect(IndexTestHelper.INDEX_TEST_DOCS.length, equals(_ir.num_docs()));
    expect(IndexTestHelper.INDEX_TEST_DOCS.length, equals(_ir.max_doc()));

    expect(4, equals(_ir.doc_freq('body', "Wally")));

    TermDocEnum tde = _ir.term_docs_for('body', "Wally");

    [
      [0, 1],
      [5, 1],
      [18, 3],
      [20, 6]
    ].forEach((row) {
      var doc = row[0], freq = row[1];
      expect(tde.next, isNotNull);
      expect(tde.doc(), equals(doc));
      expect(tde.freq(), equals(freq));
    });
    expect(tde.next(), isNull);

    tde = _ir.term_docs_for('body', "Wally");
    expect(
        '[{"document":0,"frequency":1},{"document":5,"frequency":1},{"document":18,"frequency":3},{"document":20,"frequency":6}]',
        equals(tde.to_json));
    tde = _ir.term_docs_for('body', "Wally");
    expect(tde.to_json(fast: true), equals('[[0,1],[5,1],[18,3],[20,6]]'));

    do_test_term_docpos_enum_skip_to(tde);

    // test term positions
    tde = _ir.term_positions_for('body', "read");
    [
      [
        false,
        1,
        1,
        [3]
      ],
      [
        false,
        2,
        2,
        [1, 4]
      ],
      [
        false,
        6,
        4,
        [3, 4]
      ],
      [
        false,
        9,
        3,
        [0, 4]
      ],
      [
        true,
        16,
        2,
        [2]
      ],
      [
        true,
        21,
        6,
        [3, 4, 5, 8, 9, 10]
      ]
    ].forEach((row) {
      var skip = row[0], doc = row[1], freq = row[2], positions = row[3];
      if (skip) {
        expect(tde.skip_to(doc), isTrue);
      } else {
        expect(tde.next, isNotNull);
      }
      expect(tde.doc(), equals(doc));
      expect(tde.freq(), equals(freq));
      positions.each((pos) => expect(pos, equals(tde.next_position())));
    });

    expect(tde.next_position(), isNull);
    expect(tde.next, isNotNull);

    tde = _ir.term_positions_for('body', "read");
    expect(
        tde.to_json(),
        equals('[' +
            '{"document":1,"frequency":1,"positions":[3]},' +
            '{"document":2,"frequency":2,"positions":[1,4]},' +
            '{"document":6,"frequency":4,"positions":[3,4,5,6]},' +
            '{"document":9,"frequency":3,"positions":[0,4,13]},' +
            '{"document":10,"frequency":1,"positions":[1]},' +
            '{"document":16,"frequency":2,"positions":[2,3]},' +
            '{"document":17,"frequency":1,"positions":[2]},' +
            '{"document":20,"frequency":1,"positions":[21]},' +
            '{"document":21,"frequency":6,"positions":[3,4,5,8,9,10]}]'));
    tde = _ir.term_positions_for('body', "read");
    expect(
        tde.to_json(fast: true),
        equals('[' +
            '[1,1,[3]],' +
            '[2,2,[1,4]],' +
            '[6,4,[3,4,5,6]],' +
            '[9,3,[0,4,13]],' +
            '[10,1,[1]],' +
            '[16,2,[2,3]],' +
            '[17,1,[2]],' +
            '[20,1,[21]],' +
            '[21,6,[3,4,5,8,9,10]]]'));

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
    ].forEach((row) {
      var skip_doc = row[0], doc_and_freq = row[1];
      expect(tde.skip_to(skip_doc), isTrue);
      expect(tde.doc(), equals(doc_and_freq));
      expect(tde.freq(), equals(doc_and_freq));
    });

    expect(tde.skip_to(IndexTestHelper.INDEX_TEST_DOC_COUNT), isFalse);
    expect(tde.skip_to(IndexTestHelper.INDEX_TEST_DOC_COUNT), isFalse);
    expect(tde.skip_to(IndexTestHelper.INDEX_TEST_DOC_COUNT + 100), isFalse);

    tde.seek('text', "skip");
    expect(tde.skip_to(IndexTestHelper.INDEX_TEST_DOC_COUNT), isFalse);
  }

  do_test_term_vectors() {
    var expected_tv = new TermVector(
        'body',
        [
          new TVTerm("word1", 3, [2, 4, 7]),
          new TVTerm("word2", 1, [3]),
          new TVTerm("word3", 4, [0, 5, 8, 9]),
          new TVTerm("word4", 2, [1, 6])
        ],
        [range(0, 10)].map((i) => new TVOffsets(i * 6, (i + 1) * 6 - 1)));

    var tv = _ir.term_vector(3, 'body');

    expect(tv, equals(expected_tv));

    var tvs = _ir.term_vectors(3);
    expect(tvs.length, equals(3));

    expect(tvs['body'], equals(expected_tv));

    tv = tvs['author'];
    expect(tv.field, equals('author'));
    expect(
        tv.terms,
        equals([
          new TVTerm("Leo", 1, [0]),
          new TVTerm("Tolstoy", 1, [1])
        ]));
    expect(tv.offsets, isNull);

    tv = tvs['title'];
    expect(tv.field, equals('title'));
    expect(tv.terms, equals([new TVTerm("War And Peace", 1, null)]));
    expect(tv.offsets, equals([new TVOffsets(0, 13)]));
  }

  do_test_get_doc() {
    var doc = _ir.get_document(3);
    ['author', 'body', 'title', 'year'].forEach((fn) {
      expect(doc.fields.contains(fn), isTrue);
    });
    expect(doc.fields.length, equals(4));
    expect(doc.length, equals(0));
    expect(doc.keys, equals([]));

    expect(doc['author'], equals("Leo Tolstoy"));
    expect(doc['body'],
        equals("word3 word4 word1 word2 word1 word3 word4 word1 word3 word3"));
    expect(doc['title'], equals("War And Peace"));
    expect(doc['year'], equals("1865"));
    expect(doc['text'], isNull);

    expect(4, equals(doc.length));
    ['author', 'body', 'title', 'year'].forEach((fn) {
      expect(doc.keys.contains(fn), isTrue);
    });
//    expect([_ir[0].load, _ir[1].load, _ir[2].load], _ir[0, 3].collect((d) => d.load());
//    expect([_ir[61].load, _ir[62].load, _ir[63].load], _ir[61, 100].collect((d) => d.load());
//    expect([_ir[0].load, _ir[1].load, _ir[2].load], _ir[0..2].collect((d) => d.load());
//    expect([_ir[61].load, _ir[62].load, _ir[63].load], _ir[range(61, 100)].collect((d) => d.load));
    expect(_ir[-60], _ir[4]);
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

    var norms = _ir.norms('text');

    expect(norms.codeUnitAt(3), equals(202));
    expect(norms.codeUnitAt(25), equals(20));
    expect(norms.codeUnitAt(50), equals(200));
    expect(norms.codeUnitAt(63), equals(155));

    norms = _ir.norms('title');
    expect(norms.codeUnitAt(3), equals(1));

    norms = _ir.norms('body');
    expect(norms.codeUnitAt(3), equals(12));

    norms = _ir.norms('author');
    expect(norms.codeUnitAt(3), equals(145));

    norms = _ir.norms('year');
    // TODO: this returns two possible results depending on whether it is
    // a multi reader or a segment reader. If it is a multi reader it will
    // always return an empty set of norms, otherwise it will return nil.
    // I'm not sure what to do here just yet or if this is even an issue.
    //expect(norms.nil?);

    norms = " " * 164;
    _ir.get_norms_into('text', norms, 100);
    expect(norms.codeUnitAt(103), equals(202));
    expect(norms.codeUnitAt(125), equals(20));
    expect(norms.codeUnitAt(150), equals(200));
    expect(norms.codeUnitAt(163), equals(155));

    _ir.commit();

    iw_optimize();

    var ir2 = ir_new();

    norms = " " * 164;
    ir2.get_norms_into('text', norms, 100);
    expect(norms.codeUnitAt(103), equals(202));
    expect(norms.codeUnitAt(125), equals(20));
    expect(norms.codeUnitAt(150), equals(200));
    expect(norms.codeUnitAt(163), equals(155));
    ir2.close();
  }

  test_ir_delete() {
    var doc_count = IndexTestHelper.INDEX_TEST_DOCS.length;
    _ir.delete(1000); // non existant doc_num
    expect(_ir.has_deletions(), isFalse);
    expect(_ir.max_doc(), equals(doc_count));
    expect(_ir.num_docs(), equals(doc_count));
    expect(_ir.deleted(10), isFalse);

    [
      [10, doc_count - 1],
      [10, doc_count - 1],
      [doc_count - 1, doc_count - 2],
      [doc_count - 2, doc_count - 3],
    ].forEach((row) {
      var del_num = row[0], num_docs = row[1];
      _ir.delete(del_num);
      expect(_ir.has_deletions(), isTrue);
      expect(_ir.max_doc(), equals(doc_count));
      expect(_ir.num_docs(), equals(num_docs));
      expect(_ir.deleted(del_num), isTrue);
    });

    _ir.undelete_all();
    expect(_ir.has_deletions(), isFalse);
    expect(_ir.max_doc(), equals(doc_count));
    expect(_ir.num_docs(), equals(doc_count));
    expect(_ir.deleted(10), isFalse);
    expect(_ir.deleted(doc_count - 2), isFalse);
    expect(_ir.deleted(doc_count - 1), isFalse);

    var del_list = [10, 20, 30, 40, 50, doc_count - 1];

    del_list.forEach((doc_num) => _ir.delete(doc_num));
    expect(_ir.has_deletions(), isTrue);
    expect(_ir.max_doc(), equals(doc_count));
    expect(_ir.num_docs(), equals(doc_count - del_list.length));
    del_list.forEach((doc_num) {
      expect(_ir.deleted(doc_num), isTrue);
    });

    var ir2 = ir_new();
    expect(ir2.has_deletions(), isFalse);
    expect(ir2.max_doc(), equals(doc_count));
    expect(ir2.num_docs(), equals(doc_count));

    _ir.commit();

    expect(ir2.has_deletions(), isFalse);
    expect(ir2.max_doc(), equals(doc_count));
    expect(ir2.num_docs(), equals(doc_count));

    ir2.close();
    ir2 = ir_new();
    expect(ir2.has_deletions(), isTrue);
    expect(ir2.max_doc(), equals(doc_count));
    expect(ir2.num_docs(), equals(doc_count - 6));
    del_list.forEach((doc_num) {
      expect(ir2.deleted(doc_num), isTrue);
    });

    ir2.undelete_all();
    expect(ir2.has_deletions(), isFalse);
    expect(ir2.max_doc(), equals(doc_count));
    expect(ir2.num_docs(), equals(doc_count));
    del_list.forEach((doc_num) {
      expect(ir2.deleted(doc_num), isFalse);
    });

    del_list.forEach((doc_num) {
      expect(_ir.deleted(doc_num), isTrue);
    });

    ir2.commit();

    del_list.forEach((doc_num) {
      expect(_ir.deleted(doc_num), isTrue);
    });

    del_list.forEach((doc_num) => ir2.delete(doc_num));
    ir2.commit();

    iw_optimize();

    var ir3 = ir_new();

    expect(ir3.has_deletions(), isFalse);
    expect(ir3.max_doc(), equals(doc_count - 6));
    expect(ir3.num_docs(), equals(doc_count - 6));

    ir2.close();
    ir3.close();
  }

  test_latest() {
    expect(_ir.latest, isTrue);
    var ir2 = ir_new();
    expect(ir2.latest, isTrue);

    ir2.delete(0);
    ir2.commit();
    expect(ir2.latest, isTrue);
    expect(_ir.latest, isFalse);

    ir2.close();
  }

  IndexReader ir_new();

  void iw_optimize();
}

class MultiReaderTest extends IndexReaderCommon {
  //< Test::Unit::TestCase
  //include
  Directory _dir;

  ir_new() {
    new IndexReader(_ferret, _dir);
  }

  iw_optimize() {
    var iw =
        new IndexWriter(_ferret, dir: _dir, analyzer: new WhiteSpaceAnalyzer());
    iw.optimize();
    iw.close();
  }

  setup() {
    _dir = new RAMDirectory(_ferret);

    var iw = new IndexWriter(_ferret,
        dir: _dir,
        analyzer: new WhiteSpaceAnalyzer(_ferret),
        create: true,
        field_infos: IndexTestHelper.INDEX_TEST_FIS,
        max_buffered_docs: 15);
    IndexTestHelper.INDEX_TEST_DOCS.each((doc) => iw.add_document(doc));

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

class MultiExternalReaderTest extends IndexReaderCommon {
  //< Test::Unit::TestCase
  //include IndexReaderCommon
  List<Directory> _dirs;

  ir_new() {
    var readers = _dirs.map((dir) => new IndexReader(_ferret, dir));
    new IndexReader(_ferret, readers);
  }

  iw_optimize() {
    _dirs.forEach((dir) {
      var iw = new IndexWriter(_ferret,
          dir: dir, analyzer: new WhiteSpaceAnalyzer(_ferret));
      iw.optimize();
      iw.close();
    });
  }

  setup() {
    _dirs = [];

    [
      [0, 10],
      [10, 30],
      [30, IndexTestHelper.INDEX_TEST_DOCS.length]
    ].forEach((row) {
      var start = row[0], finish = row[1];
      var dir = new RAMDirectory(_ferret);
      _dirs.add(dir);

      var iw = new IndexWriter(_ferret,
          dir: dir,
          analyzer: new WhiteSpaceAnalyzer(_ferret),
          create: true,
          field_infos: IndexTestHelper.INDEX_TEST_FIS);
      range(start, finish).forEach((doc_id) {
        iw.add_document(IndexTestHelper.INDEX_TEST_DOCS[doc_id]);
      });
      iw.close();
    });
    _ir = ir_new();
  }

  teardown() {
    _ir.close();
    _dirs.forEach((dir) => dir.close());
  }
}

class MultiExternalReaderDirTest extends IndexReaderCommon {
  //< Test::Unit::TestCase
  //include
  List<Directory> _dirs;

  ir_new() {
    return new IndexReader(_ferret, _dirs);
  }

  iw_optimize() {
    _dirs.forEach((dir) {
      var iw = new IndexWriter(_ferret,
          dir: dir, analyzer: new WhiteSpaceAnalyzer(_ferret));
      iw.optimize();
      iw.close();
    });
  }

  setup() {
    _dirs = [];

    [
      [0, 10],
      [10, 30],
      [30, IndexTestHelper.INDEX_TEST_DOCS.length]
    ].forEach((row) {
      var start = row[0], finish = row[1];
      var dir = new RAMDirectory(_ferret);
      _dirs.add(dir);

      var iw = new IndexWriter(_ferret,
          dir: dir,
          analyzer: new WhiteSpaceAnalyzer(_ferret),
          create: true,
          field_infos: IndexTestHelper.INDEX_TEST_FIS);
      range(start, finish).forEach((doc_id) {
        iw.add_document(IndexTestHelper.INDEX_TEST_DOCS[doc_id]);
      });
      iw.close();
    });
    _ir = ir_new();
  }

  teardown() {
    _ir.close();
    _dirs.forEach((dir) => dir.close());
  }
}

class MultiExternalReaderPathTest extends IndexReaderCommon {
  //< Test::Unit::TestCase
  //include
  List<String> _paths;

  ir_new() {
    return new IndexReader(_ferret, _paths);
  }

  iw_optimize() {
    _paths.forEach((path) {
      var iw = new IndexWriter(_ferret,
          path: path, analyzer: new WhiteSpaceAnalyzer(_ferret));
      iw.optimize();
      iw.close();
    });
  }

  setup() {
    var base_dir = File
        .expand_path(File.join(File.dirname(__FILE__), '../../temp/multidir'));
    FileUtils.mkdir_p(base_dir);
    _paths = [
      File.join(base_dir, "i1"),
      File.join(base_dir, "i2"),
      File.join(base_dir, "i3")
    ];

    int i = 0;
    [
      [0, 10],
      [10, 30],
      [30, IndexTestHelper.INDEX_TEST_DOCS.length]
    ].each_with_index((row) {
      var start = row[0], finish = row[1];
      var path = _paths[i];

      var iw = new IndexWriter(_ferret,
          path: path,
          analyzer: new WhiteSpaceAnalyzer(_ferret),
          create: true,
          field_infos: IndexTestHelper.INDEX_TEST_FIS);
      range(start, finish).forEach((doc_id) {
        iw.add_document(IndexTestHelper.INDEX_TEST_DOCS[doc_id]);
      });
      iw.close();
      i++;
    });
    _ir = ir_new();
  }

  teardown() {
    _ir.close();
  }
}

class IndexReaderTest {
  //< Test::Unit::TestCase
  //include Ferret::Index
  //include Ferret::Analysis
  Ferret _ferret;
  Directory _dir, _fs_dir;
  String _fs_dpath;

  setup() {
    _dir = new RAMDirectory(_ferret);
  }

  teardown() {
    _dir.close();
  }

  test_ir_multivalue_fields() {
    _fs_dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    _fs_dir = new FSDirectory(_ferret, _fs_dpath, create: true);

    var iw = new IndexWriter(_ferret,
        dir: _fs_dir, analyzer: new WhiteSpaceAnalyzer(_ferret), create: true);
    var doc = {
      'tag': ["Ruby", "C", "Lucene", "Ferret"],
      'body': "this is the body Document Field",
      'title': "this is the title DocField",
      'author': "this is the author field"
    };
    iw.add_document(doc);

    iw.close();

    _dir = new RAMDirectory(_ferret, dir: _fs_dir);
    var ir = new IndexReader(_ferret, _dir);
    expect(doc, ir.get_document(0).load);
    ir.close();
  }

  do_test_term_vectors(ir) {
    var expected_tv = new TermVector(
        'body',
        [
          new TVTerm("word1", 3, [2, 4, 7]),
          new TVTerm("word2", 1, [3]),
          new TVTerm("word3", 4, [0, 5, 8, 9]),
          new TVTerm("word4", 2, [1, 6])
        ],
        [range(0, 10)].map((i) => new TVOffsets(i * 6, (i + 1) * 6 - 1)));

    var tv = ir.term_vector(3, 'body');

    expect(expected_tv, equals(tv));

    var tvs = ir.term_vectors(3);
    expect(3, equals(tvs.length));

    expect(expected_tv, equals(tvs['body']));

    tv = tvs['author'];
    expect('author', equals(tv.field));
    expect([
      new TVTerm("Leo", 1, [0]),
      new TVTerm("Tolstoy", 1, [1])
    ], equals(tv.terms));
    expect(tv.offsets, isNull);

    tv = tvs['title'];
    expect('title', equals(tv.field));
    expect([new TVTerm("War And Peace", 1, null)], equals(tv.terms));
    expect([new TVOffsets(0, 13)], equals(tv.offsets));
  }

  do_test_ir_read_while_optimizing(dir) {
    var iw = new IndexWriter(_ferret,
        dir: dir,
        analyzer: new WhiteSpaceAnalyzer(_ferret),
        create: true,
        field_infos: IndexTestHelper.INDEX_TEST_FIS);

    IndexTestHelper.INDEX_TEST_DOCS.each((doc) => iw.add_document(doc));

    iw.close();

    var ir = new IndexReader(_ferret, dir);
    do_test_term_vectors(ir);

    iw = new IndexWriter(_ferret,
        dir: dir, analyzer: new WhiteSpaceAnalyzer(_ferret));
    iw.optimize();
    iw.close();

    do_test_term_vectors(ir);

    ir.close();
  }

  test_ir_read_while_optimizing() {
    do_test_ir_read_while_optimizing(_dir);
  }

  test_ir_read_while_optimizing_on_disk() {
    var dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    var fs_dir = new FSDirectory(_ferret, dpath, create: true);
    do_test_ir_read_while_optimizing(fs_dir);
    fs_dir.close();
  }

  test_latest() {
    var dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    var fs_dir = new FSDirectory(_ferret, dpath, create: true);

    var iw = new IndexWriter(_ferret,
        dir: fs_dir, analyzer: new WhiteSpaceAnalyzer(_ferret), create: true);
    iw.add_document({'field': "content"});
    iw.close();

    var ir = new IndexReader(_ferret, fs_dir);
    expect(ir.latest, isTrue);

    iw = new IndexWriter(_ferret,
        dir: fs_dir, analyzer: new WhiteSpaceAnalyzer(_ferret));
    iw.add_document({'field': "content2"});
    iw.close();

    expect(ir.latest, isFalse);

    ir.close();
    ir = new IndexReader(_ferret, fs_dir);
    expect(ir.latest, isTrue);
    ir.close();
  }
}
