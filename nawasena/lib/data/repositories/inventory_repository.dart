import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/inventory_model.dart';

class InventoryRepository {
  final Dio _dio = DioClient.instance;

  Future<List<InventoryModel>> getUrgentInventories() async {
    final response = await _dio.get(
      ApiConstants.inventories,
      queryParameters: {'urgent_level': 'high'},
    );

    final List data = response.data['data'] ?? response.data;
    return data.map((e) => InventoryModel.fromJson(e)).toList();
  }

  Future<List<InventoryModel>> getByFoundation(String foundationId) async {
    final response = await _dio.get(
      '/foundations/$foundationId/inventories',
    );
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => InventoryModel.fromJson(e)).toList();
  }
}