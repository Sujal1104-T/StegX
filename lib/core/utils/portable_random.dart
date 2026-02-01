
import 'dart:math';

/// A portable 32-bit pseudo-random number generator (Xorshift32).
/// 
/// Dart's [Random] implementation varies across platforms (VM vs JS), 
/// which breaks the deterministic requirement for steganography when 
/// embedding on one platform and extracting on another.
/// 
/// This implementation guarantees the same sequence of numbers for a given seed
/// on ALL platforms.
class PortableRandom implements Random {
  int _state;

  PortableRandom(int seed) : _state = seed == 0 ? 1 : seed; // 0 is not a valid seed for Xorshift

  @override
  int nextInt(int max) {
    return _next() % max;
  }

  @override
  double nextDouble() {
    return _next() / 4294967296.0;
  }
  
  @override
  bool nextBool() {
    return _next() % 2 == 0;
  }

  /// Xorshift32 algorithm
  int _next() {
    int x = _state;
    x ^= x << 13;
    x &= 0xFFFFFFFF; // Ensure 32-bit wrapping
    x ^= x >> 17;
    x &= 0xFFFFFFFF;
    x ^= x << 5;
    x &= 0xFFFFFFFF;
    _state = x;
    return x; // Returns unsigned 32-bit int logic via masking, effectively positive
  }
}
