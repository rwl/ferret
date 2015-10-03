library ferret.test.index.document;

import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

class IndexTestHelper {
  static make_binary(size) {
    var tmp = new List(size);
    size.times((i) => tmp[i] = i % 256);
    return tmp.pack("c*");
  }

  static final BINARY_DATA = IndexTestHelper.make_binary(256);
  static final COMPRESSED_BINARY_DATA = IndexTestHelper.make_binary(56);

  static prepare_document(Ferret ferret, dir) {
    var fis = new FieldInfos(ferret);
    fis.add_field('text_field1', term_vector: TermVectorStorage.NO);
    fis.add_field('text_field2');
    fis.add_field('key_field', index: FieldIndexing.UNTOKENIZED);
    fis.add_field('unindexed_field', index: FieldIndexing.NO);
    fis.add_field('unstored_field1',
        store: FieldStorage.NO, term_vector: TermVectorStorage.NO);
    fis.add_field('unstored_field2',
        store: FieldStorage.NO, term_vector: TermVectorStorage.YES);
    fis.add_field('compressed_field',
        store: FieldStorage.COMPRESS, term_vector: TermVectorStorage.YES);
    fis.add_field('binary_field',
        index: FieldIndexing.NO, term_vector: TermVectorStorage.NO);
    fis.add_field('compressed_binary_field',
        store: FieldStorage.COMPRESS,
        index: FieldIndexing.NO,
        term_vector: TermVectorStorage.NO);
    var doc = {
      'text_field1': "field one text",
      'text_field2': "field field field two text",
      'key_field': "keyword",
      'unindexed_field': "unindexed field text",
      'unstored_field1': "unstored field text one",
      'unstored_field2': "unstored field text two",
      'compressed_field': "compressed text",
      'binary_field': BINARY_DATA,
      'compressed_binary_field': COMPRESSED_BINARY_DATA
    };
    return doc; //, fis;
  }

  static prepare_documents() {
    return [
      ["apple", "green"],
      ["apple", "red"],
      ["orange", "orange"],
      ["grape", "green"],
      ["grape", "purple"],
      ["mandarin", "orange"],
      ["peach", "orange"],
      ["apricot", "orange"]
    ].map((food) => {"name": food[0], "colour": food[1]});
  }

  static prepare_book_list() {
    return [
      {
        "author": "P.H. Newby",
        "title": "Something To Answer For",
        "year": "1969"
      },
      {
        "author": "Bernice Rubens",
        "title": "The Elected Member",
        "year": "1970"
      },
      {"author": "V. S. Naipaul", "title": "In a Free State", "year": "1971"},
      {"author": "John Berger", "title": "G", "year": "1972"},
      {
        "author": "J. G. Farrell",
        "title": "The Siege of Krishnapur",
        "year": "1973"
      },
      {"author": "Stanley Middleton", "title": "Holiday", "year": "1974"},
      {
        "author": "Nadine Gordimer",
        "title": "The Conservationist",
        "year": "1974"
      },
      {
        "author": "Ruth Prawer Jhabvala",
        "title": "Heat and Dust",
        "year": "1975"
      },
      {"author": "David Storey", "title": "Saville", "year": "1976"},
      {"author": "Paul Scott", "title": "Staying On", "year": "1977"},
      {"author": "Iris Murdoch", "title": "The Sea", "year": "1978"},
      {"author": "Penelope Fitzgerald", "title": "Offshore", "year": "1979"},
      {
        "author": "William Golding",
        "title": "Rites of Passage",
        "year": "1980"
      },
      {
        "author": "Salman Rushdie",
        "title": "Midnight's Children",
        "year": "1981"
      },
      {"author": "Thomas Keneally", "title": "Schindler's Ark", "year": "1982"},
      {
        "author": "J. M. Coetzee",
        "title": "Life and Times of Michael K",
        "year": "1983"
      },
      {"author": "Anita Brookner", "title": "Hotel du Lac", "year": "1984"},
      {"author": "Keri Hulme", "title": "The Bone People", "year": "1985"},
      {"author": "Kingsley Amis", "title": "The Old Devils", "year": "1986"},
      {"author": "Penelope Lively", "title": "Moon Tiger", "year": "1987"},
      {"author": "Peter Carey", "title": "Oscar and Lucinda", "year": "1988"},
      {
        "author": "Kazuo Ishiguro",
        "title": "The Remains of the Day",
        "year": "1989"
      },
      {"author": "A. S. Byatt", "title": "Possession", "year": "1990"},
      {"author": "Ben Okri", "title": "The Famished Road", "year": "1991"},
      {
        "author": "Michael Ondaatje",
        "title": "The English Patient",
        "year": "1992"
      },
      {"author": "Barry Unsworth", "title": "Sacred Hunger", "year": "1992"},
      {
        "author": "Roddy Doyle",
        "title": "Paddy Clarke Ha Ha Ha",
        "year": "1993"
      },
      {
        "author": "James Kelman",
        "title": "How Late It Was, How Late",
        "year": "1994"
      },
      {"author": "Pat Barker", "title": "The Ghost Road", "year": "1995"},
      {"author": "Graham Swift", "title": "Last Orders", "year": "1996"},
      {
        "author": "Arundati Roy",
        "title": "The God of Small Things",
        "year": "1997"
      },
      {"author": "Ian McEwan", "title": "Amsterdam", "year": "1998"},
      {"author": "J. M. Coetzee", "title": "Disgrace", "year": "1999"},
      {
        "author": "Margaret Atwood",
        "title": "The Blind Assassin",
        "year": "2000"
      },
      {
        "author": "Peter Carey",
        "title": "True History of the Kelly Gang",
        "year": "2001"
      },
      {"author": "Yann Martel", "title": "The Life of Pi", "year": "2002"},
      {"author": "DBC Pierre", "title": "Vernon God Little", "year": "2003"}
    ];
  }

