import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';

enum InventoryCategory { logistik, edukasi, medis, unknown }
enum UrgentLevel { high, medium, low, unknown }

extension InventoryCategoryX on InventoryCategory {
  String get label {
    switch (this) {
      case InventoryCategory.logistik: return 'Logistik';
      case InventoryCategory.edukasi:  return 'Edukasi';
      case InventoryCategory.medis:    return 'Medis';
      case InventoryCategory.unknown:  return '-';
    }
  }

  static InventoryCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'logistik': return InventoryCategory.logistik;
      case 'edukasi':  return InventoryCategory.edukasi;
      case 'medis':    return InventoryCategory.medis;
      default:         return InventoryCategory.unknown;
    }
  }
}

extension UrgentLevelX on UrgentLevel {
  String get label {
    switch (this) {
      case UrgentLevel.high:    return 'Mendesak';
      case UrgentLevel.medium:  return 'Sedang';
      case UrgentLevel.low:     return 'Rendah';
      case UrgentLevel.unknown: return '-';
    }
  }

  Color get color {
    switch (this) {
      case UrgentLevel.high:    return AppColors.urgentHigh;
      case UrgentLevel.medium:  return AppColors.urgentMedium;
      case UrgentLevel.low:     return AppColors.urgentLow;
      case UrgentLevel.unknown: return AppColors.textHint;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case UrgentLevel.high:    return AppColors.errorLight;
      case UrgentLevel.medium:  return AppColors.warningLight;
      case UrgentLevel.low:     return AppColors.successLight;
      case UrgentLevel.unknown: return AppColors.surfaceVariant;
    }
  }

  static UrgentLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'high':   return UrgentLevel.high;
      case 'medium': return UrgentLevel.medium;
      case 'low':    return UrgentLevel.low;
      default:       return UrgentLevel.unknown;
    }
  }
}

class InventoryModel extends Equatable {
  final String id;
  final String foundationId;
  final String itemName;
  final InventoryCategory category;
  final String unit;
  final int targetQty;
  final int currentQty;
  final UrgentLevel urgentLevel;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InventoryModel({
    required this.id,
    required this.foundationId,
    required this.itemName,
    required this.category,
    required this.unit,
    required this.targetQty,
    required this.currentQty,
    required this.urgentLevel,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id:           (json['_id'] ?? json['id'] ?? '').toString(),
      foundationId: json['foundation_id']?.toString() ?? '',
      itemName:     json['item_name']?.toString() ?? '',
      category:     InventoryCategoryX.fromString(json['category']?.toString() ?? ''),
      unit:         json['unit']?.toString() ?? '',
      targetQty:    (json['target_qty'] as num?)?.toInt() ?? 0,
      currentQty:   (json['current_qty'] as num?)?.toInt() ?? 0,
      urgentLevel:  UrgentLevelX.fromString(json['urgent_level']?.toString() ?? ''),
      description:  json['description']?.toString(),
      createdAt:    json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt:    json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':           id,
    'foundation_id': foundationId,
    'item_name':     itemName,
    'category':      category.label,
    'unit':          unit,
    'target_qty':    targetQty,
    'current_qty':   currentQty,
    'urgent_level':  urgentLevel.name,
    'description':   description,
    'created_at':    createdAt?.toIso8601String(),
    'updated_at':    updatedAt?.toIso8601String(),
  };

  /// Persentase pemenuhan kebutuhan (0.0 – 1.0)
  double get fulfillmentRatio {
    if (targetQty == 0) return 1.0;
    return (currentQty / targetQty).clamp(0.0, 1.0);
  }

  int get remainingQty => (targetQty - currentQty).clamp(0, targetQty);

  bool get isFulfilled => currentQty >= targetQty;

  @override
  List<Object?> get props => [
    id, foundationId, itemName, category, unit,
    targetQty, currentQty, urgentLevel, description,
    createdAt, updatedAt,
  ];
}