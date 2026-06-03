import 'package:dio/dio.dart';
import 'package:nawasena_mobile/core/constants/api_constants.dart';
import 'package:nawasena_mobile/core/network/api_client.dart';
import 'package:nawasena_mobile/features/donor/data/models/donation_model.dart';
import 'package:nawasena_mobile/features/donor/data/repositories/foundation_repository.dart';

class DonationRepository {
  final ApiClient _api;

  DonationRepository({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  Future<PaginatedResult<DonationModel>> getMyDonations({
    String? status,
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (status != null) query['status'] = status;

    final data = await _api.get<Map<String, dynamic>>(
      ApiConstants.myDonations,
      queryParameters: query,
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
    final raw = data['data'] as List<dynamic>? ?? [];
    return PaginatedResult<DonationModel>(
      data:        raw.map((e) => DonationModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      total:       (data['total'] as num?)?.toInt() ?? 0,
      currentPage: (data['current_page'] as num?)?.toInt() ?? 1,
      lastPage:    (data['last_page'] as num?)?.toInt() ?? 1,
    );
  }

  Future<DonationModel> getDonationDetail(String id) async {
    return await _api.get<DonationModel>(
      ApiConstants.donationDetail(id),
      fromJson: (json) => DonationModel.fromJson(Map<String, dynamic>.from(json)),
    );
  }

  Future<DonationModel> createDonation({
    required String foundationId,
    required String inventoryId,
    required String type,
    required String itemName,
    required int qty,
    required String unit,
    bool isAnonymous = false,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      ApiConstants.donations,
      data: {
        'foundation_id': foundationId,
        'inventory_id':  inventoryId,
        'type':          type,
        'item_detail': {
          'name': itemName,
          'qty':  qty,
          'unit': unit,
        },
        'is_anonymous': isAnonymous,
      },
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
    return DonationModel.fromJson(Map<String, dynamic>.from(data['donation']));
  }

  Future<DonationModel> updateDonationStatus({
    required String donationId,
    required String status,
    String? note,
    String? proofImageUrl,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (note          != null) body['note']        = note;
    if (proofImageUrl != null) body['proof_image'] = proofImageUrl;

    final data = await _api.patch<Map<String, dynamic>>(
      ApiConstants.donationUpdateStatus(donationId),
      data: body,
      fromJson: (json) => Map<String, dynamic>.from(json),
    );
    return DonationModel.fromJson(Map<String, dynamic>.from(data['donation']));
  }

  Future<QrCodeModel> getDonationQr(String donationId) async {
    return await _api.get<QrCodeModel>(
      ApiConstants.donationQr(donationId),
      fromJson: (json) => QrCodeModel.fromJson(Map<String, dynamic>.from(json)),
    );
  }

  Future<String> uploadProofImage(String filePath) async {
    final formData = FormData.fromMap({
      'file':   await MultipartFile.fromFile(filePath, filename: 'proof.jpg'),
      'folder': 'donations',
    });
    return await _api.uploadFile(ApiConstants.uploads, formData);
  }
}