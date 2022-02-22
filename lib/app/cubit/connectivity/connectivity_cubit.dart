import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(ConnectivityInitial());

  void connectivityEvent(ConnectivityResult connectivityResult) async {
    emit(ConnectivityChanged(connectivityResult: connectivityResult));
  }
}
