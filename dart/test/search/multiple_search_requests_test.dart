library ferret.test.search.multiple_search_requests;

class MultipleSearchRequestsTest {
  //< Test::Unit::TestCase

  setup() {
    dpath =
        File.expand_path(File.join(File.dirname(__FILE__), '../../temp/fsdir'));
    fs_dir = new FSDirectory(dpath, true);

    iw = new IndexWriter(dir: fs_dir, create: true, key: ['id']);
    repeat(1000).times((x) {
      doc = {'id': x};
      iw.add(doc);
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
      bq = new BooleanQuery();
      tq1 = new TermQuery('id', 1);
      tq2 = new TermQuery('another_id', 1);
      bq.add_query(tq1, 'must');
      bq.add_query(tq2, 'must');
      top_docs = _ix.search(bq);
    });
  }

  test_repeated_queries_bus_error() {
    repeat(1000).times((x) {
      bq = new BooleanQuery();
      tq1 = new TermQuery('id', '1');
      tq2 = new TermQuery('another_id', '1');
      tq3 = new TermQuery('yet_another_id', '1');
      tq4 = new TermQuery('still_another_id', '1');
      tq5 = new TermQuery('one_more_id', '1');
      tq6 = new TermQuery('and_another_id', '1');
      bq.add_query(tq1, 'must');
      bq.add_query(tq2, 'must');
      bq.add_query(tq3, 'must');
      bq.add_query(tq4, 'must');
      bq.add_query(tq5, 'must');
      bq.add_query(tq6, 'must');
      top_docs = _ix.search(bq);
    });
  }
}
