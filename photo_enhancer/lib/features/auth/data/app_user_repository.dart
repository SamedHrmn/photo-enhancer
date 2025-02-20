import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/common/helpers/photo_enhancer_channel_helper.dart';
import 'package:photo_enhancer/common/helpers/shared_pref_manager.dart';
import 'package:photo_enhancer/core/api/dio_api_client.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';
import 'package:photo_enhancer/core/enums/shared_pref_keys.dart';
import 'package:photo_enhancer/features/auth/data/create_user_response.dart';
import 'package:photo_enhancer/features/auth/data/get_user_data_response.dart';
import 'package:photo_enhancer/features/auth/data/verify_integrity_response.dart';
import 'package:photo_enhancer/locator.dart';

class AppUserRepository {
  final DioApiClient dioApiClient;

  AppUserRepository({required this.dioApiClient});

  Future<String?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      return googleUser.id;
    } catch (e) {
      log(e.toString(), error: e);
      if (googleSignIn.currentUser != null) {
        googleSignIn.currentUser!.clearAuthCache();
      }
      return null;
    }
  }

  Future<bool> signOutFromGoogle() async {
    final googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.signOut();
      return true;
    } catch (e) {
      log(e.toString(), error: e);
      if (googleSignIn.currentUser != null) {
        googleSignIn.currentUser!.clearAuthCache();
      }
      return false;
    }
  }

  Future<VerifyIntegrityResponse?> verifyIntegrity({
    required VerifyIntegrityRequest integrityRequest,
  }) async {
    try {
      final response = await dioApiClient.post<Map<String, dynamic>>(
        AppInitializer.getStringEnv(EnvKeys.verifyIntegrityUrl),
        data: integrityRequest.toJson(),
      );

      if (response == null) return null;

      return VerifyIntegrityResponse.fromJson(response);
    } catch (e) {
      log(e.toString(), error: e);
      return null;
    }
  }

  Future<String?> getAndroidId() async {
    try {
      return PhotoEnhancerChannelHelper.getAndroidId();
    } catch (e) {
      log(e.toString(), error: e);
      return null;
    }
  }

  Future<CreateUserResponse?> createUser({required CreateUserRequest createUserRequest}) async {
    try {
      final response = await dioApiClient.post<Map<String, dynamic>>(
        AppInitializer.getStringEnv(EnvKeys.createUserUrl),
        data: createUserRequest.toJson(),
      );

      if (response == null) return null;

      return CreateUserResponse.fromJson(response);
    } catch (e) {
      log(e.toString(), error: e);
      return null;
    }
  }

  Future<GetUserDataResponse?> getUserData({required String id}) async {
    try {
      final response = await dioApiClient.fetch<Map<String, dynamic>>(
        AppInitializer.getStringEnv(EnvKeys.getUserDataUrl),
        data: {
          "userId": id,
        },
      );

      if (response == null) return null;

      return GetUserDataResponse.fromMap(response);
    } on PhotoEnhancerApiException catch (e) {
      log(e.toString(), error: e);

      if (e is UserDataNotFound) {
        getIt<SharedPrefManager>().setString(SharedPrefKeys.googleId, "");
      }

      return null;
    }
  }

  Future<bool> deleteAccount({required String id}) async {
    try {
      final success = await signOutFromGoogle();
      if (!success) return false;

      final response = await dioApiClient.post<Map<String, dynamic>>(
        AppInitializer.getStringEnv(EnvKeys.deleteAccountUrl),
        data: {
          "uid": id,
        },
      );

      if (response != null) {
        return response["success"] as bool;
      }

      return false;
    } catch (e) {
      log(e.toString(), error: e);
      return false;
    }
  }
}
