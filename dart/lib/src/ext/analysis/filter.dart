part of ferret.ext.analysis;

/// [AsciiLowerCaseFilter] normalizes a token's text to lowercase but only for
/// ASCII characters. For other characters use [LowerCaseFilter].
///
///     ["One", "TWO", "three", "RÉSUMÉ"] => ["one", "two", "three", "rÉsumÉ"]
class AsciiLowerCaseFilter extends TokenStream {
  /// Create an [AsciiLowerCaseFilter] which normalizes a token's text to
  /// lowercase but only for ASCII characters. For other characters use
  /// [LowerCaseFilter].
  AsciiLowerCaseFilter(TokenStream token_stream) : super() {
    handle =
        module.callMethod('_frt_lowercase_filter_new', [token_stream.handle]);
  }
}

/// [LowerCaseFilter] normalizes a token's text to lowercase based on the
/// current locale.
///
///     ["One", "TWO", "three", "RÉSUMÉ"] => ["one", "two", "three", "résumé"]
class LowerCaseFilter extends TokenStream {
  /// Create an [LowerCaseFilter] which normalizes a token's text to
  /// lowercase based on the current locale.
  LowerCaseFilter(TokenStream token_stream) : super() {
    handle =
        module.callMethod('_frjs_lowercase_filter_init', [token_stream.handle]);
  }
}

/// [HyphenFilter] filters hyphenated words by adding both the word
/// concatenated into a single word and split into multiple words. ie "e-mail"
/// becomes "email" and "e mail". This way a search for "e-mail", "email" and
/// "mail" will all match. This filter is used by default by the
/// [StandardAnalyzer].
///
///     ["e-mail", "set-up"] => ["email", "e", "mail", "setup", "set", "up"]
class HyphenFilter extends TokenStream {
  /// Create an [HyphenFilter] which filters hyphenated words. The way it
  /// works is by adding both the word concatenated into a single word and
  /// split into multiple words. ie "e-mail" becomes "email" and "e mail".
  /// This way a search for "e-mail", "email" and "mail" will all match.
  /// This filter is used by default by the [StandardAnalyzer].
  HyphenFilter(TokenStream token_stream) : super() {
    handle = module.callMethod('_frt_hyphen_filter_new', [token_stream.handle]);
  }
}

/// A [MappingFilter] maps strings in tokens. This is usually used to map
/// UTF-8 characters to ASCII characters for easier searching and better
/// search recall. The mapping is compiled into a Deterministic Finite
/// Automata so it is super fast. This [Filter] can therefor be used for
/// indexing very large datasets. Currently regular expressions are not
/// supported.
///
///     mapping = {
///       ['à','á','â','ã','ä','å','ā','ă']         => 'a',
///       'æ'                                       => 'ae',
///       ['ď','đ']                                 => 'd',
///       ['ç','ć','č','ĉ','ċ']                     => 'c',
///       ['è','é','ê','ë','ē','ę','ě','ĕ','ė',]    => 'e',
///       ['ƒ']                                     => 'f',
///       ['ĝ','ğ','ġ','ģ']                         => 'g',
///       ['ĥ','ħ']                                 => 'h',
///       ['ì','ì','í','î','ï','ī','ĩ','ĭ']         => 'i',
///       ['į','ı','ĳ','ĵ']                         => 'j',
///       ['ķ','ĸ']                                 => 'k',
///       ['ł','ľ','ĺ','ļ','ŀ']                     => 'l',
///       ['ñ','ń','ň','ņ','ŉ','ŋ']                 => 'n',
///       ['ò','ó','ô','õ','ö','ø','ō','ő','ŏ','ŏ'] => 'o',
///       ['œ']                                     => 'oek',
///       ['ą']                                     => 'q',
///       ['ŕ','ř','ŗ']                             => 'r',
///       ['ś','š','ş','ŝ','ș']                     => 's',
///       ['ť','ţ','ŧ','ț']                         => 't',
///       ['ù','ú','û','ü','ū','ů','ű','ŭ','ũ','ų'] => 'u',
///       ['ŵ']                                     => 'w',
///       ['ý','ÿ','ŷ']                             => 'y',
///       ['ž','ż','ź']                             => 'z'
///     }
///     filt = new MappingFilter.new(token_stream, mapping);
class MappingFilter extends TokenStream {
  /// Create an [MappingFilter] which maps strings in tokens. This is usually
  /// used to map UTF-8 characters to ASCII characters for easier searching
  /// and better search recall. The mapping is compiled into a Deterministic
  /// Finite Automata so it is super fast. This Filter can therefor be used
  /// for indexing very large datasets. Currently regular expressions are not
  /// supported.
  ///
  /// [mapping] is a hash of mappings to apply to tokens. The key can be a
  /// [String] or a [List] of Strings. The value must be a [String]:
  ///
  ///     var filt = new MappingFilter(token_stream,
  ///       {
  ///         ['à','á','â','ã','ä','å'] => 'a',
  ///         ['è','é','ê','ë','ē','ę'] => 'e'
  ///       });
  MappingFilter(TokenStream token_stream, Map<List<String>, String> mapping)
      : super() {
    handle =
        module.callMethod('_frt_mapping_filter_new', [token_stream.handle]);
    mapping.forEach((List<String> patterns, String replacement) {
      int p_replacement = allocString(replacement);
      patterns.forEach((String pattern) {
        int p_pattern = allocString(pattern);
        module.callMethod(
            '_frt_mapping_filter_add', [handle, p_pattern, p_replacement]);
        free(p_pattern);
      });
      free(p_replacement);
    });
    int p_mapping = module.callMethod('_frjs_mapping_get_mapper', [handle]);
    module.callMethod('_frt_mulmap_compile', [p_mapping]);
  }
}

