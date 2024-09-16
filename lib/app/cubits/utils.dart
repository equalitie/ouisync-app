import 'package:flutter_bloc/flutter_bloc.dart';

extension EmitUnlessClosed<CubitState> on Cubit<CubitState> {
  void emitUnlessClosed(CubitState cubitState) {
    if (!isClosed) {
      emit(cubitState);
    }
  }
}
