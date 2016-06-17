library ferret.test.index;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

check_results(index, query, expected) {
  var cnt = 0;
  print("${query} - ${expected.inspect}");
  print(index.length);
  index.search_each(query).forEach((doc, score) {
    print("doc-${doc} score=${score}");
    expect(expected.index(doc), isNotNull,
        reason: "doc ${doc} found but not expected");
    cnt += 1;
  });
  expect(expected.length, cnt);
}

do_test_index_with_array(index) {
  [
    ["one two"],
    ["one", "three"],
    ["two"],
    ["one", "four"],
    ["one two"],
    ["two", "three", "four"],
    ["one"],
    ["two", "three", "four", "five"]
  ].forEach((doc) => index.add(doc));
  expect(8, equals(index.length));
  var q = "one";
  check_results(index, q, [0, 1, 3, 4, 6]);
  q = "one AND two";
  check_results(index, q, [0, 4]);
  q = "one OR five";
  check_results(index, q, [0, 1, 3, 4, 6, 7]);
  expect("two three four five", equals(index.doc(7)['xxx']));
}

do_test_index_with_hash(index) {
  var data = [
    {'xxx': "one two"},
    {'xxx': "one", 'field2': "three"},
    {'xxx': "two"},
    {'xxx': "one", 'field2': "four"},
    {'xxx': "one two"},
    {'xxx': "two", 'field2': "three", 'field3': "four"},
    {'xxx': "one"},
    {'xxx': "two", 'field2': "three", 'field3': "five"}
  ];
  data.forEach((doc) => index.add(doc));
  var q = "one AND two";
  check_results(index, q, [0, 4]);
  q = "one OR five";
  check_results(index, q, [0, 1, 3, 4, 6]);
  q = "one OR field3:five";
  check_results(index, q, [0, 1, 3, 4, 6, 7]);
  expect("four", index[5]["field3"]);
  q = "field3:f*";
  check_results(index, q, [5, 7]);
  q = "*:(one AND NOT three)";
  check_results(index, q, [0, 3, 4, 6]);
  q = "*:(one AND (NOT three))";
  check_results(index, q, [0, 3, 4, 6]);
  q = "two AND field3:f*";
  check_results(index, q, [5, 7]);
  expect("five", equals(index.doc(7)["field3"]));
  expect("two", equals(index.doc(7)['xxx']));
}

do_test_index_with_doc_array(index) {
  var data = [
    {'xxx': "one two multi", 'id': "myid"},
    {'xxx': "one", 'field2': "three multi"},
    {'xxx': "two"},
    {'xxx': "one", 'field2': "four"},
    {'xxx': "one two"},
    {'xxx': "two", 'field2': "three", 'field3': "four"},
    {'xxx': "one multi2", 'id': "hello"},
    {'xxx': "two", 'field2': "this three multi2", 'field3': "five multi"}
  ];
  data.forEach((doc) => index.add(doc));
  var q = "one AND two";
  check_results(index, q, [0, 4]);
  q = "one OR five";
  check_results(index, q, [0, 1, 3, 4, 6]);
  q = "one OR field3:five";
  check_results(index, q, [0, 1, 3, 4, 6, 7]);
  q = "two AND (field3:f*)";
  check_results(index, q, [5, 7]);
  q = "*:(multi OR multi2)";
  check_results(index, q, [0, 1, 6, 7]);
  q = "field2|field3:(multi OR multi2)";
  check_results(index, q, [1, 7]);
  var doc = index[5];
  expect("three", equals(index[5]["field2"]));
  expect(index.has_deletions(), isFalse);
  expect(index.deleted(5), isFalse);
  expect(8, equals(index.length));
  index.deleteAndClose(5);
  expect(index.has_deletions(), isTrue);
  expect(index.deleted(5), isTrue);
  expect(7, equals(index.length));
  q = "two AND (field3:f*)";
  check_results(index, q, [7]);

  doc.load();
  doc['field2'] = "dave";
  index.add(doc);
  check_results(index, q, [7, 8]);
  check_results(index, "*:this", []);
  expect(8, equals(index.length));
  expect("dave", equals(index[8]['field2']));
  index.optimize();
  check_results(index, q, [6, 7]);
  expect("dave", equals(index[7]['field2']));
  index.query_delete("field2:three");
  expect(index.deleted(1), isTrue);
  expect(index.deleted(6), isTrue);
  expect(!index.deleted(7), isTrue);
  expect("one multi2", equals(index["hello"]['xxx']));
  expect("one two multi", equals(index["myid"]['xxx']));
  index.deleteAndClose("myid");
  expect(index.deleted(0), isTrue);
}

