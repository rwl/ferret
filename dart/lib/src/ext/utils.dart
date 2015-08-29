/// The Utils module contains a number of helper classes and modules that are
/// useful when indexing with Ferret. They are:
///
/// * [BitVector]
/// * [MultiMapper]
/// * [PriorityQueue]
///
/// These helper classes could also be quite useful outside of Ferret and may
/// one day find themselves in their own separate library.
library ferret.ext.utils;

/// A [BitVector] is pretty easy to implement in Dart using Dart's BigNum class.
/// This [BitVector] however allows you to count the set bits with the
/// [count] method (or unset bits of flipped bit vectors) and also
/// to quickly scan the set bits.
///
/// [BitVector] handles four boolean operations:
///
/// * [&]
/// * [|]
/// * [^]
/// * [~]
///
///     var bv1 = new BitVector();
///     var bv2 = new BitVector();
///     var bv3 = new BitVector();
///
///     var bv4 = (bv1 & bv2) | ~bv3;
///
/// You can also do the operations in-place:
///
/// * [and]
/// * [or]
/// * [xor]
/// * [not]
///
///     bv4.and(bv5).not()
///
/// Perhaps the most useful functionality in [BitVector] is the ability to
/// quickly scan for set bits. To print all set bits:
///
///     bv.each((bit) => print(bit));
///
/// Alternatively you could use the lower level [next] or [next_unset]
/// methods. Note that the [each] method will automatically scan unset bits
/// if the [BitVector] has been flipped (using [not]).
class BitVector {
  BitVector() {
    frb_bv_init;
  }

  set() => frb_bv_set_on;
  unset() => frb_bv_set_off;
  operator []=() => frb_bv_set;
  get() => frb_bv_get;
  operator [] => frb_bv_get;
  count() => frb_bv_count;
  clear() => frb_bv_clear;
  bool eql() => frb_bv_eql;
  operator ==() => frb_bv_eql;
  hash() => frb_bv_hash;
  andx() => frb_bv_and_x;
  and() => frb_bv_and;
  operator &() => frb_bv_and;
  orx() => frb_bv_or_x;
  or() => frb_bv_or;
  operator |() => frb_bv_or;
  xorx() => frb_bv_xor_x;
  xor() => frb_bv_xor;
  operator ^() => frb_bv_xor;
  notx() => frb_bv_not_x;
  not() => frb_bv_not;
  operator ~() => frb_bv_not;
  reset_scan() => frb_bv_reset_scan;
  next() => frb_bv_next;
  next_unset() => frb_bv_next_unset;
  next_from() => frb_bv_next_from;
  next_unset_from() => frb_bv_next_unset_from;
  each() => frb_bv_each;
  to_a() => frb_bv_to_a;
}

/// A [MultiMapper] performs a list of mappings from one string to another.
/// You could of course just use gsub to do this but when you are just mapping
/// strings, this is much faster.
///
/// Note that [MultiMapper] is immutable.
///
///     mapping = {
///       ['à','á','â','ã','ä','å','ā','ă']         => 'a',
///       'æ'                                       => 'ae',
///       ['ď','đ']                                 => 'd',
///       ['ç','ć','č','ĉ','ċ']                     => 'c',
///       ['è','é','ê','ë','ē','ę','ě','ĕ','ė',]    => 'e',
///       ['ƒ']                                     => 'f',
///       ['ĝ','ğ','ġ','ģ']                         => 'g',
///       ['ĥ','ħ']                                 => 'h',
///       ['ì','ì','í','î','ï','ī','ĩ','ĭ']         => 'i',
///       ['į','ı','ĳ','ĵ']                         => 'j',
///       ['ķ','ĸ']                                 => 'k',
///       ['ł','ľ','ĺ','ļ','ŀ']                     => 'l',
///       ['ñ','ń','ň','ņ','ŉ','ŋ']                 => 'n',
///       ['ò','ó','ô','õ','ö','ø','ō','ő','ŏ','ŏ'] => 'o',
///       ['œ']                                     => 'oek',
///       ['ą']                                     => 'q',
///       ['ŕ','ř','ŗ']                             => 'r',
///       ['ś','š','ş','ŝ','ș']                     => 's',
///       ['ť','ţ','ŧ','ț']                         => 't',
///       ['ù','ú','û','ü','ū','ů','ű','ŭ','ũ','ų'] => 'u',
///       ['ŵ']                                     => 'w',
///       ['ý','ÿ','ŷ']                             => 'y',
///       ['ž','ż','ź']                             => 'z'
///     var mapper = new MultiMapper(mapping);
///     var mapped_string = mapper.map(string);
class MultiMapper {
  MultiMapper() {
    frb_mulmap_init;
  }

  map() => frb_mulmap_map;
}

/// A [PriorityQueue] is a very useful data structure and one that needs a fast
/// implementation. Hence this priority queue is implemented in C. It is
/// pretty easy to use; basically you just insert elements into the queue and
/// pop them off.
///
/// The elements are sorted with the lowest valued elements on the top of
/// the heap, ie the first to be popped off. Elements are ordered using the
/// less_than '<' method. To change the order of the queue you can either
/// reimplement the '<' method pass a block when you initialize the queue.
///
/// You can also set the capacity of the [PriorityQueue]. Once you hit the
/// capacity, the lowest values elements are automatically popped of the top
/// of the queue as more elements are added.
///
/// Here is a toy example that sorts strings by their length and has a capacity
/// of 5:
///
///      var q = new PriorityQueue(5, (a, b) => a.size < b.size);
///      q.add("x");
///      q.add("xxxxx");
///      q.add("xxx");
///      q.add("xxxx");
///      q.add("xxxxxx");
///      q.add("xx"); // hit capacity so "x" will be popped off the top
///
///      print(q.size);     //=> 5
///      var word = q.pop();//=> "xx"
///      q.top.add("yyyy"); // "xxxyyyy" will still be at the top of the queue
///      q.adjust();        // move "xxxyyyy" to its correct location in queue
///      word = q.pop();    //=> "xxxx"
///      word = q.pop();    //=> "xxxxx"
///      word = q.pop();    //=> "xxxxxx"
///      word = q.pop();    //=> "xxxyyyy"
///      word = q.pop();    //=> null
class PriorityQueue {
  PriorityQueue() {
    frb_pq_init;
  }

  clone() => frb_pq_clone;
  clear() => frb_pq_clear;
  insert() => frb_pq_insert;
  operator <<() => frb_pq_insert;
  top() => frb_pq_top;
  pop() => frb_pq_pop;
  size() => frb_pq_size;
  capacity() => frb_pq_capa;
  adjust() => frb_pq_adjust;
}
