
function getInt32Array(ptr, length) {
  var bufView = new Int32Array(Module['buffer'], ptr, length);
  return bufView;
}
Module['getInt32Array'] = getInt32Array;

function getUint8Array(ptr, length) {
  var bufView = new Uint8Array(Module['buffer'], ptr, length);
  return bufView;
}
Module['getUint8Array'] = getUint8Array;
