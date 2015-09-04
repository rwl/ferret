part of ferret.ext.index;

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
class TermVector extends JsProxy {
  TermVector._handle(int hvector) : super() {
    handle = hvector;
  }

  String get field {
    int p_field = module.callMethod('_frjs_tv_get_field', [handle]);
    return stringify(p_field);
  }

  List<TVTerm> get terms {
    int term_cnt = module.callMethod('_frjs_tv_get_term_cnt', [handle]);
    var tt = new List<TVTerm>(term_cnt);
    for (int i = 0; i < term_cnt; i++) {
      int p_term = module.callMethod('_frjs_tv_get_term', [handle, i]);

      int p_text = module.callMethod('_frjs_tvt_get_text', [p_term]);
      var text = stringify(p_text);

      int freq = module.callMethod('_frjs_tvt_get_freq', [p_term]);

      var positions = new List<int>(freq);
      for (int i = 0; i < freq; i++) {
        int pos = module.callMethod('_frjs_tvt_get_position', [p_term, i]);
        positions[i] = pos;
      }

      tt[i] = new TVTerm(text, freq, positions);
    }
    return tt;
  }

  List<TVOffsets> get offsets {
    int cnt = module.callMethod('_frjs_tv_get_offset_cnt', [handle]);
    var offs = new List<TVOffsets>(cnt);
    for (int i = 0; i < cnt; i++) {
      int p_off = module.callMethod('_frjs_tv_get_offset', [handle]);

      int start = module.callMethod('_frjs_tv_offset_get_start', [p_off]);
      int end = module.callMethod('_frjs_tv_offset_get_end', [p_off]);

      offs[i] = new TVOffsets(start, end);
    }
    return offs;
  }
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
  final String text;
  final int freq;
  final List<int> positions;
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
class TermEnum extends JsProxy {

  /// Returns the next term in the enumeration or nil otherwise.
  String next() {
    return module.callMethod('_frjs_te_next', [handle]);
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
class TermDocEnum extends JsProxy {
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
  bool next() => module.callMethod('_frjs_tde_next', [handle]) != 0;

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
