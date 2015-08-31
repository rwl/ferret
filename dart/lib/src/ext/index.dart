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

import 'dart:js';
import 'dart:collection' show MapBase;

import 'store.dart' show Directory;
import 'analysis/analysis.dart' as analysis;

/// The IndexWriter is the class used to add documents to an index. You can
/// also delete documents from the index using this class. The indexing
/// process is highly customizable.
class IndexWriter {

  /*static const WRITE_LOCK_TIMEOUT = 1;
  static const COMMIT_LOCK_TIMEOUT = 10;
  static const WRITE_LOCK_NAME = WRITE_LOCK_NAME;
  static const COMMIT_LOCK_NAME = COMMIT_LOCK_NAME;
  static const DEFAULT_CHUNK_SIZE = default_config.chunk_size;
  static const DEFAULT_MAX_BUFFER_MEMORY = default_config.max_buffer_memory;
  static const DEFAULT_TERM_INDEX_INTERVAL = default_config.index_interval;
  static const DEFAULT_DOC_SKIP_INTERVAL = default_config.skip_interval;
  static const DEFAULT_MERGE_FACTOR = default_config.merge_factor;
  static const DEFAULT_MAX_BUFFERED_DOCS = default_config.max_buffered_docs;
  static const DEFAULT_MAX_MERGE_DOCS = default_config.max_merge_docs;
  static const DEFAULT_MAX_FIELD_LENGTH = default_config.max_field_length;
  static const DEFAULT_USE_COMPOUND_FILE = default_config.use_compound_file ? Qtrue : Qfalse;*/

  var _boost;

  var _create;
  var _create_if_missing;
  var _field_infos;

  var _chunk_size;
  var _max_buffer_memory;
  var _term_index_interval;
  var _doc_skip_interval;
  var _merge_factor;
  var _max_buffered_docs;
  var _max_merge_docs;
  var _max_field_length;
  var _use_compound_file;

