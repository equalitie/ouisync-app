import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits.dart' show CubitActions;

class WatchSelf<Self> extends Cubit<Changed> with CubitActions {
  WatchSelf() : super(Changed(0));

  void changed() {
    emitUnlessClosed(state.next);
  }

  void update(void Function(Self) f) {
    f(this as Self);
    changed();
  }

  Widget builder(Widget Function(Self) builderFunc) {
    return BlocBuilder<WatchSelf<Self>, Changed>(
      bloc: this,
      builder: (BuildContext ctx, Changed _) {
        return builderFunc(this as Self);
      },
    );
  }

  Widget consumer(
    Widget Function(Self) builderFunc,
    void Function(Self) listenerFunc,
  ) {
    return BlocConsumer<WatchSelf<Self>, Changed>(
      bloc: this,
      builder: (BuildContext ctx, Changed _) {
        return builderFunc(this as Self);
      },
      listener: (BuildContext ctx, Changed _) {
        listenerFunc(this as Self);
      },
    );
  }
}

class Changed extends Equatable {
  final int version;

  Changed(this.version);

  Changed get next => Changed(version + 1);

  @override
  List<Object?> get props => [version];
}
