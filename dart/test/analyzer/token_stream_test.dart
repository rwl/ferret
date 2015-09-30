library ferret.test.analyzer.token_stream;

import 'package:ferret/ferret.dart';
import 'package:test/test.dart';

test_token() {
  var t = new Token.test("text", 1, 2, 3);
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

  t = new Token.test("text", 1, 2);
  expect(1, equals(t.pos_inc));
}

test_ascii_letter_tokenizer() {
  var input = r'DBalmain@gmail.com is My e-mail 523@#$ ADDRESS. 23#!$';
  var t = new AsciiLetterTokenizer(input);
  expect(new Token.test("DBalmain", 0, 8), equals(t.next()));
  expect(new Token.test("gmail", 9, 14), equals(t.next()));
  expect(new Token.test("com", 15, 18), equals(t.next()));
  expect(new Token.test("is", 19, 21), equals(t.next()));
  expect(new Token.test("My", 22, 24), equals(t.next()));
  expect(new Token.test("e", 25, 26), equals(t.next()));
  expect(new Token.test("mail", 27, 31), equals(t.next()));
  expect(new Token.test("ADDRESS", 39, 46), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token.test("one", 0, 3), equals(t.next()));
  expect(new Token.test("two", 4, 7), equals(t.next()));
  expect(new Token.test("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new AsciiLetterTokenizer(input));
  expect(new Token.test("dbalmain", 0, 8), equals(t.next()));
  expect(new Token.test("gmail", 9, 14), equals(t.next()));
  expect(new Token.test("com", 15, 18), equals(t.next()));
  expect(new Token.test("is", 19, 21), equals(t.next()));
  expect(new Token.test("my", 22, 24), equals(t.next()));
  expect(new Token.test("e", 25, 26), equals(t.next()));
  expect(new Token.test("mail", 27, 31), equals(t.next()));
  expect(new Token.test("address", 39, 46), equals(t.next()));
  expect(t.next(), isNull);
}

test_letter_tokenizer() {
  var input =
      r'DBalmän@gmail.com is My e-mail 52   #$ address. 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var t = new LetterTokenizer(input);
  expect(new Token.test('DBalmän', 0, 8), equals(t.next()));
  expect(new Token.test('gmail', 9, 14), equals(t.next()));
  expect(new Token.test('com', 15, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('My', 22, 24), equals(t.next()));
  expect(new Token.test('e', 25, 26), equals(t.next()));
  expect(new Token.test('mail', 27, 31), equals(t.next()));
  expect(new Token.test('address', 40, 47), equals(t.next()));
  expect(new Token.test('ÁÄGÇ', 55, 62), equals(t.next()));
  expect(new Token.test('ÊËÌ', 64, 70), equals(t.next()));
  expect(new Token.test('ÚØÃ', 72, 78), equals(t.next()));
  expect(new Token.test('ÖÎÍ', 80, 86), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token.test("one", 0, 3), equals(t.next()));
  expect(new Token.test("two", 4, 7), equals(t.next()));
  expect(new Token.test("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new LetterTokenizer(input));
  expect(new Token.test('dbalmän', 0, 8), equals(t.next()));
  expect(new Token.test('gmail', 9, 14), equals(t.next()));
  expect(new Token.test('com', 15, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('my', 22, 24), equals(t.next()));
  expect(new Token.test('e', 25, 26), equals(t.next()));
  expect(new Token.test('mail', 27, 31), equals(t.next()));
  expect(new Token.test('address', 40, 47), equals(t.next()));
  expect(new Token.test('áägç', 55, 62), equals(t.next()));
  expect(new Token.test('êëì', 64, 70), equals(t.next()));
  expect(new Token.test('úøã', 72, 78), equals(t.next()));
  expect(new Token.test('öîí', 80, 86), equals(t.next()));
  expect(t.next(), isNull);
  t = new LetterTokenizer(input, lower: true);
  expect(new Token.test('dbalmän', 0, 8), equals(t.next()));
  expect(new Token.test('gmail', 9, 14), equals(t.next()));
  expect(new Token.test('com', 15, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('my', 22, 24), equals(t.next()));
  expect(new Token.test('e', 25, 26), equals(t.next()));
  expect(new Token.test('mail', 27, 31), equals(t.next()));
  expect(new Token.test('address', 40, 47), equals(t.next()));
  expect(new Token.test('áägç', 55, 62), equals(t.next()));
  expect(new Token.test('êëì', 64, 70), equals(t.next()));
  expect(new Token.test('úøã', 72, 78), equals(t.next()));
  expect(new Token.test('öîí', 80, 86), equals(t.next()));
  expect(t.next(), isNull);
}

test_ascii_whitespace_tokenizer() {
  var input = r'DBalmain@gmail.com is My e-mail 52   #$ ADDRESS. 23#!$';
  var t = new AsciiWhiteSpaceTokenizer(input);
  expect(new Token.test('DBalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('My', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test(r'#$', 37, 39), equals(t.next()));
  expect(new Token.test('ADDRESS.', 40, 48), equals(t.next()));
  expect(new Token.test(r'23#!$', 49, 54), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token.test("one_two", 0, 7), equals(t.next()));
  expect(new Token.test("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new AsciiWhiteSpaceTokenizer(input));
  expect(new Token.test('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('my', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test(r'#$', 37, 39), equals(t.next()));
  expect(new Token.test('address.', 40, 48), equals(t.next()));
  expect(new Token.test(r'23#!$', 49, 54), equals(t.next()));
  expect(t.next(), isNull);
}

test_whitespace_tokenizer() {
  var input =
      r'DBalmän@gmail.com is My e-mail 52   #$ address. 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var t = new WhiteSpaceTokenizer(input);
  expect(new Token.test('DBalmän@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('My', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test(r'#$', 37, 39), equals(t.next()));
  expect(new Token.test('address.', 40, 48), equals(t.next()));
  expect(new Token.test(r'23#!$', 49, 54), equals(t.next()));
  expect(new Token.test('ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ', 55, 86), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token.test("one_two", 0, 7), equals(t.next()));
  expect(new Token.test("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new WhiteSpaceTokenizer(input));
  expect(new Token.test('dbalmän@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('my', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test(r'#$', 37, 39), equals(t.next()));
  expect(new Token.test('address.', 40, 48), equals(t.next()));
  expect(new Token.test(r'23#!$', 49, 54), equals(t.next()));
  expect(new Token.test('áägç®êëì¯úøã¬öîí', 55, 86), equals(t.next()));
  expect(t.next(), isNull);
  t = new WhiteSpaceTokenizer(input, lower: true);
  expect(new Token.test('dbalmän@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('my', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test(r'#$', 37, 39), equals(t.next()));
  expect(new Token.test('address.', 40, 48), equals(t.next()));
  expect(new Token.test(r'23#!$', 49, 54), equals(t.next()));
  expect(new Token.test('áägç®êëì¯úøã¬öîí', 55, 86), equals(t.next()));
  expect(t.next(), isNull);
}

test_ascii_standard_tokenizer() {
  var input =
      r'DBalmain@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/results/ T.N.T. 123-1235-ASD-1234';
  var t = new AsciiStandardTokenizer(input);
  expect(new Token.test('DBalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('My', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test('Address', 40, 47), equals(t.next()));
  expect(new Token.test('23', 49, 51), equals(t.next()));
  expect(new Token.test('www.google.com/results', 55, 85), equals(t.next()));
  expect(new Token.test('TNT', 86, 91), equals(t.next()));
  expect(new Token.test('123-1235-ASD-1234', 93, 110), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token.test("one_two", 0, 7), equals(t.next()));
  expect(new Token.test("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new AsciiStandardTokenizer(input));
  expect(new Token.test('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('my', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test('address', 40, 47), equals(t.next()));
  expect(new Token.test('23', 49, 51), equals(t.next()));
  expect(new Token.test('www.google.com/results', 55, 85), equals(t.next()));
  expect(new Token.test('tnt', 86, 91), equals(t.next()));
  expect(new Token.test('123-1235-asd-1234', 93, 110), equals(t.next()));
  expect(t.next(), isNull);
}

test_standard_tokenizer() {
  var input =
      r'DBalmán@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/res_345/ T.N.T. 123-1235-ASD-1234 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var t = new StandardTokenizer(input);
  expect(new Token.test('DBalmán@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('My', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test('Address', 40, 47), equals(t.next()));
  expect(new Token.test('23', 49, 51), equals(t.next()));
  expect(new Token.test('www.google.com/res_345', 55, 85), equals(t.next()));
  expect(new Token.test('TNT', 86, 91), equals(t.next()));
  expect(new Token.test('123-1235-ASD-1234', 93, 110), equals(t.next()));
  expect(new Token.test('23', 111, 113), equals(t.next()));
  expect(new Token.test('ÁÄGÇ', 117, 124), equals(t.next()));
  expect(new Token.test('ÊËÌ', 126, 132), equals(t.next()));
  expect(new Token.test('ÚØÃ', 134, 140), equals(t.next()));
  expect(new Token.test('ÖÎÍ', 142, 148), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token.test("one_two", 0, 7), equals(t.next()));
  expect(new Token.test("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new StandardTokenizer(input));
  expect(new Token.test('dbalmán@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('my', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test('address', 40, 47), equals(t.next()));
  expect(new Token.test('23', 49, 51), equals(t.next()));
  expect(new Token.test('www.google.com/res_345', 55, 85), equals(t.next()));
  expect(new Token.test('tnt', 86, 91), equals(t.next()));
  expect(new Token.test('123-1235-asd-1234', 93, 110), equals(t.next()));
  expect(new Token.test('23', 111, 113), equals(t.next()));
  expect(new Token.test('áägç', 117, 124), equals(t.next()));
  expect(new Token.test('êëì', 126, 132), equals(t.next()));
  expect(new Token.test('úøã', 134, 140), equals(t.next()));
  expect(new Token.test('öîí', 142, 148), equals(t.next()));
  input = "e-mail 123-1235-asd-1234 http://www.davebalmain.com/trac-site/";
  t = new HyphenFilter(new StandardTokenizer(input));
  expect(new Token.test('email', 0, 6), equals(t.next()));
  expect(new Token.test('e', 0, 1, 0), equals(t.next()));
  expect(new Token.test('mail', 2, 6, 1), equals(t.next()));
  expect(new Token.test('123-1235-asd-1234', 7, 24), equals(t.next()));
  expect(new Token.test('www.davebalmain.com/trac-site', 25, 61),
      equals(t.next()));
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
  expect(new Token.test('DBalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('My', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test('Address', 40, 47), equals(t.next()));
  expect(new Token.test('23', 49, 51), equals(t.next()));
  expect(new Token.test('http://www.google.com/RESULT_3.html', 55, 90),
      equals(t.next()));
  expect(new Token.test('T.N.T.', 91, 97), equals(t.next()));
  expect(new Token.test('123-1235-ASD-1234', 98, 115), equals(t.next()));
  expect(new Token.test('23', 116, 118), equals(t.next()));
  expect(new Token.test('Rob\'s', 119, 124), equals(t.next()));
  expect(t.next(), isNull);
  t.text = "one_two three";
  expect(new Token.test("one_two", 0, 7), equals(t.next()));
  expect(new Token.test("three", 8, 13), equals(t.next()));
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new RegExpTokenizer(input));
  var t2 =
      new LowerCaseFilter(new RegExpTokenizer(input, new RegExp(r"\w{2,}")));
  expect(new Token.test('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('my', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test('address', 40, 47), equals(t.next()));
  expect(new Token.test('23', 49, 51), equals(t.next()));
  expect(new Token.test('http://www.google.com/result_3.html', 55, 90),
      equals(t.next()));
  expect(new Token.test('t.n.t.', 91, 97), equals(t.next()));
  expect(new Token.test('123-1235-asd-1234', 98, 115), equals(t.next()));
  expect(new Token.test('23', 116, 118), equals(t.next()));
  expect(new Token.test('rob\'s', 119, 124), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token.test('dbalmain', 0, 8), t2.next);
  expect(new Token.test('gmail', 9, 14), t2.next);
  expect(new Token.test('com', 15, 18), t2.next);
  expect(new Token.test('is', 19, 21), t2.next);
  expect(new Token.test('my', 22, 24), t2.next);
  expect(new Token.test('mail', 27, 31), t2.next);
  expect(new Token.test('52', 32, 34), t2.next);
  expect(new Token.test('address', 40, 47), t2.next);
  expect(new Token.test('23', 49, 51), t2.next);
  expect(new Token.test('http', 55, 59), t2.next);
  expect(new Token.test('www', 62, 65), t2.next);
  expect(new Token.test('google', 66, 72), t2.next);
  expect(new Token.test('com', 73, 76), t2.next);
  expect(new Token.test('result_3', 77, 85), t2.next);
  expect(new Token.test('html', 86, 90), t2.next);
  expect(new Token.test('123', 98, 101), t2.next);
  expect(new Token.test('1235', 102, 106), t2.next);
  expect(new Token.test('asd', 107, 110), t2.next);
  expect(new Token.test('1234', 111, 115), t2.next);
  expect(new Token.test('23', 116, 118), t2.next);
  expect(new Token.test('rob', 119, 122), t2.next);
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
  expect(new Token.test('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token.test('is', 19, 21), equals(t.next()));
  expect(new Token.test('my', 22, 24), equals(t.next()));
  expect(new Token.test('e-mail', 25, 31), equals(t.next()));
  expect(new Token.test('52', 32, 34), equals(t.next()));
  expect(new Token.test('address', 40, 47), equals(t.next()));
  expect(new Token.test('23', 49, 51), equals(t.next()));
  expect(new Token.test('http://www.google.com/result_3.html', 55, 90),
      equals(t.next()));
  expect(new Token.test('tnt', 91, 97), equals(t.next()));
  expect(new Token.test('123-1235-asd-1234', 98, 115), equals(t.next()));
  expect(new Token.test('23', 116, 118), equals(t.next()));
  expect(new Token.test('rob', 119, 124), equals(t.next()));
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
  var input = '''
aàáâãäåāăb cæd eďđf gçćčĉċh ièéêëēęěĕėj kƒl mĝğġģn oĥħp qììíîïīĩĭr sįıĳĵt uķĸv
włľĺļŀx yñńňņŉŋz aòóôõöøōőŏŏb cœd eąf gŕřŗh iśšşŝșj kťţŧțl mùúûüūůűŭũųn oŵp
qýÿŷr sžżźt
''';
  var t = new MappingFilter(new LetterTokenizer(input), mapping);
  expect(new Token.test('aaaaaaaaab', 0, 18), equals(t.next()));
  expect(new Token.test('caed', 19, 23), equals(t.next()));
  expect(new Token.test('eddf', 24, 30), equals(t.next()));
  expect(new Token.test('gccccch', 31, 43), equals(t.next()));
  expect(new Token.test('ieeeeeeeeej', 44, 64), equals(t.next()));
  expect(new Token.test('kfl', 65, 69), equals(t.next()));
  expect(new Token.test('mggggn', 70, 80), equals(t.next()));
  expect(new Token.test('ohhp', 81, 87), equals(t.next()));
  expect(new Token.test('qiiiiiiiir', 88, 106), equals(t.next()));
  expect(new Token.test('sjjjjt', 107, 117), equals(t.next()));
  expect(new Token.test('ukkv', 118, 124), equals(t.next()));
  expect(new Token.test('wlllllx', 125, 137), equals(t.next()));
  expect(new Token.test('ynnnnnnz', 138, 152), equals(t.next()));
  expect(new Token.test('aoooooooooob', 153, 175), equals(t.next()));
  expect(new Token.test('coekd', 176, 180), equals(t.next()));
  expect(new Token.test('eqf', 181, 185), equals(t.next()));
  expect(new Token.test('grrrh', 186, 194), equals(t.next()));
  expect(new Token.test('isssssj', 195, 207), equals(t.next()));
  expect(new Token.test('kttttl', 208, 218), equals(t.next()));
  expect(new Token.test('muuuuuuuuuun', 219, 241), equals(t.next()));
  expect(new Token.test('owp', 242, 246), equals(t.next()));
  expect(new Token.test('qyyyr', 247, 255), equals(t.next()));
  expect(new Token.test('szzzt', 256, 264), equals(t.next()));
  expect(t.next(), isNull);
}

test_stop_filter() {
  var words = ["one", "four", "five", "seven"];
  var input = "one, two, three, four, five, six, seven, eight, nine, ten.";
  var t = new StopFilter(new AsciiLetterTokenizer(input), words);
  expect(new Token.test('two', 5, 8, 2), equals(t.next()));
  expect(new Token.test('three', 10, 15, 1), equals(t.next()));
  expect(new Token.test('six', 29, 32, 3), equals(t.next()));
  expect(new Token.test('eight', 41, 46, 2), equals(t.next()));
  expect(new Token.test('nine', 48, 52, 1), equals(t.next()));
  expect(new Token.test('ten', 54, 57, 1), equals(t.next()));
  expect(t.next(), isNull);
}

test_stem_filter() {
  var input = "Debate Debates DEBATED DEBating Debater";
  var t = new StemFilter(
      new AsciiLowerCaseFilter(new AsciiLetterTokenizer(input)),
      algorithm: "english");
  expect(new Token.test("debat", 0, 6), equals(t.next()));
  expect(new Token.test("debat", 7, 14), equals(t.next()));
  expect(new Token.test("debat", 15, 22), equals(t.next()));
  expect(new Token.test("debat", 23, 31), equals(t.next()));
  expect(new Token.test("debat", 32, 39), equals(t.next()));
  expect(t.next(), isNull);
  t = new StemFilter(new AsciiLetterTokenizer(input), algorithm: 'english');
  expect(new Token.test("Debat", 0, 6), equals(t.next()));
  expect(new Token.test("Debat", 7, 14), equals(t.next()));
  expect(new Token.test("DEBATED", 15, 22), equals(t.next()));
  expect(new Token.test("DEBate", 23, 31), equals(t.next()));
  expect(new Token.test("Debat", 32, 39), equals(t.next()));

  if (Ferret.locale && Ferret.locale.downcase.index("utf")) {
    input = "Dêbate dêbates DÊBATED DÊBATing dêbater";
    t = new StemFilter(new LowerCaseFilter(new LetterTokenizer(input)),
        algorithm: 'english');
    expect(new Token.test("dêbate", 0, 7), equals(t.next()));
    expect(new Token.test("dêbate", 8, 16), equals(t.next()));
    expect(new Token.test("dêbate", 17, 25), equals(t.next()));
    expect(new Token.test("dêbate", 26, 35), equals(t.next()));
    expect(new Token.test("dêbater", 36, 44), equals(t.next()));
    t = new StemFilter(new LetterTokenizer(input), algorithm: 'english');
    expect(new Token.test("Dêbate", 0, 7), equals(t.next()));
    expect(new Token.test("dêbate", 8, 16), equals(t.next()));
    expect(new Token.test("DÊBATED", 17, 25), equals(t.next()));
    expect(new Token.test("DÊBATing", 26, 35), equals(t.next()));
    expect(new Token.test("dêbater", 36, 44), equals(t.next()));
    expect(t.next(), isNull);
  }

  var tz = new AsciiLetterTokenizer(input);
  expect(
      new StemFilter(tz, algorithm: 'HunGarIaN', encoding: 'Utf-8'), isNotNull);
  expect(new StemFilter(tz, algorithm: 'romanIAN', encoding: 'iso-8859-2'),
      isNotNull);
  expect(ArgumentError, () {
    new StemFilter(tz, algorithm: 'Jibberish', encoding: 'UTF-8');
  });
}

//require 'strscan'

class MyRegExpTokenizer extends TokenStream {
  var _ss;

  MyRegExpTokenizer(String input) {
    _ss = new StringScanner(input);
  }

  /// Returns the next token in the stream, or null at EOS.
  next() {
    var term, term_end, term_start;
    if (_ss.scan_until(token_re)) {
      term = _ss.matched;
      term_end = _ss.pos;
      term_start = term_end - term.size;
    } else {
      return null;
    }

    return new Token.test(normalize(term), term_start, term_end);
  }

  set text(String text) {
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

class MyReverseTokenFilter extends TokenStream {
  var _token_stream;

  MyReverseTokenFilter(token_stream) {
    _token_stream = token_stream;
  }

  set text(text) {
    _token_stream.text = text;
  }

  next() {
    var token;
    if (token = _token_stream.next()) {
      token.text = token.text.reverse;
    }
    return token;
  }
}

class MyCSVTokenizer extends MyRegExpTokenizer {
  MyCSVTokenizer(token_stream) : super(token_stream);

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
  expect(new Token.test("FIRST FIELD", 0, 11), equals(t.next()));
  expect(new Token.test("2ND FIELD", 12, 21), equals(t.next()));
  expect(
      new Token.test("  P A D D E D  F I E L D  ", 22, 48), equals(t.next()));
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new MyCSVTokenizer(input));
  expect(new Token.test("first field", 0, 11), equals(t.next()));
  expect(new Token.test("2nd field", 12, 21), equals(t.next()));
  expect(
      new Token.test("  p a d d e d  f i e l d  ", 22, 48), equals(t.next()));
  expect(t.next(), isNull);
  t = new MyReverseTokenFilter(
      new AsciiLowerCaseFilter(new MyCSVTokenizer(input)));
  expect(new Token.test("dleif tsrif", 0, 11), equals(t.next()));
  expect(new Token.test("dleif dn2", 12, 21), equals(t.next()));
  expect(
      new Token.test("  d l e i f  d e d d a p  ", 22, 48), equals(t.next()));
  t.text = "one,TWO,three";
  expect(new Token.test("eno", 0, 3), equals(t.next()));
  expect(new Token.test("owt", 4, 7), equals(t.next()));
  expect(new Token.test("eerht", 8, 13), equals(t.next()));
  t = new AsciiLowerCaseFilter(
      new MyReverseTokenFilter(new MyCSVTokenizer(input)));
  expect(new Token.test("dleif tsrif", 0, 11), equals(t.next()));
  expect(new Token.test("dleif dn2", 12, 21), equals(t.next()));
  expect(
      new Token.test("  d l e i f  d e d d a p  ", 22, 48), equals(t.next()));
  t.text = "one,TWO,three";
  expect(new Token.test("eno", 0, 3), equals(t.next()));
  expect(new Token.test("owt", 4, 7), equals(t.next()));
  expect(new Token.test("eerht", 8, 13), equals(t.next()));
}

class TokenFilter extends TokenStream {
  var _input;
  //protected
  /// Construct a token stream filtering the given input.
  TokenFilter(input) {
    _input = input;
  }
}

/// Normalizes token text to lower case.
class CapitalizeFilter extends TokenFilter {
  CapitalizeFilter(input) : super(input);

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
  expect(new Token.test("This", 0, 4), equals(t.next()));
  expect(new Token.test("Text", 5, 9), equals(t.next()));
  expect(new Token.test("Should", 10, 16), equals(t.next()));
  expect(new Token.test("Be", 17, 19), equals(t.next()));
  expect(new Token.test("Capitalized", 20, 31), equals(t.next()));
  expect(new Token.test("I", 36, 37), equals(t.next()));
  expect(new Token.test("Hope", 38, 42), equals(t.next()));
  expect(new Token.test("S", 46, 47), equals(t.next()));
  expect(t.next(), isNull);
  t = new StemFilter(new CapitalizeFilter(new AsciiLetterTokenizer(input)));
  expect(new Token.test("This", 0, 4), equals(t.next()));
  expect(new Token.test("Text", 5, 9), equals(t.next()));
  expect(new Token.test("Should", 10, 16), equals(t.next()));
  expect(new Token.test("Be", 17, 19), equals(t.next()));
  expect(new Token.test("Capit", 20, 31), equals(t.next()));
  expect(new Token.test("I", 36, 37), equals(t.next()));
  expect(new Token.test("Hope", 38, 42), equals(t.next()));
  expect(new Token.test("S", 46, 47), equals(t.next()));
  expect(t.next(), isNull);
}
