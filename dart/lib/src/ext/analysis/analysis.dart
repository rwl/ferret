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

import 'dart:typed_data' show Uint8List;

import '../../proxy.dart';

part 'analyzer.dart';
part 'filter.dart';
part 'tokenizer.dart';

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
class Token extends JsProxy implements Comparable {
  String _text;
  int _start;
  int _end;
  int _pos_inc;

  /// Creates a new token setting the text, start and end offsets of the token
  /// and the position increment for the token.
  ///
  /// The position increment is usually set to 1 but you can set it to other
  /// values as needed.  For example, if you have a stop word filter you will
  /// be skipping tokens. Let's say you have the stop words "the" and "and"
  /// and you parse the title "The Old Man and the Sea". The terms "Old",
  /// "Man" and "Sea" will have the position increments 2, 1 and 3
  /// respectively.
  ///
  /// Another reason you might want to vary the position increment is if you
  /// are adding synonyms to the index. For example let's say you have the
  /// synonym group "quick", "fast" and "speedy". When tokenizing the phrase
  /// "Next day speedy delivery", you'll add "speedy" first with a position
  /// increment of 1 and then "fast" and "quick" with position increments of
  /// 0 since they are represented in the same position.
  ///
  /// The offset set values [start] and [end] should be byte offsets, not
  /// character offsets. This makes it easy to use those offsets to quickly
  /// access the token in the input string and also to insert highlighting
  /// tags when necessary.
  ///
  /// [text] is the main text for the token. [start] is the start offset of
  /// the token in bytes. [end] is the end offset of the token in bytes.
  /// [pos_inc] is the position increment of a token.
  /*Token(this._text, this._start, this._end, [this._pos_inc = 1]) : super() {
    frb_token_init;
  }*/

  Token._handle(int htk) : super() {
    handle = htk;
    int p_text = module.callMethod('_frjs_tk_get_text', [handle]);
    _text = stringify(p_text);
    _start = module.callMethod('_frjs_tk_get_start', [handle]);
    _end = module.callMethod('_frjs_tk_get_end', [handle]);
    _pos_inc = module.callMethod('_frjs_tk_get_pos_inc', [handle]);
  }

  /// Used to compare two tokens. Token is extended by [Comparable] so you
  /// can also use `<`, `>`, `<=`, `>=` etc. to compare tokens.
  ///
  /// Tokens are sorted by the position in the text at which they occur, ie
  /// the start offset. If two tokens have the same start offset, (see
  /// [pos_inc]) then, they are sorted by the end offset and then lexically
  /// by the token text.
  int compareTo(Token other_token) {
    int cmp;
    if (start > other_token.start) {
      cmp = 1;
    } else if (start < other_token.start) {
      cmp = -1;
    } else {
      if (end > other_token.end) {
        cmp = 1;
      } else if (end < other_token.end) {
        cmp = -1;
      } else {
        cmp = text.compareTo(other_token.text);
      }
    }
    return cmp;
  }

  void _set() {
    int p_text = allocString(_text);
    module.callMethod(
        '_frt_tk_set_no_len', [handle, p_text, _start, _end, _pos_inc]);
    free(p_text);
  }

  /// Returns the text that this token represents.
  String get text => _text;

  /// Set the text for this token.
  void set text(String val) {
    _text = val;
    _set();
  }

  /// Start byte-position of this token.
  int get start => _start;

  /// Set start byte-position of this token.
  void set start(int val) {
    _start = val;
    _set();
  }

  /// End byte-position of this token.
  int get end => _end;

  /// Set end byte-position of this token.
  void set end(int val) {
    _end = val;
    _set();
  }

  /// Position Increment for this token.
  int get pos_inc => _pos_inc;

  /// Set the position increment. This determines the position of this token
  /// relative to the previous Token in a TokenStream, used in phrase
  /// searching.
  ///
  /// The default value is 1.
  ///
  /// Some common uses for this are:
  ///
  /// * Set it to zero to put multiple terms in the same position.  This is
  ///   useful if, e.g., a word has multiple stems.  Searches for phrases
  ///   including either stem will match.  In this case, all but the first
  ///   stem's increment should be set to zero: the increment of the first
  ///   instance should be one.  Repeating a token with an increment of zero
  ///   can also be used to boost the scores of matches on that token.
  ///
  /// * Set it to values greater than one to inhibit exact phrase matches.
  ///   If, for example, one does not want phrases to match across removed
  ///   stop words, then one could build a stop word filter that removes stop
  ///   words and also sets the increment to the number of stop words removed
  ///   before each non-stop word.  Then exact phrase queries will only match
  ///   when the terms occur with no intervening stop words.
  set pos_inc(int val) {
    _pos_inc = val;
    _set();
  }

  /// Return a string representation of the token.
  String to_s() => 'token["$_text":$_start:$_end:$_pos_inc]';
}

/// A [TokenStream] enumerates the sequence of tokens, either from
/// fields of a document or from query text.
///
/// This is an abstract class. Concrete subclasses are:
///
/// * [Tokenizer]: a [TokenStream] whose input is a string
/// * [TokenFilter]: a [TokenStream] whose input is another [TokenStream]
abstract class TokenStream extends JsProxy {
  TokenStream._handle(int hts) : super() {
    handle = hts;
  }

  /// Return the next token from the [TokenStream] or null if there are no
  /// more tokens.
  Token next() {
    int p_tk = module.callMethod('_frjs_ts_next', [handle]);
    return new Token._handle(p_tk);
  }

  /// Set the text attribute of the [TokenStream] to the text you wish to be
  /// tokenized. For example, you may do this:
  ///
  ///     token_stream.text = File.read(file_name);
  void set text(String val) {
    int p_text = allocString(val);
    module.callMethod('_frjs_ts_set_text', [handle, p_text]);
    free(p_text);
  }

  /// Return the text that the TokenStream is tokenizing.
  String get text {
    int p_text = module.callMethod('_frjs_ts_get_text', [handle]);
    return stringify(p_text);
  }
}
