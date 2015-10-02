library ferret.test;

import 'package:ferret/ferret.dart';

import 'analyzer/analyzer_test.dart';
import 'utils/bit_vector_test.dart';
import 'utils/priority_queue_test.dart';
import 'utils/number_tools_test.dart';
import 'query_parser/query_parser_test.dart';

main() {
  initFerret();

//  test_analyzer();
//  test_ascii_letter_analyzer();
//  test_letter_analyzer();
//  test_ascii_white_space_analyzer();
  test_white_space_analyzer();

//  queryParserTest();

//  bitVectorTest();
//  priorityQueueTest();
//  numberToolsTest();
}
