part of ferret.ext.index;

/// [IndexReader] is used for reading data from the index. This class is
/// usually used directly for more advanced tasks like iterating through
/// terms in an index, accessing term-vectors or deleting documents by
/// document id. It is also used internally by [IndexSearcher].
class IndexReader extends JsProxy {
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
  IndexReader(Directory dir) : super() {
    if (dir is List) {
      throw dir; // FIXME
    } else if (dir is Directory) {
      handle = module.callMethod('_frt_ir_open', [dir.handle]);
    } else if (dir is String) {
      throw dir; // FIXME
    }
  }

  /// Expert: change the boost value for a [field] in document at [doc_id].
  /// [val] should be an integer in the range 0..255 which corresponds to an
  /// encoded float value.
  //void set_norm(int doc_id, String field, int val) => frb_ir_set_norm;

  /// Expert: Returns a string containing the norm values for a field. The
  /// string length will be equal to the number of documents in the index and
  /// it could have null bytes.
  //String norms(String field) => frb_ir_norms;

  /// Expert: Get the norm values into a string [buffer] starting at [offset].
  //StringBuffer get_norms_into(field, StringBuffer buffer, int offset) =>
  //    frb_ir_get_norms_into;

  /// Commit any deletes made by this particular [IndexReader] to the index. This
  /// will use open a Commit lock.
  void commit() => module.callMethod('_frjs_ir_commit', [handle]);

  /// Close the [IndexReader]. This method also commits any deletions made by
  /// this [IndexReader]. This method will be called explicitly by the garbage
  /// collector but you should call it explicitly to commit any changes as
  /// soon as possible and to close any locks held by the object to prevent
  /// locking errors.
  close() => module.callMethod('_frt_ir_close', [handle]);

  /// Return `true` if the index has any deletions, either uncommitted by this
  /// [IndexReader] or committed by any other [IndexReader].
  bool has_deletions() => module.callMethod('_frjs_ir_has_deletions', [handle]);

  /// Delete document referenced internally by document id [doc_id]. The
  /// document_id is the number used to reference documents in the index and
  /// is returned by search methods.
  void delete(int doc_id) =>
      module.callMethod('_frt_ir_delete_doc', [handle, doc_id]);

  /// Returns `true` if the document at [doc_id] has been deleted.
  bool deleted(int doc_id) =>
      module.callMethod('_frjs_ir_is_deleted', [handle]) != 0;

  /// Returns 1 + the maximum document id in the index. It is the
  /// document_id that will be used by the next document added to the index.
  /// If there are no deletions, this number also refers to the number of
  /// documents in the index.
  num max_doc() => module.callMethod('_frjs_ir_max_doc', [handle]);

  /// Returns the number of accessible (not deleted) documents in the index.
  /// This will be equal to [max_doc] if there have been no documents deleted
  /// from the index.
  int num_docs() => module.callMethod('_frjs_ir_num_docs', [handle]);

  /// Undelete all deleted documents in the index. This is kind of like a
  /// rollback feature. Not that once an index is committed or a merge happens
  /// during index, deletions will be committed and undelete_all will have no
  /// effect on these documents.
  void undelete_all() => module.callMethod('_frt_ir_undelete_all', [handle]);

  /// Return true if the index version referenced by this [IndexReader] is the
  /// latest version of the index. If it isn't you should close and reopen the
  /// index to search the latest documents added to the index.
  bool latest() => module.callMethod('_frt_ir_is_latest', [handle]) != 0;

  /// Retrieve a document from the index. See [LazyDoc] for more details on
  /// the document returned. Documents are referenced internally by document
  /// ids which are returned by the Searchers search methods.
  LazyDoc get_document(int id) {
    int max = max_doc();
    int pos = (id < 0) ? (max + id) : id;
    if (pos < 0 || pos >= max) {
      throw new ArgumentError("index $pos is out of range [0..$max] for "
          "IndexReader.get_document");
    }

    int p_doc = module.callMethod('_frjs_ir_get_lazy_doc', [handle, pos]);

    return new LazyDoc()..handle = p_doc;
  }

  /// Alias for [get_document].
  LazyDoc operator [](int id) => get_document(id);

  /// Return the [TermVector] for the field [field] in the document at
  /// [doc_id] in the index. Return `null` if no such term_vector exists.
  TermVector term_vector(int doc_id, String field) {
    int p_field = allocString(field);
    int p_tv =
        module.callMethod('_frjs_ir_term_vector', [handle, doc_id, p_field]);
    free(p_field);
    return new TermVector._handle(p_tv);
  }

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
  TermDocEnum term_docs_for(String field, String term) {
    int p_field = allocString(field);
    int symbol = module.callMethod('_frt_intern', [p_field]);
    free(p_field);

    int p_term = allocString(term);
    int p_tde =
        module.callMethod('_frt_ir_term_docs_for', [handle, symbol, p_term]);
    free(p_term);

    return new TermDocEnum()..handle = p_tde;
  }

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
