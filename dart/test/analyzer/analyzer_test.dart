library ferret.test.analyzer;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

test_analyzer() {
  var input = r'DBalmain@gmail.com is My E-Mail 523@#$ ADDRESS. 23#!$';
  var a = new Analyzer();
  var t = a.token_stream("fieldname", input);
  var t2 = a.token_stream("fieldname", input);
  expect(new Token("dbalmain", 0, 8), equals(t.next()));
  expect(new Token("gmail", 9, 14), equals(t.next()));
  expect(new Token("com", 15, 18), equals(t.next()));
  expect(new Token("is", 19, 21), equals(t.next()));
  expect(new Token("my", 22, 24), equals(t.next()));
  expect(new Token("e", 25, 26), equals(t.next()));
  expect(new Token("mail", 27, 31), equals(t.next()));
  expect(new Token("address", 39, 46), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token("dbalmain", 0, 8), equals(t2.next()));
  expect(new Token("gmail", 9, 14), equals(t2.next()));
  expect(new Token("com", 15, 18), equals(t2.next()));
  expect(new Token("is", 19, 21), equals(t2.next()));
  expect(new Token("my", 22, 24), equals(t2.next()));
  expect(new Token("e", 25, 26), equals(t2.next()));
  expect(new Token("mail", 27, 31), equals(t2.next()));
  expect(new Token("address", 39, 46), equals(t2.next()));
  expect(t2.next(), isNull);
  a = new Analyzer(lower: false);
  t = a.token_stream("fieldname", input);
  expect(new Token("DBalmain", 0, 8), equals(t.next()));
  expect(new Token("gmail", 9, 14), equals(t.next()));
  expect(new Token("com", 15, 18), equals(t.next()));
  expect(new Token("is", 19, 21), equals(t.next()));
  expect(new Token("My", 22, 24), equals(t.next()));
  expect(new Token("E", 25, 26), equals(t.next()));
  expect(new Token("Mail", 27, 31), equals(t.next()));
  expect(new Token("ADDRESS", 39, 46), equals(t.next()));
  expect(t.next(), isNull);
}

test_ascii_letter_analyzer() {
  var input = r'DBalmain@gmail.com is My E-Mail 523@#$ ADDRESS. 23#!$';
  var a = new AsciiLetterAnalyzer();
  var t = a.token_stream("fieldname", input);
  var t2 = a.token_stream("fieldname", input);
  expect(new Token("dbalmain", 0, 8), equals(t.next()));
  expect(new Token("gmail", 9, 14), equals(t.next()));
  expect(new Token("com", 15, 18), equals(t.next()));
  expect(new Token("is", 19, 21), equals(t.next()));
  expect(new Token("my", 22, 24), equals(t.next()));
  expect(new Token("e", 25, 26), equals(t.next()));
  expect(new Token("mail", 27, 31), equals(t.next()));
  expect(new Token("address", 39, 46), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token("dbalmain", 0, 8), equals(t2.next()));
  expect(new Token("gmail", 9, 14), equals(t2.next()));
  expect(new Token("com", 15, 18), equals(t2.next()));
  expect(new Token("is", 19, 21), equals(t2.next()));
  expect(new Token("my", 22, 24), equals(t2.next()));
  expect(new Token("e", 25, 26), equals(t2.next()));
  expect(new Token("mail", 27, 31), equals(t2.next()));
  expect(new Token("address", 39, 46), equals(t2.next()));
  expect(t2.next(), isNull);
  a = new AsciiLetterAnalyzer(lower: false);
  t = a.token_stream("fieldname", input);
  expect(new Token("DBalmain", 0, 8), equals(t.next()));
  expect(new Token("gmail", 9, 14), equals(t.next()));
  expect(new Token("com", 15, 18), equals(t.next()));
  expect(new Token("is", 19, 21), equals(t.next()));
  expect(new Token("My", 22, 24), equals(t.next()));
  expect(new Token("E", 25, 26), equals(t.next()));
  expect(new Token("Mail", 27, 31), equals(t.next()));
  expect(new Token("ADDRESS", 39, 46), equals(t.next()));
  expect(t.next(), isNull);
}

