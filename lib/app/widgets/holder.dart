import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Helper widget that maintains a lifecycle of some resource and explicitly provides it to the
/// descendant widgets. This is similar to `Provider` from the `provider` package but it passes the
/// resource explicitly via the `builder` callback instead of implicitly via `context`. This means
/// that it's impossible to forget to pass the resource as it would lead to compile time error,
/// unlike `Provider` which would cause runtime error in such case.
class ObjectHolder<T> extends StatefulWidget {
  const ObjectHolder({
    super.key,
    required this.create,
    this.dispose,
    required this.builder,
  });

  final T Function() create;
  final void Function(T)? dispose;
  final Widget Function(BuildContext, T) builder;

  @override
  State<ObjectHolder<T>> createState() => _ObjectHolderState<T>();
}

class _ObjectHolderState<T> extends State<ObjectHolder<T>> {
  late T object;

  @override
  void initState() {
    super.initState();
    object = widget.create();
  }

  @override
  void dispose() {
    widget.dispose?.call(object);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, object);
}

/// Helper widget that maintains a lifecycle of a `Bloc` or `Cubit`. Similar to `BlocProvider` but
/// passes the bloc/cubit explicitly to avoid runtime errors.
class BlocHolder<T extends BlocBase> extends ObjectHolder<T> {
  BlocHolder({super.key, required super.create, required super.builder})
    : super(dispose: (bloc) => unawaited(bloc.close()));
}