test_ram_index(Ferret ferret) {
  var index = new Index(ferret, default_input_field: 'xxx');
  do_test_index_with_array(index);
  index.close();

  index = new Index(ferret, default_field: 'xxx');
  do_test_index_with_hash(index);
  index.close();

  index = new Index(ferret, default_field: 'xxx', id_field: 'id');
  do_test_index_with_doc_array(index);
  index.close();
}

test_fs_index(Ferret ferret) {
  var fs_path =
      File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));

  Dir[File.join(fs_path, "*")].each((path) {
    try {
      File.deleteAndClose(path);
    } catch (_) {}
    assert_raise(FileNotFoundError, () {
      new Index(ferret,
          path: fs_path, create_if_missing: false, default_field: 'xxx');
    });
  });

  var index = new Index(ferret, path: fs_path, default_input_field: 'xxx');
  do_test_index_with_array(index);
  index.close();

  Dir[File.join(fs_path, "*")].each((path) {
    try {
      File.deleteAndClose(path);
    } catch (_) {}
  });
  index = new Index(ferret, path: fs_path, default_field: 'xxx');
  do_test_index_with_hash(index);
  index.close();

  Dir[File.join(fs_path, "*")].each((path) {
    try {
      File.deleteAndClose(path);
    } catch (_) {}
  });
  index =
      new Index(ferret, path: fs_path, default_field: 'xxx', id_field: "id");
  do_test_index_with_doc_array(index);
  index.close();
}

test_fs_index_is_persistant(Ferret ferret) {
  var fs_path =
      File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
  var index =
      new Index(ferret, path: fs_path, default_field: 'xxx', create: true);

  [
    {'xxx': "one two", 'id': "me"},
    {'xxx': "one", 'field2': "three"},
    {'xxx': "two"},
    {'xxx': "one", 'field2': "four"},
    {'xxx': "one two"},
    {'xxx': "two", 'field2': "three", 'field3': "four"},
    {'xxx': "one"},
    {'xxx': "two", 'field2': "three", 'field3': "five"}
  ].forEach((doc) => index.add_document(doc));
  expect(8, equals(index.size));
  index.close();

  index = new Index(ferret, path: fs_path, create_if_missing: false);
  expect(8, equals(index.size));
  expect("four", equals(index[5]["field3"]));
  index.close();
}

test_key_used_for_id_field(Ferret ferret) {
  var fs_path =
      File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));

  var index = new Index(ferret, path: fs_path, key: 'my_id', create: true);
  [
    {'my_id': "three", 'id': "me"},
    {'my_id': "one", 'field2': "three"},
    {'my_id': "two"},
    {'my_id': "one", 'field2': "four"},
    {'my_id': "three"},
    {'my_id': "two", 'field2': "three", 'field3': "four"},
    {'my_id': "one"},
    {'my_id': "two", 'field2': "three", 'field3': "five"}
  ].forEach((doc) => index.add_document(doc));
  index.optimize();
  expect(3, equals(index.size));
  expect("three", equals(index["two"]['field2']));
  index.close();
}

