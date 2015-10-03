library ferret.test.search.multiple_search_requests;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

multipleSearchRequestsTest(Ferret ferret) {
  Index _ix;

  setUp(() {
    var dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    var fs_dir = new FSDirectory(ferret, dpath, create: true);

    var iw = new IndexWriter(ferret, dir: fs_dir, create: true, key: ['id']);
    range(1000).forEach((x) {
      var doc = {'id': x};
      iw.add_document(doc);
    });
    iw.close();
    fs_dir.close();

    _ix = new Index(ferret, path: dpath, create: true, key: ['id']);
  });

  tearDown(() {
    _ix.close();
  });

  test('repeated_queries_segmentation_fault', () {
    range(1000).forEach((x) {
      var bq = new BooleanQuery(ferret);
      var tq1 = new TermQuery(ferret, 'id', '1');
      var tq2 = new TermQuery(ferret, 'another_id', '1');
      bq.add_query(tq1, occur: BCType.MUST);
      bq.add_query(tq2, occur: BCType.MUST);
      var top_docs = _ix.search(bq);
    });
  });

  test('repeated_queries_bus_error', () {
    range(1000).forEach((x) {
      var bq = new BooleanQuery(ferret);
      var tq1 = new TermQuery(ferret, 'id', '1');
      var tq2 = new TermQuery(ferret, 'another_id', '1');
      var tq3 = new TermQuery(ferret, 'yet_another_id', '1');
      var tq4 = new TermQuery(ferret, 'still_another_id', '1');
      var tq5 = new TermQuery(ferret, 'one_more_id', '1');
      var tq6 = new TermQuery(ferret, 'and_another_id', '1');
      bq.add_query(tq1, occur: BCType.MUST);
      bq.add_query(tq2, occur: BCType.MUST);
      bq.add_query(tq3, occur: BCType.MUST);
      bq.add_query(tq4, occur: BCType.MUST);
      bq.add_query(tq5, occur: BCType.MUST);
      bq.add_query(tq6, occur: BCType.MUST);
      var top_docs = _ix.search(bq);
    });
  });
}
