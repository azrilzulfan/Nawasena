import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';

enum DonationStatus { pending, sent, received, verified, unknown }

extension DonationStatusX on DonationStatus {
  String get label {
    switch (this) {
      case DonationStatus.pending:  return 'Menunggu';
      case DonationStatus.sent:     return 'Dikirim';
      case DonationStatus.received: return 'Diterima';
      case DonationStatus.verified: return 'Terverifikasi';
      case DonationStatus.unknown:  return '-';
    }
  }

  Color get color {
    switch (this) {
      case DonationStatus.pending:  return AppColors.statusPending;
      case DonationStatus.sent:     return AppColors.statusSent;
      case DonationStatus.received: return AppColors.statusReceived;
      case DonationStatus.verified: return AppColors.statusVerified;
      case DonationStatus.unknown:  return AppColors.textHint;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case DonationStatus.pending:  return AppColors.warningLight;
      case DonationStatus.sent:     return AppColors.infoLight;
      case DonationStatus.received: return const Color(0xFFF3E5F5);
      case DonationStatus.verified: return AppColors.successLight;
      case DonationStatus.unknown:  return AppColors.surfaceVariant;
    }
  }

  static DonationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':  return DonationStatus.pending;
      case 'sent':     return DonationStatus.sent;
      case 'received': return DonationStatus.received;
      case 'verified': return DonationStatus.verified;
      default:         return DonationStatus.unknown;
    }
  }
}

class DonationItemDetail extends Equatable {
  final String name;
  final int qty;
  final String unit;

  const DonationItemDetail({
    required this.name,
    required this.qty,
    required this.unit,
  });

  factory DonationItemDetail.fromJson(Map<String, dynamic> json) {
    return DonationItemDetail(
      name: json['name']?.toString() ?? '',
      qty:  (json['qty'] as num?)?.toInt() ?? 0,
      unit: json['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'qty':  qty,
    'unit': unit,
  };

  @override
  List<Object?> get props => [name, qty, unit];
}

class DonationHistoryLog extends Equatable {
  final DonationStatus status;
  final DateTime timestamp;
  final String note;
  final String? proofImage;

  const DonationHistoryLog({
    required this.status,
    required this.timestamp,
    required this.note,
    this.proofImage,
  });

  factory DonationHistoryLog.fromJson(Map<String, dynamic> json) {
    return DonationHistoryLog(
      status: DonationStatusX.fromString(json['status']?.toString() ?? ''),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      note:       json['note']?.toString() ?? '',
      proofImage: json['proof_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status':      status.name,
    'timestamp':   timestamp.toIso8601String(),
    'note':        note,
    'proof_image': proofImage,
  };

  @override
  List<Object?> get props => [status, timestamp, note, proofImage];
}

class DonationModel extends Equatable {
  final String id;
  final String foundationId;
  final String inventoryId;
  final String donorId;
  final String type;
  final DonationItemDetail itemDetail;
  final DonationStatus status;
  final bool isAnonymous;
  final String? qrCodeHash;
  final List<DonationHistoryLog> historyLogs;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DonationModel({
    required this.id,
    required this.foundationId,
    required this.inventoryId,
    required this.donorId,
    required this.type,
    required this.itemDetail,
    required this.status,
    this.isAnonymous = false,
    this.qrCodeHash,
    this.historyLogs = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    final logsRaw = json['history_logs'] as List<dynamic>? ?? [];
    return DonationModel(
      id:           (json['_id'] ?? json['id'] ?? '').toString(),
      foundationId: json['foundation_id']?.toString() ?? '',
      inventoryId:  json['inventory_id']?.toString() ?? '',
      donorId:      json['donor_id']?.toString() ?? '',
      type:         json['type']?.toString() ?? 'goods',
      itemDetail:   DonationItemDetail.fromJson(
        Map<String, dynamic>.from(json['item_detail'] ?? {}),
      ),
      status:       DonationStatusX.fromString(json['status']?.toString() ?? ''),
      isAnonymous:  json['is_anonymous'] as bool? ?? false,
      qrCodeHash:   json['qr_code_hash']?.toString(),
      historyLogs:  logsRaw
          .map((e) => DonationHistoryLog.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt:    json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt:    json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':          id,
    'foundation_id': foundationId,
    'inventory_id':  inventoryId,
    'donor_id':      donorId,
    'type':          type,
    'item_detail':   itemDetail.toJson(),
    'status':        status.name,
    'is_anonymous':  isAnonymous,
    'qr_code_hash':  qrCodeHash,
    'history_logs':  historyLogs.map((l) => l.toJson()).toList(),
    'created_at':    createdAt?.toIso8601String(),
    'updated_at':    updatedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id, foundationId, inventoryId, donorId, type,
    itemDetail, status, isAnonymous, qrCodeHash,
    historyLogs, createdAt, updatedAt,
  ];
}

class QrCodeModel extends Equatable {
  final String donationId;
  final String qrCodeHash;
  final DonationStatus status;
  final DateTime? expiresAt;

  const QrCodeModel({
    required this.donationId,
    required this.qrCodeHash,
    required this.status,
    this.expiresAt,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      donationId:  json['donation_id']?.toString() ?? '',
      qrCodeHash:  json['qr_code_hash']?.toString() ?? '',
      status:      DonationStatusX.fromString(json['status']?.toString() ?? ''),
      expiresAt:   json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [donationId, qrCodeHash, status, expiresAt];
}