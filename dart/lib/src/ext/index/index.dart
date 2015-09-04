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

import 'dart:js' as js;
import 'dart:collection' show MapBase, MapMixin;

import '../store.dart' show Directory;
import '../analysis/analysis.dart' as analysis;

import '../../proxy.dart';

part 'writer.dart';
part 'term.dart';
part 'field_info.dart';
part 'lazy_doc.dart';
part 'reader.dart';

void initFerret({String moduleName: 'Ferret', js.JsObject context}) {
  js.JsObject module = (context == null ? js.context : context)[moduleName];
  if (module == null) {
    throw new ArgumentError.notNull('Ferret module');
  }
  module.callMethod('_frjs_init');
}
