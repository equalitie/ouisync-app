import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

// We can't use Cubit as it's marked as `abstract` so this is a generic one.
class Watch<State> extends Cubit<State> {
  Watch(State initial) : super(initial);

  Widget builder(Widget func(State)) {
    return BlocBuilder<Watch<State>, State>(
      bloc: this,
      builder: (BuildContext ctx, State state) {
        return func(state);
      },
    );
  }
}
