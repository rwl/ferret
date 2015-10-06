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

import '../../ferret.dart';
import '../analysis/analysis.dart' as analysis;
import '../store.dart' show Directory;

part 'field_info.dart';
part 'lazy_doc.dart';
part 'reader.dart';
part 'term.dart';
part 'writer.dart';
