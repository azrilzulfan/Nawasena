import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/foundation_model.dart';

class FoundationRepository {
  final Dio _dio = DioClient.instance;

  Future<List<FoundationModel>> getFoundations({
    String? search,
    String? area,
    String? filterType,
  }) async {
    final response = await _dio.get(
      ApiConstants.foundations,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (area != null && area != 'Semua Area') 'area': area,
        if (filterType != null) 'type': filterType,
      },
    );

    final List data = response.data['data'] ?? response.data;
    return data.map((e) => FoundationModel.fromJson(e)).toList();
  }

  Future<FoundationModel> getFoundationDetail(String id) async {
    final response = await _dio.get(ApiConstants.foundationDetail(id));
    return FoundationModel.fromJson(response.data);
  }
}