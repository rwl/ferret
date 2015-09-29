/// The index library contains all the classes used for adding to and
/// retrieving from the index. The important classes to know about are;
///
/// * [FieldInfo]
/// * [FieldInfos]
/// * [IndexWriter]
/// * [IndexReader]
/// * [LazyDoc]
///
/// The other classes in this library are useful for more advanced uses like
/// building tag clouds, creating more-like-this queries, custom highlighting
/// etc. They are also useful for index browsers.
library ferret.ext.index;

import 'dart:collection' show MapBase, MapMixin;
import 'dart:js' as js;

import '../../proxy.dart';
import '../analysis/analysis.dart' as analysis;
import '../search/search.dart' show SortField;
import '../store.dart' show Directory;

part 'field_info.dart';
part 'lazy_doc.dart';
part 'reader.dart';
part 'term.dart';
part 'writer.dart';

void initFerret({String moduleName: 'Ferret', js.JsObject context}) {
  js.JsObject module = (context == null ? js.context : context)[moduleName];
  if (module == null) {
    throw new ArgumentError.notNull('Ferret module');
  }
  module.callMethod('_frjs_init');

  SortField.SCORE = module.callMethod('_frjs_sort_field_score');
  SortField.SCORE_REV = module.callMethod('_frjs_sort_field_score_rev');
  SortField.DOC = module.callMethod('_frjs_sort_field_doc');
  SortField.DOC_REV = module.callMethod('_frjs_sort_field_doc_rev');
}
