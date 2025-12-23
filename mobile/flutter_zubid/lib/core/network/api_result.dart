/// Generic API result wrapper for handling success and failure states
sealed class ApiResult<T> {
  const ApiResult();

  /// Create a successful result
  const factory ApiResult.success(T data) = ApiSuccess<T>;

  /// Create a failure result
  const factory ApiResult.failure(String message, {String? code, dynamic error}) = ApiFailure<T>;

  /// Check if the result is successful
  bool get isSuccess => this is ApiSuccess<T>;

  /// Check if the result is a failure
  bool get isFailure => this is ApiFailure<T>;

  /// Get the data if successful, null otherwise
  T? get data => switch (this) {
    ApiSuccess<T>(data: final data) => data,
    ApiFailure<T>() => null,
  };

  /// Get the error message if failed, null otherwise
  String? get message => switch (this) {
    ApiSuccess<T>() => null,
    ApiFailure<T>(message: final message) => message,
  };

  /// Get the error code if failed, null otherwise
  String? get code => switch (this) {
    ApiSuccess<T>() => null,
    ApiFailure<T>(code: final code) => code,
  };

  /// Get the raw error if failed, null otherwise
  dynamic get error => switch (this) {
    ApiSuccess<T>() => null,
    ApiFailure<T>(error: final error) => error,
  };

  /// Transform the data if successful
  ApiResult<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      ApiSuccess<T>(data: final data) => ApiResult.success(transform(data)),
      ApiFailure<T>(message: final message, code: final code, error: final error) => 
        ApiResult.failure(message, code: code, error: error),
    };
  }

  /// Transform the data if successful, or return the failure
  ApiResult<R> flatMap<R>(ApiResult<R> Function(T data) transform) {
    return switch (this) {
      ApiSuccess<T>(data: final data) => transform(data),
      ApiFailure<T>(message: final message, code: final code, error: final error) => 
        ApiResult.failure(message, code: code, error: error),
    };
  }

  /// Execute a function if successful
  ApiResult<T> onSuccess(void Function(T data) action) {
    if (this is ApiSuccess<T>) {
      action((this as ApiSuccess<T>).data);
    }
    return this;
  }

  /// Execute a function if failed
  ApiResult<T> onFailure(void Function(String message, String? code, dynamic error) action) {
    if (this is ApiFailure<T>) {
      final failure = this as ApiFailure<T>;
      action(failure.message, failure.code, failure.error);
    }
    return this;
  }

  /// Get the data or throw an exception
  T getOrThrow() {
    return switch (this) {
      ApiSuccess<T>(data: final data) => data,
      ApiFailure<T>(message: final message, error: final error) => 
        throw ApiException(message, error: error),
    };
  }

  /// Get the data or return a default value
  T getOrDefault(T defaultValue) {
    return switch (this) {
      ApiSuccess<T>(data: final data) => data,
      ApiFailure<T>() => defaultValue,
    };
  }

  /// Get the data or compute a default value
  T getOrElse(T Function() defaultValue) {
    return switch (this) {
      ApiSuccess<T>(data: final data) => data,
      ApiFailure<T>() => defaultValue(),
    };
  }

  /// Fold the result into a single value
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(String message, String? code, dynamic error) onFailure,
  ) {
    return switch (this) {
      ApiSuccess<T>(data: final data) => onSuccess(data),
      ApiFailure<T>(message: final message, code: final code, error: final error) => 
        onFailure(message, code, error),
    };
  }

  @override
  String toString() {
    return switch (this) {
      ApiSuccess<T>(data: final data) => 'ApiResult.success($data)',
      ApiFailure<T>(message: final message, code: final code) => 
        'ApiResult.failure($message${code != null ? ', code: $code' : ''})',
    };
  }
}

/// Successful API result
final class ApiSuccess<T> extends ApiResult<T> {
  final T data;

  const ApiSuccess(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiSuccess<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// Failed API result
final class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final String? code;
  final dynamic error;

  const ApiFailure(this.message, {this.code, this.error});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiFailure<T> && 
           other.message == message && 
           other.code == code &&
           other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, code, error);
}

/// Exception thrown when calling getOrThrow() on a failed result
class ApiException implements Exception {
  final String message;
  final dynamic error;

  const ApiException(this.message, {this.error});

  @override
  String toString() {
    return 'ApiException: $message${error != null ? ' (Error: $error)' : ''}';
  }
}

/// Extension methods for Future<ApiResult<T>>
extension ApiResultFuture<T> on Future<ApiResult<T>> {
  /// Transform the future result
  Future<ApiResult<R>> mapAsync<R>(R Function(T data) transform) async {
    final result = await this;
    return result.map(transform);
  }

  /// Transform the future result with another async operation
  Future<ApiResult<R>> flatMapAsync<R>(Future<ApiResult<R>> Function(T data) transform) async {
    final result = await this;
    return switch (result) {
      ApiSuccess<T>(data: final data) => await transform(data),
      ApiFailure<T>(message: final message, code: final code, error: final error) => 
        ApiResult.failure(message, code: code, error: error),
    };
  }

  /// Execute an action if the future result is successful
  Future<ApiResult<T>> onSuccessAsync(Future<void> Function(T data) action) async {
    final result = await this;
    if (result is ApiSuccess<T>) {
      await action(result.data);
    }
    return result;
  }

  /// Execute an action if the future result is failed
  Future<ApiResult<T>> onFailureAsync(Future<void> Function(String message, String? code, dynamic error) action) async {
    final result = await this;
    if (result is ApiFailure<T>) {
      await action(result.message, result.code, result.error);
    }
    return result;
  }
}
