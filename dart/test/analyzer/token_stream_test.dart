library ferret.test.analyzer.token_stream;

test_token() {
  t = new Token("text", 1, 2, 3);
  assert_equal("text", t.text);
  assert_equal(1, t.start);
  assert_equal(2, t.end);
  assert_equal(3, t.pos_inc);
  t.text = "yada yada yada";
  t.start = 11;
  t.end = 12;
  t.pos_inc = 13;
  assert_equal("yada yada yada", t.text);
  assert_equal(11, t.start);
  assert_equal(12, t.end);
  assert_equal(13, t.pos_inc);

  t = new Token("text", 1, 2);
  assert_equal(1, t.pos_inc);
}

test_ascii_letter_tokenizer() {
  input = r'DBalmain@gmail.com is My e-mail 523@#$ ADDRESS. 23#!$';
  t = new AsciiLetterTokenizer(input);
  assert_equal(new Token("DBalmain", 0, 8), t.next());
  assert_equal(new Token("gmail", 9, 14), t.next());
  assert_equal(new Token("com", 15, 18), t.next());
  assert_equal(new Token("is", 19, 21), t.next());
  assert_equal(new Token("My", 22, 24), t.next());
  assert_equal(new Token("e", 25, 26), t.next());
  assert_equal(new Token("mail", 27, 31), t.next());
  assert_equal(new Token("ADDRESS", 39, 46), t.next());
  expect(t.next(), isNull);
  t.text = "one_two three";
  assert_equal(new Token("one", 0, 3), t.next());
  assert_equal(new Token("two", 4, 7), t.next());
  assert_equal(new Token("three", 8, 13), t.next());
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new AsciiLetterTokenizer(input));
  assert_equal(new Token("dbalmain", 0, 8), t.next());
  assert_equal(new Token("gmail", 9, 14), t.next());
  assert_equal(new Token("com", 15, 18), t.next());
  assert_equal(new Token("is", 19, 21), t.next());
  assert_equal(new Token("my", 22, 24), t.next());
  assert_equal(new Token("e", 25, 26), t.next());
  assert_equal(new Token("mail", 27, 31), t.next());
  assert_equal(new Token("address", 39, 46), t.next());
  expect(t.next(), isNull);
}