test_merging_indexes(Ferret ferret) {
  var index1 = new Index(ferret, default_field: 'f');
  var index2 = new Index(ferret, default_field: 'f');
  var index3 = new Index(ferret, default_field: 'f');

  [
    {'f': "zero"},
    {'f': "one"},
    {'f': "two"}
  ].forEach((doc) => index1.add_document(doc));
  [
    {'f': "three"},
    {'f': "four"},
    {'f': "five"}
  ].forEach((doc) => index2.add_document(doc));
  [
    {'f': "six"},
    {'f': "seven"},
    {'f': "eight"}
  ].forEach((doc) => index3.add_document(doc));

  var index = new Index(ferret, default_field: 'f');
  index.add_indexes([index1]);
  expect(3, equals(index.size));
  expect("zero", equals(index[0]['f']));
  index.add_indexes([index2, index3]);
  expect(9, equals(index.size));
  expect("zero", equals(index[0]['f']));
  expect("eight", equals(index[8]['f']));
  index1.close();
  index2.close();
  index3.close();
  expect("seven", equals(index[7]['f']));
  var data = [
    {'f': "alpha"},
    {'f': "beta"},
    {'f': "charlie"}
  ];
  var dir1 = new RAMDirectory(ferret);
  index1 = new Index(ferret, dir: dir1, default_field: 'f');
  data.forEach((doc) => index1.add_document(doc));
  index1.flush();
  data = [
    {'f': "delta"},
    {'f': "echo"},
    {'f': "foxtrot"}
  ];
  var dir2 = new RAMDirectory(ferret);
  index2 = new Index(ferret, dir: dir2, default_field: 'f');
  data.forEach((doc) => index2.add_document(doc));
  index2.flush();
  data = [
    {'f': "golf"},
    {'f': "india"},
    {'f': "juliet"}
  ];
  var dir3 = new RAMDirectory(ferret);
  index3 = new Index(ferret, dir: dir3, default_field: 'f');
  data.forEach((doc) => index3.add_document(doc));
  index3.flush();

  index.add_indexes([dir1]);
  expect(12, equals(index.size));
  expect("alpha", equals(index[9]['f']));
  index.add_indexes([dir2, dir3]);
  expect(18, equals(index.size));
  expect("juliet", equals(index[17]['f']));
  index1.close();
  dir1.close();
  index2.close();
  dir2.close();
  index3.close();
  dir3.close();
  expect("golf", equals(index[15]['f']));
  index.close();
}

test_persist_index(Ferret ferret) {
  var data = [
    {'f': "zero"},
    {'f': "one"},
    {'f': "two"}
  ];
  var index = new Index(ferret, default_field: 'f');
  data.forEach((doc) => index.add_document(doc));
  var fs_path =
      File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));

  index.persist(fs_path, true);
  expect(3, equals(index.size));
  expect("zero", equals(index[0]['f']));
  index.close();

  index = new Index(ferret, path: fs_path);
  expect(3, equals(index.size));
  expect("zero", equals(index[0]['f']));
  index.close();

  data = [
    {'f': "romeo"},
    {'f': "sierra"},
    {'f': "tango"}
  ];
  index = new Index(ferret, default_field: 'f');
  data.forEach((doc) => index.add_document(doc));
  expect(3, equals(index.size));
  expect("romeo", equals(index[0]['f']));
  var dir = new FSDirectory(ferret, fs_path, create: false);
  index.persist(dir);
  expect(6, equals(index.size));
  expect("zero", equals(index[0]['f']));
  expect("romeo", equals(index[3]['f']));
  index.close();

  index = new Index(ferret, path: fs_path);
  expect(6, equals(index.size));
  expect("zero", equals(index[0]['f']));
  expect("romeo", equals(index[3]['f']));
  index.close();
}

test_auto_update_when_externally_modified(Ferret ferret) {
  var fs_path =
      File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
  var index =
      new Index(ferret, path: fs_path, default_field: 'f', create: true);
  index.add_document("document 1");
  expect(1, equals(index.size));

  var index2 = new Index(ferret, path: fs_path, default_field: 'f');
  expect(1, equals(index2.size));
  index2.add_document("document 2");
  expect(2, equals(index2.size));
  expect(2, equals(index.size));
  var top_docs = index.search("content3");

  expect(0, equals(top_docs.hits.length));

  var iw = new IndexWriter(ferret,
      path: fs_path, analyzer: new WhiteSpaceAnalyzer(ferret));
  iw.add_document({'f': "content3"});
  iw.close();

  top_docs = index.search("content3");
  expect(1, equals(top_docs.hits.length));
  expect(3, equals(index.size));
  expect("content3", equals(index[2]['f']));
  index2.close();
  index.close();
}

