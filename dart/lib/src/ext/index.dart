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

/// The IndexWriter is the class used to add documents to an index. You can
/// also delete documents from the index using this class. The indexing
/// process is highly customizable.
class IndexWriter {

  static const WRITE_LOCK_TIMEOUT = 1;
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
  static const DEFAULT_USE_COMPOUND_FILE = default_config.use_compound_file ? Qtrue : Qfalse;

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
     bool create:false, FieldInfo field_infos, Analyzer analyzer,
     int chunk_size: 0x100000, int max_buffer_memory: 0x1000000,
     int term_index_interval: 128, int doc_skip_interval: 16, int merge_factor: 10,
     int max_buffered_docs: 10000, max_merge_docs, int max_field_length: 10000,
     bool use_compound_file: true});

  doc_count() {
    frb_iw_get_doc_count;
  }

  close() {
    frb_iw_close;
  }

  add_document() {
    frb_iw_add_doc;
  }

  operator <<() => frb_iw_add_doc;

  optimize() {
    frb_iw_optimize;
  }

  commit() {
    frb_iw_commit;
  }

  add_readers() {
    frb_iw_add_readers;
  }

  delete() {
    frb_iw_delete;
  }

  field_infos() {
    frb_iw_field_infos;
  }

  get analyzer() {
    frb_iw_get_analyzer;
  }

  set analyzer() {
    frb_iw_set_analyzer();
  }

  version() {
    frb_iw_version();
  }

  get chunk_size() {
    frb_iw_get_chunk_size;
  }

  set chunk_size() {
    frb_iw_set_chunk_size;
  }

  get max_buffer_memory() {
    frb_iw_get_max_buffer_memory;
  }

  set max_buffer_memory() {
    frb_iw_set_max_buffer_memory;
  }

  get term_index_interval() {
    frb_iw_get_index_interval;
  }

  set term_index_interval() {
    frb_iw_set_index_interval;
  }

  get doc_skip_interval() {
    frb_iw_get_skip_interval;
  }

  set doc_skip_interval() {
    frb_iw_set_skip_interval;
  }

  get merge_factor() {
    frb_iw_get_merge_factor;
  }

  set merge_factor() {
    frb_iw_set_merge_factor;
  }

  get max_buffered_docs() {
    frb_iw_get_max_buffered_docs;
  }

  set max_buffered_docs() {
    frb_iw_set_max_buffered_docs;
  }

  get max_merge_docs() {
    frb_iw_get_max_merge_docs;
  }

  set max_merge_docs() {
    frb_iw_set_max_merge_docs;
  }

  get max_field_length() {
    frb_iw_get_max_field_length;
  }

  set max_field_length() {
    frb_iw_set_max_field_length;
  }

  get use_compound_file() {
    frb_iw_get_use_compound_file;
  }

  set use_compound_file() {
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

  term() {}
  doc_freq() {}
  skip_to() {}
  each() {}
  field() {}
  set_field() {}
  to_json() {}
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

  seek() {
    frb_tde_seek;
  }

  seek_term_enum() {
    frb_tde_seek_te;
  }

  doc() {
    frb_tde_doc;
  }

  freq() {
    frb_tde_freq;
  }

  bool next() {
    frb_tde_next;
  }

  next_position() {
    frb_tde_next_position;
  }

  each() {
    frb_tde_each;
  }

  each_position() {
    frb_tde_each_position;
  }

  skip_to() {
    frb_tde_skip_to;
  }

  to_json() {
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
  FieldInfos() {
    frb_fis_init;
  }

  to_a() {
    frb_fis_to_a;
  }

  operator [] {
    frb_fis_get;
  }

  add() {
    frb_fis_add;
  }

  operator <<() => frb_fis_add;

  add_field() {
    frb_fis_add_field;
  }

  each() {
    frb_fis_each;
  }

  to_s() {
    frb_fis_to_s;
  }

  size() {
    frb_fis_size;
  }

  create_index() {
    frb_fis_create_index;
  }

  fields() {
    frb_fis_get_fields;
  }

  tokenized_fields() {
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

  FieldInfo() {
    frb_fi_init;
  }

  name() {
    frb_fi_name;
  }

  bool stored() {
    frb_fi_is_stored;
  }

  bool compressed() {
    frb_fi_is_compressed;
  }

  bool indexed() {
    frb_fi_is_indexed;
  }

  bool tokenized() {
    frb_fi_is_tokenized;
  }

  bool omit_norms() {
    frb_fi_omit_norms;
  }

  bool store_term_vector() {
    frb_fi_store_term_vector;
  }

  bool store_positions() {
    frb_fi_store_positions;
  }

  bool store_offsets() {
    frb_fi_store_offsets;
  }

  bool has_norms() {
    frb_fi_has_norms;
  }

  boost() {
    frb_fi_boost;
  }

  to_s() {
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

  defaultDoc() {
    frb_lzd_default;
  }

  load() {
    frb_lzd_load;
  }

  fields() {
    frb_lzd_fields;
  }
}

class LazyDocData {
}

/// [IndexReader] is used for reading data from the index. This class is
/// usually used directly for more advanced tasks like iterating through
/// terms in an index, accessing term-vectors or deleting documents by
/// document id. It is also used internally by [IndexSearcher].
class IndexReader {
  IndexReader() {
    frb_ir_init;
  }

  set_norm() => frb_ir_set_norm;
  norms() => frb_ir_norms;
  get_norms_into() => frb_ir_get_norms_into;
  commit() => frb_ir_commit;
  close() => frb_ir_close;
  bool has_deletions() => frb_ir_has_deletions;
  delete() => frb_ir_delete;
  bool deleted() => frb_ir_is_deleted;
  max_doc() => frb_ir_max_doc;
  num_docs() => frb_ir_num_docs;
  undelete_all() => frb_ir_undelete_all;
  bool latest() => frb_ir_is_latest;
  get_document() => frb_ir_get_doc;
  operator []() => frb_ir_get_doc;
  term_vector() => frb_ir_term_vector;
  term_vectors() => frb_ir_term_vectors;
  term_docs() => frb_ir_term_docs;
  term_positions() => frb_ir_term_positions;
  term_docs_for() => frb_ir_term_docs_for;
  term_positions_for() => frb_ir_t_pos_for;
  doc_freq() => frb_ir_doc_freq;
  terms() => frb_ir_terms;
  terms_from() => frb_ir_terms_from;
  term_count() => frb_ir_term_count;
  fields() => frb_ir_fields;
  field_names() => frb_ir_fields;
  field_infos() => frb_ir_field_infos;
  tokenized_fields() => frb_ir_tk_fields;
  version() => frb_ir_version;
}
