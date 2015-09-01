library ferret.test.document;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';

class DocumentTest {
  //< Test::Unit::TestCase
  test_field() {
    var f = new Field();
    expect(0, equals(f.length));
    expect(1.0, equals(f.boost));

    var f2 = new Field();
    expect(f, equals(f2));

    f.add("section0");
    expect(1, equals(f.length));
    expect(1.0, equals(f.boost));
    expect("section0", equals(f[0]));
    expect(f, isNot(equals(f2)));

    f.add("section1");
    expect(2, equals(f.length));
    expect(1.0, equals(f.boost));
    expect("section0", equals(f[0]));
    expect("section1", equals(f[1]));
    expect('["section0", "section1"]', equals(f.to_s));
    expect(f, isNot(equals(f2)));
    f2.add(f);
    expect(f, equals(f2));

    f.boost = 4.0;
    expect(f, isNot(equals(f2)));
    expect('["section0", "section1"]^4.0', equals(f.to_s));

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

    expect(1, equals(d.length));
    expect(1.0, equals(d.boost));
    expect('''
Document {
  :name => ["section0", "section1"]
}'''.trim(), equals(d.to_s));

    d.boost = 123.0;
    d['name'].add("section2");
    d['name'].boost = 321.0;
    expect(123.0, equals(d.boost));
    expect(321.0, equals(d['name'].boost));
    expect('''
Document {
  :name => ["section0", "section1", "section2"]^321.0
}^123.0'''.trim(), equals(d.to_s));

    d['title'] = "Shawshank Redemption";
    d['actors'] = ["Tim Robbins", "Morgan Freeman"];

    expect(3, equals(d.length));
    expect('''
Document {
  :actors => ["Tim Robbins", "Morgan Freeman"]
  :name => ["section0", "section1", "section2"]^321.0
  :title => "Shawshank Redemption"
}^123.0'''.trim(), equals(d.to_s));

    var d2 = new Document(123.0);
    d2['name'] = new Field(["section0", "section1", "section2"], 321.0);
    d2['title'] = "Shawshank Redemption";
    d2['actors'] = ["Tim Robbins", "Morgan Freeman"];
    expect(d, equals(d2));
  }
}
