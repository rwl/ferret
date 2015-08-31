part of ferret.index;

class FieldInfosUtils {
  /// Load FieldInfos from a YAML file. The YAML file should look something
  /// like this:
  ///     default:
  ///       store: :yes
  ///       index: :yes
  ///       term_vector: :no
  ///
  ///     fields:
  ///       id:
  ///         index: :untokenized
  ///         term_vector: :no
  ///
  ///       title:
  ///         boost: 20.0
  ///         term_vector: :no
  ///
  ///       content:
  ///         term_vector: :with_positions_offsets
  static load(String yaml_str) {
    var info = YAML.load(yaml_str);
    _convert_strings_to_symbols(info);
    var fis = new FieldInfos(info['default']);
    var fields = info['fields'];
    if (fields != null) {
      fields.keys.each((key) => fis.add_field(key, fields[key]));
    }
    return fis;
  }

  static _convert_strings_to_symbols(Map hash) {
    hash.keys.each((key) {
      if (hash[key] is Map) {
        _convert_strings_to_symbols(hash[key]);
      }
      if (key is String) {
        hash[key.intern] = hash[key];
        hash.delete(key);
      }
    });
  }
}
