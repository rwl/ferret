library ferret.test.search.sort;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

class SortTest {
  //< Test.Unit.TestCase

  test_basic() {
    var s = Sort.RELEVANCE;
    expect(2, equals(s.fields.length));
    expect(SortField.SCORE, equals(s.fields[0]));
    expect(SortField.DOC_ID, equals(s.fields[1]));

    s = Sort.INDEX_ORDER;
    expect(1, equals(s.fields.length));
    expect(SortField.DOC_ID, equals(s.fields[0]));
  }

  test_string_init() {
    var s = new Sort(sort_fields: 'field');
    expect(2, equals(s.fields.length));
    expect('auto', equals(s.fields[0].type));
    expect('field', equals(s.fields[0].name));
    expect(SortField.DOC_ID, equals(s.fields[1]));

    s = new Sort(sort_fields: ['field1', 'field2', 'field3']);
    expect(4, equals(s.fields.length));
    expect('auto', equals(s.fields[0].type));
    expect('field1', equals(s.fields[0].name));
    expect('auto', equals(s.fields[1].type));
    expect('field2', equals(s.fields[1].name));
    expect('auto', equals(s.fields[2].type));
    expect('field3', equals(s.fields[2].name));
    expect(SortField.DOC_ID, equals(s.fields[3]));
  }

  test_multi_fields() {
    var sf1 = new SortField('field', type: 'integer', reverse: true);
    var sf2 = SortField.SCORE;
    var sf3 = SortField.DOC_ID;
    var s = new Sort(sort_fields: [sf1, sf2, sf3]);

    expect(3, equals(s.fields.length));
    expect('integer', equals(s.fields[0].type));
    expect('field', equals(s.fields[0].name));
    expect(s.fields[0].reverse, isTrue);
    expect(SortField.SCORE, equals(s.fields[1]));
    expect(SortField.DOC_ID, equals(s.fields[2]));
  }
}
