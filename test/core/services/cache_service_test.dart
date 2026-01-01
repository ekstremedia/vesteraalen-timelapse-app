import 'package:flutter_test/flutter_test.dart';
import 'package:vesteraalen_timelapse/core/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
    });

    test('get returns null for non-existent key', () {
      expect(cacheService.get<String>('non_existent'), isNull);
    });

    test('set and get returns stored value', () {
      cacheService.set('test_key', 'test_value', const Duration(seconds: 60));
      expect(cacheService.get<String>('test_key'), 'test_value');
    });

    test('get returns null for expired cache', () async {
      cacheService.set('expiring_key', 'value', const Duration(seconds: 1));
      await Future.delayed(const Duration(seconds: 2));
      expect(cacheService.get<String>('expiring_key'), isNull);
    });

    test('invalidate deletes cached value', () {
      cacheService.set('key_to_remove', 'value', const Duration(seconds: 60));
      expect(cacheService.get<String>('key_to_remove'), 'value');

      cacheService.invalidate('key_to_remove');
      expect(cacheService.get<String>('key_to_remove'), isNull);
    });

    test('clear removes all cached values', () {
      cacheService.set('key1', 'value1', const Duration(seconds: 60));
      cacheService.set('key2', 'value2', const Duration(seconds: 60));

      cacheService.clear();

      expect(cacheService.get<String>('key1'), isNull);
      expect(cacheService.get<String>('key2'), isNull);
    });

    test('can store different types', () {
      cacheService.set(
        'string_key',
        'string_value',
        const Duration(seconds: 60),
      );
      cacheService.set('int_key', 42, const Duration(seconds: 60));
      cacheService.set('list_key', [1, 2, 3], const Duration(seconds: 60));

      expect(cacheService.get<String>('string_key'), 'string_value');
      expect(cacheService.get<int>('int_key'), 42);
      expect(cacheService.get<List<int>>('list_key'), [1, 2, 3]);
    });

    test('overwriting key updates value', () {
      cacheService.set('key', 'old_value', const Duration(seconds: 60));
      cacheService.set('key', 'new_value', const Duration(seconds: 120));

      expect(cacheService.get<String>('key'), 'new_value');
    });

    test('has returns true for existing non-expired key', () {
      cacheService.set('exists', 'value', const Duration(seconds: 60));
      expect(cacheService.has('exists'), isTrue);
    });

    test('has returns false for non-existent key', () {
      expect(cacheService.has('not_exists'), isFalse);
    });

    test('size returns correct count', () {
      expect(cacheService.size, 0);

      cacheService.set('key1', 'value1', const Duration(seconds: 60));
      expect(cacheService.size, 1);

      cacheService.set('key2', 'value2', const Duration(seconds: 60));
      expect(cacheService.size, 2);
    });

    test('invalidatePattern removes matching keys', () {
      cacheService.set('camera_1', 'value1', const Duration(seconds: 60));
      cacheService.set('camera_2', 'value2', const Duration(seconds: 60));
      cacheService.set('settings', 'value3', const Duration(seconds: 60));

      cacheService.invalidatePattern('camera');

      expect(cacheService.get<String>('camera_1'), isNull);
      expect(cacheService.get<String>('camera_2'), isNull);
      expect(cacheService.get<String>('settings'), 'value3');
    });
  });
}
