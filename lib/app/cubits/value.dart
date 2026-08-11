import 'package:flutter/material.dart' show BuildContext, Widget;
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, Cubit;

import 'cubits.dart' show CubitActions;

// The simplest cubit. We can't use `Cubit` directly because that is abstract.
class Value<State> extends Cubit<State> with CubitActions {
  Value(super.initial);

  Widget builder(Widget Function(State) func) {
    return BlocBuilder<Value<State>, State>(
      bloc: this,
      builder: (BuildContext ctx, State state) {
        return func(state);
      },
    );
  }

  void changed() {
    emitUnlessClosed(state);
  }

  void update(void Function(State) f) {
    f(state);
    changed();
  }
}
