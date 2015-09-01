library ferret.test.content_generator;

import 'dart:math' show Random, min, sqrt;

import 'words.dart';

class ContentGenerator {
  static final Random _r = new Random();

  static int rand(int max) => _r.nextInt(max);

  static final CHARS =
      'abcdefghijklmnopqrstuvwxyz1234567890`~!@#\$%^&*()_-+={[}]|\\:;"\'<,>.?/';
  static final ALNUM = 'abcdefghijklmnopqrstuvwxyz1234567890';
  static final ALPHA = 'abcdefghijklmnopqrstuvwxyz';
  static final URL_SUFFIXES = "com net org biz info".split(" ");
  static final URL_COUNTRY_CODES = "au jp uk nz tv".split(" ");
  static final TEXT_CACHE = {};
  static final WORD_CACHE = {};
  static final MARKDOWN_EMPHASIS_MARKERS = "* _ ** __ ` ``".split(" ");
  static final MARKDOWN_LIST_MARKERS = "- * + 1.".split(" ");

  static String generate_text(
      {int min_len: 5, int max_len: 10, unique, key, bool chars}) {
    if (min_len < 0 || max_len < min_len) {
      throw new ArgumentError("range must be positive");
    }
    var length = min_len + rand(max_len - min_len);

    var text = '';
    if (chars) {
      String word;
      while ((word = random_word()) != null &&
          text.length + word.length < length) {
        text += (word + ' ');
      }
      text.trim();
      text += generate_word(min_len: length - text.length);
    } else {
      text = new List.generate(length, (x) => random_word()).join(' ');
    }
    var k = unique != null ? unique : key;
    if (k != null) {
      if (!TEXT_CACHE.containsKey(k)) {
        TEXT_CACHE[k] = {};
      }
      Map<String, bool> cache = TEXT_CACHE[k];
      if (cache[text]) {
        return generate_text(
            min_len: min_len,
            max_len: max_len,
            unique: unique,
            key: key,
            chars: chars);
      } else {
        cache[text] = true;
        return text;
      }
    }
    return text;
  }

  static String generate_word(
      {int min_len: 5, int max_len: 10, charset, unique, key}) {
    if (min_len < 0 || max_len < min_len) {
      throw new ArgumentError("range must be positive");
    }
    var length = min_len + rand(max_len - min_len);

    var word = '';
    switch (charset) {
      case 'alpha':
        word = new List.generate(length, (x) => random_alpha()).pack('c*');
        break;
      case 'alnum':
        word = new List.generate(length, (x) => random_alnum()).pack('c*');
        break;
      default:
        word = new List.generate(length, (x) => random_char()).pack('c*');
    }

    var k = unique != null ? unique : key;
    if (k != null) {
      if (!WORD_CACHE.containsKey(k)) {
        WORD_CACHE[k] = {};
      }
      var cache = WORD_CACHE[k];
      if (cache[word]) {
        return generate_word(
            min_len: min_len,
            max_len: max_len,
            charset: charset,
            unique: unique,
            key: key);
      } else {
        cache[word] = true;
      }
    }
    return word;
  }

  static String generate_alpha_word(
      {int min_len: 5, int max_len: 10, unique, key}) {
    return generate_word(
        min_len: min_len,
        max_len: max_len,
        charset: 'alpha',
        unique: unique,
        key: key);
  }

  static String generate_alnum_word(
      {int min_len: 5, int max_len: 10, unique, key}) {
    return generate_word(
        min_len: min_len,
        max_len: max_len,
        charset: 'alnum',
        unique: unique,
        key: key);
  }

  static String generate_email([options = const {}]) {
    var num_name_sections = 1 + rand(2);
    var num_url_sections = 1 + rand(2);
    var name = new List.generate(num_name_sections, (x) => generate_alnum_word)
        .join('.');
    var url = [generate_alnum_word];
    url.addAll(new List.generate(
        num_url_sections, (x) => generate_alpha_word(min_len: 2, max_len: 3)));
    url = url.join('.');
    return name + '@' + url;
  }

  static String generate_url([options = const {}]) {
    var ext = random_from(URL_SUFFIXES);
    if (rand(2) > 0) {
      ext += '.' + random_from(URL_COUNTRY_CODES);
    }
    return "http://www.${generate_alnum_word()}.${ext}/";
  }

  static int _footnote_num;

