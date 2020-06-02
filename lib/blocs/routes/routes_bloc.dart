import 'dart:async';
import 'dart:math';

import 'package:assignment/exceptions/routes_failed_exception.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

part 'routes_event.dart';
part 'routes_state.dart';

///Handles the routes related logic for the map
///
///Takes a `PolyLlinePpoinnts` as initial input
class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  final Logger logger = Logger();
  final PolylinePoints polylinePoints;
  final Random rand = Random();

  //the directions api should be stored externally like in firebase remote config, for this demo however it is simply stored here;
  final String _DIRECTIONS_API_KEY = "AIzaSyC_A46PtGItoOICjad12zikcyF2N7thKSU";

  RoutesBloc(this.polylinePoints);

  @override
  RoutesState get initialState => RoutesInitial();

  @override
  Stream<RoutesState> mapEventToState(
    RoutesEvent event,
  ) async* {
    if (event is LoadRoutesEvent) {
      yield* loadRoutes();
    }
  }

  ///Loads the coordinates and routes of the users current position and destination
  ///Yields a `Stream<RoutesState>`
  Stream<RoutesState> loadRoutes() async* {
    yield (RoutesLoading());
    try {
      Position startPosition = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      Position destPosition = Position(
          latitude: startPosition.latitude + rand.nextDouble() * 0.1,
          longitude: startPosition.longitude + rand.nextDouble() * 0.1);

      Polyline route = await getRouteLine(startPosition, destPosition);
      yield (RoutesLoaded({
        route
      }, {
        Marker(
          infoWindow: InfoWindow(title: "Your Destination"),
          markerId: MarkerId("destination"),
          position: LatLng(destPosition.latitude, destPosition.longitude),
        )
      }, destPosition));
    } on PlatformException catch (e) {
      yield (RoutesFailed(RoutesFailedException(
          errorMsg: e.message,
          displayText:
              "Oops, failed to create a route. Did you enable permissions?")));
    }
  }

  ///creates a route line
  ///Returns a `Polyline` once the route has been generated
  Future<Polyline> getRouteLine(
      Position startPosition, Position destPosition) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        _DIRECTIONS_API_KEY,
        PointLatLng(startPosition.latitude, startPosition.longitude),
        PointLatLng(destPosition.latitude, destPosition.longitude));
    List<LatLng> points = List();
    result.points.forEach((element) {
      points.add(LatLng(element.latitude, element.longitude));
    });
    return Polyline(
      width: 4,
      polylineId: PolylineId(
          "1"), //a fixed polyline id, each route is replaced when a new one is made
      visible: true,
      points: points,
      color: Colors.pink,
    );
  }
}
