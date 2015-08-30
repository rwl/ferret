library ferret.ext.analysis.analyzer;

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
abstract class Analyzer {
  Analyzer() {
    frb_letter_analyzer_init;
  }
  token_stream() => frb_analyzer_token_stream;
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
  AsciiLetterAnalyzer() {
    frb_a_letter_analyzer_init;
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
  LetterAnalyzer() {
    frb_letter_analyzer_init;
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
  AsciiWhiteSpaceAnalyzer() {
    frb_a_white_space_analyzer_init;
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
  WhiteSpaceAnalyzer() {
    frb_white_space_analyzer_init;
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
  AsciiStandardAnalyzer() {
    frb_a_standard_analyzer_init;
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
  StandardAnalyzer() {
    frb_standard_analyzer_init;
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
  PerFieldAnalyzer() {
    frb_per_field_analyzer_init;
  }

  add_field() {
    frb_per_field_analyzer_add_field;
  }

  operator []=() {
    frb_per_field_analyzer_add_field;
  }

  token_stream() {
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
  RegExpAnalyzer() {
    frb_re_analyzer_init;
  }

  token_stream() {
    frb_re_analyzer_token_stream;
  }
}