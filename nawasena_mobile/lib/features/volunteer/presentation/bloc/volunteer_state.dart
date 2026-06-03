import 'package:equatable/equatable.dart';
import 'package:nawasena_mobile/features/volunteer/data/models/workshop_model.dart';

abstract class VolunteerState extends Equatable {
  const VolunteerState();
  @override
  List<Object?> get props => [];
}

class VolunteerInitial extends VolunteerState {
  const VolunteerInitial();
}

class WorkshopsLoading extends VolunteerState {
  const WorkshopsLoading();
}

class WorkshopDetailLoading extends VolunteerState {
  const WorkshopDetailLoading();
}

class WorkshopActionLoading extends VolunteerState {
  const WorkshopActionLoading();
}

class CheckinLoading extends VolunteerState {
  const CheckinLoading();
}

class WorkshopsLoaded extends VolunteerState {
  final List<WorkshopModel> workshops;
  const WorkshopsLoaded({required this.workshops});
  @override
  List<Object?> get props => [workshops];
}

class WorkshopDetailLoaded extends VolunteerState {
  final WorkshopModel workshop;
  const WorkshopDetailLoaded({required this.workshop});
  @override
  List<Object?> get props => [workshop];
}

class WorkshopRegistered extends VolunteerState {
  final String workshopId;
  const WorkshopRegistered({required this.workshopId});
  @override
  List<Object?> get props => [workshopId];
}

class WorkshopUnregistered extends VolunteerState {
  final String workshopId;
  const WorkshopUnregistered({required this.workshopId});
  @override
  List<Object?> get props => [workshopId];
}

class CheckinSuccess extends VolunteerState {
  final String message;
  const CheckinSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class VolunteerError extends VolunteerState {
  final String message;
  const VolunteerError({required this.message});
  @override
  List<Object?> get props => [message];
}