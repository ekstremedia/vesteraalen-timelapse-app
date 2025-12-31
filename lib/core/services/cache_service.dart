/// In-memory cache service with TTL (Time-To-Live) support.
/// Prevents excessive API calls while maintaining data freshness.
class CacheService {
  final Map<String, _CacheEntry> _cache = {};

  /// Get a cached value by key.
  /// Returns null if the key doesn't exist or has expired.
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T;
  }

  /// Set a value in the cache with a TTL.
  void set<T>(String key, T data, Duration ttl) {
    _cache[key] = _CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  /// Check if a key exists and is not expired.
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Invalidate a specific key.
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Invalidate all keys matching a pattern.
  void invalidatePattern(String pattern) {
    _cache.removeWhere((key, _) => key.contains(pattern));
  }

  /// Clear all cached data.
  void clear() {
    _cache.clear();
  }

  /// Get the number of cached entries.
  int get size => _cache.length;

  /// Remove all expired entries.
  void cleanup() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
