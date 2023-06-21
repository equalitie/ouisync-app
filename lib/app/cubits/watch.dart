import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class WatchSelf<Self> {
  final _Cubit _cubit = _Cubit();

  void changed() {
    _cubit.change();
  }

  void update(void Function(Self) f) {
    f(this as Self);
    changed();
  }

  Widget builder(Widget Function(Self) builderFunc) {
    return BlocBuilder<_Cubit, Changed>(
      bloc: _cubit,
      builder: (BuildContext ctx, Changed _) {
        return builderFunc(this as Self);
      },
    );
  }

  Widget consumer(
      Widget Function(Self) builderFunc, void Function(Self) listenerFunc) {
    return BlocConsumer<_Cubit, Changed>(
      bloc: _cubit,
      builder: (BuildContext ctx, Changed _) {
        return builderFunc(this as Self);
      },
      listener: (BuildContext ctx, Changed _) {
        listenerFunc(this as Self);
      },
    );
  }

  Stream<Changed> get stream => _cubit.stream;
}

class Changed extends Equatable {
  static int _nextChangeVersion = 0;
  final int _version;

  Changed() : _version = _nextChangeVersion {
    _nextChangeVersion += 1;
  }

  @override
  List<Object?> get props => [_version];
}

// We can't use Cubit as it's marked as `abstract` so this is a generic one.
class _Cubit extends Cubit<Changed> {
  _Cubit() : super(Changed());

  void change() => emit(Changed());
}