  static String generate_markdown({int min_len: 100, int max_len: 1000}) {
    _footnote_num = 0;
    if (min_len < 0 || max_len < min_len) {
      throw new ArgumentError("range must be positive");
    }
    var length = min_len + rand(max_len - min_len);

    var text = [];
    while (length > 0) {
      var r = _r.nextDouble();
      if (r > 0.3 && r < 1) {
        var l = gen_num(length, 50);
        var paragraph = _gen_md_para(l);
        if (_r.nextDouble() > 0.95) {
          // make block quote
          paragraph = '> ' + paragraph;
        }
        text.add(paragraph);
        length -= l;
      } else if (r > 0.2 && r <= 0.3) {
        // generate list
        var li = random_from(MARKDOWN_LIST_MARKERS) + ' ';
        var num_elements = gen_num(length ~/ 5, 10);
        for (int i = 0; i < num_elements; i++) {
          if (length == 0) {
            break;
          }
          if (_r.nextDouble() > 0.75) {
            // do paragraph list element
            var xli = li;
            for (var i = 0; i < 2 + rand(3); i++) {
              if (length == 0) {
                break;
              }
              var l = gen_num(length, 10);
              text.add(xli);
              text.add(_gen_md_para(l, no_footnotes: true));
              text.add("\n\n");
              if (i == 0) {
                xli = ' ' * xli.length;
              }
              length -= l;
            }
          } else {
            var l = gen_num(length, 10);
            text.add(li);
            text.add(_gen_md_para(l, no_footnotes: true));
            text.add("\n");
            length -= l;
          }
        }
      } else if (r > 0.1 && r <= 0.2) {
        // header
        var l = gen_num(length, 7);
        var t = _gen_md_para(l, no_footnotes: true);
        if (_r.nextDouble() > 0.8) {
          t += "\n" + random_from("= -".split(" ")) * t.length;
        } else {
          t = ('#' * (1 + rand(6))) + ' ' + t;
        }
        length -= l;
        text.add(t);
      } else {
        text.add('---');
      }
      text.add("\n\n");
    }
    return text.join();
  }

  static String random_word() {
    return random_from(words);
  }

  static String random_char() {
    return random_from(CHARS);
  }

  static String random_alnum() {
    return random_from(ALNUM);
  }

  static String random_alpha() {
    return random_from(ALPHA);
  }

  static String _gen_md_para(int length, {bool no_footnotes: false}) {
    var link_words = rand(1 + length ~/ 10);
    length -= link_words;
    List<String> text = _gen_md_text(length);
    text.add("\n");
    var footnote_cnt = 0;
    while (link_words > 0) {
      if (no_footnotes || _r.nextDouble() > 0.5) {
        if (_r.nextDouble() > 0.6) {
          // inline link
          var l = gen_num(link_words, 5);
          var link =
              "[${_gen_md_text(l)}](${generate_url()} \"${generate_text(min_len: 1 + rand(5))}\")";
          text.insert(rand(text.length - footnote_cnt), link);
          link_words -= l;
        } else {
          // auto link
          text.insert(rand(text.length - footnote_cnt), "<${generate_url()}>");
          link_words -= 1;
        }
      } else {
        // footnote link
        var l = gen_num(link_words, 5);
        var reference = "[${_gen_md_text(l).join(' ')}][${_footnote_num}]";
        text.insert(rand(text.length - footnote_cnt), reference);
        var link =
            "\n[${_footnote_num}]: ${generate_url} \"${generate_text(min_len: 1 + rand(5))}\"";
        text.add(link);
        _footnote_num += 1;
        footnote_cnt += 1;
        link_words -= l;
      }
    }
    if (text.last == "\n") {
      text.removeLast();
    }
    return text.join(' ');
  }

  static List<String> _gen_md_text(length) {
    var text = new List.generate(length, (x) => random_word());
    if (_r.nextDouble() > 0.8) {
      for (var i = 0; i < 1 + rand(sqrt(length).toInt()); i++) {
        var first = rand(text.length);
        var last = first + rand(3);
        if (last >= text.length) {
          last = text.length - 1;
        }
        var words = text.sublist(first, last);
        var em = random_from(MARKDOWN_EMPHASIS_MARKERS);
        if (words.join().indexOf(em.substring(0, 1)) == null) {
          words = "${em}${words.join(' ')}${em}";
        }
        flatten(input) => input.expand((x) => x is Iterable ? flatten(x) : [x]);
        text = flatten(text..insert(first, words));
      }
    }
    return text;
  }

  static int gen_num(int max1, int max2) {
    var minmax = min(max1, max2);
    return minmax == 0 ? 0 : 1 + rand(minmax);
  }

  static String random_from(list) {
    return list[rand(list.length)];
  }
}