test_delete(Ferret ferret) {
  var index = new Index(ferret, analyzer: new WhiteSpaceAnalyzer(ferret));
  [
    {'id': 0, 'cat': "/cat1/subcat1"},
    {'id': 1, 'cat': "/cat1/subcat2"},
    {'id': 2, 'cat': "/cat1/subcat2"},
    {'id': 3, 'cat': "/cat1/subcat3"},
    {'id': 4, 'cat': "/cat1/subcat4"},
    {'id': 5, 'cat': "/cat2/subcat1"},
    {'id': 6, 'cat': "/cat2/subcat2"},
    {'id': 7, 'cat': "/cat2/subcat3"},
    {'id': 8, 'cat': "/cat2/subcat4"},
    {'id': 9, 'cat': "/cat2/subcat5"},
  ].forEach((doc) => index.add_document(doc));
  expect(10, equals(index.size));
  expect(1, equals(index.search("id:9").total_hits));
  index.delete(9);
  expect(9, equals(index.size));
  expect(0, equals(index.search("id:9").total_hits));
  expect(1, equals(index.search("id:8").total_hits));
  index.delete("8");
  expect(8, equals(index.size));
  expect(0, equals(index.search("id:8").total_hits));
  expect(5, equals(index.search("cat:/cat1*").total_hits));
  index.query_delete("cat:/cat1*");
  expect(3, equals(index.size));
  expect(0, equals(index.search("cat:/cat1*").total_hits));
  index.close();
}

test_update(Ferret ferret) {
  var index = new Index(ferret,
      analyzer: new WhiteSpaceAnalyzer(ferret),
      default_input_field: 'content',
      id_field: 'id');
  [
    {'id': 0, 'cat': "/cat1/subcat1", 'content': "content0"},
    {'id': 1, 'cat': "/cat1/subcat2", 'content': "content1"},
    {'id': 2, 'cat': "/cat1/subcat2", 'content': "content2"},
    {'id': 3, 'cat': "/cat1/subcat3", 'content': "content3"},
    {'id': 4, 'cat': "/cat1/subcat4", 'content': "content4"},
    {'id': 5, 'cat': "/cat2/subcat1", 'content': "content5"},
    {'id': 6, 'cat': "/cat2/subcat2", 'content': "content6"},
    {'id': 7, 'cat': "/cat2/subcat3", 'content': "content7"},
    {'id': 8, 'cat': "/cat2/subcat4", 'content': "content8"},
    {'id': 9, 'cat': "/cat2/subcat5", 'content': "content9"},
  ].forEach((doc) => index.add_document(doc));
  expect(10, equals(index.size));
  expect("content5", equals(index["5"]['content']));
  index.query_update("id:5", {'content': "content five"});
  expect("content five", equals(index["5"]['content']));
  expect(index["5"]['extra_content'], isNull);
  index.update("5", {
    'id': "5",
    'cat': "/cat1/subcat6",
    'content': "high five",
    'extra_content': "hello"
  });
  expect("hello", equals(index["5"]['extra_content']));
  expect("high five", equals(index["5"]['content']));
  expect("/cat1/subcat6", equals(index["5"]['cat']));
  expect("content9", equals(index["9"]['content']));
  index.query_update("content:content9", {'content': "content nine"});
  expect("content nine", equals(index["9"]['content']));
  expect("content0", equals(index["0"]['content']));
  expect(index["0"]['extra_content'], isNull);
  var document = index[0].load();
  document['content'] = "content zero";
  document['extra_content'] = "extra content";
  index.update(0, document);
  expect("content zero", equals(index["0"]['content']));
  expect("extra content", equals(index["0"]['extra_content']));
  expect(index["1"]['tag'], isNull);
  expect(index["2"]['tag'], isNull);
  expect(index["3"]['tag'], isNull);
  expect(index["4"]['tag'], isNull);
  index.query_update("id:<5 AND cat:>=/cat1/subcat2", {'tag': "cool"});
  expect("cool", equals(index["1"]['tag']));
  expect("cool", equals(index["2"]['tag']));
  expect("cool", equals(index["3"]['tag']));
  expect("cool", equals(index["4"]['tag']));
  expect(4, equals(index.search("tag:cool").total_hits));
  index.close();
}

