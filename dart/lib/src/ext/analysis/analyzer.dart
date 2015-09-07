part of ferret.ext.analysis;

/// An [Analyzer] builds [TokenStream]s, which analyze text. It thus
/// represents a policy for extracting index terms from text.
///
/// Typical implementations first build a [Tokenizer], which breaks the stream
/// of characters from the [Reader] into raw [Token]s. One or more
/// [TokenFilter]s may then be applied to the output of the [Tokenizer].
///
/// The default [Analyzer] just creates a [LowerCaseTokenizer] which converts
/// all text to lowercase tokens. See [LowerCaseTokenizer] for more details.
///
/// To create your own custom Analyzer you simply need to implement a
/// [token_stream] method which takes the field name and the data to be
/// tokenized as parameters and returns a [TokenStream]. Most analyzers
/// typically ignore the field name.
///
/// Here we'll create a StemmingAnalyzer:
///
///     class MyAnalyzer extends Analyzer {
///       token_stream(field, str) {
///         return new StemFilter(new LowerCaseFilter(new StandardTokenizer(str)));
///       }
///     }
abstract class Analyzer extends JsProxy {
  /// Create a new [LetterAnalyzer] which downcases tokens by default but can
  /// optionally leave case as is. Lowercasing will be done based on the current
  /// locale.
  Analyzer(/*{bool lower: true}*/) : super() {
//    frb_letter_analyzer_init;
  }

  TokenStream _makeTokenStream(int h_ts);

  /// Create a new [TokenStream] to tokenize [input]. The [TokenStream]
  /// created may also depend on the [field_name]. Although this parameter
  /// is typically ignored.
  TokenStream token_stream(String field_name, String input) {
    int p_field = allocString(field_name);
    int p_text = allocString(input);
    int p_ts = module.callMethod(
        '_frjs_analyzer_token_stream', [handle, p_field, p_text]);
    free(p_field);
    free(p_text);
    var ts = _makeTokenStream(p_ts);
    //ts.text = input;
    return ts;
  }
}

/// An [AsciiLetterAnalyzer] creates a [TokenStream] that splits the input up
/// into maximal strings of ASCII characters. If implemented in Dart it would
/// look like:
///
///     class AsciiLetterAnalyzer extends Analyzer {
///       AsciiLetterAnalyzer([lower = true]) {
///         _lower = lower;
///       }
///
///       token_stream(field, str) {
///         if (_lower) {
///           return new AsciiLowerCaseFilter(new AsciiLetterTokenizer(str));
///         } else {
///           return new AsciiLetterTokenizer(str);
///         }
///       }
///     }
///
/// As you can see it makes use of the [AsciiLetterTokenizer] and
/// [AsciiLowerCaseFilter]. Note that this tokenizer won't recognize non-ASCII
/// characters so you should use the [LetterAnalyzer] is you want to analyze
/// multi-byte data like "UTF-8".
class AsciiLetterAnalyzer extends Analyzer {
  /// Create a new [AsciiWhiteSpaceAnalyzer] which downcases tokens by default
  /// but can optionally leave case as is. Lowercasing will only be done to
  /// ASCII characters.
  AsciiLetterAnalyzer({bool lower: true}) {
    handle = module.callMethod('_frt_letter_analyzer_new', [lower ? 1 : 0]);
  }

  TokenStream _makeTokenStream(int h_ts) {
    return new AsciiLetterTokenizer._handle(h_ts);
  }
}

/// A [LetterAnalyzer] creates a [TokenStream] that splits the input up into
/// maximal strings of characters as recognized by the current locale. If
/// implemented in Dart it would look like:
///
///     class LetterAnalyzer extends Analyzer {
///       LetterAnalyzer([lower = true]) {
///         _lower = lower;
///       }
///
///       token_stream(field, str) {
///         return new LetterTokenizer(str, _lower);
///       }
///     }
///
/// As you can see it makes use of the [LetterTokenizer].
class LetterAnalyzer extends Analyzer {
  /// Create a new [LetterAnalyzer] which downcases tokens by default but can
  /// optionally leave case as is. Lowercasing will be done based on the
  /// current locale.
  LetterAnalyzer({bool lower: true}) {
    handle = module.callMethod('_frjs_letter_analyzer_init', [lower ? 1 : 0]);
  }

