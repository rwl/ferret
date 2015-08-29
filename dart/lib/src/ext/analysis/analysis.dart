///The Analysis library contains all the classes used to analyze and tokenize
///the data to be indexed. There are three main classes you need to know
///about when dealing with analysis; [Analyzer], [TokenStream] and [Token].
///
/// [Analyzer]s handle all of your tokenizing needs. You pass an [Analyzer] to
/// the indexing class when you create it and it will create the
/// [TokenStream]s necessary to tokenize the fields in the documents. Most of
/// the time you won't need to worry about [TokenStream]s and [Token]s, one of
/// the [Analyzer]s distributed with Ferret will do exactly what you need.
/// Otherwise you'll need to implement a custom analyzer.
///
/// A [TokenStream] is an enumeration of [Token]s. There are two standard
/// types of [TokenStream]; [Tokenizer] and [TokenFilter]. A [Tokenizer] takes
/// a [String] and turns it into a list of [Tokens]. A [TokenFilter] takes
/// another [TokenStream] and post-processes the [Tokens]. You can chain as
/// many [TokenFilters] together as you like but they always need to finish
/// with a [Tokenizer].
///
/// A [Token] is a single term from a document field. A token contains the
/// text representing the term as well as the start and end offset of the
/// token. The start and end offset will represent the token as it appears in
/// the source field. Some [TokenFilter]s may change the text in the [Token]
/// but the start and end offsets should stay the same so (end - start) won't
/// necessarily be equal to the length of text in the token. For example using
/// a stemming [TokenFilter] the term "Beginning" might have start and end
/// offsets of 10 and 19 respectively ("Beginning".length == 9) but
/// [Token.text] might be "begin" (after stemming).
library ferret.ext.analysis;

/// A [Token] is an occurrence of a term from the text of a field.  It
/// consists of a term's text and the start and end offset of the term in the
/// text of the field.
///
/// The start and end offsets permit applications to re-associate a token with
/// its source text, e.g., to display highlighted query terms in a document
/// browser, or to show matching text fragments in a KWIC (KeyWord In Context)
/// display, etc.
///
/// [text] is the terms text which may have been modified by a [TokenFilter]
/// or [Tokenizer] from the text originally found in the document.
/// [start] is the position of the first character corresponding to this token
/// in the source text.
/// [end] is equal to one greater than the position of the last character
/// corresponding of this token.
/// Note that the difference between [end_offset] and [start_offset] may not
/// be equal to [text.length], as the term text may have been altered by a
/// stemmer or some other filter.
class Token implements Comparable {
  Token() {
    frb_token_init;
  }

  compareTo() => frb_token_cmp;
  get text() => frb_token_get_text;
  set text() => frb_token_set_text;
  get start() => frb_token_get_start_offset;
  set start() => frb_token_set_start_offset;
  get end() => frb_token_get_end_offset;
  set end() => frb_token_set_end_offset;
  get pos_inc() => frb_token_get_pos_inc;
  set pos_inc() => frb_token_set_pos_inc;
  to_s() => frb_token_to_s;
}

/// A [TokenStream] enumerates the sequence of tokens, either from
/// fields of a document or from query text.
///
/// This is an abstract class. Concrete subclasses are:
///
/// * [Tokenizer]: a [TokenStream] whose input is a string
/// * [TokenFilter]: a [TokenStream] whose input is another [TokenStream]
abstract class TokenStream {
  next() => frb_ts_next;
  set text() => frb_ts_set_text;
  get text() => frb_ts_get_text;
}
