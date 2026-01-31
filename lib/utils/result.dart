sealed class Result<T> {
  const Result();

  static Result<T> attempt<T>(T Function() callback) {
    try {
      return Ok._(callback());
    } catch (e, stackTrace) {
      return Err._("$e\n$stackTrace");
    }
  }

  static Future<Result<T>> attemptAsync<T>(
    Future<T> Function() callback,
  ) async {
    try {
      return Ok._(await callback());
    } catch (e, stackTrace) {
      return Err._("$e\n$stackTrace");
    }
  }

  E map<E>(E Function(T) onSuccess, E Function(String) onFailure) {
    switch (this) {
      case Ok<T>(value: var v):
        return onSuccess(v);
      case Err<T>(message: var e):
        return onFailure(e);
    }
  }

  T? get unwrapOrNull {
    switch (this) {
      case Ok<T>(value: var v):
        return v;
      case Err<T>():
        return null;
    }
  }
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok._(this.value);

  @override
  String toString() => "Result.Ok(${value.runtimeType} - $value)";
}

final class Err<T> extends Result<T> {
  const Err._(this.message);
  final String message;

  @override
  String toString() => "Result.Err($message)";
}
