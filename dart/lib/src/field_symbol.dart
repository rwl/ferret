//final FIELD_TYPES = %w(integer float string byte).map{|t| t.to_sym}

/*if defined?(BasicObject)
  /// Ruby 1.9.x
  class BlankSlate < BasicObject
  end
else
  /// Ruby 1.8.x
  /// BlankSlate is a class with no instance methods except for __send__ and
  /// __id__. It is useful for creating proxy classes. It is currently used by
  /// the FieldSymbol class which is a proxy to the Symbol class
  class BlankSlate
    instance_methods.each { |m| undef_method m unless m =~ /^__|object_id/ }
  end
end*/

/// The [FieldSymbolMethods] module contains the methods that are added to
/// both the [Symbol] class and the [FieldSymbol] class. These methods allow
/// you to set the type easily set the type of a field by calling a method on
/// a symbol.
///
/// Right now this is only useful for [Sorting] and grouping, but some day
/// Ferret may have typed fields, in which case these this methods will come
/// in handy.
///
/// The available types are specified in [FIELD_TYPES].
///
///     index.search(query, sort: title.string.desc);
///
///     index.search(query, sort: [price.float, count.integer.desc]);
///
///     index.search(query, group_by: catalogue.string);
///
/// If you set the field type multiple times, the last type specified will be
/// the type used. For example;
///
///     print title.integer.float.byte.string.type.inspect // => string
///
/// Calling [desc] twice will set [desc]? to false:
///
///     print(title.desc);           // => false
///     print(title.desc.desc);      // => true
///     print(title.desc.desc.desc); // => false
class FieldSymbolMethods {
  /*FIELD_TYPES.each do |method|
    define_method(method) do
      fsym = FieldSymbol.new(self, respond_to?(:desc?) ? desc? : false)
      fsym.type = method
      fsym
    end
  end*/

  /// Set a field to be a descending field. This only makes sense in sort
  /// specifications.
  _desc() {
    var fsym = new FieldSymbol(self, respond_to('desc' /*?*/) ? !desc() : true);
    if (respond_to('type')) {
      fsym.type = type;
    }
    return fsym;
  }

  /// Return whether or not this field should be a descending field.
  bool desc() => _desc == true;

  /// Return the type of this field;
  type() => _type || null;
}

/// See [FieldSymbolMethods]
class FieldSymbol extends Object with FieldSymbolMethods {
  FieldSymbol(symbol, [desc = false]) {
    _symbol = symbol;
    _desc = desc;
  }

  method_missing(method, args) {
    //@symbol.__send__(method, *args)
  }

  //attr_writer :type, :desc
}

/// See [FieldSymbolMethods]
class Symbol extends Object with FieldSymbolMethods {}
