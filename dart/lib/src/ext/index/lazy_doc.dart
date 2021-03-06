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
class LazyDoc extends MapBase<String, dynamic> {
  final Ferret _ferret;
  final int handle;

  final Map<String, dynamic> _map = {};

  List<String> _fields;

  LazyDoc.wrap(this._ferret, this.handle) {
    int size = _ferret.callFunc('frjs_lzd_size', [handle]);
    _fields = new List<String>(size);
    for (int i = 0; i < size; i++) {
      int p_lazy_df = _ferret.callFunc('frjs_lzd_field', [handle, i]);

      int p_name = _ferret.callFunc('frjs_lzd_field_name', [p_lazy_df]);
      _fields[i] = _ferret.stringify(p_name);
    }
  }

  Iterable<String> get keys => _map.keys;

  operator [](String key) => _map[key];

  operator []=(String key, value) => _map[key] = value;

  remove(String key) => _map.remove(key);

  void clear() => _map.clear();

  String _df_load(String key, int p_lazy_df) {
    var value;
    if (p_lazy_df != 0) {
      int size = _ferret.callFunc('frjs_lzd_field_size', [p_lazy_df]);
      if (size == 1) {
        int p_data = _ferret.callFunc('frt_lazy_df_get_data', [p_lazy_df, 0]);
        int len = _ferret.callFunc('frjs_lzd_field_length', [p_lazy_df]);
        value = _ferret.stringify(p_data, false, len);
      } else {
        value = new List<String>(size);
        for (int i = 0; i < size; i++) {
          int p_data = _ferret.callFunc('frt_lazy_df_get_data', [p_lazy_df, i]);
          int len =
              _ferret.callFunc('frjs_lzd_field_data_length', [p_lazy_df, i]);
          value[i] = _ferret.stringify(p_data, false, len);
        }
      }
    }
    return value;
  }

  /// This method is used internally to lazily load fields. You should never
  /// really need to call it yourself.
  String loadField(String key) {
    int symbol = _ferret.intern(key);
    int p_lazy_df = _ferret.callFunc('frt_lazy_doc_get', [handle, symbol]);
    return _df_load(key, p_lazy_df);
  }

  /// Load all unloaded fields in the document from the index.
  LazyDoc load() {
    int size = _ferret.callFunc('frjs_lzd_size', [handle]);
    for (int i = 0; i < size; i++) {
      int p_lazy_df = _ferret.callFunc('frjs_lzd_field', [handle, i]);

      int p_name = _ferret.callFunc('frjs_lzd_field_name', [p_lazy_df]);
      var key = _ferret.stringify(p_name);
      var value = _df_load(key, p_lazy_df);
      _map[key] = value;
    }
  }

  /// Returns the list of fields stored for this particular document. If you
  /// try to access any of these fields in the document the field will be
  /// loaded. Try to access any other field an null will be returned.
  List<String> get fields => _fields;
}
