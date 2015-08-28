library ferret.test.search.sort;

class SortFieldTest {
  //< Test::Unit::TestCase

  test_field_score() {
    fs = SortField.SCORE;
    assert_equal('score', fs.type);
    assert_nil(fs.name);
    expect(fs.reverse, isFalse, "SCORE_ID should not be reverse");
    assert_nil(fs.comparator);
  }

  test_field_doc() {
    fs = SortField.DOC_ID;
    assert_equal('doc_id', fs.type);
    assert_nil(fs.name);
    expect(fs.reverse, isFalse, "DOC_ID should be reverse");
    assert_nil(fs.comparator);
  }

  test_error_raised() {
    assert_raise(() {
      fs = new SortField(null, type: 'integer');
    }, ArgumentError);
  }
}
