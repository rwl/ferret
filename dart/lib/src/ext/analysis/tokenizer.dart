part of ferret.ext.analysis;

/// A [LetterTokenizer] is a tokenizer that divides text at non-ASCII letters.
/// That is to say, it defines tokens as maximal strings of adjacent letters,
/// as defined by the regular expression _/[A-Za-z]+/_.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave", "s", "r", "sum", "at", "http", "www", "davebalmain", "com"]
class AsciiLetterTokenizer extends TokenStream {
  AsciiLetterTokenizer(Ferret ferret, String text)
      : super.wrap(ferret, ferret.callFunc('frt_letter_tokenizer_new')) {
    this.text = text;
  }

  AsciiLetterTokenizer._handle(Ferret ferret, int h) : super.wrap(ferret, h);
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
  LetterTokenizer(Ferret ferret, String text, {bool lower: true})
      : super.wrap(ferret,
            ferret.callFunc('frjs_letter_tokenizer_init', [lower ? 1 : 0])) {
    this.text = text;
  }

  LetterTokenizer._handle(Ferret ferret, int h) : super.wrap(ferret, h);
}

/// A [WhiteSpaceTokenizer] is a tokenizer that divides text at white-space.
/// Adjacent sequences of non-WhiteSpace characters form tokens.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave's", "résumé,", "at", "http://www.davebalmain.com", "1234"]
class AsciiWhiteSpaceTokenizer extends TokenStream {
  AsciiWhiteSpaceTokenizer(Ferret ferret, String text)
      : super.wrap(ferret, ferret.callFunc('frt_whitespace_tokenizer_new')) {
    this.text = text;
  }

  AsciiWhiteSpaceTokenizer._handle(Ferret ferret, int h)
      : super.wrap(ferret, h);
}

/// A [WhiteSpaceTokenizer] is a tokenizer that divides text at white-space.
/// Adjacent sequences of non-WhiteSpace characters form tokens.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave's", "résumé,", "at", "http://www.davebalmain.com", "1234"]
class WhiteSpaceTokenizer extends TokenStream {
  /// Create a new [WhiteSpaceTokenizer] which optionally downcases tokens.
  /// Downcasing is done according the current locale.
  WhiteSpaceTokenizer(Ferret ferret, String text, {bool lower: true})
      : super.wrap(
            ferret,
            ferret.callFunc(
                'frjs_whitespace_tokenizer_init', [lower ? 1 : 0])) {
    this.text = text;
  }

  WhiteSpaceTokenizer._handle(Ferret ferret, int h) : super.wrap(ferret, h);
}

/// The standard tokenizer is an advanced tokenizer which tokenizes most
/// words correctly as well as tokenizing things like email addresses, web
/// addresses, phone numbers, etc.
///
///     "Dave's résumé, at http://www.davebalmain.com/ 1234"
///     => ["Dave's", "r", "sum", "at", "http://www.davebalmain.com", "1234"]
class AsciiStandardTokenizer extends TokenStream {
  AsciiStandardTokenizer(Ferret ferret, String text)
      : super.wrap(ferret, ferret.callFunc('frt_standard_tokenizer_new')) {
    this.text = text;
  }

  AsciiStandardTokenizer._handle(Ferret ferret, int h) : super.wrap(ferret, h);
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
  StandardTokenizer(Ferret ferret, String text, {bool lower: true})
      : super.wrap(ferret, ferret.callFunc('frjs_standard_tokenizer_init')) {
    this.text = text;
  }

  StandardTokenizer._handle(Ferret ferret, int h) : super.wrap(ferret, h);
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
  RegExpTokenizer(Ferret ferret, String text, RegExp regexp)
      : super.wrap(ferret, frb_rets_init);

  /// Set the text to be tokenized by the tokenizer. The tokenizer gets reset
  /// to tokenize the text from the beginning.
  void set text(String val) => frb_rets_set_text;

  /// Get the text being tokenized by the tokenizer.
  String get text => frb_rets_get_text;
}
