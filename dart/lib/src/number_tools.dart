library ferret.number_tools;

import 'dart:math' show pow;

class Float {
  /// Return `true` if [a] is within [precision] of the other value [b]. This
  /// is used to accommodate for floating point errors.
  static bool closeTo(double a, double b, [double precision = 0.0000000001]) {
    return (1 - a / b).abs() < precision;
  }
}

/// Provides support for converting integers to [String]s, and back again. The
/// strings are structured so that lexicographic sorting order is preserved.
///
/// That is, if integer1 is less than integer2 for any two integers integer1
/// and integer2, then integer1.to_s_lex is lexicographically less than
/// integer2.to_s_lex. (Similarly for "greater than" and "equals".)
///
/// This class handles numbers between - 10 ** 10,000 and 10 ** 10,000
/// which should cover all practical numbers. If you need bigger numbers,
/// increase [Integer.LEN_STR_SIZE].
class Integer {
  /// LEN_SIZE of 4 should handle most numbers that can practically be held in
  /// memory.
  static int LEN_STR_SIZE = 4;
  static final int NEG_LEN_MASK = pow(10, LEN_STR_SIZE);
  static String LEN_STR_TEMPLATE; // = "%0#{LEN_STR_SIZE}d"

  /// Convert the number to a lexicographically sortable string. This string
  /// will use printable characters only but will not be human readable.
  static String to_s_lex(int a) {
    if (a >= 0) {
      var num_str = a.toString();
      var len_str; // = LEN_STR_TEMPLATE % num_str.size
      return len_str + num_str;
    } else {
      var _num = -a;
      var num_str = _num.toString();
      var num_len = num_str.length;
      var len_str; // = LEN_STR_TEMPLATE % (NEG_LEN_MASK - num_len)
      _num; // = (10 ** num_str.size) - _num
      //return "-#{len_str}%0#{num_len}d" % num
    }
  }

  /// Convert the number to a lexicographically sortable string by padding
  /// with `0`s. You should make sure that you set the width to a number large
  /// enough to accommodate all possible values. Also note that this method
  /// will not work with negative numbers. That is negative numbers will sort
  /// in the opposite direction as positive numbers. If you have very large
  /// numbers or a mix of positive and negative numbers you should use the
  /// [Integer.to_s_lex] method.
  ///
  /// [width] is the number of characters in the string returned. So
  /// `123.to_s_pad(5) => 00123 and -123.to_s_pad(5) => -0123`
  String to_s_pad([int width = 10]) {
    //"%#{width}d" % self
  }
}

class Date {
  /// Convert the Date to a lexicographically sortable string with the
  /// required [precision]. The format used is `%Y%m%d`
  ///
  /// [precision] is the precision required in the string version of the date.
  /// The options are `year`, `month` and `day`.
  static String to_s_lex(DateTime d, [precision = 'day']) {
    //self.strftime(Time.LEX_FORMAT[precision]);
  }
}

class DateTime {
  /// Convert the DateTime to a lexicographically sortable string with the
  /// required [precision]. The format used is `%Y%m%d %H:%M:%S`.
  ///
  /// [precision] is the precision required in the string version of the date.
  /// The options are `year`, `month`, `day`, `hour`, `minute` and `second`
  static String to_s_lex(DateTime d, [precision = 'day']) {
    //self.strftime(Time.LEX_FORMAT[precision])
  }
}

class Time {
  static Map LEX_FORMAT = {
    'year': "%Y",
    'month': "%Y-%m",
    'day': "%Y-%m-%d",
    'hour': "%Y-%m-%d %H",
    'minute': "%Y-%m-%d %H:%M",
    'second': "%Y-%m-%d %H:%M:%S",
    'millisecond': "%Y-%m-%d %H:%M:%S"
  };

  /// Convert the Time to a lexicographically sortable string with the
  /// required [precision]. The format used is `%Y%m%d %H:%M:%S`.
  ///
  /// [precision] is the precision required in the string version of the time.
  /// The options are `year`, `month`, `day`, `hour`, `minute` and `second`
  static String to_s_lex(DateTime d, [precision = 'day']) {
    //self.strftime(LEX_FORMAT[precision])
  }
}

class String {
  /// Convert a string to an integer. This method will only work on strings
  /// that were previously created with [Integer.to_s_lex], otherwise the
  /// result will be unpredictable.
  static int to_i_lex(String s) {
    /*if (self[0] == ?-) {
      return self[(Integer::LEN_STR_SIZE + 1)..-1].to_i -
        10 ** (self.size - Integer::LEN_STR_SIZE - 1)
    } else {
      return self[Integer::LEN_STR_SIZE..-1].to_i
    }*/
  }

  /// Convert a string to a Time. This method will only work on strings that
  /// match the format %Y%m%d %H%M%S, otherwise the result will be
  /// unpredictable.
  static DateTime to_time_lex(String s) {
    var vals = [];
    //self.gsub(/(?:^|[- :])(\d+)/) {vals << $1.to_i; $&}
    //Time.mktime(*vals)
  }

  /// Convert a string to a Date. This method will only work on strings that
  /// match the format %Y%m%d %H%M%S, otherwise the result will be
  /// unpredictable.
  static DateTime to_date_lex(String s) {
    return Date.strptime(s + "-02-01", "%Y-%m-%d");
  }

  /// Convert a string to a DateTime. This method will only work on strings
  /// that match the format %Y%m%d %H%M%S, otherwise the result will be
  /// unpredictable.
  static DateTime to_date_time_lex(String s) {
    return DateTime.strptime(s + "-01-01", "%Y-%m-%d %H:%M:%S");
  }

  static _get_lex_format(len) {
    switch (len) {
      case 0:
      case 1:
      case 2:
      case 3:
        return "";
      case 4:
      case 5:
        return "%Y";
      case 6:
      case 7:
        return "%Y%m";
      case 8:
      case 9:
        return "%Y%m%d";
      case 10:
      case 11:
        return "%Y%m%d%H";
      case 12:
      case 13:
        return "%Y%m%d%H%M";
      default:
        return "%Y%m%d%H%M%S";
    }
  }
}
