import 'dart:async';

// A dart counterpart to Rust's `tokio::sync::watch`.
// Use it for cases where you'd use Stream but you don't want to buffer the
// sent values.
//
// ### Usage: ###
//
// final sender = Sender<int>();
// final receiver = sender.subscribe();
//
// // Sending code
// unawaited(() async {
//   int i = 0;
//   while (true) {
//     sender.send(i);
//     i += 1;
//   }
// });
//
// // Receiving code
// unawaited(() async {
//   while (true) {
//     switch (await receiver.receive()) {
//       case Value(value: final i):
//         print("Last value from sender is $i");
//         break;
//       case Closed():
//         return;
//     }
//   }
// });

class Sender<T> {
  _SharedState<T> _state;

  Sender(T initialValue) : _state = _SharedState(initialValue);

  void send(T newValue) {
    _state.value = newValue;
    _state.valueVersion = _state.valueVersion + BigInt.one;

    final completers = _state.completers;
    _state.completers = [];

    for (final completer in completers) {
      completer.complete();
    }
  }

  Receiver<T> subscribe() {
    return Receiver<T>._(_state);
  }

  bool get isClosed => _state.isClosed;

  void close() {
    final completers = _state.completers;
    _state.completers = [];
    _state.isClosed = true;

    for (final completer in completers) {
      completer.complete();
    }
  }
}

class Receiver<T> {
  _SharedState<T> _state;
  BigInt? _lastSeenVersion = null;

  Receiver._(this._state);

  Future<Result<T>> receive() async {
    final lastSeenVersion = _lastSeenVersion;

    if (_state.isClosed) {
      return Closed();
    }

    if (lastSeenVersion == null || lastSeenVersion < _state.valueVersion) {
      _lastSeenVersion = _state.valueVersion;
      return Value(_state.value);
    } else {
      final completer = Completer<T>();
      final future = completer.future;

      _state.completers.add(completer);

      await future;

      if (_state.isClosed) {
        return Closed();
      }

      _lastSeenVersion = _state.valueVersion;
      return Value(_state.value);
    }
  }
}

sealed class Result<T> {}

class Value<T> extends Result<T> {
  T value;
  Value(this.value);
}

class Closed<T> extends Result<T> {}

// -- Private support classes ----------------------------------------

class _SharedState<T> {
  T value;
  BigInt valueVersion = BigInt.zero;
  List<Completer<T>> completers = [];
  bool isClosed = false;

  _SharedState(this.value);
}
