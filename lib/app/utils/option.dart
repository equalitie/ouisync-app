/// Optional value, inspired by rust's `Option`. Alternative to nullable types. Useful for example
/// for the `copyWith` idiom when a field itself is nullable, to distinguish between "don't change"
/// and "set to null".
sealed class Option<T> {
  const Option();

  T? get value;

  @override
  bool operator ==(Object other) {
    if (other is! Option<T>) return false;
    switch ((this, other)) {
      case (Some(value: var lv), Some(value: var rv)):
        return lv == rv;
      case (None, None):
        return true;
      case (_, _):
        return false;
    }
  }

  String toString();
}

class Some<T> extends Option<T> {
  const Some(this.value);

  @override
  final T value;

  @override
  String toString() => "Some($value)";
}

class None<T> extends Option<T> {
  const None();

  @override
  T? get value => null;

  @override
  String toString() => "None";
}
