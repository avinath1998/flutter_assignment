part of 'routes_bloc.dart';

@immutable
abstract class RoutesState {}

class RoutesInitial extends RoutesState {}

class RoutesLoaded extends RoutesState {
  final Set<Polyline> lines;
  final Set<Marker> markers;
  final Position destPosition;

  RoutesLoaded(this.lines, this.markers, this.destPosition);
}

class RoutesLoading extends RoutesState {}

class RoutesFailed extends RoutesState {
  final RoutesFailedException routesFailedException;

  RoutesFailed(this.routesFailedException);
}