  TokenStream _makeTokenStream(int h_ts) {
    return new LetterTokenizer._handle(h_ts);
  }
}

/// The [AsciiWhiteSpaceAnalyzer] recognizes tokens as maximal strings of
/// non-whitespace characters. If implemented in Dart the
/// [AsciiWhiteSpaceAnalyzer] would look like:
///
///     class AsciiWhiteSpaceAnalyzer extends Analyzer {
///       AsciiWhiteSpaceAnalyzer([lower = true]) {
///         _lower = lower;
///       }
///
///       token_stream(field, str) {
///         if (_lower_ {
///           return new AsciiLowerCaseFilter(new AsciiWhiteSpaceTokenizer(str));
///         } else {
///           return new AsciiWhiteSpaceTokenizer(str);
///         }
///       }
///     }
///
/// As you can see it makes use of the [AsciiWhiteSpaceTokenizer]. You should
/// use [WhiteSpaceAnalyzer] if you want to recognize multibyte encodings such
/// as "UTF-8".
class AsciiWhiteSpaceAnalyzer extends Analyzer {
  /// Create a new [AsciiWhiteSpaceAnalyzer] which downcases tokens by default
  /// but can optionally leave case as is. Lowercasing will only be done to
  /// ASCII characters.
  AsciiWhiteSpaceAnalyzer({bool lower: true}) {
    handle = module.callMethod('_frt_whitespace_analyzer_new', [lower ? 1 : 0]);
  }

  TokenStream _makeTokenStream(int h_ts) {
    return new AsciiWhiteSpaceTokenizer._handle(h_ts);
  }
}

/// The [WhiteSpaceAnalyzer] recognizes tokens as maximal strings of
/// non-whitespace characters. If implemented in Dart the [WhiteSpaceAnalyzer]
/// would look like:
///
///     class WhiteSpaceAnalyzer extends Analyzer {
///       WhiteSpaceAnalyzer([lower = true]) {
///         _lower = lower;
///       }
///
///       token_stream(field, str) {
///         return new WhiteSpaceTokenizer(str, _lower);
///       }
///     }
///
/// As you can see it makes use of the [WhiteSpaceTokenizer].
class WhiteSpaceAnalyzer extends Analyzer {
  /// Create a new [WhiteSpaceAnalyzer] which downcases tokens by default but
  /// can optionally leave case as is. Lowercasing will be done based on the
  /// current locale.
  WhiteSpaceAnalyzer({bool lower: true}) {
    handle =
        module.callMethod('_frjs_white_space_analyzer_init', [lower ? 1 : 0]);
  }

  TokenStream _makeTokenStream(int h_ts) {
    return new WhiteSpaceTokenizer._handle(h_ts);
  }
}

/// The [AsciiStandardAnalyzer] is the most advanced of the available
/// ASCII-analyzers. If it were implemented in Dart it would look like this:
///
///     class AsciiStandardAnalyzer extends Analyzer {
///       AsciiStandardAnalyzer([stop_words = FULL_ENGLISH_STOP_WORDS, lower = true]) {
///         _lower = lower;
///         _stop_words = stop_words;
///       }
///
///       token_stream(field, str) {
///         var ts = new AsciiStandardTokenizer(str);
///         if (_lower) {
///           ts = new AsciiLowerCaseFilter(ts);
///         }
///         ts = new StopFilter(ts, _stop_words);
///         ts = new HyphenFilter(ts);
///       }
///     }
///
/// As you can see it makes use of the [AsciiStandardTokenizer] and you can
/// also add your own list of stop-words if you wish. Note that this tokenizer
/// won't recognize non-ASCII characters so you should use the
/// [StandardAnalyzer] is you want to analyze multi-byte data like "UTF-8".
class AsciiStandardAnalyzer extends Analyzer {
  /// Create a new [AsciiStandardAnalyzer] which downcases tokens by default
  /// but can optionally leave case as is. Lowercasing will be done based on
  /// the current locale. You can also set the list of stop-words to be used
  /// by the [StopFilter].
  AsciiStandardAnalyzer(
      {lower: true, stop_words /*: FULL_ENGLISH_STOP_WORDS*/}) {
    int p_stop_words = 0; // FIXME
    handle = module.callMethod(
        '_frjs_a_standard_analyzer_init', [lower ? 1 : 0, p_stop_words]);
  }

