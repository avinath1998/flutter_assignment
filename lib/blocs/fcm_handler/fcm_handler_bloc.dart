import 'dart:async';

import 'package:assignment/exceptions/fcm_handler_failed_exception.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'fcm_handler_event.dart';
part 'fcm_handler_state.dart';

///Handles the FCM logic for the widget tree
///
///Takes an `FirebaseMessaging` as initial input
class FcmHandlerBloc extends Bloc<FcmHandlerEvent, FcmHandlerState> {
  final FirebaseMessaging _firebaseMessaging;
  final Logger logger = Logger();
  bool _isFCMInitialized = false;

  FcmHandlerBloc(this._firebaseMessaging);

  @override
  FcmHandlerState get initialState => FcmHandlerInitial();

  @override
  Stream<FcmHandlerState> mapEventToState(
    FcmHandlerEvent event,
  ) async* {
    if (event is FcmMessageReceivedEvent) {
      yield (FcmMessageLoadedState(event.message, event.title));
    } else if (event is FcmInit) {
      yield* initFCM();
    }
  }

  ///initializes the Firebase cloud messaging
  ///Yields a `Stream<FcmHandlerState>`
  Stream<FcmHandlerState> initFCM() async* {
    try {
      if (!_isFCMInitialized) {
        _firebaseMessaging.configure(onMessage: (map) async {
          add(FcmMessageReceivedEvent(
              map["notification"]["body"], map["notification"]["title"]));
        });
        _isFCMInitialized = true;
      }
      String token = await _firebaseMessaging.getToken();
      logger.i(token);
      yield (FcmInitializedState());
    } on ArgumentError catch (e) {
      logger.e(e.message);
      yield FcmFailedState(FcmHandlerFailedException(
          e.message, "Error initializing messaging."));
    } on UnsupportedError catch (e) {
      logger.e(e.message);
      yield FcmFailedState(FcmHandlerFailedException(
          e.message, "Oops, an unsupported message has been received."));
    }
  }
}
