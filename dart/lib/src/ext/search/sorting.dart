library ferret.ext.search.sorting;

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
  var _type;
  var _reverse;
  var _comparator;

  /* Sort types */
  var integer;
  var float;
  var string;
  var auto;
  var doc_id;
  var score;
  var byte;

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
  SortField(field, {type: 'auto', bool reverse: false}) {
    frb_sf_init;
  }

  /// Return `true` if the field is to be reverse sorted. This attribute is
  /// set when you create the sort_field.
  bool get reverse => frb_sf_is_reverse;

  /// Returns the name of the field to be sorted.
  String get name => frb_sf_get_name;

  /// Return the type of sort. Should be one of; `auto`, `integer`, `float`,
  /// `string`, `byte`, `doc_id` or `score`.
  type() => frb_sf_get_type;

  /// TODO: currently unsupported
  comparator() => frb_sf_get_comparator;

  /// Return a human readable string describing this sort_field.
  to_s() => frb_sf_to_s;

  static final ScoreField SCORE;
  static final ScoreField SCORE_REV;
  static final ScoreField DOC_ID;
  static final ScoreField DOC_ID_REV;
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
  /// Create a new Sort object. If [reverse] is true, all sort_fields will be
  /// reversed so if any of them are already reversed the  will be turned back
  /// to their natural order again.
  Sort({sort_fields: const [SortField::SCORE, SortField::DOC_ID], reverse: false}) {
    frb_sort_init;
  }

  /// Returns an array of the [SortField]s held by the [Sort] object.
  List<SortField> get fields => frb_sort_get_fields;

  /// Returns a human readable string representing the sort object.
  String to_s() => frb_sort_to_s;

  static final Sort RELEVANCE;
  static final Sort INDEX_ORDER;
}
