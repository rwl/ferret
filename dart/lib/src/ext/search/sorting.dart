part of ferret.ext.search;

enum SortType { SCORE, DOC, BYTE, INTEGER, FLOAT, STRING, AUTO }

/// A [SortField] is used to sort the result-set of a search be the contents
/// of a field. The following types of [sort_field] are available:
///
/// * auto
/// * integer
/// * float
/// * string
/// * byte
/// * doc_id
/// * score
///
/// The type of the [SortField] is set by passing it as a parameter to the
/// constructor. The `auto` type specifies that the [SortField] should detect
/// the sort type by looking at the data in the field. This is the default
/// [type] value although it is recommended that you explicitly specify the
/// fields type.
///
///     var title_sf = new SortField('title', type: 'string');
///     var rating_sf = new SortField('rating', type: 'float', reverse: true);
///
/// Note 1: Care should be taken when using the :auto sort-type since numbers
/// will occur before other strings in the index so if you are sorting a field
/// with both numbers and strings (like a title field which might have "24"
/// and "Prison Break") then the sort_field will think it is sorting integers
/// when it really should be sorting strings.
///
/// Note 2: When sorting by integer, integers are only 4 bytes so anything
/// larger will cause strange sorting behaviour.
class SortField {
  final Ferret _ferret;
  final int handle;

  SortField.wrap(this._ferret, this.handle);

  /// Create a new [SortField] which can be used to sort the result-set by the
  /// value in field [field].
  ///
  /// [type] specifies how a field should be sorted. Choose from one of;
  /// `auto`, `integer`, `float`, `string`, `byte`, `doc_id` or `score`.
  /// `auto` will check the datatype of the field by trying to parse it into
  /// either a number or a float before settling on a string sort. String sort
  /// is locale dependent and works for multibyte character sets like UTF-8 if
  /// you have your locale set correctly.
  /// Set [reverse] to `true` if you want to reverse the sort.
  factory SortField(Ferret ferret, String field,
      {SortType type: SortType.AUTO, bool reverse: false}) {
    int p_field = ferret.allocString(field);
    int symbol = ferret.callMethod('_frt_internal', [p_field]);
    ferret.free(p_field);
    int h = ferret.callMethod(
        '_frt_sort_field_new', [symbol, type.index, reverse ? 1 : 0]);
    return new SortField.wrap(ferret, h);
  }

  /// Return `true` if the field is to be reverse sorted. This attribute is
  /// set when you create the sort_field.
  bool get reverse => _ferret.callMethod('_frjs_sf_is_reverse', [handle]) != 0;

  void _reverse() {
    _ferret.callMethod('_frjs_sort_field_reverse', [handle]);
  }

  /// Returns the name of the field to be sorted.
  String get name {
    int p_name = _ferret.callMethod('_frjs_sf_get_name', [handle]);
    return _ferret.stringify(p_name);
  }

  /// Return the type of sort. Should be one of; `auto`, `integer`, `float`,
  /// `string`, `byte`, `doc_id` or `score`.
  SortType type() {
    int t = _ferret.callMethod('_frjs_sf_get_type', [handle]);
    return SortType.values[t];
  }

  /// TODO: currently unsupported
  //comparator() => frb_sf_get_comparator;

  /// Return a human readable string describing this sort_field.
  String to_s() {
    int p_s = _ferret.callMethod('_sort_field_to_s', [handle]);
    var s = _ferret.stringify(p_s);
    _ferret.free(p_s);
    return s;
  }

  static SortField SCORE;
  static SortField SCORE_REV;
  static SortField DOC;
  static SortField DOC_REV;
}

/// A [Sort] object is used to combine and apply a list of [SortField]s. The
/// [SortField]s are applied in the order they are added to the [SortObject].
///
/// Here is how you would create a [Sort] object that sorts first by rating
/// and then by title:
///
///     var sf_rating = new SortField('rating', type: 'float', reverse: true);
///     var sf_title = new SortField('title', type: 'string');
///     var sort = new Sort([sf_rating, sf_title]);
///
/// Remember that the [type] parameter for [SortField] is set to `auto` be
/// default be I strongly recommend you specify a `type` value.
class Sort {
  final Ferret _ferret;
  final int handle;

  Sort._(this._ferret, this.handle);

  /// Create a new Sort object. If [reverse] is true, all sort_fields will be
  /// reversed so if any of them are already reversed the will be turned back
  /// to their natural order again.
  factory Sort(Ferret ferret,
      {List<SortField> sort_fields, bool reverse: false}) {
    if (sort_fields == null) {
      sort_fields = [SortField.SCORE, SortField.DOC];
    }
    int h = ferret.callMethod('_frt_sort_new');
    ferret.callMethod('_frjs_sort_set_destroy_all', [h, 0]);
    for (var sf in sort_fields) {
      if (reverse) {
        sf._reverse();
      }
      ferret.callMethod('_frt_sort_add_sort_field', [h, sf.handle]);
    }
    if (!sort_fields.contains(SortField.DOC)) {
      ferret.callMethod('_frt_sort_add_sort_field', [h, SortField.DOC.handle]);
    }
    return new Sort._(ferret, h);
  }

  /// Returns an array of the [SortField]s held by the [Sort] object.
  List<SortField> get fields {
    int size = _ferret.callMethod('_frjs_sort_get_size', [handle]);
    var a = new List<SortField>(size);
    for (int i = 0; i < size; i++) {
      int p_sf = _ferret.callMethod('_frjs_sort_get_sort_field', [handle, i]);
      a[i] = new SortField.wrap(_ferret, p_sf);
    }
    return a;
  }

  /// Returns a human readable string representing the sort object.
  String to_s() {
    int p_s = _ferret.callMethod('_frt_sort_to_s', [handle]);
    var s = _ferret.stringify(p_s);
    _ferret.free(p_s);
    return s;
  }

  static Sort RELEVANCE;
  static Sort INDEX_ORDER;
}