  TokenStream _makeTokenStream(int h_ts) {
    return new AsciiStandardTokenizer._handle(h_ts);
  }
}

/// The [StandardAnalyzer] is the most advanced of the available analyzers. If
/// it were implemented in Dart it would look like this:
///
///     class StandardAnalyzer extends Analyzer {
///       StandardAnalyzer([stop_words = FULL_ENGLISH_STOP_WORDS, lower = true]) {
///         _lower = lower;
///         _stop_words = stop_words;
///       }
///
///       token_stream(field, str) {
///         var ts = new StandardTokenizer(str);
///         if (_lower) {
///           ts = new LowerCaseFilter(ts);
///         }
///         ts = new StopFilter(ts, _stop_words);
///         ts = new HyphenFilter(ts);
///       }
///     }
/// As you can see it makes use of the StandardTokenizer and you can also add
/// your own list of stopwords if you wish.
class StandardAnalyzer extends Analyzer {
  /// Create a new [StandardAnalyzer] which downcases tokens by default but
  /// can optionally leave case as is. Lowercasing will be done based on the
  /// current locale. You can also set the list of stop-words to be used by
  /// the [StopFilter].
  StandardAnalyzer({lower: true /*, stop_words : FULL_ENGLISH_STOP_WORDS*/}) {
    int _lower = lower ? 1 : 0;
    int p_stop_words = 0; // FIXME
    handle = module.callMethod(
        '_frjs_standard_analyzer_init', [_lower, p_stop_words]);
  }

  TokenStream _makeTokenStream(int h_ts) {
    return new StandardTokenizer._handle(h_ts);
  }
}

/// The [PerFieldAnalyzer] is for use when you want to analyze different
/// fields with different analyzers. With the PerFieldAnalyzer you can specify
/// how you want each field analyzed.
///
///     // Create a new PerFieldAnalyzer which uses StandardAnalyzer by default
///     var pfa = new PerFieldAnalyzer(new StandardAnalyzer());
///
///     // Use the WhiteSpaceAnalyzer with no lowercasing on the 'title' field
///     pfa['title'] = new WhiteSpaceAnalyzer(false);
///
///     // Use a custom analyzer on the 'created_at' field
///     pfa['created_at'] = new DateAnalyzer();
class PerFieldAnalyzer extends Analyzer {
  /// Create a new [PerFieldAnalyzer] specifying the default analyzer to use
  /// on all fields that are set specifically.
  PerFieldAnalyzer(Analyzer default_analyzer) {
    frb_per_field_analyzer_init;
  }

  /// Set the analyzer to be used on field [field_name].
  add_field(String field_name, Analyzer default_analyzer) {
    frb_per_field_analyzer_add_field;
  }

  /// Alias for [add_field].
  operator []=(String field_name, Analyzer default_analyzer) {
    frb_per_field_analyzer_add_field;
  }

  /// Create a new [TokenStream] to tokenize [input]. The [TokenStream]
  /// created will also depend on the [field_name] in the case of the
  /// [PerFieldAnalyzer].
  TokenStream token_stream(String field_name, input) {
    frb_pfa_analyzer_token_stream;
  }
}

/// Using a [RegExpAnalyzer] is a simple way to create a custom analyzer. If
/// implemented in Dart it would look like this:
///
///     class RegExpAnalyzer extends Analyzer {
///       RegExpAnalyzer(reg_exp, [lower = true]) {
///         _lower = lower;
///         _reg_exp = reg_exp;
///       }
///
///       token_stream(field, str) {
///         if (_lower) {
///           return new LowerCaseFilter(new RegExpTokenizer(str, reg_exp));
///         } else {
///           return new RegExpTokenizer(str, reg_exp);
///         }
///       }
///     }
///
/// Example:
///
///     var csv_analyzer = new RegExpAnalyzer(r"[^,]+", false);
class RegExpAnalyzer extends Analyzer {
  /// Create a new [RegExpAnalyzer] which will create tokenizers based on the
  /// regular expression and lowercasing if required.
  RegExpAnalyzer(RegExp reg_exp, {bool lower: true}) {
    frb_re_analyzer_init;
  }

  /// Create a new [TokenStream] to tokenize [input]. The [TokenStream]
  /// created may also depend on the [field_name]. Although this parameter
  /// is typically ignored.
  TokenStream token_stream(String field_name, input) {
    frb_re_analyzer_token_stream;
  }
}
