import 'dart:async';

import 'package:assignment/exceptions/current_location_exception.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'location_event.dart';
part 'location_state.dart';

///handles the locationr related logic for the map
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final Logger logger = Logger();
  @override
  LocationState get initialState => LocationInitial();

  @override
  Stream<LocationState> mapEventToState(
    LocationEvent event,
  ) async* {
    if (event is LoadMyLocationEvent) {
      yield* loadLoc();
    }
  }

  ///loads the users current location
  ///Yields a `Stream<LocationState`
  Stream<LocationState> loadLoc() async* {
    yield (MyLocationLoadingState());
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      yield (MyLocationReadyState(position));
    } on PlatformException catch (e) {
      yield (MyLocationFailedState(CurrentLocationException(
          errorMsg: e.message,
          displayText:
              "We could not find you! Did you check your permissions?")));
      logger.e(e.message);
    }
  }
}