  /// Create a new [IndexWriter]. You should either pass a path or a directory
  /// to this constructor. For example, here are three ways you can create an
  /// [IndexWriter]:
  ///
  ///     var dir = new RAMDirectory();
  ///     var iw = new IndexWriter(dir: dir);
  ///
  ///     dir = new FSDirectory("/path/to/index");
  ///     iw = new IndexWriter(dir: dir);
  ///
  ///     iw = new IndexWriter(path: "/path/to/index");
  ///
  /// [dir] is a [Directory] object. You should either pass a [dir] or a [path]
  /// when creating an index.
  /// [path] is a string representing the path to the index directory. If you
  /// are creating the index for the first time the directory will be created if
  /// it's missing. You should not choose a directory which contains other files
  /// as they could be over-written. To protect against this set
  /// [create_if_missing] to false.
  /// Set [create_if_missing] to `true` to create the index if no index is found
  /// in the specified directory. Otherwise, use the existing index.
  /// Setting [create] to `true` creates the index, even if one already exists.
  /// That means any existing index will be deleted. It is probably better to
  /// use the [create_if_missing] option so that the index is only created the
  /// first time when it doesn't exist.
  /// [field_infos] is the [FieldInfos] object to use when creating a new index
  /// if [create_if_missing] or [create] is set to `true`. If an existing index
  /// is opened then this parameter is ignored.
  /// [analyzer] sets the default analyzer for the index. This is used by both
  /// the [IndexWriter] and the [QueryParser] to tokenize the input. The default
  /// is the [StandardAnalyzer].
  /// [chunk_size] is a memory performance tuning parameter. Sets the default
  /// size of chunks of memory malloced for use during indexing. You can usually
  /// leave this parameter as is.
  /// [max_buffer_memory] is a memory performance tuning parameter. Sets the
  /// amount of memory to be used by the indexing process. Set to a larger value
  /// to increase indexing speed. Note that this only includes memory used by
  /// the indexing process, not the rest of your application.
  /// [term_index_interval] is the skip interval between terms in the term
  /// dictionary. A smaller value will possibly increase search performance
  /// while also increasing memory usage and impacting negatively impacting
  /// indexing performance.
  /// [doc_skip_interval] is the skip interval for document numbers in the
  /// index. As with [term_index_interval] you have a trade-off. A smaller
  /// number may increase search performance while also increasing memory usage
  /// and impacting negatively impacting indexing performance.
  /// [merge_factor] must never be less than 2. Specifies the number of segments
  /// of a certain size that must exist before they are merged. A larger value
  /// will improve indexing performance while slowing search performance.
  /// [max_buffered_docs] is the maximum number of documents that may be stored
  /// in memory before being written to the index. If you have a lot of memory
  /// and are indexing a large number of small documents (like products in a
  /// product database for example) you may want to set this to a much higher
  /// number (like [Ferret.FIX_INT_MAX]). If you are worried about your
  /// application crashing during the middle of index you might set this to a
  /// smaller number so that the index is committed more often. This is like
  /// having an auto-save in a word processor application.
  /// Set [max_merge_docs] to limit the number of documents that go into a
  /// single segment. Use this to avoid extremely long merge times during
  /// indexing which can make your application seem unresponsive. This is only
  /// necessary for very large indexes (millions of documents).
  /// [max_field_length] is the maximum number of terms added to a single field.
  /// This can be useful to protect the indexer when indexing documents from the
  /// web for example. Usually the most important terms will occur early on in a
  /// document so you can often safely ignore the terms in a field after a
  /// certain number of them. If you wanted to speed up indexing and same space
  /// in your index you may only want to index the first 1000 terms in a field.
  /// On the other hand, if you want to be more thorough and you are indexing
  /// documents from your file-system you may set this parameter to
  /// [Ferret.FIX_INT_MAX].
  /// [use_compound_file] uses a compound file to store the index. This prevents
  /// an error being raised for having too many files open at the same time. The
  /// default is true but performance is better if this is set to false.
  ///
  /// Both [IndexReader] and IndexWriter allow you to delete documents. You
  /// should use the [IndexReader] to delete documents by document id and
  /// [IndexWriter] to delete documents by term which we'll explain now. It is
  /// preferrable to delete documents from an index using [IndexWriter] for
  /// performance reasons. To delete documents using the [IndexWriter] you
  /// should give each document in the index a unique ID. If you are indexing
  /// documents from the file-system this unique ID will be the full file path.
  /// If indexing documents from the database you should use the primary key as
  /// the ID field. You can then use the delete method to delete a file
  /// referenced by the ID. For example:
  ///
  ///     index_writer.delete('id', "/path/to/indexed/file");
  IndexWriter({Directory dir, String path, bool create_if_missing: true,
      bool create: false, FieldInfo field_infos, analysis.Analyzer analyzer,
      int chunk_size: 0x100000, int max_buffer_memory: 0x1000000,
      int term_index_interval: 128, int doc_skip_interval: 16,
      int merge_factor: 10, int max_buffered_docs: 10000, max_merge_docs,
      int max_field_length: 10000, bool use_compound_file: true});

  /// Returns the number of documents in the [Index]. Note that deletions
  /// won't be taken into account until the [IndexWriter] has been committed.
  int doc_count() {
    frb_iw_get_doc_count;
  }

  /// Close the [IndexWriter]. This will close and free all resources used
  /// exclusively by the index writer. The garbage collector will do this
  /// automatically if not called explicitly.
  void close() {
    frb_iw_close;
  }

  /// Add a document to the index. See [Document]. A document can also be a
  /// simple map object.
  void add_document(doc) {
    frb_iw_add_doc;
  }

  /// Alias for [add_document].
  operator <<(doc) => frb_iw_add_doc;

  /// Optimize the index for searching. This commits any unwritten data to the
  /// index and optimizes the index into a single segment to improve search
  /// performance. This is an expensive operation and should not be called too
  /// often. The best time to call this is at the end of a long batch indexing
  /// process. Note that calling the optimize method do not in any way effect
  /// indexing speed (except for the time taken to complete the optimization
  /// process).
  void optimize() {
    frb_iw_optimize;
  }

  /// Explicitly commit any changes to the index that may be hanging around in
  /// memory. You should call this method if you want to read the latest index
  /// with an [IndexWriter].
  void commit() {
    frb_iw_commit;
  }

  /// Use this method to merge other indexes into the one being written by
  /// [IndexWriter]. This is useful for parallel indexing. You can have
  /// several indexing processes running in parallel, possibly even on
  /// different machines. Then you can finish by merging all of the indexes
  /// into a single index.
  void add_readers(List readers) {
    frb_iw_add_readers;
  }

  /// Delete all documents in the index with the given [term] or [terms] in
  /// the field [field]. You should usually have a unique document id which
  /// you use with this method, rather then deleting all documents with the
  /// word "the" in them. There are of course exceptions to this rule. For
  /// example, you may want to delete all documents with the term "viagra"
  /// when deleting spam.
  void delete(fields, {term, terms}) {
    frb_iw_delete;
  }

