library ferret.proxy;

import 'dart:js' as js;

abstract class JsProxy {
  /// Memory address.
  int handle;

  /// Emscripten module.
  final js.JsObject module;

  JsProxy({String moduleName: 'Ferret', js.JsObject context})
      : module = (context == null ? js.context : context)[moduleName] {
    if (module == null) {
      throw new ArgumentError.notNull('Ferret module');
    }
  }

  JsProxy.mixin() : module = js.context['Ferret'];

  int allocString(String s) {
    var ptr = module.callMethod('_malloc', [s.length + 1]);
    module.callMethod('writeStringToMemory', [s, ptr]);
    return ptr;
  }

  void free(int ptr) => module.callMethod('_free', [ptr]);

  String stringify(int ptr) => module.callMethod('_Pointer_stringify', [ptr]);
}
