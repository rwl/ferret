library ferret.document;

import 'dart:collection';

/// Instead of using documents to add data to an index you can use Hashes and
/// Arrays. The only real benefits of using a Document over a Hash are pretty
/// printing and the boost attribute. You can add the boost attribute to
/// Hashes and arrays using the BoostMixin. For example;
///
///    class Hash
///      include BoostMixin
///    end
///
///    class Array
///      include BoostMixin
///    end
///
///    class String
///      include BoostMixin
///    end
class BoostMixin {
  var boost;
}

/// Documents are the unit of indexing and search.
///
/// A Document is a set of fields. Each field has a name and an array of
/// textual values. If you are coming from a Lucene background you should note
/// that [Field]s don't have any properties except for the boost property. You
/// should use the [FieldInfos] class to set field properties
/// across the whole index instead.
///
/// The boost attribute makes a [Document] more important in the index. That
/// is, you can increase the score of a match for queries that match a
/// particular document, making it more likely to appear at the top of search
/// results.
/// You may, for example, want to boost products that have a higher user
/// rating so that they are more likely to appear in search results.
///
/// Note: that fields which are _not_ stored (see [FieldInfos])
/// are _not_ available in documents retrieved from the index, e.g.
/// [Searcher.doc] or [IndexReader.doc].
///
/// Note: that modifying a [Document] retrieved from the index will not modify
/// the document contained within the index. You need to delete the old
/// version of the document and add the new version of the document.
class Document extends MapBase with BoostMixin {

  /// Create a new Document object with a boost. The boost defaults to 1.0.
  Document([boost = 1.0]) {
    this.boost = boost;
  }

  /// Return true if the documents are equal, ie they have the same fields
  bool eql(o) {
    return (o is Document &&
        (o.boost == this.boost) &&
        (this.keys == o.keys) &&
        (this.values == o.values));
  }
  //alias :== :eql?

  /// Create a string representation of the document
  to_s() {
    var buf = new StringBuffer("Document {");
    this.keys.sort_by((key) => key.to_s).each((key) {
      var val = this[key];
      var val_str;
      if (val is List) {
        //val_str = %{["#{val.join('", "')}"]}
      } else if (val is Field) {
        val_str = val.to_s();
      } else {
        //val_str = %{"#{val.to_s}"}
      }
      buf.write("  :#{key} => #{val_str}");
    });
    buf.write(["}#{@boost == 1.0 ? " " : " ^ " + @boost.to_s}"]);
    return buf.join("\n");
  }
}

/// A [Field] is a section of a [Document]. A [Field] is basically an array
/// with a boost attribute. It also provides pretty printing of the field
/// with the [to_s] method.
///
/// The boost attribute makes a field more important in the index. That is,
/// you can increase the score of a match for queries that match terms in a
/// boosted field. You may, for example, want to boost a title field so that
/// matches that match in the `title` field score more highly than matches
/// that match in the `contents` field.
///
/// Note: If you'd like to use boosted fields without having to use
/// the [Field] class you can just include the [BoostMixin] in the [List]
/// class.
class Field extends ListBase with BoostMixin {

  /// Create a new [Field] object. You can pass data to the field as either a
  /// string;
  ///
  ///     var f = new Field("This is the fields data");
  ///
  /// or as an array of strings;
  ///
  ///     var f = new Field(["this", "is", "an", "array", "of", "field", "data"]);
  ///
  /// Of course Fields can also be boosted;
  ///
  ///     var f = new Field("field data", 1000.0);
  Field([data = null, boost = 1.0]) {
    if (data == null) {
      data = [];
    }
    this.boost = boost;
    if (data is List) {
      data.each((v) => this.add(v));
    } else {
      this.add(data.to_s);
    }
  }

  bool eql(o) {
    return (o is Field && (o.boost == this.boost) && super.eql(o));
  }
  //alias :== :eql?

  add(o) {
    return new Field(super.add(o), this.boost);
  }

  String to_s() {
    var buf = ''; //%{["#{self.join('", "')}"]};
    if (boost != 1.0) {
      buf += "^#@boost";
    }
    return buf;
  }
}
