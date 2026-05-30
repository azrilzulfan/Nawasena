class DonationModel {
  final String id;
  final String foundationId;
  final String inventoryId;
  final String type;
  final Map<String, dynamic> itemDetail;
  final bool isAnonymous;
  final String status;
  final String? qrCodeHash;
  final List<Map<String, dynamic>> historyLogs;
  final DateTime? createdAt;

  const DonationModel({
    required this.id,
    required this.foundationId,
    required this.inventoryId,
    required this.type,
    required this.itemDetail,
    required this.isAnonymous,
    required this.status,
    this.qrCodeHash,
    this.historyLogs = const [],
    this.createdAt,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) => DonationModel(
        id: json['_id'] ?? json['id'] ?? '',
        foundationId: json['foundation_id'] ?? '',
        inventoryId: json['inventory_id'] ?? '',
        type: json['type'] ?? 'goods',
        itemDetail: Map<String, dynamic>.from(json['item_detail'] ?? {}),
        isAnonymous: json['is_anonymous'] ?? false,
        status: json['status'] ?? 'pending',
        qrCodeHash: json['qr_code_hash'],
        historyLogs: List<Map<String, dynamic>>.from(json['history_logs'] ?? []),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );

  String get referenceNumber =>
      'NWS-${id.substring(id.length > 6 ? id.length - 6 : 0).toUpperCase()}';

  String get itemName => itemDetail['name'] ?? '';
  int get itemQty => itemDetail['qty'] ?? 0;
  String get itemUnit => itemDetail['unit'] ?? '';
}