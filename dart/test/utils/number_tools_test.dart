library ferret.test.utils.number_tools;

import 'dart:math' show Random;

import 'package:test/test.dart';
import 'package:ferret/ferret.dart';
import 'package:quiver/iterables.dart' show range;

void numberToolsTest() {
  final Random _r = new Random();

  int rand(max) => _r.nextInt(max);

  test('to_i_lex_near_zero', () {
    range(-10, 10).forEach((num) {
      expect(
          num.to_s_lex > (num - 1).to_s_lex,
          "Strings should sort correctly but " +
              "${num.to_s_lex} <= ${(num-1).to_s_lex}");
      expect(num, equals(num.to_s_lex.to_i_lex));
    });
  });

  test('to_i_pad_near_zero', () {
    range(1, 10).forEach((num) {
      expect(
          num.to_s_pad(3) > (num - 1).to_s_pad(3),
          "Strings should sort correctly but " +
              "${num.to_s_pad(3)} <= ${(num-1).to_s_pad(3)}");
      expect(num, equals(num.to_s_pad(3).to_i));
    });
  });

  test('to_i_lex_larger_numbers', () {
    range(100).forEach((_) {
      var num1 = rand(10000000000000000000000000000000000);
      var num2 = rand(10000000000000000000000000000000000);
      if (rand(2) == 0) {
        num1 *= -1;
      }
      if (rand(2) == 0) {
        num2 *= -1;
      }

      expect(num1, equals(num1.to_s_lex.to_i_lex));
      expect(num2, equals(num2.to_s_lex.to_i_lex));
      expect(num1 < num2, equals(num1.to_s_lex < num2.to_s_lex),
          reason: "Strings should sort correctly but " +
              "${num1} < ${num2} == ${num1 < num2} but " +
              "${num1.to_s_lex} < ${num2.to_s_lex} == " +
              "${num1.to_s_lex < num2.to_s_lex}");
    });
  });

  test('to_i_pad', () {
    range(100).forEach((_) {
      var num1 = rand(10000000000000000000000000000000000);
      var num2 = rand(10000000000000000000000000000000000);
      expect(num1, equals(num1.to_s_pad(35).to_i));
      expect(num2, equals(num2.to_s_pad(35).to_i));
      expect(num1 < num2, equals(num1.to_s_pad(35) < num2.to_s_pad(35)),
          reason: "Strings should sort correctly but " +
              "${num1} < ${num2} == ${num1 < num2} but " +
              "${num1.to_s_pad(35)} < ${num2.to_s_pad(35)} == " +
              "${num1.to_s_pad(35) < num2.to_s_pad(35)}");
    });
  });

  test('time_to_s_lex', () {
    var t_num = Time.now.to_i - 365 * 24 * 60 * 60; // prevent range error

    range(10).forEach((_) {
      var t1 = Time.now - rand(t_num);
      var t2 = Time.now - rand(t_num);
      expect(t1.to_s, equals(t1.to_s_lex('second').to_time_lex.to_s));
      expect(t2.to_s, equals(t2.to_s_lex('second').to_time_lex.to_s));
      ['year', 'month', 'day', 'hour', 'minute', 'second', 'millisecond']
          .forEach((prec) {
        var t1_x = t1.to_s_lex(prec).to_time_lex();
        var t2_x = t2.to_s_lex(prec).to_time_lex();
        expect(t1_x < t2_x, equals(t1.to_s_lex(prec) < t2.to_s_lex(prec)),
            reason: "Strings should sort correctly but " +
                "${t1_x} < ${t2_x} == ${t1_x < t2_x} but " +
                "${t1.to_s_lex(prec)} < ${t2.to_s_lex(prec)} == " +
                "${t1.to_s_lex(prec) < t2.to_s_lex(prec)}");
      });
    });
  });

  test('date_to_s_lex', () {
    range(10).forEach((_) {
      var d1 = Date.civil(rand(2200), rand(12) + 1, rand(28) + 1);
      var d2 = Date.civil(rand(2200), rand(12) + 1, rand(28) + 1);
      expect(d1.to_s, equals(d1.to_s_lex('day').to_date_lex.to_s));
      expect(d2.to_s, equals(d2.to_s_lex('day').to_date_lex.to_s));
      ['year', 'month', 'day'].forEach((prec) {
        var d1_x = d1.to_s_lex(prec).to_date_lex();
        var d2_x = d2.to_s_lex(prec).to_date_lex();
        expect(d1_x < d2_x, equals(d1.to_s_lex(prec) < d2.to_s_lex(prec)),
            reason: "Strings should sort correctly but " +
                "${d1_x} < ${d2_x} == ${d1_x < d2_x} but " +
                "${d1.to_s_lex(prec)} < ${d2.to_s_lex(prec)} == " +
                "${d1.to_s_lex(prec) < d2.to_s_lex(prec)}");
      });
    });
  });

  test('date_time_to_s_lex', () {
    range(10).forEach((_) {
      var d1 = "${rand(600) + 1600}-${rand(12)+1}-${rand(28)+1} " +
          "${rand(24)}:${rand(60)}:${rand(60)}";
      var d2 = "${rand(600) + 1600}-${rand(12)+1}-${rand(28)+1} " +
          "${rand(24)}:${rand(60)}:${rand(60)}";
      d1 = DateTime.strptime(d1, "%Y-%m-%d %H:%M:%S");
      d2 = DateTime.strptime(d2, "%Y-%m-%d %H:%M:%S");
      expect(d1.to_s, equals(d1.to_s_lex('second').to_date_time_lex.to_s));
      expect(d2.to_s, equals(d2.to_s_lex('second').to_date_time_lex.to_s));
      ['year', 'month', 'day', 'hour', 'minute', 'second'].forEach((prec) {
        var d1_x = d1.to_s_lex(prec).to_date_lex();
        var d2_x = d2.to_s_lex(prec).to_date_lex();
        expect(d1_x < d2_x, equals(d1.to_s_lex(prec) < d2.to_s_lex(prec)),
            reason: "Strings should sort correctly but " +
                "${d1_x} < ${d2_x} == ${d1_x < d2_x} but " +
                "${d1.to_s_lex(prec)} < ${d2.to_s_lex(prec)} == " +
                "${d1.to_s_lex(prec) < d2.to_s_lex(prec)}");
      });
    });
  });
}
