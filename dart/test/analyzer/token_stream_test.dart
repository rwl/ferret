library ferret.test.analyzer.token_stream;

import 'package:ferret/ferret.dart';
import 'package:test/test.dart';

test_token() {
  var t = new Token("text", 1, 2, 3);
  expect("text", equals(t.text));
  expect(1, equals(t.start));
  expect(2, equals(t.end));
  expect(3, equals(t.pos_inc));
  t.text = "yada yada yada";
  t.start = 11;
  t.end = 12;
  t.pos_inc = 13;
  expect("yada yada yada", equals(t.text));
  expect(11, equals(t.start));
  expect(12, equals(t.end));
  expect(13, equals(t.pos_inc));

  t = new Token("text", 1, 2);
  expect(1, equals(t.pos_inc));
}

test_ascii_letter_tokenizer() {
  var input = r'DBalmain@gmail.com is My e-mail 523@#$ ADDRESS. 23#!$';
  var t = new AsciiLetterTokenizer(input);
  expect(new Token("DBalmain", 0, 8), equals(t.next()));
  expect(new Token("gmail", 9, 14), equals(t.next()));
  expect(new Token("com", 15, 18), equals(t.next()));
  expect(new Token("is", 19, 21), equals(t.next()));
  expect(new Token("My", 22, 24), equals(t.next()));
  expect(new Token("e", 25, 26), equals(t.next()));
  expect(new Token("mail", 27, 31), equals(t.next()));
  expect(new Token("ADDRESS", 39, 46), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token("one", 0, 3), equals(t.next()));
  expect(new Token("two", 4, 7), equals(t.next()));
  expect(new Token("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new AsciiLetterTokenizer(input));
  expect(new Token("dbalmain", 0, 8), equals(t.next()));
  expect(new Token("gmail", 9, 14), equals(t.next()));
  expect(new Token("com", 15, 18), equals(t.next()));
  expect(new Token("is", 19, 21), equals(t.next()));
  expect(new Token("my", 22, 24), equals(t.next()));
  expect(new Token("e", 25, 26), equals(t.next()));
  expect(new Token("mail", 27, 31), equals(t.next()));
  expect(new Token("address", 39, 46), equals(t.next()));
  expect(t.next(), isNull);
}

test_letter_tokenizer() {
  var input =
      r'DBalmän@gmail.com is My e-mail 52   #$ address. 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var t = new LetterTokenizer(input);
  expect(new Token('DBalmän', 0, 8), equals(t.next()));
  expect(new Token('gmail', 9, 14), equals(t.next()));
  expect(new Token('com', 15, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('e', 25, 26), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('ÁÄGÇ', 55, 62), equals(t.next()));
  expect(new Token('ÊËÌ', 64, 70), equals(t.next()));
  expect(new Token('ÚØÃ', 72, 78), equals(t.next()));
  expect(new Token('ÖÎÍ', 80, 86), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token("one", 0, 3), equals(t.next()));
  expect(new Token("two", 4, 7), equals(t.next()));
  expect(new Token("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new LetterTokenizer(input));
  expect(new Token('dbalmän', 0, 8), equals(t.next()));
  expect(new Token('gmail', 9, 14), equals(t.next()));
  expect(new Token('com', 15, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e', 25, 26), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('áägç', 55, 62), equals(t.next()));
  expect(new Token('êëì', 64, 70), equals(t.next()));
  expect(new Token('úøã', 72, 78), equals(t.next()));
  expect(new Token('öîí', 80, 86), equals(t.next()));
  expect(t.next(), isNull);
  t = new LetterTokenizer(input, lower: true);
  expect(new Token('dbalmän', 0, 8), equals(t.next()));
  expect(new Token('gmail', 9, 14), equals(t.next()));
  expect(new Token('com', 15, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e', 25, 26), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('áägç', 55, 62), equals(t.next()));
  expect(new Token('êëì', 64, 70), equals(t.next()));
  expect(new Token('úøã', 72, 78), equals(t.next()));
  expect(new Token('öîí', 80, 86), equals(t.next()));
  expect(t.next(), isNull);
}

test_ascii_whitespace_tokenizer() {
  var input = r'DBalmain@gmail.com is My e-mail 52   #$ ADDRESS. 23#!$';
  var t = new AsciiWhiteSpaceTokenizer(input);
  expect(new Token('DBalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token(r'#$', 37, 39), equals(t.next()));
  expect(new Token('ADDRESS.', 40, 48), equals(t.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token("one_two", 0, 7), equals(t.next()));
  expect(new Token("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new AsciiWhiteSpaceTokenizer(input));
  expect(new Token('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token(r'#$', 37, 39), equals(t.next()));
  expect(new Token('address.', 40, 48), equals(t.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t.next()));
  expect(t.next(), isNull);
}

test_whitespace_tokenizer() {
  var input =
      r'DBalmän@gmail.com is My e-mail 52   #$ address. 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var t = new WhiteSpaceTokenizer(input);
  expect(new Token('DBalmän@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token(r'#$', 37, 39), equals(t.next()));
  expect(new Token('address.', 40, 48), equals(t.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t.next()));
  expect(new Token('ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ', 55, 86), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token("one_two", 0, 7), equals(t.next()));
  expect(new Token("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new WhiteSpaceTokenizer(input));
  expect(new Token('dbalmän@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token(r'#$', 37, 39), equals(t.next()));
  expect(new Token('address.', 40, 48), equals(t.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t.next()));
  expect(new Token('áägç®êëì¯úøã¬öîí', 55, 86), equals(t.next()));
  expect(t.next(), isNull);
  t = new WhiteSpaceTokenizer(input, true);
  expect(new Token('dbalmän@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token(r'#$', 37, 39), equals(t.next()));
  expect(new Token('address.', 40, 48), equals(t.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t.next()));
  expect(new Token('áägç®êëì¯úøã¬öîí', 55, 86), equals(t.next()));
  expect(t.next(), isNull);
}

test_ascii_standard_tokenizer() {
  var input =
      r'DBalmain@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/results/ T.N.T. 123-1235-ASD-1234';
  var t = new AsciiStandardTokenizer(input);
  expect(new Token('DBalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('Address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t.next()));
  expect(new Token('TNT', 86, 91), equals(t.next()));
  expect(new Token('123-1235-ASD-1234', 93, 110), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token("one_two", 0, 7), equals(t.next()));
  expect(new Token("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new AsciiStandardTokenizer(input));
  expect(new Token('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t.next()));
  expect(new Token('tnt', 86, 91), equals(t.next()));
  expect(new Token('123-1235-asd-1234', 93, 110), equals(t.next()));
  expect(t.next(), isNull);
}

test_standard_tokenizer() {
  var input =
      r'DBalmán@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/res_345/ T.N.T. 123-1235-ASD-1234 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var t = new StandardTokenizer(input);
  expect(new Token('DBalmán@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('Address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('www.google.com/res_345', 55, 85), equals(t.next()));
  expect(new Token('TNT', 86, 91), equals(t.next()));
  expect(new Token('123-1235-ASD-1234', 93, 110), equals(t.next()));
  expect(new Token('23', 111, 113), equals(t.next()));
  expect(new Token('ÁÄGÇ', 117, 124), equals(t.next()));
  expect(new Token('ÊËÌ', 126, 132), equals(t.next()));
  expect(new Token('ÚØÃ', 134, 140), equals(t.next()));
  expect(new Token('ÖÎÍ', 142, 148), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token("one_two", 0, 7), equals(t.next()));
  expect(new Token("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new StandardTokenizer(input));
  expect(new Token('dbalmán@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('www.google.com/res_345', 55, 85), equals(t.next()));
  expect(new Token('tnt', 86, 91), equals(t.next()));
  expect(new Token('123-1235-asd-1234', 93, 110), equals(t.next()));
  expect(new Token('23', 111, 113), equals(t.next()));
  expect(new Token('áägç', 117, 124), equals(t.next()));
  expect(new Token('êëì', 126, 132), equals(t.next()));
  expect(new Token('úøã', 134, 140), equals(t.next()));
  expect(new Token('öîí', 142, 148), equals(t.next()));
  input = "e-mail 123-1235-asd-1234 http://www.davebalmain.com/trac-site/";
  t = new HyphenFilter(new StandardTokenizer(input));
  expect(new Token('email', 0, 6), equals(t.next()));
  expect(new Token('e', 0, 1, 0), equals(t.next()));
  expect(new Token('mail', 2, 6, 1), equals(t.next()));
  expect(new Token('123-1235-asd-1234', 7, 24), equals(t.next()));
  expect(new Token('www.davebalmain.com/trac-site', 25, 61), equals(t.next()));
  expect(t.next(), isNull);
}

const ALPHA = r"[[:alpha:]_-]+";
const APOSTROPHE = r"#{ALPHA}('#{ALPHA})+";
const ACRONYM = r"#{ALPHA}\.(#{ALPHA}\.)+";
const ACRONYM_WORD = r"^#{ACRONYM}$";
const APOSTROPHE_WORD = r"^#{APOSTROPHE}$";

test_reg_exp_tokenizer() {
  var input =
      r"DBalmain@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/RESULT_3.html T.N.T. 123-1235-ASD-1234 23 Rob's";
  var t = new RegExpTokenizer(input);
  expect(new Token('DBalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('Address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('http://www.google.com/RESULT_3.html', 55, 90),
      equals(t.next()));
  expect(new Token('T.N.T.', 91, 97), equals(t.next()));
  expect(new Token('123-1235-ASD-1234', 98, 115), equals(t.next()));
  expect(new Token('23', 116, 118), equals(t.next()));
  expect(new Token('Rob\'s', 119, 124), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token("one_two", 0, 7), equals(t.next()));
  expect(new Token("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new RegExpTokenizer(input));
  var t2 = new LowerCaseFilter(new RegExpTokenizer(input, r"\w{2,}"));
  expect(new Token('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('http://www.google.com/result_3.html', 55, 90),
      equals(t.next()));
  expect(new Token('t.n.t.', 91, 97), equals(t.next()));
  expect(new Token('123-1235-asd-1234', 98, 115), equals(t.next()));
  expect(new Token('23', 116, 118), equals(t.next()));
  expect(new Token('rob\'s', 119, 124), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token('dbalmain', 0, 8), t2.next);
  expect(new Token('gmail', 9, 14), t2.next);
  expect(new Token('com', 15, 18), t2.next);
  expect(new Token('is', 19, 21), t2.next);
  expect(new Token('my', 22, 24), t2.next);
  expect(new Token('mail', 27, 31), t2.next);
  expect(new Token('52', 32, 34), t2.next);
  expect(new Token('address', 40, 47), t2.next);
  expect(new Token('23', 49, 51), t2.next);
  expect(new Token('http', 55, 59), t2.next);
  expect(new Token('www', 62, 65), t2.next);
  expect(new Token('google', 66, 72), t2.next);
  expect(new Token('com', 73, 76), t2.next);
  expect(new Token('result_3', 77, 85), t2.next);
  expect(new Token('html', 86, 90), t2.next);
  expect(new Token('123', 98, 101), t2.next);
  expect(new Token('1235', 102, 106), t2.next);
  expect(new Token('asd', 107, 110), t2.next);
  expect(new Token('1234', 111, 115), t2.next);
  expect(new Token('23', 116, 118), t2.next);
  expect(new Token('rob', 119, 122), t2.next);
  assert(!t2.next());
  t = new RegExpTokenizer(input, (str) {
    if (str = ~ACRONYM_WORD) {
      str.gsub /*!*/ (r"\.", '');
    } else if (str = ~APOSTROPHE_WORD) {
      str.gsub /*!*/ (r"'[sS]$", '');
    }
    return str;
  });
  t = new LowerCaseFilter(t);
  expect(new Token('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('http://www.google.com/result_3.html', 55, 90),
      equals(t.next()));
  expect(new Token('tnt', 91, 97), equals(t.next()));
  expect(new Token('123-1235-asd-1234', 98, 115), equals(t.next()));
  expect(new Token('23', 116, 118), equals(t.next()));
  expect(new Token('rob', 119, 124), equals(t.next()));
  expect(t.next(), isNull);
}

test_mapping_filter() {
  var mapping = {
    ['à', 'á', 'â', 'ã', 'ä', 'å', 'ā', 'ă']: 'a',
    'æ': 'ae',
    ['ď', 'đ']: 'd',
    ['ç', 'ć', 'č', 'ĉ', 'ċ']: 'c',
    ['è', 'é', 'ê', 'ë', 'ē', 'ę', 'ě', 'ĕ', 'ė',]: 'e',
    ['ƒ']: 'f',
    ['ĝ', 'ğ', 'ġ', 'ģ']: 'g',
    ['ĥ', 'ħ']: 'h',
    ['ì', 'ì', 'í', 'î', 'ï', 'ī', 'ĩ', 'ĭ']: 'i',
    ['į', 'ı', 'ĳ', 'ĵ']: 'j',
    ['ķ', 'ĸ']: 'k',
    ['ł', 'ľ', 'ĺ', 'ļ', 'ŀ']: 'l',
    ['ñ', 'ń', 'ň', 'ņ', 'ŉ', 'ŋ']: 'n',
    ['ò', 'ó', 'ô', 'õ', 'ö', 'ø', 'ō', 'ő', 'ŏ', 'ŏ']: 'o',
    'œ': 'oek',
    'ą': 'q',
    ['ŕ', 'ř', 'ŗ']: 'r',
    ['ś', 'š', 'ş', 'ŝ', 'ș']: 's',
    ['ť', 'ţ', 'ŧ', 'ț']: 't',
    ['ù', 'ú', 'û', 'ü', 'ū', 'ů', 'ű', 'ŭ', 'ũ', 'ų']: 'u',
    'ŵ': 'w',
    ['ý', 'ÿ', 'ŷ']: 'y',
    ['ž', 'ż', 'ź']: 'z'
  };
  input.add('''
aàáâãäåāăb cæd eďđf gçćčĉċh ièéêëēęěĕėj kƒl mĝğġģn oĥħp qììíîïīĩĭr sįıĳĵt uķĸv
włľĺļŀx yñńňņŉŋz aòóôõöøōőŏŏb cœd eąf gŕřŗh iśšşŝșj kťţŧțl mùúûüūůűŭũųn oŵp
qýÿŷr sžżźt
''');
  var t = new MappingFilter(new LetterTokenizer(input), mapping);
  expect(new Token('aaaaaaaaab', 0, 18), equals(t.next()));
  expect(new Token('caed', 19, 23), equals(t.next()));
  expect(new Token('eddf', 24, 30), equals(t.next()));
  expect(new Token('gccccch', 31, 43), equals(t.next()));
  expect(new Token('ieeeeeeeeej', 44, 64), equals(t.next()));
  expect(new Token('kfl', 65, 69), equals(t.next()));
  expect(new Token('mggggn', 70, 80), equals(t.next()));
  expect(new Token('ohhp', 81, 87), equals(t.next()));
  expect(new Token('qiiiiiiiir', 88, 106), equals(t.next()));
  expect(new Token('sjjjjt', 107, 117), equals(t.next()));
  expect(new Token('ukkv', 118, 124), equals(t.next()));
  expect(new Token('wlllllx', 125, 137), equals(t.next()));
  expect(new Token('ynnnnnnz', 138, 152), equals(t.next()));
  expect(new Token('aoooooooooob', 153, 175), equals(t.next()));
  expect(new Token('coekd', 176, 180), equals(t.next()));
  expect(new Token('eqf', 181, 185), equals(t.next()));
  expect(new Token('grrrh', 186, 194), equals(t.next()));
  expect(new Token('isssssj', 195, 207), equals(t.next()));
  expect(new Token('kttttl', 208, 218), equals(t.next()));
  expect(new Token('muuuuuuuuuun', 219, 241), equals(t.next()));
  expect(new Token('owp', 242, 246), equals(t.next()));
  expect(new Token('qyyyr', 247, 255), equals(t.next()));
  expect(new Token('szzzt', 256, 264), equals(t.next()));
  expect(t.next(), isNull);
}

test_stop_filter() {
  var words = ["one", "four", "five", "seven"];
  var input = "one, two, three, four, five, six, seven, eight, nine, ten.";
  var t = new StopFilter(new AsciiLetterTokenizer(input), words);
  expect(new Token('two', 5, 8, 2), equals(t.next()));
  expect(new Token('three', 10, 15, 1), equals(t.next()));
  expect(new Token('six', 29, 32, 3), equals(t.next()));
  expect(new Token('eight', 41, 46, 2), equals(t.next()));
  expect(new Token('nine', 48, 52, 1), equals(t.next()));
  expect(new Token('ten', 54, 57, 1), equals(t.next()));
  expect(t.next(), isNull);
}

test_stem_filter() {
  var input = "Debate Debates DEBATED DEBating Debater";
  var t = new StemFilter(
      new AsciiLowerCaseFilter(new AsciiLetterTokenizer(input)),
      algorithm: "english");
  expect(new Token("debat", 0, 6), equals(t.next()));
  expect(new Token("debat", 7, 14), equals(t.next()));
  expect(new Token("debat", 15, 22), equals(t.next()));
  expect(new Token("debat", 23, 31), equals(t.next()));
  expect(new Token("debat", 32, 39), equals(t.next()));
  expect(t.next(), isNull);
  t = new StemFilter(new AsciiLetterTokenizer(input), algorithm: 'english');
  expect(new Token("Debat", 0, 6), equals(t.next()));
  expect(new Token("Debat", 7, 14), equals(t.next()));
  expect(new Token("DEBATED", 15, 22), equals(t.next()));
  expect(new Token("DEBate", 23, 31), equals(t.next()));
  expect(new Token("Debat", 32, 39), equals(t.next()));

  if (Ferret.locale && Ferret.locale.downcase.index("utf")) {
    input = "Dêbate dêbates DÊBATED DÊBATing dêbater";
    t = new StemFilter(new LowerCaseFilter(new LetterTokenizer(input)),
        algorithm: 'english');
    expect(new Token("dêbate", 0, 7), equals(t.next()));
    expect(new Token("dêbate", 8, 16), equals(t.next()));
    expect(new Token("dêbate", 17, 25), equals(t.next()));
    expect(new Token("dêbate", 26, 35), equals(t.next()));
    expect(new Token("dêbater", 36, 44), equals(t.next()));
    t = new StemFilter(new LetterTokenizer(input), algorithm: 'english');
    expect(new Token("Dêbate", 0, 7), equals(t.next()));
    expect(new Token("dêbate", 8, 16), equals(t.next()));
    expect(new Token("DÊBATED", 17, 25), equals(t.next()));
    expect(new Token("DÊBATing", 26, 35), equals(t.next()));
    expect(new Token("dêbater", 36, 44), equals(t.next()));
    expect(t.next(), isNull);
  }

  tz = new AsciiLetterTokenizer(input);
  assert_not_nil(new StemFilter(tz, 'HunGarIaN', 'Utf-8'), isNotNull);
  assert_not_nil(new StemFilter(tz, 'romanIAN', 'iso-8859-2'), isNotNull);
  assert_raises(ArgumentError, () {
    new StemFilter(tz, algorithm: 'Jibberish', encoding: 'UTF-8');
  });
}

//require 'strscan'

class MyRegExpTokenizer {
  //extends TokenStream {

  initialize(input) {
    _ss = new StringScanner(input);
  }

  /// Returns the next token in the stream, or null at EOS.
  next() {
    if (_ss.scan_until(token_re)) {
      term = _ss.matched;
      term_end = _ss.pos;
      term_start = term_end - term.size;
    } else {
      return null;
    }

    return new Token(normalize(term), term_start, term_end);
  }

  set text(text) {
    _ss = new StringScanner(text);
  }

  //protected
  /// returns the regular expression used to find the next token
  static const TOKEN_RE = r"[[:alpha:]]+";
  token_re() {
    return TOKEN_RE;
  }

  /// Called on each token to normalize it before it is added to the
  /// token.  The default implementation does nothing.  Subclasses may
  /// use this to, e.g., lowercase tokens.
  normalize(str) {
    return str;
  }
}

class MyReverseTokenFilter {
  //extends TokenStream {
  initialize(token_stream) {
    _token_stream = token_stream;
  }

  set text(text) {
    _token_stream.text = text;
  }

  next() {
    if (token = _token_stream.next) {
      token.text = token.text.reverse;
    }
    return token;
  }
}

class MyCSVTokenizer extends MyRegExpTokenizer {
  //protected
  /// returns the regular expression used to find the next token
  static const TOKEN_RE = r"[^,]+";
  token_re() {
    return TOKEN_RE;
  }

  /// Called on each token to normalize it before it is added to the
  /// token.  The default implementation does nothing.  Subclasses may
  /// use this to, e.g., lowercase tokens.
  normalize(str) {
    return str.upcase();
  }
}

test_custom_tokenizer() {
  var input = "First Field,2nd Field,  P a d d e d  F i e l d  ";
  var t = new MyCSVTokenizer(input);
  expect(new Token("FIRST FIELD", 0, 11), equals(t.next()));
  expect(new Token("2ND FIELD", 12, 21), equals(t.next()));
  expect(new Token("  P A D D E D  F I E L D  ", 22, 48), equals(t.next()));
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new MyCSVTokenizer(input));
  expect(new Token("first field", 0, 11), equals(t.next()));
  expect(new Token("2nd field", 12, 21), equals(t.next()));
  expect(new Token("  p a d d e d  f i e l d  ", 22, 48), equals(t.next()));
  expect(t.next(), isNull);
  t = new MyReverseTokenFilter(
      new AsciiLowerCaseFilter(new MyCSVTokenizer(input)));
  expect(new Token("dleif tsrif", 0, 11), equals(t.next()));
  expect(new Token("dleif dn2", 12, 21), equals(t.next()));
  expect(new Token("  d l e i f  d e d d a p  ", 22, 48), equals(t.next()));
  t.text = "one,TWO,three";
  expect(new Token("eno", 0, 3), equals(t.next()));
  expect(new Token("owt", 4, 7), equals(t.next()));
  expect(new Token("eerht", 8, 13), equals(t.next()));
  t = new AsciiLowerCaseFilter(
      new MyReverseTokenFilter(new MyCSVTokenizer(input)));
  expect(new Token("dleif tsrif", 0, 11), equals(t.next()));
  expect(new Token("dleif dn2", 12, 21), equals(t.next()));
  expect(new Token("  d l e i f  d e d d a p  ", 22, 48), equals(t.next()));
  t.text = "one,TWO,three";
  expect(new Token("eno", 0, 3), equals(t.next()));
  expect(new Token("owt", 4, 7), equals(t.next()));
  expect(new Token("eerht", 8, 13), equals(t.next()));
}

class TokenFilter {
  //extends TokenStream {
  //protected
  /// Construct a token stream filtering the given input.
  initialize(input) {
    _input = input;
  }
}

/// Normalizes token text to lower case.
class CapitalizeFilter extends TokenFilter {
  next() {
    var t = _input.next();

    if (t == null) {
      return null;
    }

    t.text = t.text.capitalize();

    return t;
  }
}

test_custom_filter() {
  var input = "This text SHOULD be capitalized ... I hope. :-S";
  var t = new CapitalizeFilter(new AsciiLetterTokenizer(input));
  expect(new Token("This", 0, 4), equals(t.next()));
  expect(new Token("Text", 5, 9), equals(t.next()));
  expect(new Token("Should", 10, 16), equals(t.next()));
  expect(new Token("Be", 17, 19), equals(t.next()));
  expect(new Token("Capitalized", 20, 31), equals(t.next()));
  expect(new Token("I", 36, 37), equals(t.next()));
  expect(new Token("Hope", 38, 42), equals(t.next()));
  expect(new Token("S", 46, 47), equals(t.next()));
  expect(t.next(), isNull);
  t = new StemFilter(new CapitalizeFilter(new AsciiLetterTokenizer(input)));
  expect(new Token("This", 0, 4), equals(t.next()));
  expect(new Token("Text", 5, 9), equals(t.next()));
  expect(new Token("Should", 10, 16), equals(t.next()));
  expect(new Token("Be", 17, 19), equals(t.next()));
  expect(new Token("Capit", 20, 31), equals(t.next()));
  expect(new Token("I", 36, 37), equals(t.next()));
  expect(new Token("Hope", 38, 42), equals(t.next()));
  expect(new Token("S", 46, 47), equals(t.next()));
  expect(t.next(), isNull);
}
