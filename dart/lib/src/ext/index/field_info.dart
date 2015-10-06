part of ferret.ext.index;

/// Used to specify how fields are stored.
class FieldStorage {
  /// Don't store field.
  static const NO = const FieldStorage._('NO', 0);

  /// Store field in its original format. Use this value if you want to
  /// highlight matches or print match excerpts a la Google search.
  static const YES = const FieldStorage._('YES', 1);

  /// Store field in compressed format.
  static const COMPRESS = const FieldStorage._('COMPRESS', 2);

  final String _name;
  final int _value;

  const FieldStorage._(this._name, this._value);

  String toString() => 'FieldStorage.$_name';
}

/// Used to specify how fields are indexed.
class FieldIndexing {
  /// Do not make this field searchable.
  static const NO = const FieldIndexing._('NO', 0);

  /// Make this field searchable but do not tokenize its contents.
  /// Use this value for fields you wish to sort by.
  static const UNTOKENIZED = const FieldIndexing._('UNTOKENIZED', 1);

  /// Make this field searchable and tokenized its contents.
  static const YES = const FieldIndexing._('YES', 3);

  /// Same as [UNTOKENIZED] except omit the norms file. Norms files can
  /// be omitted if you don't boost any fields and you don't need
  /// scoring based on field length.
  static const UNTOKENIZED_OMIT_NORMS =
      const FieldIndexing._('UNTOKENIZED_OMIT_NORMS', 5);

  /// Same as [YES] except omit the norms file. The norms file can
  /// be omitted if you don't boost any fields and you don't need
  /// scoring based on field length.
  static const YES_OMIT_NORMS = const FieldIndexing._('YES_OMIT_NORMS', 7);

  final String _name;
  final int _value;

  const FieldIndexing._(this._name, this._value);

  String toString() => 'FieldIndexing.$_name';
}

/// Used to specify how term vectors are stored.
class TermVectorStorage {
  /// Don't store term-vectors.
  static const NO = const TermVectorStorage._('NO', 0);

  /// Store term-vectors without storing positions or offsets.
  static const YES = const TermVectorStorage._('YES', 1);

  /// Store term-vectors with positions.
  static const WITH_POSITIONS = const TermVectorStorage._('WITH_POSITIONS', 3);

  /// Store term-vectors with offsets.
  static const WITH_OFFSETS = const TermVectorStorage._('WITH_OFFSETS', 5);

  /// Store term-vectors with positions and offsets.
  static const WITH_POSITIONS_OFFSETS =
      const TermVectorStorage._('WITH_POSITIONS_OFFSETS', 7);

  final String _name;
  final int _value;

  const TermVectorStorage._(this._name, this._value);

  String toString() => 'TermVectorStorage.$_name';
}

/// The [FieldInfos] class holds all the field descriptors for an index. It is
/// this class that is used to create a new index using the
/// [FieldInfos.create_index] method. If you are happy with the default
/// properties for [FieldInfo] then you don't need to worry about this class.
/// [IndexWriter] can create the index for you. Otherwise you should set up
/// the index like in the example:
///
///     var field_infos = new FieldInfos(term_vector: 'no');
///
///     field_infos.add_field('title', index: 'untokenized', term_vector: 'no',
///       boost: 10.0);
///
///     field_infos.add_field('content');
///
///     field_infos.add_field('created_on', index: 'untokenized_omit_norms',
///       term_vector: 'no');
///
///     field_infos.add_field('image', store: 'compressed', index: 'no',
///       term_vector: 'no');
///
///     field_infos.create_index("/path/to/index");
///
/// See [FieldInfo] for the available field property values.
///
/// When you create the [FieldInfos] object you specify the default properties
/// for the fields. Often you'll specify all of the fields in the index before
/// you create the index so the default values won't come into play. However,
/// it is possible to continue to dynamically add fields as indexing goes
/// along. If you add a document to the index which has fields that the index
/// doesn't know about then the default properties are used for the new field.
class FieldInfos {
  final Ferret _ferret;
  final int handle;

