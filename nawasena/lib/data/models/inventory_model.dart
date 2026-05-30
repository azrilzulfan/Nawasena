class InventoryModel {
  final String id;
  final String foundationId;
  final String itemName;
  final String category;
  final String unit;
  final int targetQty;
  final int currentQty;
  final String urgentLevel; 
  final String? description;
  final String? imageUrl;

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
    this.imageUrl,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) =>
      InventoryModel(
        id: json['_id'] ?? json['id'] ?? '',
        foundationId: json['foundation_id'] ?? '',
        itemName: json['item_name'] ?? '',
        category: json['category'] ?? '',
        unit: json['unit'] ?? '',
        targetQty: json['target_qty'] ?? 0,
        currentQty: json['current_qty'] ?? 0,
        urgentLevel: json['urgent_level'] ?? 'low',
        description: json['description'],
        imageUrl: json['image_url'],
      );

  bool get isCritical => urgentLevel == 'high';
  int get neededQty => targetQty - currentQty;
}