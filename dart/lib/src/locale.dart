library ferret.locale;

import 'dart:js' as js;

/// Returns a string corresponding to the locale set. For example:
///
///     get_locale() //=> "en_US.UTF-8"
String get_locale({String moduleName: 'Ferret', js.JsObject context}) {
  js.JsObject module = (context == null ? js.context : context)[moduleName];
  if (module == null) {
    throw new ArgumentError.notNull('Ferret module');
  }
  int p_l = module.callMethod('_frjs_get_locale');
  return module.callMethod('Pointer_stringify', [p_l]);
}

/// Set the global locale. You should use this method to set different locales
/// when indexing documents with different encodings.
void set_locale(String locale,
    {String moduleName: 'Ferret', js.JsObject context}) {
  js.JsObject module = (context == null ? js.context : context)[moduleName];
  if (module == null) {
    throw new ArgumentError.notNull('Ferret module');
  }
  var ptr = module.callMethod('_malloc', [locale.length + 1]);
  module.callMethod('writeStringToMemory', [locale, ptr]);
  module.callMethod('_frjs_set_locale', [ptr]);
}
