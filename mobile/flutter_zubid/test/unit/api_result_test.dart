import 'package:flutter_test/flutter_test.dart';
import 'package:zubid_mobile/core/network/api_result.dart';

void main() {
  group('ApiResult Success', () {
    test('creates success result with data', () {
      final result = ApiResult<String>.success('test data');

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, equals('test data'));
      expect(result.message, isNull);
    });

    test('success result with null data', () {
      final result = ApiResult<String?>.success(null);

      expect(result.isSuccess, isTrue);
      expect(result.data, isNull);
    });

    test('success result with complex object', () {
      final data = {'id': 1, 'name': 'Test'};
      final result = ApiResult<Map<String, dynamic>>.success(data);

      expect(result.isSuccess, isTrue);
      expect(result.data, equals(data));
      expect(result.data!['id'], equals(1));
    });
  });

  group('ApiResult Failure', () {
    test('creates failure result with message', () {
      final result = ApiResult<String>.failure('Something went wrong');

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.message, equals('Something went wrong'));
      expect(result.data, isNull);
    });

    test('failure result with code', () {
      final result = ApiResult<String>.failure('Not found', code: 'NOT_FOUND');

      expect(result.isFailure, isTrue);
      expect(result.message, equals('Not found'));
      expect(result.code, equals('NOT_FOUND'));
    });

    test('error factory creates failure', () {
      final result = ApiResult<String>.error('Error message');

      expect(result.isFailure, isTrue);
      expect(result.message, equals('Error message'));
    });
  });

  group('ApiResult when method', () {
    test('calls success callback on success', () {
      final result = ApiResult<int>.success(42);

      final output = result.when(
        success: (data) => 'Success: $data',
        error: (error) => 'Error: $error',
      );

      expect(output, equals('Success: 42'));
    });

    test('calls error callback on failure', () {
      final result = ApiResult<int>.failure('Failed');

      final output = result.when(
        success: (data) => 'Success: $data',
        error: (error) => 'Error: $error',
      );

      expect(output, equals('Error: Failed'));
    });
  });

  group('ApiResult map method', () {
    test('transforms success data', () {
      final result = ApiResult<int>.success(10);
      final mapped = result.map((data) => data * 2);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.data, equals(20));
    });

    test('preserves failure on map', () {
      final result = ApiResult<int>.failure('Error');
      final mapped = result.map((data) => data * 2);

      expect(mapped.isFailure, isTrue);
      expect(mapped.message, equals('Error'));
    });
  });

  group('ApiResult getOrElse', () {
    test('returns data on success', () {
      final result = ApiResult<int>.success(42);
      expect(result.getOrElse(() => 0), equals(42));
    });

    test('returns default on failure', () {
      final result = ApiResult<int>.failure('Error');
      expect(result.getOrElse(() => 0), equals(0));
    });
  });

  group('ApiResult getOrDefault', () {
    test('returns data on success', () {
      final result = ApiResult<int>.success(42);
      expect(result.getOrDefault(0), equals(42));
    });

    test('returns default on failure', () {
      final result = ApiResult<int>.failure('Error');
      expect(result.getOrDefault(0), equals(0));
    });
  });

  group('ApiResult getOrThrow', () {
    test('returns data on success', () {
      final result = ApiResult<int>.success(42);
      expect(result.getOrThrow(), equals(42));
    });

    test('throws ApiException on failure', () {
      final result = ApiResult<int>.failure('Error');
      expect(() => result.getOrThrow(), throwsA(isA<ApiException>()));
    });
  });

  group('ApiResult fold', () {
    test('calls onSuccess for success', () {
      final result = ApiResult<int>.success(42);
      final output = result.fold(
        (data) => 'Data: $data',
        (message, code, error) => 'Error: $message',
      );
      expect(output, equals('Data: 42'));
    });

    test('calls onFailure for failure', () {
      final result = ApiResult<int>.failure('Failed', code: 'ERR');
      final output = result.fold(
        (data) => 'Data: $data',
        (message, code, error) => 'Error: $message, Code: $code',
      );
      expect(output, equals('Error: Failed, Code: ERR'));
    });
  });

  group('ApiResult onSuccess/onFailure', () {
    test('onSuccess executes for success', () {
      final result = ApiResult<int>.success(42);
      int? captured;
      result.onSuccess((data) => captured = data);
      expect(captured, equals(42));
    });

    test('onFailure executes for failure', () {
      final result = ApiResult<int>.failure('Error');
      String? captured;
      result.onFailure((message, code, error) => captured = message);
      expect(captured, equals('Error'));
    });
  });
}
