library ferret.module;

import 'dart:js' as js;
import 'package:emscripten/emscripten.dart';
import './ext/search/search.dart' show SortField, Sort;

class Ferret extends Module {
  Ferret({String moduleName: 'Ferret', js.JsObject context})
      : super(context: context, moduleName: moduleName) {
    callFunc('frjs_init');

    SortField.SCORE =
        new SortField.wrap(this, module.callMethod('_frjs_sort_field_score'));
    SortField.SCORE_REV = new SortField.wrap(
        this, module.callMethod('_frjs_sort_field_score_rev'));
    SortField.DOC =
        new SortField.wrap(this, module.callMethod('_frjs_sort_field_doc'));
    SortField.DOC_REV =
        new SortField.wrap(this, module.callMethod('_frjs_sort_field_doc_rev'));

    Sort.RELEVANCE = new Sort(this);
    Sort.INDEX_ORDER = new Sort(this, sort_fields: [SortField.DOC]);
  }

  /// Returns a string corresponding to the locale set. For example:
  ///
  ///     get_locale() //=> "en_US.UTF-8"
  String get_locale() {
    var p_l = callFunc('frjs_get_locale');
    return stringify(p_l, false);
  }

  /// Set the global locale. You should use this method to set different locales
  /// when indexing documents with different encodings.
  void set_locale(String locale) {
    var p_l = heapString(locale);
    callFunc('frjs_set_locale', [p_l]);
    //free(p_l); FIXME: mem leak?
  }

  int intern(String name) {
    int p_field = heapString(name);
    int symbol = callFunc('frt_intern', [p_field]);
    free(p_field);
    return symbol;
  }
}
