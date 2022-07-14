import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/repository_progress.dart';
import '../models/repo_state.dart';
import '../utils/utils.dart';

class RepositoryProgress extends StatelessWidget {
  // This is used to make the progress go all the way from the beginning of the circle to the end.
  // If we did not use it, then after the repository gets bigger, we start seeing a circle which
  // is almost full, but with only few pixels remaining.
  _Start? _start;
  RepoState? _repo;

  RepositoryProgress(this._repo);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: BlocProvider.of<RepositoryProgressCubit>(context),
      buildWhen: (context, state) {
        if (_repo == null) {
            return false;
        }

        if (!(state is RepositoryProgressUpdate)) {
          return false;
        }

        return state.repo == _repo;
      },
      builder: (context, state) {
        if (!(state is RepositoryProgressUpdate)) {
          return SizedBox.shrink();
        }

        final v = state.progress.value;
        final t = state.progress.total;

        if (v == t || t == 0) {
          return SizedBox.shrink();
        }

        var s = _start;

        if (s == null || s.total != t) {
          s = _Start(v, t);
          _start = s;
        }

        final v_ = v - s.value;
        final t_ = t - s.value;

        return ConstrainedBox(
            constraints: BoxConstraints.tight(Size.square(Dimensions.sizeIconSmall)),
            child: CircularProgressIndicator(
              backgroundColor: Constants.progressBarBackgroundColor,
              value: v_.toDouble() / t_.toDouble()
        ));
      },
      listener: (context, state) { }
    );
  }
}

class _Start {
  _Start(this.value, this.total);
  int value;
  int total;
}