  /// Get the [FieldInfos] object for this [IndexWriter]. This is useful if
  /// you need to dynamically add new fields to the index with specific
  /// properties.
  FieldInfos get field_infos {
    frb_iw_field_infos;
  }

  /// Get the [Analyzer] for this [IndexWriter]. This is useful if you need
  /// to use the same analyzer in a [QueryParser].
  Analyzer get analyzer {
    frb_iw_get_analyzer;
  }

  /// Set the [Analyzer] for this [IndexWriter]. This is useful if you need to
  /// change the analyzer for a special document. It is risky though as the
  /// same analyzer will be used for all documents during search.
  void set analyzer(Analyzer a) {
    frb_iw_set_analyzer();
  }

  /// Returns the current version of the index writer.
  int get version {
    frb_iw_version();
  }

  get chunk_size {
    frb_iw_get_chunk_size;
  }

  set chunk_size(val) {
    frb_iw_set_chunk_size;
  }

  get max_buffer_memory {
    frb_iw_get_max_buffer_memory;
  }

  set max_buffer_memory(val) {
    frb_iw_set_max_buffer_memory;
  }

  get term_index_interval {
    frb_iw_get_index_interval;
  }

  set term_index_interval(val) {
    frb_iw_set_index_interval;
  }

  get doc_skip_interval {
    frb_iw_get_skip_interval;
  }

  set doc_skip_interval(val) {
    frb_iw_set_skip_interval;
  }

  get merge_factor {
    frb_iw_get_merge_factor;
  }

  set merge_factor(val) {
    frb_iw_set_merge_factor;
  }

  get max_buffered_docs {
    frb_iw_get_max_buffered_docs;
  }

  set max_buffered_docs(val) {
    frb_iw_set_max_buffered_docs;
  }

  get max_merge_docs {
    frb_iw_get_max_merge_docs;
  }

  set max_merge_docs(val) {
    frb_iw_set_max_merge_docs;
  }

  get max_field_length {
    frb_iw_get_max_field_length;
  }

  set max_field_length(val) {
    frb_iw_set_max_field_length;
  }

  get use_compound_file {
    frb_iw_get_use_compound_file;
  }

  set use_compound_file(val) {
    frb_iw_set_use_compound_file;
  }
}

/// TermVectors are most commonly used for creating search result excerpts and
/// highlight search matches in results. This is all done internally so you
/// won't need to worry about the [TermVector] object. There are some other
/// reasons you may want to use the TermVectors object however. For example,
/// you may wish to see which terms are the most commonly occurring terms in a
/// document to implement a MoreLikeThis search.
///
///     var tv = index_reader.term_vector(doc_id, :content);
///     var tv_term = tv.find((tvt) => tvt.term = "fox");
///
///     // get the term frequency
///     term_freq = tv_term.positions.size
///
///     // get the offsets for a term
///     offsets = tv_term.positions.collect((pos) => tv.offsets[pos]);
///
/// [positions] and [offsets] can be `null` depending on what you set the
/// [term_vector] to when you set the [FieldInfo] object for the field. Note
/// in particular that you need to store both positions and offsets if you
/// want to associate offsets with particular terms.
class TermVector {
  var field, terms, offsets;
}

/// Holds the start and end byte-offsets of a term in a field. For example, if
/// the field was "the quick brown fox" then the start and end offsets of:
///
///     ["the", "quick", "brown", "fox"]
///
/// Would be:
///
///     [(0,3), (4,9), (10,15), (16,19)]
///
/// See the analysis library for more information on setting the offsets.
class TVOffsets {
  final int start, end;
  TVOffsets(this.start, this.end);
}

/// The TVTerm class holds the term information for each term in a TermVector.
/// That is it holds the term's text and its positions in the document. You
/// can use those positions to reference the offsets for the term.
///
///     tv = index_reader.term_vector('content');
///     tv_term = tv.find((tvt) => tvt.term = "fox");
///     offsets = tv_term.positions.collect((pos) => tv.offsets[pos]);
class TVTerm {
  String text;
  int freq;
  List<int> positions;
  TVTerm(this.text, this.freq, this.positions);
}

