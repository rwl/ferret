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

import '../proxy.dart';

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
class BitVector extends JsProxy {
  BitVector.handle(int handle) : super() {
    this.handle = handle;
  }

  /// Returns a new empty bit vector object.
  BitVector() : super() {
    handle = module.callMethod('_frt_bv_new');
  }

  /// Set the bit at _i_ to *on* (`true`).
  void set(int i) {
    if (i < 0) {
      throw new ArgumentError.value(i);
    }
    module.callMethod('_frt_bv_set', [handle, i]);
  }

  /// Set the bit at _i_ to *off* (`false`).
  void unset(int i) {
    if (i < 0) {
      throw new ArgumentError.value(i);
    }
    module.callMethod('_frt_bv_unset', [handle, i]);
  }

  /// Set the bit and _i_ to *val* (`true` or `false`).
  void operator []=(int i, bool val) {
    if (i < 0) {
      throw new ArgumentError.value(i);
    }
    if (val) {
      this.set(i);
    } else {
      this.unset(i);
    }
  }

  /// Get the bit value at _i_.
  bool get(int i) => module.callMethod('_frt_bv_get', [handle, i]) != 0;

  /// Alias for [get].
  bool operator [](int i) => this.get(i);

  /// Count the number of bits set in the bit vector. If the bit vector has
  /// been negated using [not] then count the number of unset bits instead.
  int count() => module.callMethod('_frjs_bv_count', [handle]);

  /// Clears all set bits in the bit vector. Negated bit vectors will still
  /// have all bits set to *off*.
  void clear() {
    module.callMethod('_frt_bv_clear', [handle]);
    module.callMethod('_frt_bv_scan_reset', [handle]);
  }

  /// Compares two bit vectors and returns true if both bit vectors have the
  /// same bits set.
  bool eql(BitVector bv2) =>
      module.callMethod('_frt_bv_eq', [handle, bv2.handle]) != 0;

  /// Alias for [eql].
  bool operator ==(BitVector bv2) => eql(bv2);

  /// Used to store bit vectors in Hashes. Especially useful if you want to
  /// cache them.
  int hash() => module.callMethod('_frt_bv_hash', [handle]);

  /// Perform an inplace boolean _and_ operation.
  void andx(BitVector bv2) {
    module.callMethod('_frt_bv_and_x', [handle, bv2]);
  }

  /// Perform a boolean _and_ operation.
  BitVector and(BitVector bv2) {
    int h = module.callMethod('_frt_bv_and', [handle, bv2]);
    return new BitVector._handle(h);
  }

  /// Alias for [and].
  BitVector operator &(BitVector bv2) => this.and(bv2);

  /// Perform an inplace boolean _or_ operation.
  void orx(BitVector bv2) {
    module.callMethod('_frt_bv_or_x', [handle, bv2]);
  }

  /// Perform a boolean _or_ operation.
  BitVector or(BitVector bv2) {
    int h = module.callMethod('_frt_bv_or', [handle, bv2]);
    return new BitVector._handle(h);
  }

  /// Alias for [or].
  BitVector operator |(bv2) => this.or(bv2);

  /// Perform an inplace boolean _xor_ operation.
  void xorx(BitVector bv2) {
    module.callMethod('_frt_bv_xor_x', [handle, bv2]);
  }

  /// Perform a boolean _or_ operation.
  BitVector xor(BitVector bv2) {
    int h = module.callMethod('_frt_bv_xor', [handle, bv2]);
    return new BitVector._handle(h);
  }

  /// Alias for [xor].
  BitVector operator ^(BitVector bv2) => this.xor(bv2);

  /// Perform an inplace boolean _not_ operation.
  void notx() {
    module.callMethod('_frt_bv_not_x', [handle]);
  }

  /// Perform a boolean _not_ operation.
  BitVector not() {
    int h = module.callMethod('_frt_bv_not', [handle]);
    return new BitVector._handle(h);
  }

  /// Alias for [not].
  BitVector operator ~() => this.not();

  /// Resets the [BitVector] ready for scanning. You should call this method
  /// before calling [next] or [next_unset]. It isn't necessary for the other
  /// scan methods or for the [each] method.
  void reset_scan() {
    module.callMethod('_frt_bv_scan_reset', [handle]);
  }

  /// Returns the next set bit in the bit vector scanning from low order to
  /// high order. You should call [reset_scan] before calling this method if
  /// you want to scan from the beginning. It is automatically reset when you
  /// first create the bit vector.
  int next() => module.callMethod('_frt_bv_scan_next', [handle]);

  /// Returns the next unset bit in the bit vector scanning from low order to
  /// high order. This method should only be called on bit vectors which have
  /// been flipped (negated). You should call [reset_scan] before calling this
  /// method if you want to scan from the beginning. It is automatically reset
  /// when you first create the bit vector.
  int next_unset() => module.callMethod('_frt_bv_scan_next_unset', [handle]);

  /// Returns the next set bit in the bit vector scanning from low order to
  /// high order and starting at [from]. The scan is inclusive so if [from] is
  /// equal to 10 and `bv[10]` is set it will return the number 10. If the bit
  /// vector has been negated than you should use the [next_unset_from]
  /// method.
  int next_from(int from) {
    if (from < 0) {
      from = 0;
    }
    return module.callMethod('_frt_bv_scan_next_from', [handle, from]);
  }

  /// Returns the next unset bit in the bit vector scanning from low order to
  /// high order and starting at [from]. The scan is inclusive so if [from] is
  /// equal to 10 and `bv[10]` is unset it will return the number 10. If the
  /// bit vector has not been negated than you should use the [next_from]
  /// method.
  int next_unset_from(int from) {
    if (from < 0) {
      from = 0;
    }
    return module.callMethod('_frt_bv_scan_next_unset_from', [handle, from]);
  }

