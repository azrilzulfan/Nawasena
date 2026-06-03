import 'package:equatable/equatable.dart';
import 'package:nawasena_mobile/features/donor/data/models/donation_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/foundation_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/inventory_model.dart';

abstract class DonorState extends Equatable {
  const DonorState();
  @override
  List<Object?> get props => [];
}

class DonorInitial extends DonorState {
  const DonorInitial();
}

// ── Loading States ─────────────────────────────────────────────────────────
class NearbyFoundationsLoading extends DonorState {
  const NearbyFoundationsLoading();
}

class GlobalInventoriesLoading extends DonorState {
  const GlobalInventoriesLoading();
}

class FoundationDetailLoading extends DonorState {
  const FoundationDetailLoading();
}

class InventoryDetailLoading extends DonorState {
  const InventoryDetailLoading();
}

class DonationPledgeLoading extends DonorState {
  const DonationPledgeLoading();
}

class MyDonationsLoading extends DonorState {
  const MyDonationsLoading();
}

class DonationDetailLoading extends DonorState {
  const DonationDetailLoading();
}

class DonationQrLoading extends DonorState {
  const DonationQrLoading();
}

// ── Success States ─────────────────────────────────────────────────────────
class NearbyFoundationsLoaded extends DonorState {
  final List<FoundationModel> foundations;
  const NearbyFoundationsLoaded({required this.foundations});
  @override
  List<Object?> get props => [foundations];
}

class GlobalInventoriesLoaded extends DonorState {
  final List<InventoryModel> inventories;
  final bool hasMore;
  const GlobalInventoriesLoaded({required this.inventories, required this.hasMore});
  @override
  List<Object?> get props => [inventories, hasMore];
}

class FoundationDetailLoaded extends DonorState {
  final FoundationModel foundation;
  final List<InventoryModel> inventories;
  const FoundationDetailLoaded({required this.foundation, required this.inventories});
  @override
  List<Object?> get props => [foundation, inventories];
}

class InventoryDetailLoaded extends DonorState {
  final InventoryModel inventory;
  const InventoryDetailLoaded({required this.inventory});
  @override
  List<Object?> get props => [inventory];
}

class DonationPledgeSuccess extends DonorState {
  final DonationModel donation;
  const DonationPledgeSuccess({required this.donation});
  @override
  List<Object?> get props => [donation];
}

class MyDonationsLoaded extends DonorState {
  final List<DonationModel> donations;
  const MyDonationsLoaded({required this.donations});
  @override
  List<Object?> get props => [donations];
}

class DonationDetailLoaded extends DonorState {
  final DonationModel donation;
  const DonationDetailLoaded({required this.donation});
  @override
  List<Object?> get props => [donation];
}

class DonationStatusUpdated extends DonorState {
  final DonationModel donation;
  const DonationStatusUpdated({required this.donation});
  @override
  List<Object?> get props => [donation];
}

class DonationQrLoaded extends DonorState {
  final QrCodeModel qrCode;
  const DonationQrLoaded({required this.qrCode});
  @override
  List<Object?> get props => [qrCode];
}

// ── Error States ───────────────────────────────────────────────────────────
class DonorError extends DonorState {
  final String message;
  const DonorError({required this.message});
  @override
  List<Object?> get props => [message];
}