/// The [TermEnum] object is used to iterate through the terms in a field. To
/// get a [TermEnum] you need to use the [IndexReader.terms] method.
///
///     var te = index_reader.terms('content');
///
///     te.each((term, doc_freq) {
///       print("${term} occurred ${doc_freq} times");
///     });
///
///     // or you could do it like this;
///     var te = index_reader.terms('content');
///
///     while (te.next() != null) {
///       print("${te.term} occurred in ${te.doc_freq} documents in the index");
///     }
class TermEnum {
  final JsObject _module;
  final num handle;

  /// Returns the next term in the enumeration or nil otherwise.
  String next() {
    return _module.callMethod('_fjs_te_next', [_handle]);
  }

  /// Returns the current term pointed to by the enum. This method should only
  /// be called after a successful call to [next].
  String term() => frb_te_next;

  /// Returns the document frequency of the current term pointed to by the
  /// enum. That is the number of documents that this term appears in. The
  /// method should only be called after a successful call to [next].
  int doc_freq() => frb_te_doc_freq;

  /// Skip to term [target]. This method can skip forwards or backwards. If
  /// you want to skip back to the start, pass the empty string "". That is:
  ///
  ///     term_enum.skip_to("");
  ///
  /// Returns the first term greater than or equal to +target+
  String skip_to(String target) => frb_te_skip_to;

  /// Iterates through all the terms in the field, yielding the term and the
  /// document frequency.
  int each(fn(String term, int doc_freq)) => frb_te_each;

  /// Set the [field] for the term_enum. The [field] value should be a symbol
  /// as usual. For example, to scan all title terms you'd do this:
  ///
  ///     term_enum.set_field('title').each((term, doc_freq) {
  ///       do_something();
  ///     });
  void set field(String field) => frb_te_set_field;

  /// Alias for [field].
  set_field(String field) {}

  /// Returns a JSON representation of the term enum. You can speed this up by
  /// having the method return arrays instead of objects, simply by passing an
  /// argument to the to_json method. For example:
  ///
  ///     term_enum.to_json(); //=>
  ///     // [
  ///     //   {"term":"apple","frequency":12},
  ///     //   {"term":"banana","frequency":2},
  ///     //   {"term":"cantaloupe","frequency":12}
  ///     // ]
  ///
  ///     term_enum.to_json(fast: true); //=>
  ///     // [
  ///     //   ["apple",12],
  ///     //   ["banana",2],
  ///     //   ["cantaloupe",12]
  ///     // ]
  List to_json({bool fast: false}) => frb_te_to_json;
}

/// Use a [TermDocEnum] to iterate through the documents that contain a
/// particular term. You can also iterate through the positions which the term
/// occurs in a document.
///
///     var tde = index_reader.term_docs_for('content', "fox");
///
///     tde.each((doc_id, freq) {
///       print("fox appeared ${freq} times in document ${doc_id}:");
///       var positions = [];
///       tde.each_position((pos) => positions.add(pos));
///       print("  ${positions.join(', ')}");
///     });
///
///     // or you can do it like this;
///     tde.seek('title', "red");
///     while (tde.next) {
///       print("red appeared ${tde.freq} times in document ${tde.doc}:");
///       var positions = [];
///       while (pos = tde.next_position) {
///         positions.add(pos);
///       }
///       print("  ${positions.join(', ')}");
///     }
class TermDocEnum {
  var field_num_map;
  var field_num;

  /// Seek the term [term] in the index for [field]. After you call this
  /// method you can call next or each to skip through the documents and
  /// positions of this particular term.
  void seek(String field, String term) {
    frb_tde_seek;
  }

  /// Seek the current term in [term_enum]. You could just use the standard
  /// seek method like this:
  ///
  ///     term_doc_enum.seek(term_enum.term);
  ///
  /// However the [seek_term_enum] method saves an index lookup so should
  /// offer a large performance improvement.
  void seek_term_enum(String term) {
    frb_tde_seek_te;
  }

  /// Returns the current document number pointed to by the [term_doc_enum].
  dynamic doc() {
    frb_tde_doc;
  }

  /// Returns the frequency of the current document pointed to by the
  /// [term_doc_enum].
  int freq() {
    frb_tde_freq;
  }

  /// Move forward to the next document in the enumeration. Returns `true` if
  /// there is another document or `false` otherwise.
  bool next() {
    frb_tde_next;
  }

  /// Move forward to the next document in the enumeration. Returns `true` if
  /// there is another document or `false` otherwise.
  bool next_position() {
    frb_tde_next_position;
  }