test_letter_tokenizer() {
  input =
      r'DBalmän@gmail.com is My e-mail 52   #$ address. 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  t = new LetterTokenizer(input);
  assert_equal(new Token('DBalmän', 0, 8), t.next);
  assert_equal(new Token('gmail', 9, 14), t.next);
  assert_equal(new Token('com', 15, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('My', 22, 24), t.next);
  assert_equal(new Token('e', 25, 26), t.next);
  assert_equal(new Token('mail', 27, 31), t.next);
  assert_equal(new Token('address', 40, 47), t.next);
  assert_equal(new Token('ÁÄGÇ', 55, 62), t.next);
  assert_equal(new Token('ÊËÌ', 64, 70), t.next);
  assert_equal(new Token('ÚØÃ', 72, 78), t.next);
  assert_equal(new Token('ÖÎÍ', 80, 86), t.next);
  expect(t.next(), isNull);
  t.text = "one_two three";
  assert_equal(new Token("one", 0, 3), t.next());
  assert_equal(new Token("two", 4, 7), t.next());
  assert_equal(new Token("three", 8, 13), t.next());
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new LetterTokenizer(input));
  assert_equal(new Token('dbalmän', 0, 8), t.next);
  assert_equal(new Token('gmail', 9, 14), t.next);
  assert_equal(new Token('com', 15, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('my', 22, 24), t.next);
  assert_equal(new Token('e', 25, 26), t.next);
  assert_equal(new Token('mail', 27, 31), t.next);
  assert_equal(new Token('address', 40, 47), t.next);
  assert_equal(new Token('áägç', 55, 62), t.next);
  assert_equal(new Token('êëì', 64, 70), t.next);
  assert_equal(new Token('úøã', 72, 78), t.next);
  assert_equal(new Token('öîí', 80, 86), t.next);
  expect(t.next(), isNull);
  t = new LetterTokenizer(input, true);
  assert_equal(new Token('dbalmän', 0, 8), t.next);
  assert_equal(new Token('gmail', 9, 14), t.next);
  assert_equal(new Token('com', 15, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('my', 22, 24), t.next);
  assert_equal(new Token('e', 25, 26), t.next);
  assert_equal(new Token('mail', 27, 31), t.next);
  assert_equal(new Token('address', 40, 47), t.next);
  assert_equal(new Token('áägç', 55, 62), t.next);
  assert_equal(new Token('êëì', 64, 70), t.next);
  assert_equal(new Token('úøã', 72, 78), t.next);
  assert_equal(new Token('öîí', 80, 86), t.next);
  expect(t.next(), isNull);
}

test_ascii_whitespace_tokenizer() {
  input = r'DBalmain@gmail.com is My e-mail 52   #$ ADDRESS. 23#!$';
  t = new AsciiWhiteSpaceTokenizer(input);
  assert_equal(new Token('DBalmain@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('My', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token(r'#$', 37, 39), t.next);
  assert_equal(new Token('ADDRESS.', 40, 48), t.next);
  assert_equal(new Token(r'23#!$', 49, 54), t.next);
  expect(t.next(), isNull);
  t.text = "one_two three";
  assert_equal(new Token("one_two", 0, 7), t.next());
  assert_equal(new Token("three", 8, 13), t.next());
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new AsciiWhiteSpaceTokenizer(input));
  assert_equal(new Token('dbalmain@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('my', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token(r'#$', 37, 39), t.next);
  assert_equal(new Token('address.', 40, 48), t.next);
  assert_equal(new Token(r'23#!$', 49, 54), t.next);
  expect(t.next(), isNull);
}

test_whitespace_tokenizer() {
  input =
      r'DBalmän@gmail.com is My e-mail 52   #$ address. 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  t = new WhiteSpaceTokenizer(input);
  assert_equal(new Token('DBalmän@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('My', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token(r'#$', 37, 39), t.next);
  assert_equal(new Token('address.', 40, 48), t.next);
  assert_equal(new Token(r'23#!$', 49, 54), t.next);
  assert_equal(new Token('ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ', 55, 86), t.next);
  expect(t.next(), isNull);
  t.text = "one_two three";
  assert_equal(new Token("one_two", 0, 7), t.next());
  assert_equal(new Token("three", 8, 13), t.next());
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new WhiteSpaceTokenizer(input));
  assert_equal(new Token('dbalmän@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('my', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token(r'#$', 37, 39), t.next);
  assert_equal(new Token('address.', 40, 48), t.next);
  assert_equal(new Token(r'23#!$', 49, 54), t.next);
  assert_equal(new Token('áägç®êëì¯úøã¬öîí', 55, 86), t.next);
  expect(t.next(), isNull);
  t = new WhiteSpaceTokenizer(input, true);
  assert_equal(new Token('dbalmän@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('my', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token(r'#$', 37, 39), t.next);
  assert_equal(new Token('address.', 40, 48), t.next);
  assert_equal(new Token(r'23#!$', 49, 54), t.next);
  assert_equal(new Token('áägç®êëì¯úøã¬öîí', 55, 86), t.next);
  expect(t.next(), isNull);
}

test_ascii_standard_tokenizer() {
  input =
      r'DBalmain@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/results/ T.N.T. 123-1235-ASD-1234';
  t = new AsciiStandardTokenizer(input);
  assert_equal(new Token('DBalmain@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('My', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token('Address', 40, 47), t.next);
  assert_equal(new Token('23', 49, 51), t.next);
  assert_equal(new Token('www.google.com/results', 55, 85), t.next);
  assert_equal(new Token('TNT', 86, 91), t.next);
  assert_equal(new Token('123-1235-ASD-1234', 93, 110), t.next);
  expect(t.next(), isNull);
  t.text = "one_two three";
  assert_equal(new Token("one_two", 0, 7), t.next());
  assert_equal(new Token("three", 8, 13), t.next());
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new AsciiStandardTokenizer(input));
  assert_equal(new Token('dbalmain@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('my', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token('address', 40, 47), t.next);
  assert_equal(new Token('23', 49, 51), t.next);
  assert_equal(new Token('www.google.com/results', 55, 85), t.next);
  assert_equal(new Token('tnt', 86, 91), t.next);
  assert_equal(new Token('123-1235-asd-1234', 93, 110), t.next);
  expect(t.next(), isNull);
}

test_standard_tokenizer() {
  input =
      r'DBalmán@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/res_345/ T.N.T. 123-1235-ASD-1234 23#!$ ÁÄGÇ®ÊËÌ¯ÚØÃ¬ÖÎÍ';
  t = new StandardTokenizer(input);
  assert_equal(new Token('DBalmán@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('My', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token('Address', 40, 47), t.next);
  assert_equal(new Token('23', 49, 51), t.next);
  assert_equal(new Token('www.google.com/res_345', 55, 85), t.next);
  assert_equal(new Token('TNT', 86, 91), t.next);
  assert_equal(new Token('123-1235-ASD-1234', 93, 110), t.next);
  assert_equal(new Token('23', 111, 113), t.next);
  assert_equal(new Token('ÁÄGÇ', 117, 124), t.next);
  assert_equal(new Token('ÊËÌ', 126, 132), t.next);
  assert_equal(new Token('ÚØÃ', 134, 140), t.next);
  assert_equal(new Token('ÖÎÍ', 142, 148), t.next);
  expect(t.next(), isNull);
  t.text = "one_two three";
  assert_equal(new Token("one_two", 0, 7), t.next());
  assert_equal(new Token("three", 8, 13), t.next());
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new StandardTokenizer(input));
  assert_equal(new Token('dbalmán@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('my', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token('address', 40, 47), t.next);
  assert_equal(new Token('23', 49, 51), t.next);
  assert_equal(new Token('www.google.com/res_345', 55, 85), t.next);
  assert_equal(new Token('tnt', 86, 91), t.next);
  assert_equal(new Token('123-1235-asd-1234', 93, 110), t.next);
  assert_equal(new Token('23', 111, 113), t.next);
  assert_equal(new Token('áägç', 117, 124), t.next);
  assert_equal(new Token('êëì', 126, 132), t.next);
  assert_equal(new Token('úøã', 134, 140), t.next);
  assert_equal(new Token('öîí', 142, 148), t.next);
  input = "e-mail 123-1235-asd-1234 http://www.davebalmain.com/trac-site/";
  t = new HyphenFilter(new StandardTokenizer(input));
  assert_equal(new Token('email', 0, 6), t.next);
  assert_equal(new Token('e', 0, 1, 0), t.next);
  assert_equal(new Token('mail', 2, 6, 1), t.next);
  assert_equal(new Token('123-1235-asd-1234', 7, 24), t.next);
  assert_equal(new Token('www.davebalmain.com/trac-site', 25, 61), t.next);
  expect(t.next(), isNull);
}

const ALPHA = r"[[:alpha:]_-]+";
const APOSTROPHE = r"#{ALPHA}('#{ALPHA})+";
const ACRONYM = r"#{ALPHA}\.(#{ALPHA}\.)+";
const ACRONYM_WORD = r"^#{ACRONYM}$";
const APOSTROPHE_WORD = r"^#{APOSTROPHE}$";

test_reg_exp_tokenizer() {
  input =
      r"DBalmain@gmail.com is My e-mail 52   #$ Address. 23#!$ http://www.google.com/RESULT_3.html T.N.T. 123-1235-ASD-1234 23 Rob's";
  t = new RegExpTokenizer(input);
  assert_equal(new Token('DBalmain@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('My', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token('Address', 40, 47), t.next);
  assert_equal(new Token('23', 49, 51), t.next);
  assert_equal(
      new Token('http://www.google.com/RESULT_3.html', 55, 90), t.next);
  assert_equal(new Token('T.N.T.', 91, 97), t.next);
  assert_equal(new Token('123-1235-ASD-1234', 98, 115), t.next);
  assert_equal(new Token('23', 116, 118), t.next);
  assert_equal(new Token('Rob\'s', 119, 124), t.next);
  expect(t.next(), isNull);
  t.text = "one_two three";
  assert_equal(new Token("one_two", 0, 7), t.next());
  assert_equal(new Token("three", 8, 13), t.next());
  expect(t.next(), isNull);
  t = new LowerCaseFilter(new RegExpTokenizer(input));
  t2 = new LowerCaseFilter(new RegExpTokenizer(input, r"\w{2,}"));
  assert_equal(new Token('dbalmain@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('my', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token('address', 40, 47), t.next);
  assert_equal(new Token('23', 49, 51), t.next);
  assert_equal(
      new Token('http://www.google.com/result_3.html', 55, 90), t.next);
  assert_equal(new Token('t.n.t.', 91, 97), t.next);
  assert_equal(new Token('123-1235-asd-1234', 98, 115), t.next);
  assert_equal(new Token('23', 116, 118), t.next);
  assert_equal(new Token('rob\'s', 119, 124), t.next);
  expect(t.next(), isNull);
  assert_equal(new Token('dbalmain', 0, 8), t2.next);
  assert_equal(new Token('gmail', 9, 14), t2.next);
  assert_equal(new Token('com', 15, 18), t2.next);
  assert_equal(new Token('is', 19, 21), t2.next);
  assert_equal(new Token('my', 22, 24), t2.next);
  assert_equal(new Token('mail', 27, 31), t2.next);
  assert_equal(new Token('52', 32, 34), t2.next);
  assert_equal(new Token('address', 40, 47), t2.next);
  assert_equal(new Token('23', 49, 51), t2.next);
  assert_equal(new Token('http', 55, 59), t2.next);
  assert_equal(new Token('www', 62, 65), t2.next);
  assert_equal(new Token('google', 66, 72), t2.next);
  assert_equal(new Token('com', 73, 76), t2.next);
  assert_equal(new Token('result_3', 77, 85), t2.next);
  assert_equal(new Token('html', 86, 90), t2.next);
  assert_equal(new Token('123', 98, 101), t2.next);
  assert_equal(new Token('1235', 102, 106), t2.next);
  assert_equal(new Token('asd', 107, 110), t2.next);
  assert_equal(new Token('1234', 111, 115), t2.next);
  assert_equal(new Token('23', 116, 118), t2.next);
  assert_equal(new Token('rob', 119, 122), t2.next);
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
  assert_equal(new Token('dbalmain@gmail.com', 0, 18), t.next);
  assert_equal(new Token('is', 19, 21), t.next);
  assert_equal(new Token('my', 22, 24), t.next);
  assert_equal(new Token('e-mail', 25, 31), t.next);
  assert_equal(new Token('52', 32, 34), t.next);
  assert_equal(new Token('address', 40, 47), t.next);
  assert_equal(new Token('23', 49, 51), t.next);
  assert_equal(
      new Token('http://www.google.com/result_3.html', 55, 90), t.next);
  assert_equal(new Token('tnt', 91, 97), t.next);
  assert_equal(new Token('123-1235-asd-1234', 98, 115), t.next);
  assert_equal(new Token('23', 116, 118), t.next);
  assert_equal(new Token('rob', 119, 124), t.next);
  expect(t.next(), isNull);
}

test_mapping_filter() {
  mapping = {
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
  t = new MappingFilter(new LetterTokenizer(input), mapping);
  assert_equal(new Token('aaaaaaaaab', 0, 18), t.next);
  assert_equal(new Token('caed', 19, 23), t.next);
  assert_equal(new Token('eddf', 24, 30), t.next);
  assert_equal(new Token('gccccch', 31, 43), t.next);
  assert_equal(new Token('ieeeeeeeeej', 44, 64), t.next);
  assert_equal(new Token('kfl', 65, 69), t.next);
  assert_equal(new Token('mggggn', 70, 80), t.next);
  assert_equal(new Token('ohhp', 81, 87), t.next);
  assert_equal(new Token('qiiiiiiiir', 88, 106), t.next);
  assert_equal(new Token('sjjjjt', 107, 117), t.next);
  assert_equal(new Token('ukkv', 118, 124), t.next);
  assert_equal(new Token('wlllllx', 125, 137), t.next);
  assert_equal(new Token('ynnnnnnz', 138, 152), t.next);
  assert_equal(new Token('aoooooooooob', 153, 175), t.next);
  assert_equal(new Token('coekd', 176, 180), t.next);
  assert_equal(new Token('eqf', 181, 185), t.next);
  assert_equal(new Token('grrrh', 186, 194), t.next);
  assert_equal(new Token('isssssj', 195, 207), t.next);
  assert_equal(new Token('kttttl', 208, 218), t.next);
  assert_equal(new Token('muuuuuuuuuun', 219, 241), t.next);
  assert_equal(new Token('owp', 242, 246), t.next);
  assert_equal(new Token('qyyyr', 247, 255), t.next);
  assert_equal(new Token('szzzt', 256, 264), t.next);
  expect(t.next(), isNull);
}

test_stop_filter() {
  words = ["one", "four", "five", "seven"];
  input = "one, two, three, four, five, six, seven, eight, nine, ten.";
  t = new StopFilter(new AsciiLetterTokenizer(input), words);
  assert_equal(new Token('two', 5, 8, 2), t.next);
  assert_equal(new Token('three', 10, 15, 1), t.next);
  assert_equal(new Token('six', 29, 32, 3), t.next);
  assert_equal(new Token('eight', 41, 46, 2), t.next);
  assert_equal(new Token('nine', 48, 52, 1), t.next);
  assert_equal(new Token('ten', 54, 57, 1), t.next);
  expect(t.next(), isNull);
}

test_stem_filter() {
  input = "Debate Debates DEBATED DEBating Debater";
  t = new StemFilter(
      new AsciiLowerCaseFilter(new AsciiLetterTokenizer(input)), "english");
  assert_equal(new Token("debat", 0, 6), t.next);
  assert_equal(new Token("debat", 7, 14), t.next);
  assert_equal(new Token("debat", 15, 22), t.next);
  assert_equal(new Token("debat", 23, 31), t.next);
  assert_equal(new Token("debat", 32, 39), t.next);
  expect(t.next(), isNull);
  t = new StemFilter(new AsciiLetterTokenizer(input), 'english');
  assert_equal(new Token("Debat", 0, 6), t.next);
  assert_equal(new Token("Debat", 7, 14), t.next);
  assert_equal(new Token("DEBATED", 15, 22), t.next);
  assert_equal(new Token("DEBate", 23, 31), t.next);
  assert_equal(new Token("Debat", 32, 39), t.next);

  if (Ferret.locale && Ferret.locale.downcase.index("utf")) {
    input = "Dêbate dêbates DÊBATED DÊBATing dêbater";
    t = new StemFilter(
        new LowerCaseFilter(new LetterTokenizer(input)), 'english');
    assert_equal(new Token("dêbate", 0, 7), t.next);
    assert_equal(new Token("dêbate", 8, 16), t.next);
    assert_equal(new Token("dêbate", 17, 25), t.next);
    assert_equal(new Token("dêbate", 26, 35), t.next);
    assert_equal(new Token("dêbater", 36, 44), t.next);
    t = new StemFilter(new LetterTokenizer(input), 'english');
    assert_equal(new Token("Dêbate", 0, 7), t.next);
    assert_equal(new Token("dêbate", 8, 16), t.next);
    assert_equal(new Token("DÊBATED", 17, 25), t.next);
    assert_equal(new Token("DÊBATing", 26, 35), t.next);
    assert_equal(new Token("dêbater", 36, 44), t.next);
    expect(t.next(), isNull);
  }

  tz = new AsciiLetterTokenizer(input);
  assert_not_nil(new StemFilter(tz, 'HunGarIaN', 'Utf-8'));
  assert_not_nil(new StemFilter(tz, 'romanIAN', 'iso-8859-2'));
  assert_raises(ArgumentError, () {
    new StemFilter(tz, 'Jibberish', 'UTF-8');
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
  input = "First Field,2nd Field,  P a d d e d  F i e l d  ";
  t = new MyCSVTokenizer(input);
  assert_equal(new Token("FIRST FIELD", 0, 11), t.next);
  assert_equal(new Token("2ND FIELD", 12, 21), t.next);
  assert_equal(new Token("  P A D D E D  F I E L D  ", 22, 48), t.next);
  expect(t.next(), isNull);
  t = new AsciiLowerCaseFilter(new MyCSVTokenizer(input));
  assert_equal(new Token("first field", 0, 11), t.next);
  assert_equal(new Token("2nd field", 12, 21), t.next);
  assert_equal(new Token("  p a d d e d  f i e l d  ", 22, 48), t.next);
  expect(t.next(), isNull);
  t = new MyReverseTokenFilter(
      new AsciiLowerCaseFilter(new MyCSVTokenizer(input)));
  assert_equal(new Token("dleif tsrif", 0, 11), t.next);
  assert_equal(new Token("dleif dn2", 12, 21), t.next);
  assert_equal(new Token("  d l e i f  d e d d a p  ", 22, 48), t.next);
  t.text = "one,TWO,three";
  assert_equal(new Token("eno", 0, 3), t.next);
  assert_equal(new Token("owt", 4, 7), t.next);
  assert_equal(new Token("eerht", 8, 13), t.next);
  t = new AsciiLowerCaseFilter(
      new MyReverseTokenFilter(new MyCSVTokenizer(input)));
  assert_equal(new Token("dleif tsrif", 0, 11), t.next);
  assert_equal(new Token("dleif dn2", 12, 21), t.next);
  assert_equal(new Token("  d l e i f  d e d d a p  ", 22, 48), t.next);
  t.text = "one,TWO,three";
  assert_equal(new Token("eno", 0, 3), t.next);
  assert_equal(new Token("owt", 4, 7), t.next);
  assert_equal(new Token("eerht", 8, 13), t.next);
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
    t = _input.next();

    if (t == null) return null;

    t.text = t.text.capitalize();

    return t;
  }
}

test_custom_filter() {
  input = "This text SHOULD be capitalized ... I hope. :-S";
  t = new CapitalizeFilter(new AsciiLetterTokenizer(input));
  assert_equal(new Token("This", 0, 4), t.next);
  assert_equal(new Token("Text", 5, 9), t.next);
  assert_equal(new Token("Should", 10, 16), t.next);
  assert_equal(new Token("Be", 17, 19), t.next);
  assert_equal(new Token("Capitalized", 20, 31), t.next);
  assert_equal(new Token("I", 36, 37), t.next);
  assert_equal(new Token("Hope", 38, 42), t.next);
  assert_equal(new Token("S", 46, 47), t.next);
  expect(t.next(), isNull);
  t = new StemFilter(new CapitalizeFilter(new AsciiLetterTokenizer(input)));
  assert_equal(new Token("This", 0, 4), t.next);
  assert_equal(new Token("Text", 5, 9), t.next);
  assert_equal(new Token("Should", 10, 16), t.next);
  assert_equal(new Token("Be", 17, 19), t.next);
  assert_equal(new Token("Capit", 20, 31), t.next);
  assert_equal(new Token("I", 36, 37), t.next);
  assert_equal(new Token("Hope", 38, 42), t.next);
  assert_equal(new Token("S", 46, 47), t.next);
  expect(t.next(), isNull);
}
