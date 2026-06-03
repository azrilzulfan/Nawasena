import 'package:equatable/equatable.dart';

class GeoLocation extends Equatable {
  final String type;
  final List<double> coordinates; // [lng, lat]

  const GeoLocation({
    this.type = 'Point',
    required this.coordinates,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    final raw = json['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    return GeoLocation(
      type: json['type']?.toString() ?? 'Point',
      coordinates: raw.map((e) => (e as num).toDouble()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'coordinates': coordinates,
  };

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get latitude  => coordinates.length > 1 ? coordinates[1] : 0.0;

  @override
  List<Object?> get props => [type, coordinates];
}

class BankAccount extends Equatable {
  final String bankName;
  final String accountNumber;
  final String accountName;

  const BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      bankName:      json['bank_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      accountName:   json['account_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'bank_name':      bankName,
    'account_number': accountNumber,
    'account_name':   accountName,
  };

  @override
  List<Object?> get props => [bankName, accountNumber, accountName];
}

class FoundationModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String address;
  final String contactPhone;
  final GeoLocation? location;
  final BankAccount? bankAccount;
  final List<String> verificationDocs;
  final bool isVerified;
  final String? adminId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FoundationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.contactPhone,
    this.location,
    this.bankAccount,
    this.verificationDocs = const [],
    this.isVerified = false,
    this.adminId,
    this.createdAt,
    this.updatedAt,
  });

  factory FoundationModel.fromJson(Map<String, dynamic> json) {
    return FoundationModel(
      id:           (json['_id'] ?? json['id'] ?? '').toString(),
      name:         json['name']?.toString() ?? '',
      description:  json['description']?.toString() ?? '',
      address:      json['address']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
      location: json['location'] != null
          ? GeoLocation.fromJson(Map<String, dynamic>.from(json['location']))
          : null,
      bankAccount: json['bank_account'] != null
          ? BankAccount.fromJson(Map<String, dynamic>.from(json['bank_account']))
          : null,
      verificationDocs: json['verification_docs'] != null
          ? List<String>.from(json['verification_docs'])
          : [],
      isVerified: json['is_verified'] as bool? ?? false,
      adminId:    json['admin_id']?.toString(),
      createdAt:  json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt:  json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':              id,
    'name':             name,
    'description':      description,
    'address':          address,
    'contact_phone':    contactPhone,
    'location':         location?.toJson(),
    'bank_account':     bankAccount?.toJson(),
    'verification_docs': verificationDocs,
    'is_verified':      isVerified,
    'admin_id':         adminId,
    'created_at':       createdAt?.toIso8601String(),
    'updated_at':       updatedAt?.toIso8601String(),
  };

  FoundationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? contactPhone,
    GeoLocation? location,
    BankAccount? bankAccount,
    List<String>? verificationDocs,
    bool? isVerified,
    String? adminId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FoundationModel(
      id:              id ?? this.id,
      name:            name ?? this.name,
      description:     description ?? this.description,
      address:         address ?? this.address,
      contactPhone:    contactPhone ?? this.contactPhone,
      location:        location ?? this.location,
      bankAccount:     bankAccount ?? this.bankAccount,
      verificationDocs: verificationDocs ?? this.verificationDocs,
      isVerified:      isVerified ?? this.isVerified,
      adminId:         adminId ?? this.adminId,
      createdAt:       createdAt ?? this.createdAt,
      updatedAt:       updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, description, address, contactPhone,
    location, bankAccount, verificationDocs, isVerified,
    adminId, createdAt, updatedAt,
  ];
}