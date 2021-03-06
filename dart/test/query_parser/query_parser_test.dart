library ferret.test.query_parser;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

queryParserTest(Ferret ferret) {
  test('strings', () {
    var parser = new QueryParser(ferret,
        default_field: "xxx",
        all_fields: ["xxx", "field", "f1", "f2"],
        tokenized_fields: ["xxx", "f1", "f2"]);
    var pairs = [
      ['', ''],
      ['*:word', 'word field:word f1:word f2:word'],
      ['word', 'word'],
      ['field:word', 'field:word'],
      ['"word1 word2 word#"', '"word1 word2 word"'],
      ['"word1 %%% word3"', '"word1 <> word3"~1'],
      ['field:"one two three"', 'field:"one two three"'],
      ['field:"one %%% three"', 'field:"one %%% three"'],
      ['f1:"one %%% three"', 'f1:"one <> three"~1'],
      ['field:"one <> three"', 'field:"one <> three"'],
      ['field:"one <> three <>"', 'field:"one <> three"'],
      ['field:"one <> <> <> three <>"', 'field:"one <> <> <> three"'],
      [
        'field:"one <> 222 <> three|four|five <>"',
        'field:"one <> 222 <> three|four|five"'
      ],
      [
        'field:"on1|tw2 THREE|four|five six|seven"',
        'field:"on1|tw2 THREE|four|five six|seven"'
      ],
      ['field:"testing|trucks"', 'field:"testing|trucks"'],
      ['[aaa bbb]', '[aaa bbb]'],
      ['{aaa bbb]', '{aaa bbb]'],
      ['field:[aaa bbb}', 'field:[aaa bbb}'],
      ['{aaa bbb}', '{aaa bbb}'],
      ['{aaa>', '{aaa>'],
      ['[aaa>', '[aaa>'],
      ['field:<a\ aa}', 'field:<a aa}'],
      ['<aaa]', '<aaa]'],
      ['>aaa', '{aaa>'],
      ['>=aaa', '[aaa>'],
      ['<aaa', '<aaa}'],
      ['[A>', '[a>'],
      ['field:<=aaa', 'field:<aaa]'],
      ['REQ one REQ two', '+one +two'],
      ['REQ one two', '+one two'],
      ['one REQ two', 'one +two'],
      ['+one +two', '+one +two'],
      ['+one two', '+one two'],
      ['one +two', 'one +two'],
      ['-one -two', '-one -two'],
      ['-one two', '-one two'],
      ['one -two', 'one -two'],
      ['!one !two', '-one -two'],
      ['!one two', '-one two'],
      ['one !two', 'one -two'],
      ['NOT one NOT two', '-one -two'],
      ['NOT one two', '-one two'],
      ['one NOT two', 'one -two'],
      ['NOT two', '-two +*'],
      ['one two', 'one two'],
      ['one OR two', 'one two'],
      ['one AND two', '+one +two'],
      ['one two AND three', 'one two +three'],
      ['one two OR three', 'one two three'],
      ['one (two AND three)', 'one (+two +three)'],
      ['one AND (two OR three)', '+one +(two three)'],
      ['field:(one AND (two OR three))', '+field:one +(field:two field:three)'],
      ['one AND (two OR [aaa vvv})', '+one +(two [aaa vvv})'],
      [
        'one AND (f1:two OR f2:three) AND four',
        '+one +(f1:two f2:three) +four'
      ],
      ['one^1.23', 'one^1.23'],
      ['(one AND two)^100.23', '(+one +two)^100.23'],
      ['field:(one AND two)^100.23', '(+field:one +field:two)^100.23'],
      [
        'field:(one AND [aaa bbb]^23.3)^100.23',
        '(+field:one +field:[aaa bbb]^23.3)^100.23'
      ],
      ['(REQ field:"one two three")^23', 'field:"one two three"^23.0'],
      ['asdf~0.2', 'asdf~0.2'],
      ['field:asdf~0.2', 'field:asdf~0.2'],
      ['asdf~0.2^100.0', 'asdf~0.2^100.0'],
      ['field:asdf~0.2^0.1', 'field:asdf~0.2^0.1'],
      ['field:"asdf <> asdf|asdf"~4', 'field:"asdf <> asdf|asdf"~4'],
      ['"one two three four five"~5', '"one two three four five"~5'],
      ['ab?de', 'ab?de'],
      ['ab*de', 'ab*de'],
      ['asdf?*?asd*dsf?asfd*asdf?', 'asdf?*?asd*dsf?asfd*asdf?'],
      ['field:a* AND field:(b*)', '+field:a* +field:b*'],
      ['field:abc~ AND field:(b*)', '+field:abc~ +field:b*'],
      ['asdf?*?asd*dsf?asfd*asdf?^20.0', 'asdf?*?asd*dsf?asfd*asdf?^20.0'],
      ['*:xxx', 'xxx field:xxx f1:xxx f2:xxx'],
      ['f1|f2:xxx', 'f1:xxx f2:xxx'],
      ['*:asd~0.2', 'asd~0.2 field:asd~0.2 f1:asd~0.2 f2:asd~0.2'],
      ['f1|f2:asd~0.2', 'f1:asd~0.2 f2:asd~0.2'],
      ['*:a?d*^20.0', '(a?d* field:a?d* f1:a?d* f2:a?d*)^20.0'],
      ['f1|f2:a?d*^20.0', '(f1:a?d* f2:a?d*)^20.0'],
      [
        '*:"asdf <> xxx|yyy"',
        '"asdf <> xxx|yyy" field:"asdf <> xxx|yyy" f1:"asdf <> xxx|yyy" f2:"asdf <> xxx|yyy"'
      ],
      ['f1|f2:"asdf <> xxx|yyy"', 'f1:"asdf <> xxx|yyy" f2:"asdf <> xxx|yyy"'],
      ['f1|f2:"asdf <> do|yyy"', 'f1:"asdf <> yyy" f2:"asdf <> yyy"'],
      ['f1|f2:"do|cat"', 'f1:cat f2:cat'],
      ['*:[bbb xxx]', '[bbb xxx] field:[bbb xxx] f1:[bbb xxx] f2:[bbb xxx]'],
      ['f1|f2:[bbb xxx]', 'f1:[bbb xxx] f2:[bbb xxx]'],
      [
        '*:(xxx AND bbb)',
        '+(xxx field:xxx f1:xxx f2:xxx) +(bbb field:bbb f1:bbb f2:bbb)'
      ],
      ['f1|f2:(xxx AND bbb)', '+(f1:xxx f2:xxx) +(f1:bbb f2:bbb)'],
      ['asdf?*?asd*dsf?asfd*asdf?^20.0', 'asdf?*?asd*dsf?asfd*asdf?^20.0'],
      ['"onewordphrase"', 'onewordphrase'],
      ["who'd", "who'd"]
    ];

    pairs.forEach((row) {
      var query_str = row[0], expected = row[1];
      expect(parser.parse(query_str).to_s("xxx"), equals(expected),
          reason: 'query: $query_str');
    });
  });

  test('qp_with_standard_analyzer', () {
    var parser = new QueryParser(ferret,
        default_field: "xxx",
        all_fields: ["xxx", "key"],
        analyzer: new StandardAnalyzer(ferret));
    var pairs = [
      ['key:1234', 'key:1234'],
      ['key:(1234 and Dave)', 'key:1234 key:dave'],
      ['key:(1234)', 'key:1234'],
      ['and the but they with', '']
    ];

    pairs.forEach((row) {
      var query_str = row[0], expected = row[1];
      expect(parser.parse(query_str).to_s("xxx"), equals(expected));
    });
  });

  test('qp_changing_fields', () {
    var parser = new QueryParser(ferret,
        default_field: "xxx",
        all_fields: ["xxx", "key"],
        analyzer: new WhiteSpaceAnalyzer(ferret));
    expect(parser.parse("*:word").to_s("xxx"), equals('word key:word'));

    parser.fields = ["xxx", "one", "two", "three"];
    expect(parser.parse("*:word").to_s("xxx"),
        equals('word one:word two:word three:word'));
    expect(parser.parse("three:word four:word").to_s("xxx"),
        equals('three:word four:word'));
  });

  test('qp_allow_any_field', () {
    var parser = new QueryParser(ferret,
        default_field: "xxx",
        all_fields: ["xxx", "key"],
        analyzer: new WhiteSpaceAnalyzer(ferret),
        validate_fields: true);

    expect(parser.parse("key:word song:word").to_s("xxx"), equals('key:word'));
    expect(parser.parse("*:word").to_s("xxx"), equals('word key:word'));

    parser = new QueryParser(ferret,
        default_field: "xxx",
        all_fields: ["xxx", "key"],
        analyzer: new WhiteSpaceAnalyzer(ferret));

    expect(parser.parse("key:word song:word").to_s("xxx"),
        equals('key:word song:word'));
    expect(parser.parse("*:word").to_s("xxx"), equals('word key:word'));
  });

  do_test_query_parse_exception_raised(String str) {
    var parser = new QueryParser(ferret,
        default_field: "xxx",
        all_fields: ["f1", "f2", "f3"],
        handle_parse_errors: false);
    expect(QueryParseException, () => parser.parse(str),
        reason: str + " should have failed");
  }

  test('or_default', () {
    var parser = new QueryParser(ferret,
        default_field: '*',
        all_fields: ['x', 'y'],
        or_default: false,
        analyzer: new StandardAnalyzer(ferret));
    var pairs = [
      ['word', 'x:word y:word'],
      ['word1 word2', '+(x:word1 y:word1) +(x:word2 y:word2)']
    ];

    pairs.forEach((row) {
      var query_str = row[0], expected = row[1];
      expect(parser.parse(query_str).to_s(""), equals(expected));
    });
  });

  test('prefix_query', () {
    var parser = new QueryParser(ferret,
        default_field: "xxx",
        all_fields: ["xxx"],
        analyzer: new StandardAnalyzer(ferret));
    expect(parser.parse("asdg*") is PrefixQuery, isTrue);
    expect(parser.parse("a?dg*") is WildcardQuery, isTrue);
    expect(parser.parse("a*dg*") is WildcardQuery, isTrue);
    expect(parser.parse("adg*c") is WildcardQuery, isTrue);
  });

  test('bad_queries', () {
    var parser =
        new QueryParser(ferret, default_field: "xxx", all_fields: ["f1", "f2"]);

    var pairs = [
      ['::*word', 'word'],
      ['::*&)(*^&*(', ''],
      ['::*&one)(*two(*&"', '"one two"~1'],
      [':', ''],
      ['[, ]', ''],
      ['{, }', ''],
      ['!', ''],
      ['+', ''],
      ['~', ''],
      ['^', ''],
      ['-', ''],
      ['|', ''],
      ['<, >', ''],
      ['=', ''],
      ['<script>', 'script']
    ];

    pairs.forEach((row) {
      var query_str = row[0], expected = row[1];
      do_test_query_parse_exception_raised(query_str);
      expect(parser.parse(query_str).to_s("xxx"), equals(expected));
    });
  });

  test('use_keywords_switch', () {
    var analyzer = new LetterAnalyzer(ferret);
    var parser =
        new QueryParser(ferret, analyzer: analyzer, default_field: "xxx");
    expect(parser.parse("REQ www (xxx AND yyy) OR NOT zzz").to_s("xxx"),
        equals("+www (+xxx +yyy) -zzz"));

    parser = new QueryParser(ferret,
        analyzer: analyzer, default_field: "xxx", use_keywords: false);
    expect(parser.parse("REQ www (xxx AND yyy) OR NOT zzz").to_s("xxx"),
        equals("req www (xxx and yyy) or not zzz"));
  });
}
