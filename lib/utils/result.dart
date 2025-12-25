sealed class Result<T> {
  const Result();

  static Result<T> attempt<T>(T Function() callback) {
    return Ok._(callback());
    try {
      return Ok._(callback());
    } catch (e) {
      return Err._(e.toString());
    }
  }

  static Future<Result<T>> attemptAsync<T>(
    Future<T> Function() callback,
  ) async {
    return Ok._(await callback());
    try {
      return Ok._(await callback());
    } catch (e) {
      return Err._(e.toString());
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
