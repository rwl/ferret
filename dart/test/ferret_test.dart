library ferret.test;

import 'package:ferret/ferret.dart';

import 'utils/bit_vector_test.dart';
import 'utils/priority_queue_test.dart';
import 'utils/number_tools_test.dart';
import 'query_parser/query_parser_test.dart';

main() {
  initFerret();
//  bitVectorTest();
//  priorityQueueTest();
//  numberToolsTest();
  queryParserTest();
}
