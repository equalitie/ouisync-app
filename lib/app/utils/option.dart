/// Optional value, inspired by rust's `Option`. Alternative to nullable types. Useful for example
/// for the `copyWith` idiom when a field itself is nullable, to distinguish between "don't change"
/// and "set to null".
sealed class Option<T> {
  const Option();

  T? get value;
}

class Some<T> extends Option<T> {
  const Some(this.value);

  @override
  final T value;
}

class None<T> extends Option<T> {
  const None();

  @override
  T? get value => null;
}
