library ferret.test.search.sort;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

void sortFieldTest(Ferret ferret) {
  test('field_score', () {
    var fs = SortField.SCORE;
    expect('score', fs.type);
    expect(fs.name, isNull);
    expect(fs.reverse, isFalse, reason: "SCORE_ID should not be reverse");
    expect(fs.comparator, isNull);
  });

  test('field_doc', () {
    var fs = SortField.DOC;
    expect('doc_id', fs.type);
    expect(fs.name, isNull);
    expect(fs.reverse, isFalse, reason: "DOC_ID should be reverse");
    expect(fs.comparator, isNull);
  });

  test('error_raised', () {
    expect(() {
      new SortField(ferret, null, type: SortType.INTEGER);
    }, throwsArgumentError);
  });
}
