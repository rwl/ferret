part of ferret.ext.index;

class StoreValue {
  final String _name;
  final int value;
  const StoreValue._internal(this._name, this.value);
  toString() => 'StoreValue.$_name';

  static const NO = const StoreValue._internal('NO', 0);
  static const YES = const StoreValue._internal('YES', 1);
  static const COMPRESS = const StoreValue._internal('COMPRESS', 2);
}

class IndexValue {
  final String _name;
  final int value;
  const IndexValue._internal(this._name, this.value);
  toString() => 'IndexValue.$_name';

  static const NO = const IndexValue._internal('NO', 0);
  static const UNTOKENIZED = const IndexValue._internal('UNTOKENIZED', 1);
  static const YES = const IndexValue._internal('YES', 3);
  static const UNTOKENIZED_OMIT_NORMS =
      const IndexValue._internal('UNTOKENIZED_OMIT_NORMS', 5);
  static const YES_OMIT_NORMS = const IndexValue._internal('YES_OMIT_NORMS', 7);
}

class TermVectorValue {
  final String _name;
  final int value;
  const TermVectorValue._internal(this._name, this.value);
  toString() => 'TermVectorValue.$_name';

  static const NO = const TermVectorValue._internal('NO', 0);
  static const YES = const TermVectorValue._internal('YES', 1);
  static const WITH_POSITIONS =
      const TermVectorValue._internal('WITH_POSITIONS', 3);
  static const WITH_OFFSETS =
      const TermVectorValue._internal('WITH_OFFSETS', 5);
  static const WITH_POSITIONS_OFFSETS =
      const TermVectorValue._internal('WITH_POSITIONS_OFFSETS', 7);
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
class FieldInfos extends JsProxy {
  /// Create a new [FieldInfos] object which uses the default values for
  /// fields specified in the [default_values] hash parameter. See [FieldInfo]
  /// for available property values.
  FieldInfos(
      {StoreValue store: StoreValue.YES,
      IndexValue index: IndexValue.YES,
      TermVectorValue term_vector: TermVectorValue.WITH_POSITIONS_OFFSETS})
      : super() {
    handle = module.callMethod(
        '_frt_fis_new', [store.value, index.value, term_vector.value]);
  }

  /// Return an array of the [FieldInfo] objects contained but this
  /// [FieldInfos] object.
  List<FieldInfo> to_a() {
    frb_fis_to_a;
  }

  /// Get the [FieldInfo] object. [FieldInfo] objects can be referenced by
  /// either their field-number of the field-name (which must be a symbol).
  /// For example:
  ///
  ///     var fi = fis['name'];
  ///     fi = fis[2];
  FieldInfo operator [](name_or_num) {
    frb_fis_get;
  }

  /// Add a [FieldInfo] object. Use the [add_field] method where possible.
  void add(FieldInfo fi) {
    frb_fis_add;
  }

  /// Alias for [add].
  operator <<(fi) => frb_fis_add;

  /// Add a new [field] to the [FieldInfos] object. See [FieldInfo] for a
  /// description of the available [properties].
  add_field(field, properties) {
    frb_fis_add_field;
  }

  /// Iterate through the [FieldInfo] objects.
  void each(fn(FieldInfo fi)) {
    frb_fis_each;
  }

  /// Return a string representation of the [FieldInfos] object.
  String to_s() {
    frb_fis_to_s;
  }

  /// Return the number of fields in the [FieldInfos] object.
  int size() {
    frb_fis_size;
  }

  /// Create a new index in the directory specified. The directory [dir] can
  /// either be a string path representing a directory on the file-system or
  /// an actual directory object. Care should be taken when using this method.
  /// Any existing index (or other files for that matter) will be deleted from
  /// the directory and overwritten by the new index.
  void create_index(dir) {
    frb_fis_create_index;
  }

  /// Return a list of the field names (as symbols) of all the fields in the
  /// index.
  List<String> fields() {
    frb_fis_get_fields;
  }

