import 'package:equatable/equatable.dart';

abstract class VolunteerEvent extends Equatable {
  const VolunteerEvent();
  @override
  List<Object?> get props => [];
}

class LoadGlobalWorkshops extends VolunteerEvent {
  final String? status;
  const LoadGlobalWorkshops({this.status});
  @override
  List<Object?> get props => [status];
}

class LoadWorkshopDetail extends VolunteerEvent {
  final String workshopId;
  const LoadWorkshopDetail({required this.workshopId});
  @override
  List<Object?> get props => [workshopId];
}

class RegisterForWorkshop extends VolunteerEvent {
  final String workshopId;
  const RegisterForWorkshop({required this.workshopId});
  @override
  List<Object?> get props => [workshopId];
}

class UnregisterFromWorkshop extends VolunteerEvent {
  final String workshopId;
  const UnregisterFromWorkshop({required this.workshopId});
  @override
  List<Object?> get props => [workshopId];
}

class CheckinWorkshop extends VolunteerEvent {
  final String workshopId;
  final double lat;
  final double lng;
  const CheckinWorkshop({
    required this.workshopId,
    required this.lat,
    required this.lng,
  });
  @override
  List<Object?> get props => [workshopId, lat, lng];
}