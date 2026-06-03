import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nawasena_mobile/core/error/exceptions.dart';
import 'package:nawasena_mobile/features/donor/data/models/foundation_model.dart';
import 'package:nawasena_mobile/features/donor/data/repositories/foundation_repository.dart';
import 'package:nawasena_mobile/features/volunteer/data/models/workshop_model.dart';
import 'package:nawasena_mobile/features/volunteer/data/repositories/workshop_repository.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_bloc.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_event.dart';
import 'package:nawasena_mobile/features/volunteer/presentation/bloc/volunteer_state.dart';

// ── Mock ──────────────────────────────────────────────────────────────────────
class MockWorkshopRepository extends Mock implements WorkshopRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────────
final _mockWorkshop = WorkshopModel(
  id:                    'ws_001',
  foundationId:          'found_001',
  title:                 'Mengajar Bersama Anak Yatim',
  description:           'Kegiatan pengajaran dan pendampingan anak yatim.',
  eventDate:             DateTime.now().add(const Duration(days: 7)),
  status:                WorkshopStatus.open,
  mentorNeeded:          10,
  mentorRegisteredCount: 3,
  geofenceRadiusMeters:  100,
  location:              const GeoLocation(coordinates: [106.8456, -6.2088]),
);

final _paginatedWorkshops = PaginatedResult<WorkshopModel>(
  data:        [_mockWorkshop],
  total:       1,
  currentPage: 1,
  lastPage:    1,
);

void main() {
  late MockWorkshopRepository mockRepo;

  setUp(() => mockRepo = MockWorkshopRepository());

  VolunteerBloc buildBloc() => VolunteerBloc(repository: mockRepo);

  // ── LoadGlobalWorkshops ────────────────────────────────────────────────────
  group('LoadGlobalWorkshops', () {
    blocTest<VolunteerBloc, VolunteerState>(
      'emits [WorkshopsLoading, WorkshopsLoaded] on success',
      build: () {
        when(() => mockRepo.getGlobalWorkshops(
          status: any(named: 'status'),
        )).thenAnswer((_) async => _paginatedWorkshops);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadGlobalWorkshops()),
      expect: () => [
        const WorkshopsLoading(),
        WorkshopsLoaded(workshops: [_mockWorkshop]),
      ],
    );

    blocTest<VolunteerBloc, VolunteerState>(
      'emits [WorkshopsLoading, VolunteerError] on server error',
      build: () {
        when(() => mockRepo.getGlobalWorkshops(
          status: any(named: 'status'),
        )).thenThrow(const ServerException(message: 'Internal server error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadGlobalWorkshops()),
      expect: () => [
        const WorkshopsLoading(),
        const VolunteerError(message: 'Internal server error'),
      ],
    );
  });

  // ── LoadWorkshopDetail ─────────────────────────────────────────────────────
  group('LoadWorkshopDetail', () {
    blocTest<VolunteerBloc, VolunteerState>(
      'emits [WorkshopDetailLoading, WorkshopDetailLoaded] on success',
      build: () {
        when(() => mockRepo.getWorkshopDetail('ws_001'))
            .thenAnswer((_) async => _mockWorkshop);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadWorkshopDetail(workshopId: 'ws_001')),
      expect: () => [
        const WorkshopDetailLoading(),
        WorkshopDetailLoaded(workshop: _mockWorkshop),
      ],
    );
  });

  // ── RegisterForWorkshop ────────────────────────────────────────────────────
  group('RegisterForWorkshop', () {
    blocTest<VolunteerBloc, VolunteerState>(
      'emits [WorkshopActionLoading, WorkshopRegistered] on success',
      build: () {
        when(() => mockRepo.registerWorkshop('ws_001'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const RegisterForWorkshop(workshopId: 'ws_001')),
      expect: () => [
        const WorkshopActionLoading(),
        const WorkshopRegistered(workshopId: 'ws_001'),
      ],
    );

    blocTest<VolunteerBloc, VolunteerState>(
      'emits [WorkshopActionLoading, VolunteerError] when quota full (409)',
      build: () {
        when(() => mockRepo.registerWorkshop('ws_001'))
            .thenThrow(const ServerException(
          message:    'Volunteer quota is full',
          statusCode: 409,
        ));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const RegisterForWorkshop(workshopId: 'ws_001')),
      expect: () => [
        const WorkshopActionLoading(),
        const VolunteerError(message: 'Volunteer quota is full'),
      ],
    );
  });

  // ── UnregisterFromWorkshop ─────────────────────────────────────────────────
  group('UnregisterFromWorkshop', () {
    blocTest<VolunteerBloc, VolunteerState>(
      'emits [WorkshopActionLoading, WorkshopUnregistered] on success',
      build: () {
        when(() => mockRepo.unregisterWorkshop('ws_001'))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const UnregisterFromWorkshop(workshopId: 'ws_001')),
      expect: () => [
        const WorkshopActionLoading(),
        const WorkshopUnregistered(workshopId: 'ws_001'),
      ],
    );
  });

  // ── CheckinWorkshop ────────────────────────────────────────────────────────
  group('CheckinWorkshop', () {
    blocTest<VolunteerBloc, VolunteerState>(
      'emits [CheckinLoading, CheckinSuccess] on success',
      build: () {
        when(() => mockRepo.checkinWorkshop(
          workshopId: any(named: 'workshopId'),
          lat:        any(named: 'lat'),
          lng:        any(named: 'lng'),
        )).thenAnswer((_) async => {'message': 'Check-in berhasil!'});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckinWorkshop(
        workshopId: 'ws_001',
        lat:        -6.2088,
        lng:        106.8456,
      )),
      expect: () => [
        const CheckinLoading(),
        const CheckinSuccess(message: 'Check-in berhasil!'),
      ],
    );

    blocTest<VolunteerBloc, VolunteerState>(
      'emits [CheckinLoading, VolunteerError] when outside geofence (422)',
      build: () {
        when(() => mockRepo.checkinWorkshop(
          workshopId: any(named: 'workshopId'),
          lat:        any(named: 'lat'),
          lng:        any(named: 'lng'),
        )).thenThrow(const ServerException(
          message:    'You are outside the geofence radius.',
          statusCode: 422,
        ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CheckinWorkshop(
        workshopId: 'ws_001',
        lat:        -6.9000,
        lng:        107.6000,
      )),
      expect: () => [
        const CheckinLoading(),
        const VolunteerError(message: 'You are outside the geofence radius.'),
      ],
    );
  });
}