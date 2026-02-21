class ValueResult<T> {
  final T? _value;
  final String? _error;
  final String? _title;

  const ValueResult._(this._value, this._error, this._title);

  factory ValueResult.success(T value) {
    return ValueResult._(value, null, null);
  }

  factory ValueResult.failure(String error, {String? title}) {
    return ValueResult._(null, error, title);
  }

  T? get value {
    if (isError) {
      throw StateError(
          'Cannot access value when result is an error. Error: $_error');
    }
    return _value as T;
  }

  String get error {
    if (isSuccess) {
      throw StateError('Cannot access error when result is a success.');
    }
    return _error!;
  }

  String? get title => _title;

  bool get isSuccess => _error == null;
  bool get isError => _error != null;

  static ValueResult<S> fromError<S>(dynamic exceptionOrError) {
    String? title;
    String errorMessage = "Ocorreu um erro desconhecido.";

    try {
      final data = exceptionOrError?.response?.data;
      final error = data?['error'];
      if (error is Map) {
        title = error['title'] ?? data?['title'];
        errorMessage = error['message'] ?? data?['message'] ?? errorMessage;
      } else if (data is Map && data['message'] is String) {
        title = data['title'] as String?;
        errorMessage = data['message'] as String;
      } else if (exceptionOrError is Exception || exceptionOrError is Error) {
        errorMessage = exceptionOrError.toString();
      } else if (exceptionOrError is String) {
        errorMessage = exceptionOrError;
      } else if (exceptionOrError?.message != null) {
        errorMessage = exceptionOrError.message.toString();
      }
    } catch (_) {
      // fallback
    }

    return ValueResult<S>.failure(errorMessage, title: title);
  }

  R fold<R>(
    R Function(T value) onSuccess,
    R Function(String error) onFailure,
  ) {
    if (isSuccess) {
      return onSuccess(_value as T);
    } else {
      return onFailure(_error!);
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ValueResult.success(value: $_value)';
    } else {
      return 'ValueResult.failure(title: $_title, error: $_error)';
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ValueResult<T> &&
            other._value == _value &&
            other._error == _error &&
            other._title == _title;
  }

  @override
  int get hashCode => _value.hashCode ^ _error.hashCode ^ _title.hashCode;
}