  static prepare_ir_test_fis(Ferret ferret) {
    var fis = new FieldInfos(ferret);
    fis.add_field('body');
    fis.add_field('changing_field', term_vector: TermVectorStorage.NO);
    fis.add_field('title',
        index: FieldIndexing.UNTOKENIZED,
        term_vector: TermVectorStorage.WITH_OFFSETS);
    fis.add_field('author', term_vector: TermVectorStorage.WITH_POSITIONS);
    fis.add_field('year',
        index: FieldIndexing.NO, term_vector: TermVectorStorage.NO);
    fis.add_field('text',
        store: FieldStorage.NO, term_vector: TermVectorStorage.NO);
  }

  static const INDEX_TEST_DOC_COUNT = 64;

  static prepare_ir_test_docs() {
    var docs = new List(22);
    docs[0] = {
      'body': "Where is Wally",
      'changing_field':
          "word3 word4 word1 word2 word1 word3 word4 word1 " + "word3 word3",
    };
    docs[1] = {'body': "Some Random Sentence read"};
    docs[2] = {'body': "Some read Random Sentence read"};
    docs[3] = {
      'title': "War And Peace",
      'body': "word3 word4 word1 word2 word1 word3 word4 word1 word3 word3",
      'author': "Leo Tolstoy",
      'year': "1865",
      'text': "more text which is not stored"
    };
    docs[4] = {'body': "Some Random Sentence"};
    docs[5] = {'body': "Here's Wally"};
    docs[6] = {'body': "Some Random Sentence read read read read"};
    docs[7] = {'body': "Some Random Sentence"};
    docs[8] = {'body': "Some Random Sentence"};
    docs[9] = {
      'body': "read Some Random Sentence read this will be used after " +
          "unfinished next position read"
    };
    docs[10] = {
      'body': "Some read Random Sentence",
      'changing_field':
          "word3 word4 word1 word2 word1 word3 word4 word1 " + "word3 word3"
    };
    docs[11] = {'body': "And here too. Well, maybe Not"};
    docs[12] = {'body': "Some Random Sentence"};
    docs[13] = {'body': "Some Random Sentence"};
    docs[14] = {'body': "Some Random Sentence"};
    docs[15] = {'body': "Some Random Sentence"};
    docs[16] = {'body': "Some Random read read Sentence"};
    docs[17] = {
      'body': "Some Random read Sentence",
      'changing_field':
          "word3 word4 word1 word2 word1 word3 word4 word1 " + "word3 word3"
    };
    docs[18] = {'body': "Wally Wally Wally"};
    docs[19] = {
      'body': "Some Random Sentence",
      'changing_field':
          "word3 word4 word1 word2 word1 word3 word4 word1 " + "word3 word3"
    };
    docs[20] = {
      'body': "Wally is where Wally usually likes to go. Wally Mart! Wally " +
          "likes shopping there for Where's Wally books. Wally likes " +
          "to read",
      'changing_field':
          "word3 word4 word1 word2 word1 word3 word4 word1 " + "word3 word3"
    };
    docs[21] = {
      'body': "Some Random Sentence read read read and more read read read",
      'changing_field':
          "word3 word4 word1 word2 word1 word3 word4 word1 " + "word3 word3"
    };

    var buf = new StringBuffer();
    range(21).forEach((_) => buf.write("skip "));
    range(22, INDEX_TEST_DOC_COUNT - 1).forEach((i) {
      buf.write("skip ");
      docs[i] = {'text': buf.toString()};
    });
    return docs;
  }

  static final INDEX_TEST_DOCS = prepare_ir_test_docs();
  static final INDEX_TEST_FIS = prepare_ir_test_fis();

  static prepare_search_docs() {
    var i = 1;
    [
      ["20050930", "cat1/", 0.123, "word1"],
      ["20051001", "cat1/sub1", 0.954, "word1 word2 the quick brown fox"],
      ["20051002", "cat1/sub1/subsub1", 908.125, "word1 word3"],
      ["20051003", "cat1/sub2", 3999, "word1 word3"],
      ["20051004", "cat1/sub2/subsub2", "+.3412", "word1 word2"],
      ["20051005", "cat2/sub1", -1.298, "word1"],
      ["20051006", "cat2/sub1", "2", "word1 word3"],
      ["20051007", "cat2/sub1", "+8.894", "word1"],
      [
        "20051008",
        "cat2/sub1",
        "+21235.2135",
        "word1 word2 word3 the fast brown fox"
      ],
      ["20051009", "cat3/sub1", "10.0", "word1"],
      ["20051010", "cat3/sub1", 1, "word1"],
      ["20051011", "cat3/sub1", -12518419, "word1 word3 the quick red fox"],
      ["20051012", "cat3/sub1", "10", "word1"],
      ["20051013", "cat1/sub2", "15682954", "word1"],
      ["20051014", "cat1/sub1", "91239", "word1 word3 the quick hairy fox"],
      ["20051015", "cat1/sub2/subsub1", "-.89321", "word1"],
      [
        "20051016",
        "cat1/sub1/subsub2",
        -89,
        "word1 the quick fox is brown and hairy and a little red"
      ],
      ["20051017", "cat1/", "-1.0", "word1 the brown fox is quick and red"]
    ].map((row) {
      var doc = new Document(i);
      i += 1;
      doc['date'] = row[0];
      doc['category'] = row[1];
      doc['field'] = row[2];
      doc['number'] = row[3];
      return doc;
    });
  }

  static final SEARCH_TEST_DOCS = prepare_search_docs();
}
