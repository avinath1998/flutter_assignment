part of 'fcm_handler_bloc.dart';

@immutable
abstract class FcmHandlerState {}

class FcmHandlerInitial extends FcmHandlerState {}

class FcmMessageLoadedState extends FcmHandlerState {
  final String message;
  final String title;
  FcmMessageLoadedState(this.message, this.title);
}

class FcmInitializedState extends FcmHandlerState {}

class FcmFailedState extends FcmHandlerState {
  final FcmHandlerFailedException exception;

  FcmFailedState(this.exception);
}
