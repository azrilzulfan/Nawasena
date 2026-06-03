import 'package:nawasena_mobile/core/constants/api_constants.dart';
import 'package:nawasena_mobile/core/network/api_client.dart';
import 'package:nawasena_mobile/features/donor/data/models/foundation_model.dart';
import 'package:nawasena_mobile/features/donor/data/models/inventory_model.dart';
import 'package:dio/dio.dart';

class PaginatedResult<T> {
  final List<T> data;
  final int total;
  final int currentPage;
  final int lastPage;

  const PaginatedResult({
    required this.data,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });
}

class FoundationRepository {
  final ApiClient _api;

  FoundationRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  Future<PaginatedResult<FoundationModel>> getFoundations({
    String? search,
    bool? isVerified,
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (search    != null) query['search']      = search;
    if (isVerified != null) query['is_verified'] = isVerified;

    final data = await _api.get<Map<String, dynamic>>(
      ApiConstants.foundations,
      queryParameters: query,
      fromJson: (json) => Map<String, dynamic>.from(json),
      options: Options(extra: {'requireAuth': false}),
    );
    return _parsePaginated<FoundationModel>(
      data,
          (item) => FoundationModel.fromJson(Map<String, dynamic>.from(item)),
    );
  }

  Future<List<FoundationModel>> getNearbyFoundations({
    required double lat,
    required double lng,
    int radiusMeters = 5000,
  }) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiConstants.foundationsNearby,
      queryParameters: {
        'lat':    lat,
        'lng':    lng,
        'radius': radiusMeters,
      },
      fromJson: (json) => Map<String, dynamic>.from(json),
      options: Options(extra: {'requireAuth': false}),
    );
    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => FoundationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<FoundationModel> getFoundationDetail(String id) async {
    return await _api.get<FoundationModel>(
      ApiConstants.foundationDetail(id),
      fromJson: (json) => FoundationModel.fromJson(Map<String, dynamic>.from(json)),
    );
  }

  Future<List<InventoryModel>> getFoundationInventories(String foundationId) async {
    final data = await _api.get<List<dynamic>>(
      ApiConstants.foundationInventories(foundationId),
      fromJson: (json) => json as List<dynamic>,
    );
    return data
        .map((e) => InventoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<PaginatedResult<InventoryModel>> getGlobalInventories({
    String? category,
    String? urgentLevel,
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (category    != null) query['category']     = category;
    if (urgentLevel != null) query['urgent_level']  = urgentLevel;

    final data = await _api.get<Map<String, dynamic>>(
      ApiConstants.inventories,
      queryParameters: query,
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
    return _parsePaginated<InventoryModel>(
      data,
          (item) => InventoryModel.fromJson(Map<String, dynamic>.from(item)),
    );
  }

  Future<InventoryModel> getInventoryDetail(String id) async {
    return await _api.get<InventoryModel>(
      ApiConstants.inventoryDetail(id),
      fromJson: (json) => InventoryModel.fromJson(Map<String, dynamic>.from(json)),
    );
  }

  PaginatedResult<T> _parsePaginated<T>(
      Map<String, dynamic> json,
      T Function(dynamic) fromItem,
      ) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    return PaginatedResult<T>(
      data:        rawData.map(fromItem).toList(),
      total:       (json['total'] as num?)?.toInt() ?? 0,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage:    (json['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}