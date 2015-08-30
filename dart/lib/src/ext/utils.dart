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
  /// Returns a new empty bit vector object.
  BitVector() {
    frb_bv_init;
  }

  /// Set the bit at _i_ to *on* (`true`).
  set(i) => frb_bv_set_on;

  /// Set the bit at _i_ to *off* (`false`).
  unset(i) => frb_bv_set_off;

  /// Set the bit and _i_ to *val* (`true` or `false`).
  void operator []=(i, val) => frb_bv_set;

  /// Get the bit value at _i_.
  get(i) => frb_bv_get;

  /// Alias for [get].
  operator [] => frb_bv_get;

  /// Count the number of bits set in the bit vector. If the bit vector has
  /// been negated using [not] then count the number of unset bits instead.
  int count() => frb_bv_count;

  /// Clears all set bits in the bit vector. Negated bit vectors will still
  /// have all bits set to *off*.
  clear() => frb_bv_clear;

  /// Compares two bit vectors and returns true if both bit vectors have the
  /// same bits set.
  bool eql() => frb_bv_eql;

  /// Alias for [eql].
  bool operator == => frb_bv_eql;

  /// Used to store bit vectors in Hashes. Especially useful if you want to
  /// cache them.
  int hash() => frb_bv_hash;

  /// Perform an inplace boolean _and_ operation.
  void andx(bv2) => frb_bv_and_x;

  /// Perform a boolean _and_ operation.
  BitVector and(bv2) => frb_bv_and;

  /// Alias for [and].
  BitVector operator &() => frb_bv_and;

  /// Perform an inplace boolean _or_ operation.
  void orx() => frb_bv_or_x;

  /// Perform a boolean _or_ operation.
  BitVector or() => frb_bv_or;

  /// Alias for [or].
  BitVector operator |() => frb_bv_or;

  /// Perform an inplace boolean _xor_ operation.
  void xorx() => frb_bv_xor_x;

  /// Perform a boolean _or_ operation.
  BitVector xor(bv2) => frb_bv_xor;

  /// Alias for [xor].
  operator ^() => frb_bv_xor;

  /// Perform an inplace boolean _not_ operation.
  void notx() => frb_bv_not_x;

  /// Perform a boolean _not_ operation.
  BitVector not() => frb_bv_not;

  /// Alias for [not].
  operator ~() => frb_bv_not;

  /// Resets the [BitVector] ready for scanning. You should call this method
  /// before calling [next] or [next_unset]. It isn't necessary for the other
  /// scan methods or for the [each] method.
  reset_scan() => frb_bv_reset_scan;

  /// Returns the next set bit in the bit vector scanning from low order to
  /// high order. You should call [reset_scan] before calling this method if
  /// you want to scan from the beginning. It is automatically reset when you
  /// first create the bit vector.
  num next() => frb_bv_next;

  /// Returns the next unset bit in the bit vector scanning from low order to
  /// high order. This method should only be called on bit vectors which have
  /// been flipped (negated). You should call [reset_scan] before calling this
  /// method if you want to scan from the beginning. It is automatically reset
  /// when you first create the bit vector.
  num next_unset() => frb_bv_next_unset;

  /// Returns the next set bit in the bit vector scanning from low order to
  /// high order and starting at [from]. The scan is inclusive so if [from] is
  /// equal to 10 and `bv[10]` is set it will return the number 10. If the bit
  /// vector has been negated than you should use the [next_unset_from]
  /// method.
  num next_from(from) => frb_bv_next_from;

  /// Returns the next unset bit in the bit vector scanning from low order to
  /// high order and starting at [from]. The scan is inclusive so if [from] is
  /// equal to 10 and `bv[10]` is unset it will return the number 10. If the
  /// bit vector has not been negated than you should use the [next_from]
  /// method.
  next_unset_from(from) => frb_bv_next_unset_from;

  /// Iterate through all the set bits in the bit vector yielding each one in
  /// order.
  each(fn(num bit_num)) => frb_bv_each;

  /// Iterate through all the set bits in the bit vector adding the index of
  /// each set bit to an array. This is useful if you want to perform array
  /// methods on the bit vector.
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
  /// Returns a new multi-mapper object and compiles it for optimization.
  ///
  /// Note that MultiMapper is immutable.
  MultiMapper(mappings) {
    frb_mulmap_init;
  }

  /// Performs all the mappings on the string.
  String map(String s) => frb_mulmap_map;
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
  /// Returns a new empty priority queue object with an optional capacity.
  /// Once the capacity is filled, the lowest valued elements will be
  /// automatically popped off the top of the queue as more elements are
  /// inserted into the queue.
  PriorityQueue({capacity: 32, less_than_proc: (a, b) => a < b}) {
    frb_pq_init;
  }

  /// Returns a shallow clone of the priority queue. That is only the priority
  /// queue is cloned, its contents are not cloned.
  clone() => frb_pq_clone;

  /// Clears all elements from the priority queue. The size will be reset
  /// to 0.
  clear() => frb_pq_clear;

  /// Insert an element into a queue. It will be inserted into the correct
  /// position in the queue according to its priority.
  insert(elem) => frb_pq_insert;

  /// Alias for [insert].
  operator <<() => frb_pq_insert;

  /// Returns the top element in the queue but does not remove it from the
  /// queue.
  top() => frb_pq_top;

  /// Returns the top element in the queue removing it from the queue.
  pop() => frb_pq_pop;

  /// Returns the size of the queue, ie. the number of elements currently
  /// stored in the queue. The _size_ of a [PriorityQueue] can never be
  /// greater than its _capacity_.
  int size() => frb_pq_size;

  /// Returns the capacity of the queue, ie. the number of elements that can
  /// be stored in a [PriorityQueue] before they start to drop off the end.
  /// The _size_ of a [PriorityQueue] can never be greater than its
  /// _capacity_.
  int capacity() => frb_pq_capa;

  /// Sometimes you modify the top element in the priority queue so that its
  /// priority changes. When you do this you need to reorder the queue and you
  /// do this by calling the adjust method.
  void adjust() => frb_pq_adjust;
}
