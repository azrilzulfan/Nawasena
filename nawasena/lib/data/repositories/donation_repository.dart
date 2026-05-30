import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/donation_model.dart';

class DonationRepository {
  final Dio _dio = DioClient.instance;

  Future<DonationModel> createDonation({
    required String foundationId,
    required String inventoryId,
    required String itemName,
    required int qty,
    required String unit,
    required bool isAnonymous,
    String? prayer,
  }) async {
    final response = await _dio.post(ApiConstants.donations, data: {
      'foundation_id': foundationId,
      'inventory_id': inventoryId,
      'type': 'goods',
      'item_detail': {'name': itemName, 'qty': qty, 'unit': unit},
      'is_anonymous': isAnonymous,
      if (prayer != null && prayer.isNotEmpty) 'prayer': prayer,
    });

    return DonationModel.fromJson(response.data['donation']);
  }

  Future<Map<String, dynamic>> getQrCode(String donationId) async {
    final response = await _dio.get(ApiConstants.donationQr(donationId));
    return response.data;
  }

  Future<DonationModel> getDonationDetail(String id) async {
    final response = await _dio.get('${ApiConstants.donations}/$id');
    return DonationModel.fromJson(response.data);
  }

  Future<List<DonationModel>> getMyDonations() async {
    final response = await _dio.get('${ApiConstants.donations}/me');
    final List data = response.data['data'] ?? response.data;
    return data.map((e) => DonationModel.fromJson(e)).toList();
  }
}