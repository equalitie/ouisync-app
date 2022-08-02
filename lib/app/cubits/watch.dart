import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class Watch<State> {
  _Cubit _cubit = _Cubit();
  final State _state;

  Watch(State state) : _state = state;

  State get state => _state;

  void changed() {
    _cubit.emit(Changed());
  }

  void update(void Function(State) f) {
    f(_state);
    changed();
  }

  Widget builder(Widget Function(State) builderFunc) {
    return BlocBuilder<_Cubit, Changed>(
      bloc: _cubit,
      builder: (BuildContext ctx, Changed _) {
        return builderFunc(_state);
      },
    );
  }

  Widget consumer(Widget Function(State) builderFunc, void Function(State) listenerFunc) {
    return BlocConsumer<_Cubit, Changed>(
      bloc: _cubit,
      builder: (BuildContext ctx, Changed _) {
        return builderFunc(_state);
      },
      listener: (BuildContext ctx, Changed _) {
        listenerFunc(_state);
      },
    );
  }
}

class Changed extends Equatable {
  static int _nextChangeVersion = 0;
  final int _version;

  Changed() : _version = _nextChangeVersion {
    _nextChangeVersion += 1;
  }

  @override
  List<Object?> get props => [ _version ];
}

// We can't use Cubit as it's marked as `abstract` so this is a generic one.
class _Cubit extends Cubit<Changed> {
  _Cubit() : super(Changed()) {}
}
