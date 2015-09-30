library ferret.test.document;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

class DocumentTest {
  //< Test::Unit::TestCase
  test_field() {
    var f = new Field();
    expect(f.length, equals(0));
    expect(f.boost, equals(1.0));

    var f2 = new Field();
    expect(f, equals(f2));

    f.add("section0");
    expect(f.length, equals(1));
    expect(f.boost, equals(1.0));
    expect(f[0], equals("section0"));
    expect(f, isNot(equals(f2)));

    f.add("section1");
    expect(f.length, equals(2));
    expect(f.boost, equals(1.0));
    expect(f[0], equals("section0"));
    expect(f[1], equals("section1"));
    expect(f.to_s(), equals('["section0", "section1"]'));
    expect(f, isNot(equals(f2)));
    f2.add(f);
    expect(f, equals(f2));

    f.boost = 4.0;
    expect(f, isNot(equals(f2)));
    expect(f.to_s(), equals('["section0", "section1"]^4.0'));

    f2.boost = 4.0;
    expect(f, equals(f2));

    var f3 = new Field(["section0", "section1"], 4.0);
    expect(f, equals(f3));
  }

  test_document() {
    var d = new Document();

    d['name'] = new Field();
    d['name'].add("section0");
    d['name'].add("section1");

    expect(d.length, equals(1));
    expect(d.boost, equals(1.0));
    expect(d.to_s(), equals('''
Document {
  :name => ["section0", "section1"]
}'''.trim()));

    d.boost = 123.0;
    d['name'].add("section2");
    d['name'].boost = 321.0;
    expect(d.boost, equals(123.0));
    expect(d['name'].boost, equals(321.0));
    expect(d.to_s(), equals('''
Document {
  :name => ["section0", "section1", "section2"]^321.0
}^123.0'''.trim()));

    d['title'] = "Shawshank Redemption";
    d['actors'] = ["Tim Robbins", "Morgan Freeman"];

    expect(d.length, equals(3));
    expect(d.to_s(), equals('''
Document {
  :actors => ["Tim Robbins", "Morgan Freeman"]
  :name => ["section0", "section1", "section2"]^321.0
  :title => "Shawshank Redemption"
}^123.0'''.trim()));

    var d2 = new Document(123.0);
    d2['name'] = new Field(["section0", "section1", "section2"], 321.0);
    d2['title'] = "Shawshank Redemption";
    d2['actors'] = ["Tim Robbins", "Morgan Freeman"];
    expect(d, equals(d2));
  }
}