test_index_key(Ferret ferret) {
  var data = [
    {'id': 0, 'val': "one"},
    {'id': 0, 'val': "two"},
    {'id': 1, 'val': "three"},
    {'id': 1, 'val': "four"},
  ];
  var index =
      new Index(ferret, analyzer: new WhiteSpaceAnalyzer(ferret), key: 'id');
  data.forEach((doc) => index.add_document(doc));
  expect(2, equals(index.size));
  expect("two", equals(index["0"]['val']));
  expect("four", equals(index["1"]['val']));
  index.close();
}

test_index_key_batch0(Ferret ferret) {
  var data = {
    //"0": {'id': "0", 'val': "one"},
    "0": {'id': "0", 'val': "two"},
    //"1": {'id': "1", 'val': "three"},
    "1": {'id': "1", 'val': "four"},
  };

  var index =
      new Index(ferret, analyzer: new WhiteSpaceAnalyzer(ferret), key: 'id');
  index.batch_update(data);
  expect(2, equals(index.size()));
  index.close();
}

test_index_key_batch1(Ferret ferret) {
  var data0 = {
    //"0" => {'id': "0", 'val': "one"},
    "0": {'id': "0", 'val': "two"},
    "1": {'id': "1", 'val': "three"},
    "2": {'id': "1", 'val': "four"},
  };

  var data1 = {
    "0": {'id': "0", 'val': "one"},
    "3": {'id': "3", 'val': "two"},
    "2": {'id': "2", 'val': "three"},
    "1": {'id': "1", 'val': "four"},
    "4": {'id': "4", 'val': "four"},
  };

  var index =
      new Index(ferret, analyzer: new WhiteSpaceAnalyzer(ferret), key: 'id');
  index.batch_update(data0);
  expect(3, equals(index.size));
  index.batch_update(data1);
  expect(5, equals(index.size));
  index.close();
}

test_index_key_delete_batch0(Ferret ferret) {
  var data0 = {
    "1": {'id': "1", 'val': "three"},
    "2": {'id': "2", 'val': "four"},
    "0": {'id': "0", 'val': "four"},
  };

  var data1 = ["0", "1"];

  var index =
      new Index(ferret, analyzer: new WhiteSpaceAnalyzer(ferret), key: 'id');
  index.batch_update(data0);

  expect("four", equals(index["0"]['val']));
  expect("three", equals(index["1"]['val']));
  expect("four", equals(index["2"]['val']));

  expect(3, equals(index.size));
  index.delete(data1);
  expect(1, equals(index.size));
  expect("four", equals(index["2"]['val']));

  index.close();
}

test_index_key_delete_batch1(Ferret ferret) {
  var index = new Index(ferret, analyzer: new WhiteSpaceAnalyzer(ferret));
  range(1000).forEach(
      (i) => index.add_document({'id': "${i}", 'content': "content ${i}"}));
  expect(1000, equals(index.size));
  expect("content 876", equals(index['876']['content']));

  var new_docs =
      new List.generate(1000, (i) => {'id': i, 'content': "$i > content"});
  index.batch_update(new_docs);
  expect(1000, equals(index.size));
  expect("128 > content", equals(index['128']['content']));

  new_docs =
      new List.generate(1000, (i) => {'id': i.to_s, 'content': "_(${i})_"});
  index.batch_update(new_docs);
  expect(1000, equals(index.size));
  expect("_(287)_", equals(index['287']['content']));

  new_docs = {};
  range(1000).forEach(
      (i) => new_docs[i.toString()] = {'id': i, 'content': "Hash(${i})"});
  index.batch_update(new_docs);
  expect(1000, equals(index.size));
  expect("Hash(78)", equals(index['78']['content']));
}

test_index_multi_key(Ferret ferret) {
  var index = new Index(ferret,
      analyzer: new WhiteSpaceAnalyzer(ferret), key: ['id', 'table']);
  [
    {'id': 0, 'table': "product", 'product': "tent"},
    {'id': 0, 'table': "location", 'location': "first floor"},
    {'id': 0, 'table': "product", 'product': "super tent"},
    {'id': 0, 'table': "location", 'location': "second floor"},
    {'id': 1, 'table': "product", 'product': "backback"},
    {'id': 1, 'table': "location", 'location': "second floor"},
    {'id': 1, 'table': "location", 'location': "first floor"},
    {'id': 1, 'table': "product", 'product': "rucksack"},
    {'id': 1, 'table': "product", 'product': "backpack"}
  ].forEach((doc) => index.add_document(doc));
  index.optimize();
  expect(4, equals(index.size));
  expect("super tent", equals(index[0]['product']));
  expect("second floor", equals(index[1]['location']));
  expect("backpack", equals(index[3]['product']));
  expect("first floor", equals(index[2]['location']));
  index.close();
}