  /// Iterate through all the set bits in the bit vector yielding each one in
  /// order.
  each(fn(int bit_num)) {
    var bit;
    reset_scan();
    bool extends_as_ones =
        module.callMethod('_frjs_bv_extends_as_ones', [handle]) != 0;
    if (extends_as_ones) {
      while ((bit = next_unset()) >= 0) {
        fn(bit);
      }
    } else {
      while ((bit = next()) >= 0) {
        fn(bit);
      }
    }
  }

  /// Iterate through all the set bits in the bit vector adding the index of
  /// each set bit to an array. This is useful if you want to perform array
  /// methods on the bit vector.
  List<int> to_a() {
    var bit;
    var a = <int>[];
    reset_scan();
    bool extends_as_ones =
        module.callMethod('_frjs_bv_extends_as_ones', [handle]) != 0;
    if (extends_as_ones) {
      while ((bit = next_unset()) >= 0) {
        a.add(bit);
      }
    } else {
      while ((bit = next()) >= 0) {
        a.add(bit);
      }
    }
    return a;
  }
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
class MultiMapper extends JsProxy {
  /// Returns a new multi-mapper object and compiles it for optimization.
  ///
  /// Note that MultiMapper is immutable.
  MultiMapper(Map<List<String>, String> mappings) : super() {
    handle = module.callMethod('_frt_mulmap_new');
    mappings.forEach((from, to) {
      from.forEach((fr) {
        int p_pattern = allocString(fr);
        int p_rep = allocString(to);
        module.callMethod(
            '_frt_mulmap_add_mapping', [handle, p_pattern, p_rep]);
        free(p_pattern);
        free(p_rep);
      });
    });
    module.callMethod('_frt_mulmap_compile', [handle]);
  }

  /// Performs all the mappings on the string.
  String map(String from) {
    int p_from = allocString(from);
    int p_to = module.callMethod('_frt_mulmap_dynamic_map', [handle, p_from]);
    var to = stringify(p_to);
    free(p_to);
    return to;
  }
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
class PriorityQueue extends JsProxy {
  int size = 0;
  int capa;
  int mem_capa = 32;
  List heap = [];
  var proc;

  /// Returns a new empty priority queue object with an optional capacity.
  /// Once the capacity is filled, the lowest valued elements will be
  /// automatically popped off the top of the queue as more elements are
  /// inserted into the queue.
  PriorityQueue({int capacity: 32, Function less_than_proc}) : super() {
    if (less_than_proc == null) {
      less_than_proc = (a, b) => a < b;
    }
    if (capacity < 0) {
      throw new ArgumentError.value(capacity);
    }
    capa = capacity;
    proc = less_than_proc;
  }

  /// Returns a shallow clone of the priority queue. That is only the priority
  /// queue is cloned, its contents are not cloned.
  PriorityQueue clone() => new PriorityQueue()
    ..size = size
    ..capa = capa
    ..mem_capa = mem_capa
    ..heap = new List.from(heap)
    ..proc = proc;

  /// Clears all elements from the priority queue. The size will be reset
  /// to 0.
  void clear() {
    size = 0;
  }

  /// Insert an element into a queue. It will be inserted into the correct
  /// position in the queue according to its priority.
  void insert(elem) {
    if (size < capa) {
      _push(elem);
    } else if (size > 0 && proc(heap[1], elem)) {
      heap[1] = elem;
      _down(pq);
    }
  }

  void _up() {
    int i = size;
    int j = i >> 1;

    var node = heap[i];

    while ((j > 0) && proc(node, heap[j])) {
      heap[i] = heap[j];
      i = j;
      j = j >> 1;
    }
    heap[i] = node;
  }

  void _down() {
    int i = 1;
    int j = 2; /* i << 1; */
    int k = 3; /* j + 1;  */
    var node = heap[i]; /* save top node */

    if ((k <= size) && (proc(heap[k], heap[j]))) {
      j = k;
    }

    while ((j <= size) && proc(heap[j], node)) {
      heap[i] = heap[j]; /* shift up child */
      i = j;
      j = i << 1;
      k = j + 1;
      if ((k <= size) && proc(heap[k], heap[j])) {
        j = k;
      }
    }
    heap[i] = node;
  }

  void _push(elem) {
    size++;
    if (size >= mem_capa) {
      mem_capa <<= 1;
      heap.length = mem_capa;
    }
    heap[size] = elem;
    _up();
  }

  /// Alias for [insert].
  void operator <<(elem) => insert(elem);

  /// Returns the top element in the queue but does not remove it from the
  /// queue.
  top() => (size > 0) ? heap[1] : null;

  /// Returns the top element in the queue removing it from the queue.
  pop() {
    if (size > 0) {
      var result = heap[1]; /* save first value */
      heap[1] = heap[size]; /* move last to first */
      heap[size] = null;
      size--;
      _down(); /* adjust heap */
      return result;
    } else {
      return null;
    }
  }

  /// Returns the size of the queue, ie. the number of elements currently
  /// stored in the queue. The _size_ of a [PriorityQueue] can never be
  /// greater than its _capacity_.
  int length() => size;

  /// Returns the capacity of the queue, ie. the number of elements that can
  /// be stored in a [PriorityQueue] before they start to drop off the end.
  /// The _size_ of a [PriorityQueue] can never be greater than its
  /// _capacity_.
  int capacity() => capa;

  /// Sometimes you modify the top element in the priority queue so that its
  /// priority changes. When you do this you need to reorder the queue and you
  /// do this by calling the adjust method.
  void adjust() => _down();
}