test_letter_analyzer() {
  //Ferret.locale = ""
  var input =
      r'DBalmän@gmail.com is My e-mail 52   #$ address. 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var a = new LetterAnalyzer(lower: false);
  var t = a.token_stream("fieldname", input);
  var t2 = a.token_stream("fieldname", input);
  expect(new Token("DBalmän", 0, 8), equals(t.next()));
  expect(new Token("gmail", 9, 14), equals(t.next()));
  expect(new Token("com", 15, 18), equals(t.next()));
  expect(new Token("is", 19, 21), equals(t.next()));
  expect(new Token("My", 22, 24), equals(t.next()));
  expect(new Token("e", 25, 26), equals(t.next()));
  expect(new Token("mail", 27, 31), equals(t.next()));
  expect(new Token("address", 40, 47), equals(t.next()));
  expect(new Token("ÁÄGÇ", 55, 62), equals(t.next()));
  expect(new Token("ÊËÌ", 64, 70), equals(t.next()));
  expect(new Token("ÚØÃ", 72, 78), equals(t.next()));
  expect(new Token("ÖÎÍ", 80, 86), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token("DBalmän", 0, 8), equals(t2.next()));
  expect(new Token("gmail", 9, 14), equals(t2.next()));
  expect(new Token("com", 15, 18), equals(t2.next()));
  expect(new Token("is", 19, 21), equals(t2.next()));
  expect(new Token("My", 22, 24), equals(t2.next()));
  expect(new Token("e", 25, 26), equals(t2.next()));
  expect(new Token("mail", 27, 31), equals(t2.next()));
  expect(new Token("address", 40, 47), equals(t2.next()));
  expect(new Token("ÁÄGÇ", 55, 62), equals(t2.next()));
  expect(new Token("ÊËÌ", 64, 70), equals(t2.next()));
  expect(new Token("ÚØÃ", 72, 78), equals(t2.next()));
  expect(new Token("ÖÎÍ", 80, 86), equals(t2.next()));
  expect(t2.next(), isNull);
  a = new LetterAnalyzer();
  t = a.token_stream("fieldname", input);
  expect(new Token("dbalmän", 0, 8), equals(t.next()));
  expect(new Token("gmail", 9, 14), equals(t.next()));
  expect(new Token("com", 15, 18), equals(t.next()));
  expect(new Token("is", 19, 21), equals(t.next()));
  expect(new Token("my", 22, 24), equals(t.next()));
  expect(new Token("e", 25, 26), equals(t.next()));
  expect(new Token("mail", 27, 31), equals(t.next()));
  expect(new Token("address", 40, 47), equals(t.next()));
  expect(new Token("áägç", 55, 62), equals(t.next()));
  expect(new Token("êëì", 64, 70), equals(t.next()));
  expect(new Token("úøã", 72, 78), equals(t.next()));
  expect(new Token("öîí", 80, 86), equals(t.next()));
  expect(t.next(), isNull);
}