test_index_multi_key_untokenized(Ferret ferret) {
  var field_infos = new FieldInfos(ferret, term_vector: TermVectorStorage.NO);
  field_infos.add_field('id', index: FieldIndexing.UNTOKENIZED);
  field_infos.add_field('table', index: FieldIndexing.UNTOKENIZED);

  var index = new Index(ferret,
      analyzer: new Analyzer(ferret),
      key: ['id', 'table'],
      field_infos: field_infos);
  [
    {'id': 0, 'table': "Product", 'product': "tent"},
    {'id': 0, 'table': "location", 'location': "first floor"},
    {'id': 0, 'table': "Product", 'product': "super tent"},
    {'id': 0, 'table': "location", 'location': "second floor"},
    {'id': 1, 'table': "Product", 'product': "backback"},
    {'id': 1, 'table': "location", 'location': "second floor"},
    {'id': 1, 'table': "location", 'location': "first floor"},
    {'id': 1, 'table': "Product", 'product': "rucksack"},
    {'id': 1, 'table': "Product", 'product': "backpack"}
  ].forEach((doc) => index.add_document(doc));

  expect(4, equals(index.size()));
  index.optimize();
  expect("super tent", equals(index[0]['product']));
  expect("second floor", equals(index[1]['location']));
  expect("backpack", equals(index[3]['product']));
  expect("first floor", equals(index[2]['location']));
  index.close();
}

test_sortby_date(Ferret ferret) {
  var index = new Index(ferret, analyzer: new WhiteSpaceAnalyzer(ferret));

  [
    {'content': "one", 'date': "20051023"},
    {'content': "two", 'date': "19530315"},
    {'content': "three four", 'date': "19390912"},
    {'content': "one", 'date': "19770905"},
    {'content': "two", 'date': "19810831"},
    {'content': "three", 'date': "19790531"},
    {'content': "one", 'date': "19770725"},
    {'content': "two", 'date': "19751226"},
    {'content': "four", 'date': "19390912"}
  ].forEach((doc) => index.add_document(doc));

  var sf_date = new SortField(ferret, "date", type: SortType.INTEGER);
  //top_docs = index.search("one", sort: [sf_date, SortField::SCORE]);
  var top_docs =
      index.search("one", sort: new Sort(ferret, sort_fields: ["date"]));
  expect(3, equals(top_docs.total_hits));
  expect("19770725", equals(index[top_docs.hits[0].doc]['date']));
  expect("19770905", equals(index[top_docs.hits[1].doc]['date']));
  expect("20051023", equals(index[top_docs.hits[2].doc]['date']));
  top_docs =
      index.search("one two three four", sort: [sf_date, SortField.SCORE]);

  expect("19390912", equals(index[top_docs.hits[0].doc]['date']));
  expect("three four", equals(index[top_docs.hits[0].doc]['content']));
  expect("19390912", equals(index[top_docs.hits[1].doc]['date']));
  expect("four", equals(index[top_docs.hits[1].doc]['content']));
  expect("19530315", equals(index[top_docs.hits[2].doc]['date']));

  top_docs = index.search("one two three four", sort: ['date', 'content']);
  expect("19390912", equals(index[top_docs.hits[0].doc]['date']));
  expect("four", equals(index[top_docs.hits[0].doc]['content']));
  expect("19390912", equals(index[top_docs.hits[1].doc]['date']));
  expect("three four", equals(index[top_docs.hits[1].doc]['content']));
  expect("19530315", equals(index[top_docs.hits[2].doc]['date']));

  index.close();
}