  final FieldStorage store;
  final FieldIndexing index;
  final TermVectorStorage term_vector;

  FieldInfos._wrap(this._ferret, this.handle)
      : store = FieldStorage.YES,
        index = FieldIndexing.YES,
        term_vector = TermVectorStorage.WITH_POSITIONS_OFFSETS;

  /// Create a new [FieldInfos] object which uses the default values for
  /// fields specified in the [default_values] hash parameter. See [FieldInfo]
  /// for available property values.
  FieldInfos(Ferret ferret,
      {store: FieldStorage.YES,
      index: FieldIndexing.YES,
      term_vector: TermVectorStorage.WITH_POSITIONS_OFFSETS})
      : _ferret = ferret,
        store = store,
        index = index,
        term_vector = term_vector,
        handle = ferret.callFunc(
            'frt_fis_new', [store._value, index._value, term_vector._value]);

  /// Return an array of the [FieldInfo] objects contained but this
  /// [FieldInfos] object.
  List<FieldInfo> to_a() {
    var n = size();
    var a = new List<FieldInfo>(n);
    for (int i = 0; i < n; i++) {
      var p_fi = _ferret.callFunc('frjs_fis_get_field_info', [handle, i]);
      a[i] = new FieldInfo._handle(_ferret, p_fi);
    }
    return a;
  }

  /// Get the [FieldInfo] object. [FieldInfo] objects can be referenced by
  /// either their field-number of the field-name (which must be a symbol).
  /// For example:
  ///
  ///     var fi = fis['name'];
  ///     fi = fis[2];
  FieldInfo operator [](name_or_num) {
    int p_fi;
    if (name_or_num is num) {
      int i = name_or_num.toInt();
      p_fi = _ferret.callFunc('frjs_fis_get_field_info', [handle, i]);
    } else if (name_or_num is String) {
      var p_name = _ferret.heapString(name_or_num);
      p_fi = _ferret.callFunc('frjs_fis_get_field', [handle, p_name]);
      _ferret.free(p_name);
    } else {
      throw new ArgumentError.value(
          name_or_num, 'name_or_num', 'must be num or String');
    }
    return new FieldInfo._handle(_ferret, p_fi);
  }

  /// Add a [FieldInfo] object. Use the [add_field] method where possible.
  void add(FieldInfo fi) {
    _ferret.callFunc('frjs_fis_add', [handle, fi.handle]);
  }

  /// Alias for [add].
  FieldInfos operator <<(FieldInfo fi) {
    add(fi);
    return this;
  }

  /// Add a new [field] to the [FieldInfos] object. See [FieldInfo] for a
  /// description of the available properties. Property values default to
  /// those used in the constructor.
  void add_field(String field,
      {FieldStorage store,
      FieldIndexing index,
      TermVectorStorage term_vector,
      double boost: 1.0}) {
    if (store == null) {
      store = this.store;
    }
    if (index == null) {
      index = this.index;
    }
    if (term_vector == null) {
      term_vector = this.term_vector;
    }
    int p_field = _ferret.heapString(field);
    _ferret.callFunc('frjs_fis_add_field', [
      handle,
      p_field,
      store._value,
      index._value,
      term_vector._value,
      boost
    ]);
    _ferret.free(p_field);
  }

  /// Iterate through the [FieldInfo] objects.
  void each(fn(FieldInfo fi)) {
    var n = size();
    for (int i = 0; i < n; i++) {
      var p_fi = _ferret.callFunc('frjs_fis_get_field_info', [handle, i]);
      fn(new FieldInfo._handle(_ferret, p_fi));
    }
  }

  /// Return a string representation of the [FieldInfos] object.
  String to_s() {
    int p_s = _ferret.callFunc('frt_fis_to_s', [handle]);
    return _ferret.stringify(p_s);
  }

