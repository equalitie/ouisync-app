part of 'connectivity_cubit.dart';

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityChanged extends ConnectivityState {
  const ConnectivityChanged({
    required this.connectivityResult
  });

  final ConnectivityResult connectivityResult;

  @override
  List<Object> get props => [
    connectivityResult
  ];
}