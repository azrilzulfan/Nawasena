import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawasena_mobile/core/error/exceptions.dart';
import 'package:nawasena_mobile/features/donor/data/repositories/donation_repository.dart';
import 'package:nawasena_mobile/features/donor/data/repositories/foundation_repository.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_event.dart';
import 'package:nawasena_mobile/features/donor/presentation/bloc/donor_state.dart';

class DonorBloc extends Bloc<DonorEvent, DonorState> {
  final FoundationRepository _foundationRepository;
  final DonationRepository   _donationRepository;

  DonorBloc({
    required this._foundationRepository,
    required this._donationRepository,
  })  : super(const DonorInitial()) {
    on<LoadNearbyFoundations>(_onLoadNearbyFoundations);
    on<LoadGlobalInventories>(_onLoadGlobalInventories);
    on<LoadFoundationDetail>(_onLoadFoundationDetail);
    on<LoadInventoryDetail>(_onLoadInventoryDetail);
    on<SubmitDonationPledge>(_onSubmitDonationPledge);
    on<LoadMyDonations>(_onLoadMyDonations);
    on<LoadDonationDetail>(_onLoadDonationDetail);
    on<UpdateDonationToSent>(_onUpdateDonationToSent);
    on<LoadDonationQr>(_onLoadDonationQr);
  }

  Future<void> _onLoadNearbyFoundations(
      LoadNearbyFoundations event,
      Emitter<DonorState> emit,
      ) async {
    emit(const NearbyFoundationsLoading());
    try {
      final foundations = await _foundationRepository.getNearbyFoundations(
        lat: event.lat,
        lng: event.lng,
      );
      emit(NearbyFoundationsLoaded(foundations: foundations));
    } on NetworkException catch (e) {
      emit(DonorError(message: e.message));
    } on ServerException catch (e) {
      emit(DonorError(message: e.message));
    } catch (e) {
      emit(DonorError(message: e.toString()));
    }
  }

  Future<void> _onLoadGlobalInventories(
      LoadGlobalInventories event,
      Emitter<DonorState> emit,
      ) async {
    emit(const GlobalInventoriesLoading());
    try {
      final result = await _foundationRepository.getGlobalInventories(
        category:    event.category,
        urgentLevel: event.urgentLevel,
        page:        event.page,
      );
      emit(GlobalInventoriesLoaded(
        inventories: result.data,
        hasMore:     result.currentPage < result.lastPage,
      ));
    } on ServerException catch (e) {
      emit(DonorError(message: e.message));
    } catch (e) {
      emit(DonorError(message: e.toString()));
    }
  }

  Future<void> _onLoadFoundationDetail(
      LoadFoundationDetail event,
      Emitter<DonorState> emit,
      ) async {
    emit(const FoundationDetailLoading());
    try {
      final foundation = await _foundationRepository.getFoundationDetail(event.foundationId);
      final inventories = await _foundationRepository.getFoundationInventories(event.foundationId);
      emit(FoundationDetailLoaded(foundation: foundation, inventories: inventories));
    } on ServerException catch (e) {
      emit(DonorError(message: e.message));
    } catch (e) {
      emit(DonorError(message: e.toString()));
    }
  }

  Future<void> _onLoadInventoryDetail(
      LoadInventoryDetail event,
      Emitter<DonorState> emit,
      ) async {
    emit(const InventoryDetailLoading());
    try {
      final inventory = await _foundationRepository.getInventoryDetail(event.inventoryId);
      emit(InventoryDetailLoaded(inventory: inventory));
    } on ServerException catch (e) {
      emit(DonorError(message: e.message));
    } catch (e) {
      emit(DonorError(message: e.toString()));
    }
  }

  Future<void> _onSubmitDonationPledge(
      SubmitDonationPledge event,
      Emitter<DonorState> emit,
      ) async {
    emit(const DonationPledgeLoading());
    try {
      final donation = await _donationRepository.createDonation(
        foundationId: event.foundationId,
        inventoryId:  event.inventoryId,
        type:         'goods',
        itemName:     event.itemName,
        qty:          event.qty,
        unit:         event.unit,
        isAnonymous:  event.isAnonymous,
      );
      emit(DonationPledgeSuccess(donation: donation));
    } on ValidationException catch (e) {
      emit(DonorError(message: e.firstError));
    } on ServerException catch (e) {
      emit(DonorError(message: e.message));
    } catch (e) {
      emit(DonorError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyDonations(
      LoadMyDonations event,
      Emitter<DonorState> emit,
      ) async {
    emit(const MyDonationsLoading());
    try {
      final result = await _donationRepository.getMyDonations(status: event.status);
      emit(MyDonationsLoaded(donations: result.data));
    } on ServerException catch (e) {
      emit(DonorError(message: e.message));
    } catch (e) {
      emit(DonorError(message: e.toString()));
    }
  }

  Future<void> _onLoadDonationDetail(
      LoadDonationDetail event,
      Emitter<DonorState> emit,
      ) async {
    emit(const DonationDetailLoading());
    try {
      final donation = await _donationRepository.getDonationDetail(event.donationId);
      emit(DonationDetailLoaded(donation: donation));
    } on ServerException catch (e) {
      emit(DonorError(message: e.message));
    } catch (e) {
      emit(DonorError(message: e.toString()));
    }
  }

  Future<void> _onUpdateDonationToSent(
      UpdateDonationToSent event,
      Emitter<DonorState> emit,
      ) async {
    emit(const DonationDetailLoading());
    try {
      String? proofUrl;
      if (event.proofImagePath != null) {
        proofUrl = await _donationRepository.uploadProofImage(event.proofImagePath!);
      }
      final donation = await _donationRepository.updateDonationStatus(
        donationId:    event.donationId,
        status:        'sent',
        note:          'Pengirim telah mengirimkan paket donasi',
        proofImageUrl: proofUrl,
      );
      emit(DonationStatusUpdated(donation: donation));
    } on ServerException catch (e) {
      emit(DonorError(message: e.message));
    } catch (e) {
      emit(DonorError(message: e.toString()));
    }
  }

  Future<void> _onLoadDonationQr(
      LoadDonationQr event,
      Emitter<DonorState> emit,
      ) async {
    emit(const DonationQrLoading());
    try {
      final qr = await _donationRepository.getDonationQr(event.donationId);
      emit(DonationQrLoaded(qrCode: qr));
    } on ServerException catch (e) {
      emit(DonorError(message: e.message));
    } catch (e) {
      emit(DonorError(message: e.toString()));
    }
  }
}