  /// Return the number of fields in the [FieldInfos] object.
  int size() => _ferret.callFunc('frjs_fis_size', [handle]);

  /// Create a new index in the directory specified. The directory [dir] can
  /// either be a string path representing a directory on the file-system or
  /// an actual directory object. Care should be taken when using this method.
  /// Any existing index (or other files for that matter) will be deleted from
  /// the directory and overwritten by the new index.
  void create_index(dir) {
    int p_store, p_dir;
    if (dir is String) {
      p_store = 0;
      p_dir = _ferret.heapString(dir);
    } else if (dir is Directory) {
      p_store = dir.handle;
      p_dir = 0;
    }
    _ferret.callFunc('frjs_fis_create_index', [handle, p_store, p_dir]);
    if (dir is String) {
      _ferret.free(p_dir);
    }
  }

  /// Return a list of the field names (as symbols) of all the fields in the
  /// index.
  List<String> fields() {
    int n = size();
    var f = new List<String>(n);
    for (int i = 0; i < n; i++) {
      f[i] = this[i].name;
    }
    return f;
  }

  /// Return a list of the field names (as symbols) of all the tokenized
  /// fields in the index.
  List<String> tokenized_fields() {
    var tf = new List<String>();
    for (int i = 0; i < size(); i++) {
      var fi = this[i];
      var tokd = _ferret.callFunc('frjs_fi_is_tokenized', [fi.handle]) != 0;
      if (tokd) {
        tf.add(fi.name);
      }
    }
    return tf;
  }
}

/// The [FieldInfo] class is the field descriptor for the index. It specifies
/// whether a field is compressed or not or whether it should be indexed and
/// tokenized. Every field has a name which must be a symbol. There are three
/// properties that you can set, [store], [index] and [term_vector]. You
/// can also set the default [boost] for a field as well.
///
/// The [store] property allows you to specify how a field is stored. You can
/// leave a field unstored ([FieldStorage.NO]), store it in it's original
/// format ([FieldStorage.YES]) or store it in compressed format
/// ([FieldStorage.COMPRESSED]). By default the document is stored in its
/// original format. If the field is large and it is stored elsewhere where it
/// is easily accessible you might want to leave it unstored. This will keep
/// the index size a lot smaller and make the indexing process a lot faster.
/// For example, you should probably leave the `content` field unstored when
/// indexing all the documents in your file-system.
///
/// The [index] property allows you to specify how a field is indexed. A
/// field must be indexed to be searchable. However, a field doesn't need to
/// be indexed to be store in the Ferret index. You may want to use the index
/// as a simple database and store things like images or MP3s in the index. By
/// default each field is indexed and tokenized (split into tokens)
/// ([FieldIndexing.YES]). If you don't want to index the field use
/// [FieldIndexing.NO]. If you want the field indexed but not tokenized, use
/// [FieldIndexing.UNTOKENIZED]. Do this for the fields you wish to sort by.
/// There are two other values for [index]; [FieldIndexing.YES_OMIT_NORMS]
/// and [FieldIndexing.UNTOKENIZED_OMIT_NORMS]. These values correspond to
/// [FieldIndexing.YES] and [FieldIndexing.UNTOKENIZED] respectively and are
/// useful if you are not boosting any fields and you'd like to speed up the
/// index. The norms file is the file which contains the boost values for each
/// document for a particular field.
///
/// See [TermVector] for a description of term-vectors. You can specify
/// whether or not you would like to store term-vectors. Note that you need
/// to store the positions to associate offsets with individual terms in the
/// term_vector.
///
/// The [boost] property is used to set the default boost for a field. This
/// boost value will used for all instances of the field in the index unless
/// otherwise specified when you create the field. All values should be
/// positive.
///
///     var fi = new FieldInfo('title',
///       index: FieldIndexing.UNTOKENIZED,
///       term_vector: TermVectorStorage.NO,
///       boost: 10.0);
///
///     var fi = new FieldInfo('content');
///
///     var fi = new FieldInfo('created_on',
///       index: FieldIndexing.UNTOKENIZED_OMIT_NORMS,
///       term_vector: TermVectorStorage.NO);
///
///     var fi = new FieldInfo('image',
///       store: FieldStorage.COMPRESSED,
///       index: FieldIndexing.NO,
///       term_vector: TermVectorStorage.NO);
class FieldInfo {
  final Ferret _ferret;
  final int handle;

