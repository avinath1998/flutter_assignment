part of 'fcm_handler_bloc.dart';

@immutable
abstract class FcmHandlerEvent {}

class FcmMessageReceivedEvent extends FcmHandlerEvent {
  final String message;
  final String title;
  FcmMessageReceivedEvent(this.message, this.title);
}

class FcmInit extends FcmHandlerEvent {}