test_ascii_white_space_analyzer() {
  var input = r'DBalmain@gmail.com is My E-Mail 52   #$ ADDRESS. 23#!$';
  var a = new AsciiWhiteSpaceAnalyzer();
  var t = a.token_stream("fieldname", input);
  var t2 = a.token_stream("fieldname", input);
  expect(new Token('DBalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('E-Mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token(r'#$', 37, 39), equals(t.next()));
  expect(new Token('ADDRESS.', 40, 48), equals(t.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token('DBalmain@gmail.com', 0, 18), equals(t2.next()));
  expect(new Token('is', 19, 21), equals(t2.next()));
  expect(new Token('My', 22, 24), equals(t2.next()));
  expect(new Token('E-Mail', 25, 31), equals(t2.next()));
  expect(new Token('52', 32, 34), equals(t2.next()));
  expect(new Token(r'#$', 37, 39), equals(t2.next()));
  expect(new Token('ADDRESS.', 40, 48), equals(t2.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t2.next()));
  expect(t2.next(), isNull);
  a = new AsciiWhiteSpaceAnalyzer(lower: true);
  t = a.token_stream("fieldname", input);
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

test_white_space_analyzer() {
  var input =
      r'DBalmän@gmail.com is My e-mail 52   #$ address. 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var a = new WhiteSpaceAnalyzer();
  var t = a.token_stream("fieldname", input);
  var t2 = a.token_stream("fieldname", input);
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
  expect(new Token('DBalmän@gmail.com', 0, 18), equals(t2.next()));
  expect(new Token('is', 19, 21), equals(t2.next()));
  expect(new Token('My', 22, 24), equals(t2.next()));
  expect(new Token('e-mail', 25, 31), equals(t2.next()));
  expect(new Token('52', 32, 34), equals(t2.next()));
  expect(new Token(r'#$', 37, 39), equals(t2.next()));
  expect(new Token('address.', 40, 48), equals(t2.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t2.next()));
  expect(new Token('ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ', 55, 86), equals(t2.next()));
  expect(t2.next(), isNull);
  a = new WhiteSpaceAnalyzer(lower: true);
  t = a.token_stream("fieldname", input);
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

test_ascii_standard_analyzer() {
  var input =
      r'DBalmain@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/results/ T.N.T. 123-1235-ASD-1234';
  var a = new AsciiStandardAnalyzer();
  var t = a.token_stream("fieldname", input);
  var t2 = a.token_stream("fieldname", input);
  expect(new Token('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('email', 25, 31, 3), equals(t.next()));
  expect(new Token('e', 25, 26, 0), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t.next()));
  expect(new Token('tnt', 86, 91), equals(t.next()));
  expect(new Token('123-1235-asd-1234', 93, 110), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token('dbalmain@gmail.com', 0, 18), equals(t2.next()));
  expect(new Token('email', 25, 31, 3), equals(t2.next()));
  expect(new Token('e', 25, 26, 0), equals(t2.next()));
  expect(new Token('mail', 27, 31), equals(t2.next()));
  expect(new Token('52', 32, 34), equals(t2.next()));
  expect(new Token('address', 40, 47), equals(t2.next()));
  expect(new Token('23', 49, 51), equals(t2.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t2.next()));
  expect(new Token('tnt', 86, 91), equals(t2.next()));
  expect(new Token('123-1235-asd-1234', 93, 110), equals(t2.next()));
  expect(t2.next(), isNull);
  a = new AsciiStandardAnalyzer(stop_words: ENGLISH_STOP_WORDS, lower: false);
  t = a.token_stream("fieldname", input);
  t2 = a.token_stream("fieldname", input);
  expect(new Token('DBalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('email', 25, 31, 3), equals(t.next()));
  expect(new Token('e', 25, 26, 0), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('Address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t.next()));
  expect(new Token('TNT', 86, 91), equals(t.next()));
  expect(new Token('123-1235-ASD-1234', 93, 110), equals(t.next()));
  expect(t.next(), isNull);
}

test_standard_analyzer() {
  var input =
      r'DBalmán@gmail.com is My e-mail and the Address. 23#!$ http://www.google.com/results/ T.N.T. 123-1235-ASD-1234 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var a = new StandardAnalyzer();
  var t = a.token_stream("fieldname", input);
  var t2 = a.token_stream("fieldname", input);
  expect(new Token('dbalmán@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('email', 25, 31, 3), equals(t.next()));
  expect(new Token('e', 25, 26, 0), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t.next()));
  expect(new Token('tnt', 86, 91), equals(t.next()));
  expect(new Token('123-1235-asd-1234', 93, 110), equals(t.next()));
  expect(new Token('23', 111, 113), equals(t.next()));
  expect(new Token('áägç', 117, 124), equals(t.next()));
  expect(new Token('êëì', 126, 132), equals(t.next()));
  expect(new Token('úøã', 134, 140), equals(t.next()));
  expect(new Token('öîí', 142, 148), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token('dbalmán@gmail.com', 0, 18), equals(t2.next()));
  expect(new Token('email', 25, 31, 3), equals(t2.next()));
  expect(new Token('e', 25, 26, 0), equals(t2.next()));
  expect(new Token('mail', 27, 31), equals(t2.next()));
  expect(new Token('address', 40, 47), equals(t2.next()));
  expect(new Token('23', 49, 51), equals(t2.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t2.next()));
  expect(new Token('tnt', 86, 91), equals(t2.next()));
  expect(new Token('123-1235-asd-1234', 93, 110), equals(t2.next()));
  expect(new Token('23', 111, 113), equals(t2.next()));
  expect(new Token('áägç', 117, 124), equals(t2.next()));
  expect(new Token('êëì', 126, 132), equals(t2.next()));
  expect(new Token('úøã', 134, 140), equals(t2.next()));
  expect(new Token('öîí', 142, 148), equals(t2.next()));
  expect(t2.next(), isNull);
  a = new StandardAnalyzer(stop_words: null, lower: false);
  t = a.token_stream("fieldname", input);
  expect(new Token('DBalmán@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('email', 25, 31, 3), equals(t.next()));
  expect(new Token('e', 25, 26, 0), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('Address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t.next()));
  expect(new Token('TNT', 86, 91), equals(t.next()));
  expect(new Token('123-1235-ASD-1234', 93, 110), equals(t.next()));
  expect(new Token('23', 111, 113), equals(t.next()));
  expect(new Token('ÁÄGÇ', 117, 124), equals(t.next()));
  expect(new Token('ÊËÌ', 126, 132), equals(t.next()));
  expect(new Token('ÚØÃ', 134, 140), equals(t.next()));
  expect(new Token('ÖÎÍ', 142, 148), equals(t.next()));
  expect(t.next(), isNull);
  a = new StandardAnalyzer(stop_words: ["e-mail", "23", "tnt"]);
  t = a.token_stream("fieldname", input);
  t2 = a.token_stream("fieldname", input);
  expect(new Token('dbalmán@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('and', 32, 35), equals(t.next()));
  expect(new Token('the', 36, 39), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t.next()));
  expect(new Token('123-1235-asd-1234', 93, 110), equals(t.next()));
  expect(new Token('áägç', 117, 124), equals(t.next()));
  expect(new Token('êëì', 126, 132), equals(t.next()));
  expect(new Token('úøã', 134, 140), equals(t.next()));
  expect(new Token('öîí', 142, 148), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token('dbalmán@gmail.com', 0, 18), equals(t2.next()));
  expect(new Token('is', 19, 21), equals(t2.next()));
  expect(new Token('my', 22, 24), equals(t2.next()));
  expect(new Token('and', 32, 35), equals(t2.next()));
  expect(new Token('the', 36, 39), equals(t2.next()));
  expect(new Token('address', 40, 47), equals(t2.next()));
  expect(new Token('www.google.com/results', 55, 85), equals(t2.next()));
  expect(new Token('123-1235-asd-1234', 93, 110), equals(t2.next()));
  expect(new Token('áägç', 117, 124), equals(t2.next()));
  expect(new Token('êëì', 126, 132), equals(t2.next()));
  expect(new Token('úøã', 134, 140), equals(t2.next()));
  expect(new Token('öîí', 142, 148), equals(t2.next()));
  expect(t2.next(), isNull);
}

test_per_field_analyzer() {
  var input = r'DBalmain@gmail.com is My e-mail 52   #$ address. 23#!$';
  var pfa = new PerFieldAnalyzer(new StandardAnalyzer());
  pfa['white'] = new WhiteSpaceAnalyzer(lower: false);
  pfa['white_l'] = new WhiteSpaceAnalyzer(lower: true);
  pfa['letter'] = new LetterAnalyzer(lower: false);
  pfa.add_field('letter', new LetterAnalyzer(lower: true));
  pfa.add_field('letter_u', new LetterAnalyzer(lower: false));
  var t = pfa.token_stream('white', input);
  expect(new Token('DBalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token(r'#$', 37, 39), equals(t.next()));
  expect(new Token('address.', 40, 48), equals(t.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t.next()));
  expect(t.next(), isNull);
  t = pfa.token_stream('white_l', input);
  expect(new Token('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e-mail', 25, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token(r'#$', 37, 39), equals(t.next()));
  expect(new Token('address.', 40, 48), equals(t.next()));
  expect(new Token(r'23#!$', 49, 54), equals(t.next()));
  expect(t.next(), isNull);
  t = pfa.token_stream('letter_u', input);
  expect(new Token('DBalmain', 0, 8), equals(t.next()));
  expect(new Token('gmail', 9, 14), equals(t.next()));
  expect(new Token('com', 15, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('e', 25, 26), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(t.next(), isNull);
  t = pfa.token_stream('letter', input);
  expect(new Token('dbalmain', 0, 8), equals(t.next()));
  expect(new Token('gmail', 9, 14), equals(t.next()));
  expect(new Token('com', 15, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('my', 22, 24), equals(t.next()));
  expect(new Token('e', 25, 26), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(t.next(), isNull);
  t = pfa.token_stream('XXX', input); // should use default StandardAnalzyer
  expect(new Token('dbalmain@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('email', 25, 31, 3), equals(t.next()));
  expect(new Token('e', 25, 26, 0), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(t.next(), isNull);
}

test_reg_exp_analyzer() {
  var input =
      r"DBalmain@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/RESULT_3.html T.N.T. 123-1235-ASD-1234 23 Rob's";
  var a = new RegExpAnalyzer();
  var t = a.token_stream('XXX', input);
  var t2 = a.token_stream('XXX', "one_Two three");
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
  t = t2;
  expect(new Token("one_two", 0, 7), t.next());
  expect(new Token("three", 8, 13), t.next());
  expect(t.next(), isNull);
  a = new RegExpAnalyzer(new RegExp(r"\w{2,}"), lower: false);
  t = a.token_stream('XXX', input);
  t2 = a.token_stream('XXX', "one Two three");
  expect(new Token('DBalmain', 0, 8), equals(t.next()));
  expect(new Token('gmail', 9, 14), equals(t.next()));
  expect(new Token('com', 15, 18), equals(t.next()));
  expect(new Token('is', 19, 21), equals(t.next()));
  expect(new Token('My', 22, 24), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('52', 32, 34), equals(t.next()));
  expect(new Token('Address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('http', 55, 59), equals(t.next()));
  expect(new Token('www', 62, 65), equals(t.next()));
  expect(new Token('google', 66, 72), equals(t.next()));
  expect(new Token('com', 73, 76), equals(t.next()));
  expect(new Token('RESULT_3', 77, 85), equals(t.next()));
  expect(new Token('html', 86, 90), equals(t.next()));
  expect(new Token('123', 98, 101), equals(t.next()));
  expect(new Token('1235', 102, 106), equals(t.next()));
  expect(new Token('ASD', 107, 110), equals(t.next()));
  expect(new Token('1234', 111, 115), equals(t.next()));
  expect(new Token('23', 116, 118), equals(t.next()));
  expect(new Token('Rob', 119, 122), equals(t.next()));
  expect(t.next(), isNull);
  expect(new Token("one", 0, 3), t2.next());
  expect(new Token("Two", 4, 7), t2.next());
  expect(new Token("three", 8, 13), t2.next());
  expect(t2.next(), isNull);
  a = new RegExpAnalyzer.func((str) {
    if (str = ~r"^[[:alpha:]]\.([[:alpha:]]\.)+$") {
      str.gsub /*!*/ (r"\.", '');
    } else if (str = ~r"'[sS]$") {
      str.gsub /*!*/ (r"'[sS]$", '');
    }
    return str;
  });
  t = a.token_stream('XXX', input);
  t2 = a.token_stream('XXX', "one's don't T.N.T.");
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
  expect(new Token("one", 0, 5), t2.next());
  expect(new Token("don't", 6, 11), t2.next());
  expect(new Token("tnt", 12, 18), t2.next());
  expect(t2.next(), isNull);
}

class StemmingStandardAnalyzer {
  //extends StandardAnalyzer {
  token_stream(field, text) {
    //return new StemFilter(super);
  }
}

test_custom_filter() {
  var input =
      r'DBalmán@gmail.com is My e-mail and the Address. 23#!$ http://www.google.com/results/ T.N.T. 123-1235-ASD-1234 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  var a = new StemmingStandardAnalyzer();
  var t = a.token_stream("fieldname", input);
  expect(new Token('dbalmán@gmail.com', 0, 18), equals(t.next()));
  expect(new Token('email', 25, 31, 3), equals(t.next()));
  expect(new Token('e', 25, 26, 0), equals(t.next()));
  expect(new Token('mail', 27, 31), equals(t.next()));
  expect(new Token('address', 40, 47), equals(t.next()));
  expect(new Token('23', 49, 51), equals(t.next()));
  expect(new Token('www.google.com/result', 55, 85), equals(t.next()));
  expect(new Token('tnt', 86, 91), equals(t.next()));
  expect(new Token('123-1235-asd-1234', 93, 110), equals(t.next()));
  expect(new Token('23', 111, 113), equals(t.next()));
  expect(new Token('áägç', 117, 124), equals(t.next()));
  expect(new Token('êëì', 126, 132), equals(t.next()));
  expect(new Token('úøã', 134, 140), equals(t.next()));
  expect(new Token('öîí', 142, 148), equals(t.next()));
  expect(t.next(), isNull);
  input = "Debate Debates DEBATED DEBating Debater";
  t = a.token_stream("fieldname", input);
  expect(new Token("debat", 0, 6), equals(t.next()));
  expect(new Token("debat", 7, 14), equals(t.next()));
  expect(new Token("debat", 15, 22), equals(t.next()));
  expect(new Token("debat", 23, 31), equals(t.next()));
  expect(new Token("debat", 32, 39), equals(t.next()));
  expect(t.next(), isNull);
  input = "Dêbate dêbates DÊBATED DÊBATing dêbater";
  t = new StemFilter(new LowerCaseFilter(new LetterTokenizer(input)),
      algorithm: 'english');
  expect(new Token("dêbate", 0, 7), equals(t.next()));
  expect(new Token("dêbate", 8, 16), equals(t.next()));
  expect(new Token("dêbate", 17, 25), equals(t.next()));
  expect(new Token("dêbate", 26, 35), equals(t.next()));
  expect(new Token("dêbater", 36, 44), equals(t.next()));
  expect(t.next(), isNull);
}
