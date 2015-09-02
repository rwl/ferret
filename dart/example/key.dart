import 'package:ferret/ferret.dart';

main() {
  var index = new Index(key: 'id');

  [
    {'id': '1', 'text': 'one'},
    {'id': '2', 'text': 'Two'},
    {'id': '3', 'text': 'Three'},
    {'id': '1', 'text': 'One'}
  ].forEach((doc) => index.add_document(doc));

  print(index.size); // => 3
  print(index['1'].load()); // => {'text': "One", 'id': "1"}
  print(index.search('id:1').to_s('text'));
  // => TopDocs: total_hits = 1, max_score = 1.287682 [
  //            3 "One": 1.287682
  //    ]
}
