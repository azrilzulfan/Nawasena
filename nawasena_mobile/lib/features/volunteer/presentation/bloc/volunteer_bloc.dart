import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawasena_mobile/core/error/exceptions.dart';
import 'package:nawasena_mobile/features/volunteer/data/repositories/workshop_repository.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_event.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_state.dart';

class VolunteerBloc extends Bloc<VolunteerEvent, VolunteerState> {
  final WorkshopRepository _repository;

  VolunteerBloc({required this._repository})
      : super(const VolunteerInitial()) {
    on<LoadGlobalWorkshops>(_onLoadGlobalWorkshops);
    on<LoadWorkshopDetail>(_onLoadWorkshopDetail);
    on<RegisterForWorkshop>(_onRegisterForWorkshop);
    on<UnregisterFromWorkshop>(_onUnregisterFromWorkshop);
    on<CheckinWorkshop>(_onCheckinWorkshop);
  }

  Future<void> _onLoadGlobalWorkshops(
      LoadGlobalWorkshops event,
      Emitter<VolunteerState> emit,
      ) async {
    emit(const WorkshopsLoading());
    try {
      final result = await _repository.getGlobalWorkshops(status: event.status);
      emit(WorkshopsLoaded(workshops: result.data));
    } on ServerException catch (e) {
      emit(VolunteerError(message: e.message));
    } catch (e) {
      emit(VolunteerError(message: e.toString()));
    }
  }

  Future<void> _onLoadWorkshopDetail(
      LoadWorkshopDetail event,
      Emitter<VolunteerState> emit,
      ) async {
    emit(const WorkshopDetailLoading());
    try {
      final workshop = await _repository.getWorkshopDetail(event.workshopId);
      emit(WorkshopDetailLoaded(workshop: workshop));
    } on ServerException catch (e) {
      emit(VolunteerError(message: e.message));
    } catch (e) {
      emit(VolunteerError(message: e.toString()));
    }
  }

  Future<void> _onRegisterForWorkshop(
      RegisterForWorkshop event,
      Emitter<VolunteerState> emit,
      ) async {
    emit(const WorkshopActionLoading());
    try {
      await _repository.registerWorkshop(event.workshopId);
      emit(WorkshopRegistered(workshopId: event.workshopId));
    } on ServerException catch (e) {
      emit(VolunteerError(message: e.message));
    } catch (e) {
      emit(VolunteerError(message: e.toString()));
    }
  }

  Future<void> _onUnregisterFromWorkshop(
      UnregisterFromWorkshop event,
      Emitter<VolunteerState> emit,
      ) async {
    emit(const WorkshopActionLoading());
    try {
      await _repository.unregisterWorkshop(event.workshopId);
      emit(WorkshopUnregistered(workshopId: event.workshopId));
    } on ServerException catch (e) {
      emit(VolunteerError(message: e.message));
    } catch (e) {
      emit(VolunteerError(message: e.toString()));
    }
  }

  Future<void> _onCheckinWorkshop(
      CheckinWorkshop event,
      Emitter<VolunteerState> emit,
      ) async {
    emit(const CheckinLoading());
    try {
      final result = await _repository.checkinWorkshop(
        workshopId: event.workshopId,
        lat:        event.lat,
        lng:        event.lng,
      );
      final message = result['message']?.toString() ?? 'Check-in berhasil!';
      emit(CheckinSuccess(message: message));
    } on ServerException catch (e) {
      emit(VolunteerError(message: e.message));
    } catch (e) {
      emit(VolunteerError(message: e.toString()));
    }
  }
}