library ferret.ext.analysis.tokenizer;

/// A [LetterTokenizer] is a tokenizer that divides text at non-ASCII letters.
/// That is to say, it defines tokens as maximal strings of adjacent letters,
/// as defined by the regular expression _/[A-Za-z]+/_.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave", "s", "r", "sum", "at", "http", "www", "davebalmain", "com"]
class AsciiLetterTokenizer extends TokenStream {
  AsciiLetterTokenizer() {
    frb_a_letter_tokenizer_init;
  }
}

/// A [LetterTokenizer] is a tokenizer that divides text at non-letters. That
/// is to say, it defines tokens as maximal strings of adjacent letters, as
/// defined by the regular expression `/[[:alpha:]]+/` where [:alpha] matches
/// all characters in your local locale.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave", "s", "résumé", "at", "http", "www", "davebalmain", "com"]
class LetterTokenizer extends TokenStream {
  /// Create a new [LetterTokenizer] which optionally downcases tokens.
  /// Downcasing is done according the current locale.
  LetterTokenizer({bool lower: true}) {
    frb_letter_tokenizer_init;
  }
}

/// A [WhiteSpaceTokenizer] is a tokenizer that divides text at white-space.
/// Adjacent sequences of non-WhiteSpace characters form tokens.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave's", "résumé,", "at", "http://www.davebalmain.com", "1234"]
class AsciiWhiteSpaceTokenizer extends TokenStream {
  AsciiWhiteSpaceTokenizer() {
    frb_a_whitespace_tokenizer_init;
  }
}

/// A [WhiteSpaceTokenizer] is a tokenizer that divides text at white-space.
/// Adjacent sequences of non-WhiteSpace characters form tokens.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave's", "résumé,", "at", "http://www.davebalmain.com", "1234"]
class WhiteSpaceTokenizer extends TokenStream {
  /// Create a new [WhiteSpaceTokenizer] which optionally downcases tokens.
  /// Downcasing is done according the current locale.
  WhiteSpaceTokenizer({bool lower: true}) {
    frb_whitespace_tokenizer_init;
  }
}

/// The standard tokenizer is an advanced tokenizer which tokenizes most
/// words correctly as well as tokenizing things like email addresses, web
/// addresses, phone numbers, etc.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave's", "r", "sum", "at", "http://www.davebalmain.com", "1234"]
class AsciiStandardTokenizer extends TokenStream {
  AsciiStandardTokenizer() {
    frb_a_standard_tokenizer_init;
  }
}

/// The standard tokenizer is an advanced tokenizer which tokenizes most
/// words correctly as well as tokenizing things like email addresses, web
/// addresses, phone numbers, etc.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave's", "résumé", "at", "http://www.davebalmain.com", "1234"]
class StandardTokenizer extends TokenStream {
  /// Create a new StandardTokenizer which optionally downcases tokens.
  /// Downcasing is done according the current locale.
  StandardTokenizer({bool lower: true}) {
    frb_standard_tokenizer_init
  }
}

/// A tokenizer that recognizes tokens based on a regular expression passed to
/// the constructor. Most possible tokenizers can be created using this class.
///
/// Below is an example of a simple implementation of a [LetterTokenizer]
/// using an [RegExpTokenizer]. Basically, a token is a sequence of alphabetic
/// characters separated by one or more non-alphabetic characters.
///
///     // of course you would add more than just é
///     new RegExpTokenizer(input, /[[:alpha:]é]+/);
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave", "s", "résumé", "at", "http", "www", "davebalmain", "com"]
class RegExpTokenizer extends TokenStream {
  /// Create a new tokenizer based on a regular expression.
  RegExpTokenizer(String text, RegExp regexp) {
    frb_rets_init;
  }

  /// Set the text to be tokenized by the tokenizer. The tokenizer gets reset
  /// to tokenize the text from the beginning.
  set text() => frb_rets_set_text;

  /// Get the text being tokenized by the tokenizer.
  get text() => frb_rets_get_text;
}