  FieldInfo._handle(this._ferret, this.handle);

  /// Create a new [FieldInfo] object with the name [name] and the properties
  /// specified in [options]. The available options are [`store`, `index`,
  /// `term_vector`, `boost`]. See the description of [FieldInfo] for more
  /// information on these properties.
  factory FieldInfo(Ferret ferret, String name,
      {FieldStorage store: FieldStorage.YES,
      FieldIndexing index: FieldIndexing.YES,
      TermVectorStorage term_vector: TermVectorStorage.WITH_POSITIONS_OFFSETS,
      double boost: 1.0}) {
    int p_name = ferret.heapString(name);
    int h = ferret.callFunc('frjs_fi_init',
        [p_name, store._value, index._value, term_vector._value, boost]);
    ferret.free(p_name);
    return new FieldInfo._handle(ferret, h);
  }

  /// Return the name of the field.
  String get name {
    int p_name = _ferret.callFunc('frjs_fi_name', [handle]);
    return _ferret.stringify(p_name, false);
  }

  /// Return `true` if the field is stored in the index.
  bool stored() => _ferret.callFunc('frjs_fi_is_stored', [handle]) != 0;

  /// Return `true` if the field is stored in the index in compressed format.
  bool compressed() => _ferret.callFunc('frjs_fi_is_compressed', [handle]) != 0;

  /// Return `true` if the field is indexed, ie searchable in the index.
  bool indexed() => _ferret.callFunc('frjs_fi_is_indexed', [handle]) != 0;

  /// Return true if the field is tokenized. Tokenizing is the process of
  /// breaking the field up into tokens. That is "the quick brown fox"
  /// becomes:
  ///
  ///     ["the", "quick", "brown", "fox"]
  ///
  /// A field can only be tokenized if it is indexed.
  bool tokenized() => _ferret.callFunc('frjs_fi_is_tokenized', [handle]) != 0;

  /// Return true if the field omits the norm file. The norm file is the file
  /// used to store the field boosts for an indexed field. If you do not boost
  /// any fields, and you can live without scoring based on field length then
  /// you can omit the norms file. This will give the index a slight
  /// performance boost and it will use less memory, especially for indexes
  /// which have a large number of documents.
  bool omit_norms() => _ferret.callFunc('frjs_fi_omit_norms', [handle]) != 0;

  /// Return `true` if the term-vectors are stored for this field.
  bool store_term_vector() =>
      _ferret.callFunc('frjs_fi_store_term_vector', [handle]) != 0;

  /// Return `true` if positions are stored with the term-vectors for this
  /// field.
  bool store_positions() =>
      _ferret.callFunc('frjs_fi_store_positions', [handle]) != 0;

  /// Return `true` if offsets are stored with the term-vectors for this
  /// field.
  bool store_offsets() =>
      _ferret.callFunc('frjs_fi_store_offsets', [handle]) != 0;

  /// Return `true` if this field has a norms file. This is the same as
  /// calling:
  ///
  ///     fi.indexed() && !fi.omit_norms();
  bool has_norms() => _ferret.callFunc('frjs_fi_has_norms', [handle]) != 0;

  /// Return the default boost for this field.
  double boost() => _ferret.callFunc('frjs_fi_boost', [handle]);

  /// Return a string representation of the [FieldInfo] object.
  String to_s() {
    int p_fi_s = _ferret.callFunc('frt_fi_to_s', [handle]);
    return _ferret.stringify(p_fi_s);
  }
}