/// A [StopFilter] filters *stop-words* from a [TokenStream]. Stop-words are
/// words that you don't wish to be index. Usually they will be common words
/// like "the" and "and" although you can specify whichever words you want.
///
///     ["the", "pig", "and", "whistle"] => ["pig", "whistle"]
class StopFilter extends TokenStream {
  /// Create an StopFilter which removes *stop-words* from a [TokenStream].
  /// You can optionally specify the stopwords you wish to have removed.
  ///
  /// [stop_words] is a [List] of *stop-words* you wish to be filtered out.
  /// This defaults to a list of English stop-words. The Analysis library
  /// contains a number of stop-word lists.
  StopFilter(TokenStream token_stream, [List<String> stop_words]) : super() {
    if (stop_words != null) {
      int p_stop_words = module.callMethod(
          '_malloc', [Uint8List.BYTES_PER_ELEMENT * stop_words.length]);
      for (int i = 0; i < stop_words.length; i++) {
        int p_stop_word = allocString(stop_words[i]);
        module.callMethod('setValue', [
          p_stop_words + (i * Uint8List.BYTES_PER_ELEMENT),
          p_stop_word,
          'i8'
        ]);
      }
      handle = module.callMethod('_frt_stop_filter_new_with_words',
          [token_stream.handle, p_stop_words]);
      for (int i = 0; i < stop_words.length; i++) {
        free(p_stop_words + (i * Uint8List.BYTES_PER_ELEMENT));
      }
      free(p_stop_words);
    } else {
      handle = module.callMethod('_frt_stop_filter_new', [token_stream.handle]);
    }
  }
}

/// A [StemFilter] takes a term and transforms the term as per the SnowBall
/// stemming algorithm.  Note: the input to the stemming filter must already
/// be in lower case, so you will need to use LowerCaseFilter or lowercasing
/// [Tokenizer] further down the [Tokenizer] chain in order for this to work
/// properly!
///
/// # Available algorithms and encodings
///
///     Algorithm       Algorithm Pseudonyms       Encoding
///     ----------------------------------------------------------------
///      "danish",     | "da", "dan"              | "ISO_8859_1", "UTF_8"
///      "dutch",      | "dut", "nld"             | "ISO_8859_1", "UTF_8"
///      "english",    | "en", "eng"              | "ISO_8859_1", "UTF_8"
///      "finnish",    | "fi", "fin"              | "ISO_8859_1", "UTF_8"
///      "french",     | "fr", "fra", "fre"       | "ISO_8859_1", "UTF_8"
///      "german",     | "de", "deu", "ge", "ger" | "ISO_8859_1", "UTF_8"
///      "hungarian",  | "hu", "hun"              | "ISO_8859_1", "UTF_8"
///      "italian",    | "it", "ita"              | "ISO_8859_1", "UTF_8"
///      "norwegian",  | "nl", "no"               | "ISO_8859_1", "UTF_8"
///      "porter",     |                          | "ISO_8859_1", "UTF_8"
///      "portuguese", | "por", "pt"              | "ISO_8859_1", "UTF_8"
///      "romanian",   | "ro", "ron", "rum"       | "ISO_8859_2", "UTF_8"
///      "russian",    | "ru", "rus"              | "KOI8_R",     "UTF_8"
///      "spanish",    | "es", "esl"              | "ISO_8859_1", "UTF_8"
///      "swedish",    | "sv", "swe"              | "ISO_8859_1", "UTF_8"
///      "turkish",    | "tr", "tur"              |               "UTF_8"
///
/// To use this filter with other analyzers, you'll want to write an
/// [Analyzer] class that sets up the [TokenStream] chain as you want it. To
/// use this with a lowercasing [Tokenizer], for example, you'd write an
/// analyzer like this:
///
///     class MyAnalyzer extends Analyzer {
///       token_stream(field, str) {
///         return new StemFilter(new LowerCaseFilter(new StandardTokenizer(str)));
///       }
///     }
///
///     "debate debates debated debating debater"
///     => ["debat", "debat", "debat", "debat", "debat"]
class StemFilter extends TokenStream {
  /// Create an [StemFilter] which uses a snowball stemmer (thank you Martin
  /// Porter) to stem words. You can optionally specify the [algorithm] and
  /// [encoding].
  StemFilter(TokenStream token_stream,
      {String algorithm: "english", String encoding: "UTF-8"})
      : super() {
    int p_algorithm = allocString(algorithm);
    int p_charenc = allocString(encoding);
    handle = module.callMethod(
        '_frt_stem_filter_new', [token_stream.handle, p_algorithm, p_charenc]);
    free(p_algorithm);
    free(p_charenc);
    int p_stemmer =
        module.callMethod('_frjs_stem_filter_get_stemmer', [handle]);
    if (p_stemmer == 0) {
      throw new ArgumentError("No stemmer could be found with the encoding "
          "$encoding and the language $algorithm");
    }
  }
}