// this test has been corrected to work as intended
// it now fails the same way on both 1.8 and 1.9 -- sds
test_auto_flush(Ferret ferret) {
  var fs_path =
      File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
  Dir[File.join(fs_path, "*")].each((path) {
    try {
      File.deleteAndClose(path);
    } catch (_) {}
  });

  var data = "one two three four five six seven eight nine ten eleven twelve"
      .split(" ");
  var index1 = new Index(ferret, path: fs_path, auto_flush: true, key: 'id');
  index1.add_document({'id': 0, 'content': "zero"});
  var index2 = new Index(ferret, path: fs_path, auto_flush: true);
  try {
    var n = 1;
    data.forEach((datum) {
      index1.add_document({'id': n, 'content': datum});
      index2.add_document({'id': n, 'content': datum});
      n += 1;
    });
    range(5).forEach((i) {
      index1.delete(i);
      index2.delete(i + 5);
    });
    index1.optimize();
    index2.add_document("thirteen");
  } on Exception catch (_) {
    fail("This should not cause an error when auto flush has been set");
  }
  index1.close();
  index2.close();
}

test_doc_specific_analyzer(Ferret ferret) {
  var index = new Index(ferret);
  index.add_document("abc", new Analyzer(ferret));
  expect(1, equals(index.size));
}

test_adding_empty_term_vectors(Ferret ferret) {
  var index = new Index(ferret,
      field_infos: new FieldInfos(ferret, term_vector: TermVectorStorage.NO));

  // Note: Adding keywords to either field1 or field2 gets rid of the error

  index.add_document({'field1': ''});
  index.add_document({'field2': ''});
  index.add_document({'field3': 'foo bar baz'});

  index.flush();
  index.close();
}

test_stopwords(Ferret ferret) {
  var field_infos = new FieldInfos(ferret,
      store: FieldStorage.NO, term_vector: TermVectorStorage.NO);
  field_infos.add_field('id',
      store: FieldStorage.YES, index: FieldIndexing.UNTOKENIZED);

  var i = new Index(ferret, or_default: false, default_search_field: '*');

  // adding this additional field to the document leads to failure below
  // comment out this statement and all tests pass:
  i.add_document({'id': 1, 'content': "Move or shake"});

  var hits = i.search('move nothere shake');
  expect(0, equals(hits.total_hits));
  hits = i.search('move shake');
  expect(1, equals(hits.total_hits));
  hits = i.search('move or shake');
  expect(1, equals(hits.total_hits)); // fails when id field is present
}

test_threading(Ferret ferret) {
  var path =
      File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
  var index = new Index(ferret, path: path, create: true);

  range(100).forEach((i) {
    var buf = '';
    var doc = {};
    doc['id'] = i;
    doc['foo'] = "foo ${i}";
    index.add_document(doc);
  });

  var threads = [];

  range(4).forEach((_) {
    threads.add(new Thread(index, (index) {
      var result = index.search('id:42');
      expect(1, equals(result.total_hits));
    }));
  });

  threads.forEach((t) => t.join());
}

test_wildcard() {
  j = null;
  new Index((Index i) {
    i.add_document("one");
    expect(i.search("*").total_hits, equals(1));
    i.add_document("two");
    expect(i.search("*").total_hits, equals(2));
    i.add_document({'content': "three"});
    expect(i.search("*").total_hits, equals(3));
    expect(i.search("id:*").total_hits, equals(3));
    expect(i.search('id:?*').total_hits, equals(2));
    j = i;
  });
  expect(StandardError, () => j.close());
}

check_highlight(index, q, excerpt_length, num_excerpts, expected,
    [field = 'field']) {
  var highlights = index.highlight(q, 0,
      excerpt_length: excerpt_length, num_excerpts: num_excerpts, field: field);
  expect(highlights, equals(expected));
  highlights = index.highlight(q, 1,
      excerpt_length: excerpt_length, num_excerpts: num_excerpts, field: field);
  expect(highlights, equals(expected));
}