  /// Return a list of the field names (as symbols) of all the tokenized
  /// fields in the index.
  List<String> tokenized_fields() {
    frb_fis_get_tk_fields;
  }
}

/// The [FieldInfo] class is the field descriptor for the index. It specifies
/// whether a field is compressed or not or whether it should be indexed and
/// tokenized. Every field has a name which must be a symbol. There are three
/// properties that you can set, [store], [index] and [term_vector]. You
/// can also set the default [boost] for a field as well.
///
/// The [store] property allows you to specify how a field is stored. You can
/// leave a field unstored (`no`), store it in it's original format (`yes`)
/// or store it in compressed format (`compressed`). By default the document
/// is stored in its original format. If the field is large and it is stored
/// elsewhere where it is easily accessible you might want to leave it
/// unstored. This will keep the index size a lot smaller and make the
/// indexing process a lot faster. For example, you should probably leave the
/// [content] field unstored when indexing all the documents in your
/// file-system.
///
/// The [index] property allows you to specify how a field is indexed. A
/// field must be indexed to be searchable. However, a field doesn't need to
/// be indexed to be store in the Ferret index. You may want to use the index
/// as a simple database and store things like images or MP3s in the index. By
/// default each field is indexed and tokenized (split into tokens) (`yes`).
/// If you don't want to index the field use `no`. If you want the field
/// indexed but not tokenized, use `untokenized`. Do this for the fields you
/// wish to sort by. There are two other values for [index]; `omit_norms`
/// and `untokenized_omit_norms`. These values correspond to `yes` and
/// `untokenized` respectively and are useful if you are not boosting any
/// fields and you'd like to speed up the index. The norms file is the file
/// which contains the boost values for each document for a particular field.
///
/// See [TermVector] for a description of term-vectors. You can specify
/// whether or not you would like to store term-vectors. The available options
/// are `no`, `yes`, `with_positions`, `with_offsets` and
/// `with_positions_offsets`. Note that you need to store the positions to
/// associate offsets with individual terms in the term_vector.
///
///     Property       Value                     Description
///     ------------------------------------------------------------------------
///     :store       | :no                     | Don't store field
///                  |                         |
///                  | :yes (default)          | Store field in its original
///                  |                         | format. Use this value if you
///                  |                         | want to highlight matches.
///                  |                         | or print match excerpts a la
///                  |                         | Google search.
///                  |                         |
///                  | :compressed             | Store field in compressed
///                  |                         | format.
///     -------------|-------------------------|------------------------------
///     :index       | :no                     | Do not make this field
///                  |                         | searchable.
///                  |                         |
///                  | :yes (default)          | Make this field searchable and
///                  |                         | tokenized its contents.
///                  |                         |
///                  | :untokenized            | Make this field searchable but
///                  |                         | do not tokenize its contents.
///                  |                         | use this value for fields you
///                  |                         | wish to sort by.
///                  |                         |
///                  | :omit_norms             | Same as :yes except omit the
///                  |                         | norms file. The norms file can
///                  |                         | be omitted if you don't boost
///                  |                         | any fields and you don't need
///                  |                         | scoring based on field length.
///                  |                         |
///                  | :untokenized_omit_norms | Same as :untokenized except omit
///                  |                         | the norms file. Norms files can
///                  |                         | be omitted if you don't boost
///                  |                         | any fields and you don't need
///                  |                         | scoring based on field length.
///                  |                         |
///     -------------|-------------------------|------------------------------
///     :term_vector | :no                     | Don't store term-vectors
///                  |                         |
///                  | :yes                    | Store term-vectors without
///                  |                         | storing positions or offsets.
///                  |                         |
///                  | :with_positions         | Store term-vectors with
///                  |                         | positions.
///                  |                         |
///                  | :with_offsets           | Store term-vectors with
///                  |                         | offsets.
///                  |                         |
///                  | :with_positions_offsets | Store term-vectors with
///                  | (default)               | positions and offsets.
///     -------------|-------------------------|------------------------------
///     :boost       | Float                   | The boost property is used to
///                  |                         | set the default boost for a
///                  |                         | field. This boost value will
///                  |                         | used for all instances of the
///                  |                         | field in the index unless
///                  |                         | otherwise specified when you
///                  |                         | create the field. All values
///                  |                         | should be positive.
///                  |                         |
///
///     var fi = new FieldInfo('title', index: 'untokenized', term_vector: 'no',
///       boost: 10.0);
///
///     var fi = new FieldInfo('content');
///
///     var fi = new FieldInfo('created_on', index: 'untokenized_omit_norms',
///       term_vector: 'no');
///
///     var fi = new FieldInfo('image', store: 'compressed', index: 'no',
///       term_vector: 'no');
class FieldInfo {
  var _store;
  var _index;
  var _term_vector;

  var _compress;
  var _compressed;

  var _untokenized;
  var _omit_norms;
  var _untokenized_omit_norms;

  var _with_positions;
  var _with_offsets;
  var _with_positions_offsets;

  /// Create a new [FieldInfo] object with the name [name] and the properties
  /// specified in [options]. The available options are [`store`, `index`,
  /// `term_vector`, `boost`]. See the description of [FieldInfo] for more
  /// information on these properties.
  FieldInfo(name, options) {
    frb_fi_init;
  }

  /// Return the name of the field.
  String get name {
    frb_fi_name;
  }

  /// Return `true` if the field is stored in the index.
  bool stored() {
    frb_fi_is_stored;
  }

  /// Return `true` if the field is stored in the index in compressed format.
  bool compressed() {
    frb_fi_is_compressed;
  }

  /// Return `true` if the field is indexed, ie searchable in the index.
  bool indexed() {
    frb_fi_is_indexed;
  }

  /// Return true if the field is tokenized. Tokenizing is the process of
  /// breaking the field up into tokens. That is "the quick brown fox"
  /// becomes:
  ///
  ///     ["the", "quick", "brown", "fox"]
  ///
  /// A field can only be tokenized if it is indexed.
  bool tokenized() {
    frb_fi_is_tokenized;
  }

  /// Return true if the field omits the norm file. The norm file is the file
  /// used to store the field boosts for an indexed field. If you do not boost
  /// any fields, and you can live without scoring based on field length then
  /// you can omit the norms file. This will give the index a slight
  /// performance boost and it will use less memory, especially for indexes
  /// which have a large number of documents.
  bool omit_norms() {
    frb_fi_omit_norms;
  }

  /// Return `true` if the term-vectors are stored for this field.
  bool store_term_vector() {
    frb_fi_store_term_vector;
  }

  /// Return `true` if positions are stored with the term-vectors for this
  /// field.
  bool store_positions() {
    frb_fi_store_positions;
  }

  /// Return `true` if offsets are stored with the term-vectors for this
  /// field.
  bool store_offsets() {
    frb_fi_store_offsets;
  }

  /// Return `true` if this field has a norms file. This is the same as
  /// calling:
  ///
  ///     fi.indexed() && !fi.omit_norms();
  bool has_norms() {
    frb_fi_has_norms;
  }

  /// Return the default boost for this field.
  num boost() {
    frb_fi_boost;
  }

  /// Return a string representation of the [FieldInfo] object.
  String to_s() {
    frb_fi_to_s;
  }
}
