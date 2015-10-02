library ferret.module;

import 'dart:js' as js;
import './ext/search/search.dart' show SortField, Sort;

class Ferret {
  /// Emscripten module.
  final js.JsObject module;

  Ferret({String moduleName: 'Ferret', js.JsObject context})
      : module = (context == null ? js.context : context)[moduleName] {
    if (module == null) {
      throw new ArgumentError.notNull('Ferret module');
    }

    module.callMethod('_frjs_init');

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

  callMethod(String method, [List args]) => module.callMethod(method, args);

  int allocString(String s) {
    if (s == null) {
      return 0;
    }
    var ptr = module.callMethod('_malloc', [s.length + 1]);
    module.callMethod('writeStringToMemory', [s, ptr]);
    return ptr;
  }

  void free(int ptr) => module.callMethod('_free', [ptr]);

  String stringify(int ptr, [int len]) {
    var args = [ptr];
    if (len != null) {
      args.add(len);
    }
    return module.callMethod('Pointer_stringify', args);
  }
}
