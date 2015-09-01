library ferret.test.search.multiple_search_requests;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

class MultipleSearchRequestsTest {
  //< Test::Unit::TestCase
  Index _ix;

  setup() {
    var dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    var fs_dir = FSDirectory.create(dpath, create: true);

    var iw = new IndexWriter(dir: fs_dir, create: true, key: ['id']);
    repeat(1000).times((x) {
      var doc = {'id': x};
      iw.add_document(doc);
    });
    iw.close();
    fs_dir.close();

    _ix = new Index(path: dpath, create: true, key: ['id']);
  }

  tear_down() {
    _ix.close();
  }

  test_repeated_queries_segmentation_fault() {
    repeat(1000).times((x) {
      var bq = new BooleanQuery();
      var tq1 = new TermQuery('id', 1);
      var tq2 = new TermQuery('another_id', 1);
      bq.add_query(tq1, occur: 'must');
      bq.add_query(tq2, occur: 'must');
      var top_docs = _ix.search(bq);
    });
  }

  test_repeated_queries_bus_error() {
    repeat(1000).times((x) {
      var bq = new BooleanQuery();
      var tq1 = new TermQuery('id', '1');
      var tq2 = new TermQuery('another_id', '1');
      var tq3 = new TermQuery('yet_another_id', '1');
      var tq4 = new TermQuery('still_another_id', '1');
      var tq5 = new TermQuery('one_more_id', '1');
      var tq6 = new TermQuery('and_another_id', '1');
      bq.add_query(tq1, occur: 'must');
      bq.add_query(tq2, occur: 'must');
      bq.add_query(tq3, occur: 'must');
      bq.add_query(tq4, occur: 'must');
      bq.add_query(tq5, occur: 'must');
      bq.add_query(tq6, occur: 'must');
      var top_docs = _ix.search(bq);
    });
  }
}
