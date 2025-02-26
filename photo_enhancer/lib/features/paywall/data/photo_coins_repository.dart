import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/core/api/dio_api_client.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';
import 'package:photo_enhancer/features/paywall/data/verify_purchase_request.dart';
import 'package:photo_enhancer/features/paywall/data/verify_purchase_response.dart';

class PhotoCoinsRepository {
  final DioApiClient dioApiClient;

  PhotoCoinsRepository({required this.dioApiClient});

  Future<VerifyPurchaseResponse> verifyPurchase({required VerifyPurchaseRequest request}) async {
    try {
      final response = await dioApiClient.post<Map<String, dynamic>>(
        AppInitializer.getStringEnv(EnvKeys.verifyPurchaseUrl),
        data: request.toJson(),
      );
      if (response != null) {
        return VerifyPurchaseResponse.fromJson(response);
      }
      return VerifyPurchaseResponse(success: false);
    } catch (e) {
      return VerifyPurchaseResponse(success: false);
    }
  }
}
