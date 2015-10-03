library ferret.test;

import 'package:ferret/ferret.dart';

import 'analyzer/analyzer_test.dart';
import 'utils/bit_vector_test.dart';
import 'utils/priority_queue_test.dart';
import 'utils/number_tools_test.dart';
import 'query_parser/query_parser_test.dart';

main() {
  var ferret = new Ferret();

  test_analyzer(ferret);
  test_ascii_letter_analyzer(ferret);
  test_letter_analyzer(ferret);
  test_ascii_white_space_analyzer(ferret);
  test_white_space_analyzer(ferret);

  queryParserTest(ferret);

  bitVectorTest(ferret);
  priorityQueueTest();
  numberToolsTest();
}
