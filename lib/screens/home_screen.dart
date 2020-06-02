import 'dart:async';

import 'package:assignment/blocs/auth/auth_bloc.dart';
import 'package:assignment/blocs/location/location_bloc.dart';
import 'package:assignment/blocs/routes/routes_bloc.dart';
import 'package:assignment/exceptions/routes_failed_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _controller = Completer();
  bool _isLocationLoading = false;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Set<Polyline> _polyline = {};
  final Set<Marker> _markers = {};
  RoutesBloc _routesBloc;
  LocationBloc _locationBloc;

  ///Initializes the widget, `RoutesBloc` and `LocationBloc`
  ///The current location fetching event is triggered in `LocationBloc`
  ///The random route even is triggered in `RoutesBloc`
  @override
  void initState() {
    super.initState();
    _routesBloc = RoutesBloc(PolylinePoints());
    _locationBloc = LocationBloc();
    _locationBloc.add(LoadMyLocationEvent());
    _routesBloc.add(LoadRoutesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        textTheme: Theme.of(context).appBarTheme.textTheme,
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: Text(
          "Assignment",
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.exit_to_app),
            onPressed: () =>
                BlocProvider.of<AuthBloc>(context).add(SignOutEvent()),
          ),
        ],
      ),
      body: Center(
          child: MultiBlocListener(
              listeners: [
            BlocListener<RoutesBloc, RoutesState>(
              bloc: _routesBloc,
              listener: (context, state) {
                if (state is RoutesLoading) {
                  setState(() {
                    _isLocationLoading = true;
                  });
                } else if (state is RoutesLoaded) {
                  setState(() {
                    _isLocationLoading = false;
                    _polyline.clear();
                    state.lines.forEach((element) {
                      _polyline.add(element);
                    });
                    _markers.clear();
                    state.markers.forEach((element) {
                      _markers.add(element);
                    });
                  });
                  _loadMapToLocation(state.destPosition);
                } else if (state is RoutesFailed) {
                  _isLocationLoading = false;
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(state.routesFailedException.displayText),
                  ));
                }
              },
            ),
            BlocListener<LocationBloc, LocationState>(
              bloc: _locationBloc,
              listener: (context, state) {
                if (state is MyLocationReadyState) {
                  //the current location will be loaded to the map view
                  _loadMapToLocation(state.position);
                } else if (state is MyLocationLoadingState) {
                  //nothing needs to be shown here while the my location is loading. User should be allowed to interact with the map regardless.
                } else if (state is MyLocationFailedState) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(state.exception.displayText),
                  ));
                }
              },
            )
          ],
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    polylines: _polyline,
                    markers: _markers,
                    initialCameraPosition: _kGooglePlex,
                    mapType: MapType.hybrid,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 30.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0))),
                        color: Colors.white,
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: !_isLocationLoading
                                ? Icon(
                                    Icons.refresh,
                                    color: Colors.pink,
                                    size: 36.0,
                                  )
                                : CircularProgressIndicator(),
                          ),
                        ),
                        onPressed: () {
                          _routesBloc.add(LoadRoutesEvent());
                        },
                      ),
                    ),
                  )
                ],
              ))),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _routesBloc.close();
    _locationBloc.close();
  }

  ///moves map camera over the specified position
  void _loadMapToLocation(Position position) async {
    CameraPosition _currentLoc = CameraPosition(
      zoom: 13,
      target: LatLng(
        position.latitude,
        position.longitude,
      ),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_currentLoc));
  }
}
