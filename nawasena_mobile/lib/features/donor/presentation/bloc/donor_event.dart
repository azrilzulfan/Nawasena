import 'package:equatable/equatable.dart';

abstract class DonorEvent extends Equatable {
  const DonorEvent();
  @override
  List<Object?> get props => [];
}

class LoadNearbyFoundations extends DonorEvent {
  final double lat;
  final double lng;
  const LoadNearbyFoundations({required this.lat, required this.lng});
  @override
  List<Object?> get props => [lat, lng];
}

class LoadGlobalInventories extends DonorEvent {
  final String? category;
  final String? urgentLevel;
  final int page;
  const LoadGlobalInventories({this.category, this.urgentLevel, this.page = 1});
  @override
  List<Object?> get props => [category, urgentLevel, page];
}

class LoadFoundationDetail extends DonorEvent {
  final String foundationId;
  const LoadFoundationDetail({required this.foundationId});
  @override
  List<Object?> get props => [foundationId];
}

class LoadInventoryDetail extends DonorEvent {
  final String inventoryId;
  const LoadInventoryDetail({required this.inventoryId});
  @override
  List<Object?> get props => [inventoryId];
}

class SubmitDonationPledge extends DonorEvent {
  final String foundationId;
  final String inventoryId;
  final String itemName;
  final int qty;
  final String unit;
  final bool isAnonymous;

  const SubmitDonationPledge({
    required this.foundationId,
    required this.inventoryId,
    required this.itemName,
    required this.qty,
    required this.unit,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [foundationId, inventoryId, itemName, qty, unit, isAnonymous];
}

class LoadMyDonations extends DonorEvent {
  final String? status;
  const LoadMyDonations({this.status});
  @override
  List<Object?> get props => [status];
}

class LoadDonationDetail extends DonorEvent {
  final String donationId;
  const LoadDonationDetail({required this.donationId});
  @override
  List<Object?> get props => [donationId];
}

class UpdateDonationToSent extends DonorEvent {
  final String donationId;
  final String? proofImagePath;
  const UpdateDonationToSent({required this.donationId, this.proofImagePath});
  @override
  List<Object?> get props => [donationId, proofImagePath];
}

class LoadDonationQr extends DonorEvent {
  final String donationId;
  const LoadDonationQr({required this.donationId});
  @override
  List<Object?> get props => [donationId];
}