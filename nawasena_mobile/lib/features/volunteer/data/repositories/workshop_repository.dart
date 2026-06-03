import 'package:nawasena_mobile/core/constants/api_constants.dart';
import 'package:nawasena_mobile/core/network/api_client.dart';
import 'package:nawasena_mobile/features/donor/data/repositories/foundation_repository.dart';
import 'package:nawasena_mobile/features/volunteer/data/models/workshop_model.dart';

class WorkshopRepository {
  final ApiClient _api;

  WorkshopRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  Future<PaginatedResult<WorkshopModel>> getGlobalWorkshops({
    String? status,
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (status != null) query['status'] = status;

    final data = await _api.get<Map<String, dynamic>>(
      ApiConstants.workshops,
      queryParameters: query,
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
    final raw = data['data'] as List<dynamic>? ?? [];
    return PaginatedResult<WorkshopModel>(
      data:        raw.map((e) => WorkshopModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      total:       (data['total'] as num?)?.toInt() ?? 0,
      currentPage: (data['current_page'] as num?)?.toInt() ?? 1,
      lastPage:    (data['last_page'] as num?)?.toInt() ?? 1,
    );
  }

  Future<List<WorkshopModel>> getFoundationWorkshops(String foundationId) async {
    final data = await _api.get<List<dynamic>>(
      ApiConstants.foundationWorkshops(foundationId),
      fromJson: (json) => json as List<dynamic>,
    );
    return data
        .map((e) => WorkshopModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<WorkshopModel> getWorkshopDetail(String id) async {
    return await _api.get<WorkshopModel>(
      ApiConstants.workshopDetail(id),
      fromJson: (json) => WorkshopModel.fromJson(Map<String, dynamic>.from(json)),
    );
  }

  Future<void> registerWorkshop(String workshopId) async {
    await _api.post<void>(ApiConstants.workshopRegister(workshopId));
  }

  Future<void> unregisterWorkshop(String workshopId) async {
    await _api.delete<void>(ApiConstants.workshopUnregister(workshopId));
  }

  Future<Map<String, dynamic>> checkinWorkshop({
    required String workshopId,
    required double lat,
    required double lng,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      ApiConstants.workshopCheckin(workshopId),
      data: {'lat': lat, 'lng': lng},
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
  }
}