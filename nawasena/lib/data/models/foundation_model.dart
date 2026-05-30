class FoundationModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final bool isVerified;
  final Map<String, dynamic>? location;
  final String? contactPhone;
  final List<String> verificationDocs;

  const FoundationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.isVerified,
    this.location,
    this.contactPhone,
    this.verificationDocs = const [],
  });

  factory FoundationModel.fromJson(Map<String, dynamic> json) =>
      FoundationModel(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        address: json['address'] ?? '',
        isVerified: json['is_verified'] ?? false,
        location: json['location'],
        contactPhone: json['contact_phone'],
        verificationDocs: List<String>.from(json['verification_docs'] ?? []),
      );

  double? get latitude => location?['lat']?.toDouble();
  double? get longitude => location?['lng']?.toDouble();
}