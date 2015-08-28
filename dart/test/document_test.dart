library ferret.test.document;

class DocumentTest {
  //< Test::Unit::TestCase
  test_field() {
    f = new Field();
    assert_equal(0, f.size);
    assert_equal(1.0, f.boost);

    f2 = new Field();
    assert_equal(f, f2);

    f.add("section0");
    assert_equal(1, f.size);
    assert_equal(1.0, f.boost);
    assert_equal("section0", f[0]);
    assert_not_equal(f, f2);

    f.add("section1");
    assert_equal(2, f.size);
    assert_equal(1.0, f.boost);
    assert_equal("section0", f[0]);
    assert_equal("section1", f[1]);
    assert_equal('["section0", "section1"]', f.to_s);
    assert_not_equal(f, f2);
    f2 += f;
    assert_equal(f, f2);

    f.boost = 4.0;
    assert_not_equal(f, f2);
    assert_equal('["section0", "section1"]^4.0', f.to_s);

    f2.boost = 4.0;
    assert_equal(f, f2);

    f3 = new Field(["section0", "section1"], 4.0);
    assert_equal(f, f3);
  }

  test_document() {
    d = new Document();

    d['name'] = new Field();
    d['name'].add("section0");
    d['name'].add("section1");

    assert_equal(1, d.size);
    assert_equal(1.0, d.boost);
    assert_equal('''
Document {
  :name => ["section0", "section1"]
}'''.strip, d.to_s);

    d.boost = 123.0;
    d['name'].add("section2");
    d['name'].boost = 321.0;
    assert_equal(123.0, d.boost);
    assert_equal(321.0, d['name'].boost);
    assert_equal('''
Document {
  :name => ["section0", "section1", "section2"]^321.0
}^123.0'''.strip, d.to_s);

    d['title'] = "Shawshank Redemption";
    d['actors'] = ["Tim Robbins", "Morgan Freeman"];

    assert_equal(3, d.size);
    assert_equal('''
Document {
  :actors => ["Tim Robbins", "Morgan Freeman"]
  :name => ["section0", "section1", "section2"]^321.0
  :title => "Shawshank Redemption"
}^123.0'''.strip, d.to_s);

    d2 = new Document(123.0);
    d2['name'] = new Field(["section0", "section1", "section2"], 321.0);
    d2['title'] = "Shawshank Redemption";
    d2['actors'] = ["Tim Robbins", "Morgan Freeman"];
    assert_equal(d, d2);
  }
}
