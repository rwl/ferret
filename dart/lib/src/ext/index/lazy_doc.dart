part of ferret.ext.index;

/// When a document is retrieved from the index a [LazyDoc] is returned.
/// Actually, [LazyDoc] is just a modified [Map] object which lazily adds
/// fields to itself when they are accessed. You should not that they keys
/// method will return nothing until you actually access one of the fields.
/// To see what fields are available use [LazyDoc.fields] rather than
/// [LazyDoc.keys]. To load all fields use the [LazyDoc.load] method.
///
///     var doc = index_reader[0];
///
///     doc.keys     //=> []
///     doc.values   //=> []
///     doc.fields   //=> [:title, :content]
///
///     var title = doc['title'] //=> "the title"
///     doc.keys     //=> ['title']
///     doc.values   //=> ["the title"]
///     doc.fields   //=> ['title', 'content']
///
///     doc.load
///     doc.keys     //=> ['title', 'content']
///     doc.values   //=> ["the title", "the content"]
///     doc.fields   //=> ['title', 'content']
class LazyDoc extends JsProxy /*MapBase*/ with MapMixin {
  Map _map = {};
  Iterable get keys => _map.keys;
  operator [](key) => _map[key];
  operator []=(key, value) => _map[key] = value;
  remove(key) => _map.remove(key);
  void clear() => _map.clear();

  var _fields;

  LazyDoc() : super.mixin();

  /// This method is used internally to lazily load fields. You should never
  /// really need to call it yourself.
  String defaultDoc() {
    frb_lzd_default;
  }

  /// Load all unloaded fields in the document from the index.
  LazyDoc load() {
    frb_lzd_load;
  }

  /// Returns the list of fields stored for this particular document. If you
  /// try to access any of these fields in the document the field will be
  /// loaded. Try to access any other field an null will be returned.
  List<String> fields() {
    frb_lzd_fields;
  }
}

class LazyDocData {}
