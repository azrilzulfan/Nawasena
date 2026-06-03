import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nawasena_mobile/core/error/exceptions.dart';
import 'package:nawasena_mobile/features/donor/data/models/donation_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/foundation_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/inventory_model.dart';
import 'package:nawasena_mobile/features/donor/data/repositories/donation_repository.dart';
import 'package:nawasena_mobile/features/donor/data/repositories/foundation_repository.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_bloc.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockFoundationRepository extends Mock implements FoundationRepository {}
class MockDonationRepository   extends Mock implements DonationRepository {}

// ── Fixtures ──────────────────────────────────────────────────────────────────
final _mockFoundation = FoundationModel(
  id:           'found_001',
  name:         'Panti Kasih Bunda',
  description:  'Panti asuhan terpercaya di Jakarta',
  address:      'Jl. Mawar No. 5, Jakarta',
  contactPhone: '02112345678',
  isVerified:   true,
);

final _mockInventory = InventoryModel(
  id:           'inv_001',
  foundationId: 'found_001',
  itemName:     'Beras 5 kg',
  category:     InventoryCategory.logistik,
  unit:         'karung',
  targetQty:    50,
  currentQty:   10,
  urgentLevel:  UrgentLevel.high,
);

final _mockDonation = DonationModel(
  id:           'don_001',
  foundationId: 'found_001',
  inventoryId:  'inv_001',
  donorId:      'user_001',
  type:         'goods',
  itemDetail:   const DonationItemDetail(name: 'Beras 5 kg', qty: 5, unit: 'karung'),
  status:       DonationStatus.pending,
);

final _paginatedInventories = PaginatedResult<InventoryModel>(
  data:        [_mockInventory],
  total:       1,
  currentPage: 1,
  lastPage:    1,
);

final _paginatedDonations = PaginatedResult<DonationModel>(
  data:        [_mockDonation],
  total:       1,
  currentPage: 1,
  lastPage:    1,
);

void main() {
  late MockFoundationRepository mockFoundRepo;
  late MockDonationRepository   mockDonRepo;

  setUp(() {
    mockFoundRepo = MockFoundationRepository();
    mockDonRepo   = MockDonationRepository();
  });

  DonorBloc buildBloc() => DonorBloc(
    foundationRepository: mockFoundRepo,
    donationRepository:   mockDonRepo,
  );

  // ── LoadNearbyFoundations ──────────────────────────────────────────────────
  group('LoadNearbyFoundations', () {
    blocTest<DonorBloc, DonorState>(
      'emits [NearbyFoundationsLoading, NearbyFoundationsLoaded] on success',
      build: () {
        when(() => mockFoundRepo.getNearbyFoundations(
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
        )).thenAnswer((_) async => [_mockFoundation]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoadNearbyFoundations(lat: -6.2, lng: 106.8),
      ),
      expect: () => [
        const NearbyFoundationsLoading(),
        NearbyFoundationsLoaded(foundations: [_mockFoundation]),
      ],
    );

    blocTest<DonorBloc, DonorState>(
      'emits [NearbyFoundationsLoading, DonorError] on network failure',
      build: () {
        when(() => mockFoundRepo.getNearbyFoundations(
          lat: any(named: 'lat'),
          lng: any(named: 'lng'),
        )).thenThrow(const NetworkException(message: 'No connection.'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoadNearbyFoundations(lat: -6.2, lng: 106.8),
      ),
      expect: () => [
        const NearbyFoundationsLoading(),
        const DonorError(message: 'No connection.'),
      ],
    );
  });

  // ── LoadGlobalInventories ──────────────────────────────────────────────────
  group('LoadGlobalInventories', () {
    blocTest<DonorBloc, DonorState>(
      'emits [GlobalInventoriesLoading, GlobalInventoriesLoaded] on success',
      build: () {
        when(() => mockFoundRepo.getGlobalInventories(
          category:    any(named: 'category'),
          urgentLevel: any(named: 'urgentLevel'),
          page:        any(named: 'page'),
        )).thenAnswer((_) async => _paginatedInventories);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadGlobalInventories()),
      expect: () => [
        const GlobalInventoriesLoading(),
        GlobalInventoriesLoaded(
          inventories: [_mockInventory],
          hasMore:     false,
        ),
      ],
    );
  });

  // ── LoadFoundationDetail ───────────────────────────────────────────────────
  group('LoadFoundationDetail', () {
    blocTest<DonorBloc, DonorState>(
      'emits [FoundationDetailLoading, FoundationDetailLoaded] on success',
      build: () {
        when(() => mockFoundRepo.getFoundationDetail('found_001'))
            .thenAnswer((_) async => _mockFoundation);
        when(() => mockFoundRepo.getFoundationInventories('found_001'))
            .thenAnswer((_) async => [_mockInventory]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const LoadFoundationDetail(foundationId: 'found_001'),
      ),
      expect: () => [
        const FoundationDetailLoading(),
        FoundationDetailLoaded(
          foundation:  _mockFoundation,
          inventories: [_mockInventory],
        ),
      ],
    );
  });

  // ── SubmitDonationPledge ───────────────────────────────────────────────────
  group('SubmitDonationPledge', () {
    blocTest<DonorBloc, DonorState>(
      'emits [DonationPledgeLoading, DonationPledgeSuccess] on success',
      build: () {
        when(() => mockDonRepo.createDonation(
          foundationId: any(named: 'foundationId'),
          inventoryId:  any(named: 'inventoryId'),
          type:         any(named: 'type'),
          itemName:     any(named: 'itemName'),
          qty:          any(named: 'qty'),
          unit:         any(named: 'unit'),
          isAnonymous:  any(named: 'isAnonymous'),
        )).thenAnswer((_) async => _mockDonation);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SubmitDonationPledge(
        foundationId: 'found_001',
        inventoryId:  'inv_001',
        itemName:     'Beras 5 kg',
        qty:          5,
        unit:         'karung',
      )),
      expect: () => [
        const DonationPledgeLoading(),
        DonationPledgeSuccess(donation: _mockDonation),
      ],
    );

    blocTest<DonorBloc, DonorState>(
      'emits [DonationPledgeLoading, DonorError] on validation error',
      build: () {
        when(() => mockDonRepo.createDonation(
          foundationId: any(named: 'foundationId'),
          inventoryId:  any(named: 'inventoryId'),
          type:         any(named: 'type'),
          itemName:     any(named: 'itemName'),
          qty:          any(named: 'qty'),
          unit:         any(named: 'unit'),
          isAnonymous:  any(named: 'isAnonymous'),
        )).thenThrow(const ValidationException(errors: {
          'qty': ['The qty must be at least 1.'],
        }));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SubmitDonationPledge(
        foundationId: 'found_001',
        inventoryId:  'inv_001',
        itemName:     'Beras',
        qty:          0,
        unit:         'karung',
      )),
      expect: () => [
        const DonationPledgeLoading(),
        const DonorError(message: 'The qty must be at least 1.'),
      ],
    );
  });

  // ── LoadMyDonations ────────────────────────────────────────────────────────
  group('LoadMyDonations', () {
    blocTest<DonorBloc, DonorState>(
      'emits [MyDonationsLoading, MyDonationsLoaded] on success',
      build: () {
        when(() => mockDonRepo.getMyDonations(
          status: any(named: 'status'),
        )).thenAnswer((_) async => _paginatedDonations);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadMyDonations()),
      expect: () => [
        const MyDonationsLoading(),
        MyDonationsLoaded(donations: [_mockDonation]),
      ],
    );
  });
}