  /// Iterate through the documents and document frequencies in the
  /// [term_doc_enum].
  ///
  /// NOTE: This method can only be called once after each seek. If you need
  /// to call [each] again then you should call [seek] again too.
  each(fn(doc_id, int freq)) {
    frb_tde_each;
  }

  /// Iterate through each of the positions occupied by the current term in
  /// the current document. This can only be called once per document. It can
  /// be used within the each method. For example, to print the terms documents
  /// and positions:
  ///
  ///     tde.each((doc_id, freq) {
  ///       print("term appeared ${freq} times in document ${doc_id}:");
  ///       var positions = [];
  ///       tde.each_position((pos) => positions.add(pos));
  ///       print("  ${positions.join(', ')}");
  ///     });
  each_position(fn(int pos)) {
    frb_tde_each_position;
  }

  /// Skip to the required document number [target] and return `true` if there
  /// is a document >= [target].
  bool skip_to(target) {
    frb_tde_skip_to;
  }

  /// Returns a json representation of the term doc enum. It will also add the
  /// term positions if they are available. You can speed this up by having
  /// the method return arrays instead of objects, simply by passing an
  /// argument to the [to_json] method. For example:
  ///
  ///     term_doc_enum.to_json(); //=>
  ///     // [
  ///     //   {"document":1,"frequency":12},
  ///     //   {"document":11,"frequency":1},
  ///     //   {"document":29,"frequency":120},
  ///     //   {"document":30,"frequency":3}
  ///     // ]
  ///
  ///     term_doc_enum.to_json(fast: true) //=>
  ///     // [
  ///     //   [1,12],
  ///     //   [11,1],
  ///     //   [29,120],
  ///     //   [30,3]
  ///     // ]
  List to_json({bool fast: false}) {
    frb_tde_to_json;
  }
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
  /// Create a new [FieldInfos] object which uses the default values for
  /// fields specified in the [default_values] hash parameter. See [FieldInfo]
  /// for available property values.
  FieldInfos(default_values) {
    frb_fis_init;
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
class LazyDoc extends MapBase {
  var _fields;

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

/// [IndexReader] is used for reading data from the index. This class is
/// usually used directly for more advanced tasks like iterating through
/// terms in an index, accessing term-vectors or deleting documents by
/// document id. It is also used internally by [IndexSearcher].
class IndexReader {
  /// Create a new [IndexReader]. You can either pass a string path to a
  /// file-system directory or an actual [Directory] object. For example:
  ///
  ///     var dir = new RAMDirectory();
  ///     var iw = new IndexReader(dir);
  ///
  ///     dir = new FSDirectory("/path/to/index");
  ///     iw = new IndexReader(dir);
  ///
  ///     iw = new IndexReader("/path/to/index");
  ///
  /// You can also create a what used to be known as a MultiReader by passing
  /// an array of [IndexReader] objects, Ferret::Store::Directory objects or
  /// file-system paths:
  ///
  ///     var iw = new IndexReader([dir, dir2, dir3]);
  ///
  ///     iw = new IndexReader([reader1, reader2, reader3]);
  ///
  ///     iw = new IndexReader(["/path/to/index1", "/path/to/index2"]);
  IndexReader(dir) {
    frb_ir_init;
  }

  /// Expert: change the boost value for a [field] in document at [doc_id].
  /// [val] should be an integer in the range 0..255 which corresponds to an
  /// encoded float value.
  set_norm(doc_id, field, int val) => frb_ir_set_norm;

  /// Expert: Returns a string containing the norm values for a field. The
  /// string length will be equal to the number of documents in the index and
  /// it could have null bytes.
  String norms(String field) => frb_ir_norms;

  /// Expert: Get the norm values into a string [buffer] starting at [offset].
  StringBuffer get_norms_into(field, StringBuffer buffer, int offset) =>
      frb_ir_get_norms_into;

  /// Commit any deletes made by this particular [IndexReader] to the index. This
  /// will use open a Commit lock.
  commit() => frb_ir_commit;

  /// Close the [IndexReader]. This method also commits any deletions made by
  /// this [IndexReader]. This method will be called explicitly by the garbage
  /// collector but you should call it explicitly to commit any changes as
  /// soon as possible and to close any locks held by the object to prevent
  /// locking errors.
  close() => frb_ir_close;

  /// Return `true` if the index has any deletions, either uncommitted by this
  /// [IndexReader] or committed by any other [IndexReader].
  bool has_deletions() => frb_ir_has_deletions;

  /// Delete document referenced internally by document id [doc_id]. The
  /// document_id is the number used to reference documents in the index and
  /// is returned by search methods.
  delete(doc_id) => frb_ir_delete;

  /// Returns `true` if the document at [doc_id] has been deleted.
  bool deleted(doc_id) => frb_ir_is_deleted;

  /// Returns 1 + the maximum document id in the index. It is the
  /// document_id that will be used by the next document added to the index.
  /// If there are no deletions, this number also refers to the number of
  /// documents in the index.
  num max_doc() => frb_ir_max_doc;

  /// Returns the number of accessible (not deleted) documents in the index.
  /// This will be equal to [max_doc] if there have been no documents deleted
  /// from the index.
  int num_docs() => frb_ir_num_docs;

  /// Undelete all deleted documents in the index. This is kind of like a
  /// rollback feature. Not that once an index is committed or a merge happens
  /// during index, deletions will be committed and undelete_all will have no
  /// effect on these documents.
  undelete_all() => frb_ir_undelete_all;

  /// Return true if the index version referenced by this [IndexReader] is the
  /// latest version of the index. If it isn't you should close and reopen the
  /// index to search the latest documents added to the index.
  bool latest() => frb_ir_is_latest;

  /// Retrieve a document from the index. See [LazyDoc] for more details on
  /// the document returned. Documents are referenced internally by document
  /// ids which are returned by the Searchers search methods.
  LazyDoc get_document(id) => frb_ir_get_doc;

  /// Alias for [get_document].
  LazyDoc operator [](id) => frb_ir_get_doc;

  /// Return the [TermVector] for the field [field] in the document at
  /// [doc_id] in the index. Return `null` if no such term_vector exists.
  TermVector term_vector(doc_id, field) => frb_ir_term_vector;

  /// Return the [TermVector]s for the document at [doc_id] in the index. The
  /// value returned is a hash of the [TermVector]s for each field in the
  /// document and they are referenced by field names (as symbols).
  Map term_vectors(doc_id) => frb_ir_term_vectors;

  /// Builds a [TermDocEnum] (term-document enumerator) for the index. You can
  /// use this object to iterate through the documents in which certain terms
  /// occur. See [TermDocEnum] for more info.
  TermDocEnum term_docs() => frb_ir_term_docs;

  /// Same as [term_docs] except the [TermDocEnum] will also allow you to scan
  /// through the positions at which a term occurs.
  TermDocEnum term_positions() => frb_ir_term_positions;

  /// Builds a [TermDocEnum] to iterate through the documents that contain the
  /// term [term] in the field [field].
  TermDocEnum term_docs_for(field, term) => frb_ir_term_docs_for;

  /// Same as [term_docs_for] except the [TermDocEnum] will also allow you to
  /// scan through the positions at which a term occurs.
  TermDocEnum term_positions_for(field, term) => frb_ir_t_pos_for;

  /// Return the number of documents in which the term [term] appears in the
  /// field [field].
  doc_freq(field, term) => frb_ir_doc_freq;

  /// Returns a term enumerator which allows you to iterate through all the
  /// terms in the field [field] in the index.
  TermEnum terms(field) => frb_ir_terms;

  /// Same as [terms] except that it starts the enumerator off at term [term].
  TermEnum terms_from(field, term) => frb_ir_terms_from;

  /// Same return a count of the number of terms in the field.
  int term_count() => frb_ir_term_count;

  /// Returns an array of field names in the index. This can be used to pass
  /// to the [QueryParser] so that the [QueryParser] knows how to expand the
  /// "*" wild-card to all fields in the index. A list of field names can also
  /// be gathered from the [FieldInfos] object.
  List<String> get fields => frb_ir_fields;

  /// Alias for [fields].
  List<String> field_names() => frb_ir_fields;

  /// Get the [FieldInfos] object for this [IndexReader].
  FieldInfos get field_infos => frb_ir_field_infos;

  /// Returns an array of field names of all of the tokenized fields in the
  /// index. This can be used to pass to the QueryParser so that the
  /// [QueryParser] knows how to expand the "*" wild-card to all fields in
  /// the index. A list of field names can also be gathered from the
  /// [FieldInfos] object.
  List<String> tokenized_fields() => frb_ir_tk_fields;

  /// Returns the current version of the index reader.
  int get version => frb_ir_version;
}