test_highlighter(Ferret ferret) {
  var index = new Index(ferret,
      default_field: 'field',
      default_input_field: 'field',
      analyzer: new WhiteSpaceAnalyzer(ferret));
  [
    "the words we are searching for are one and two also " +
        "sometimes looking for them as a phrase like this; one " +
        "two lets see how it goes",
    [
      "the words we",
      "are searching",
      "for are one",
      "and two also",
      "sometimes looking",
      "for them as a",
      "phrase like this;",
      "one two lets see",
      "how it goes"
    ]
  ].forEach((doc) => index.add_document(doc));

  check_highlight(index, "one", 10, 1, ["...are <b>one</b>..."]);
  check_highlight(
      index, "one", 10, 2, ["...are <b>one</b>...", "...this; <b>one</b>..."]);
  check_highlight(index, "one", 10, 3,
      ["the words...", "...are <b>one</b>...", "...this; <b>one</b>..."]);
  check_highlight(index, "one", 10, 4, [
    "the words we are...",
    "...are <b>one</b>...",
    "...this; <b>one</b>..."
  ]);
  check_highlight(index, "one", 10, 5, [
    "the words we are searching for are <b>one</b>...",
    "...this; <b>one</b>..."
  ]);
  check_highlight(index, "one", 10, 20, [
    "the words we are searching for are <b>one</b> and two also " +
        "sometimes looking for them as a phrase like this; <b>one</b> " +
        "two lets see how it goes"
  ]);
  check_highlight(index, "one", 200, 1, [
    "the words we are searching for are <b>one</b> and two also " +
        "sometimes looking for them as a phrase like this; <b>one</b> " +
        "two lets see how it goes"
  ]);
  check_highlight(index, "(one two)", 15, 2,
      ["...<b>one</b> and <b>two</b>...", "...this; <b>one</b> <b>two</b>..."]);
  check_highlight(index, 'one two "one two"', 15, 2,
      ["...<b>one</b> and <b>two</b>...", "...this; <b>one two</b>..."]);
  check_highlight(
      index, 'one two "one two"', 15, 1, ["...this; <b>one two</b>..."]);
  check_highlight(index, '"one two"', 15, 1, null, 'not_a_field');
  check_highlight(index, 'wrong_field:one', 15, 1, null, 'wrong_field');
  check_highlight(index, '"the words" "for are one and two" words one two', 10,
      1, ["<b>the words</b>..."]);
  check_highlight(index, '"the words" "for are one and two" words one two', 20,
      2, ["<b>the words</b> we are...", "...<b>for are one and two</b>..."]);
  index.close();
}

test_changing_analyzer(Ferret ferret) {
  var index = new Index(ferret);
  var a = new WhiteSpaceAnalyzer(ferret, lower: false);
  index.add_document({'content': "Content With Capitals"}, a);
  var tv = index.reader.term_vector(0, 'content');
  expect(tv.terms[0].text, equals("Capitals"));
  index.close();
}

test_top_doc_to_json(Ferret ferret) {
  var index = new Index(ferret);
  [
    {'f1': "one"},
    {
      'f2': ["two", 2, 2.0]
    },
    {'f3': 3},
    {'f4': 4.0},
    {'f5': "five", 'funny': '"' * 10000}
  ].forEach((doc) => index.add_document(doc));
  var json_str =
      index.search("one two 3 4.0 five", sort: Sort.INDEX_ORDER).to_json();
//    assert(json_str == '[{"f1":"one"},{"f2":["two","2","2.0"]},{"f3":"3"},{"f4":"4.0"},{"f5":"five","funny":"' + '\'"\'' * 10_000 + '"}]' ||
//           json_str == '[{"f1":"one"},{"f2":["two","2","2.0"]},{"f3":"3"},{"f4":"4.0"},{"funny":"' + '\'"\'' * 10_000 + '","f5":"five"}]');
  expect(index.search("xxx").to_json(), equals('[]'));
  index.close();
}

test_large_query_delete(Ferret ferret) {
  var index = new Index(ferret);
  range(20).forEach((_) {
    index.add_document({'id': 'one'});
    index.add_document({'id': 'two'});
  });
  index.query_delete('id:one');
  expect(index.size(), equals(20));
}

test_query_update_delete_more_than_ten(Ferret ferret) {
  var index = new Index(ferret);
  range(20).forEach(
      (i) => index.add_document({'id': i, 'find': 'match', 'change': 'one'}));

  expect(index.search('find:match').total_hits, equals(20));
  index.query_update('find:match', {'change': 'two'});
  expect(index.search('find:match AND change:two').total_hits, equals(20));
  index.query_delete('find:match');
  expect(index.size, equals(0));
}
