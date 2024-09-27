import 'package:flutter_bloc/flutter_bloc.dart';

extension EmitUnlessClosed<CubitState> on Cubit<CubitState> {
  // Return `true` if emited.
  bool emitUnlessClosed(CubitState cubitState) {
    if (!isClosed) {
      emit(cubitState);
    }
    return !isClosed;
  }
}
