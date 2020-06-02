part of 'location_bloc.dart';

@immutable
abstract class LocationState {}

class LocationInitial extends LocationState {}

class MyLocationReadyState extends LocationState {
  final Position position;

  MyLocationReadyState(this.position);
}

class MyLocationLoadingState extends LocationState {}

class MyLocationFailedState extends LocationState {
  final CurrentLocationException exception;

  MyLocationFailedState(this.exception);
}
