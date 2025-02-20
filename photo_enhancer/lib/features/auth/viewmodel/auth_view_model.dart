import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/common/helpers/photo_enhancer_channel_helper.dart';
import 'package:photo_enhancer/common/helpers/shared_pref_manager.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';
import 'package:photo_enhancer/core/enums/shared_pref_keys.dart';
import 'package:photo_enhancer/features/auth/data/app_user.dart';
import 'package:photo_enhancer/features/auth/data/app_user_repository.dart';
import 'package:photo_enhancer/features/auth/data/create_user_response.dart';
import 'package:photo_enhancer/features/auth/data/verify_integrity_response.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_state.dart';

class AuthViewModel extends Cubit<AuthViewDataHolder> {
  AuthViewModel({
    required this.appUserRepository,
    required this.prefManager,
  }) : super(AuthViewDataHolder.initial());

  final AppUserRepository appUserRepository;
  final SharedPrefManager prefManager;

  void updateState({
    VerifyingStatus? status,
    AppUser? appUser,
    CreateUserRequest? createUserRequest,
    SignInStatus? signInStatus,
  }) {
    emit(state.copyWith(
      verifyingStatus: status,
      appUser: appUser,
      createUserRequest: createUserRequest,
      signInStatus: signInStatus,
    ));
  }

  void clearState() {
    emit(AuthViewDataHolder.initial());
  }

  Future<void> verifyIntegrity() async {
    final gcpId = AppInitializer.getStringEnv(EnvKeys.gcpId);

    final futures = await Future.wait([
      PhotoEnhancerChannelHelper.getIntegrityToken(gcpId: gcpId),
      PhotoEnhancerChannelHelper.getAndroidId(),
    ]);

    if (futures.isEmpty || futures.any((element) => element == null)) {
      updateState(status: VerifyingStatus.error);
      return;
    }

    final (token, androidId) = (futures[0]!, futures[1]!);

    final response = await appUserRepository.verifyIntegrity(
      integrityRequest: VerifyIntegrityRequest(
        integrityToken: token,
        packageName: AppInitializer.getStringEnv(EnvKeys.packageName),
      ),
    );

    if (response == null) {
      updateState(status: VerifyingStatus.error);
      return;
    } else if (!response.success) {
      updateState(status: VerifyingStatus.rejected);
      return;
    }

    await prefManager.setBool(SharedPrefKeys.deviceVerified, true);

    updateState(
      status: VerifyingStatus.success,
      createUserRequest: CreateUserRequest(androidId: androidId),
    );
  }

  Future<void> signInWithGoogle() async {
    updateState(signInStatus: SignInStatus.loading);

    final googleId = await appUserRepository.signInWithGoogle();
    if (googleId == null) {
      updateState(signInStatus: SignInStatus.error);
      return;
    }

    updateState(
      createUserRequest: state.createUserRequest!.copyWith(googleId: googleId),
    );
  }

  Future<void> createUser() async {
    // Check user created already before
    final id = await prefManager.getString(SharedPrefKeys.googleId);
    if (id.isEmpty) {
      await _createNewUser();

      return;
    }

    // Check user trying to login new account
    if (id != state.createUserRequest!.googleId) {
      await _createNewUser();
    } else {
      // User trying to login with existing account
      final userDataResponse = await appUserRepository.getUserData(id: id);
      if (userDataResponse != null) {
        updateState(
          appUser: AppUser.fromResponse(userDataResponse),
          signInStatus: SignInStatus.success,
        );
      } else {
        updateState(
          signInStatus: SignInStatus.error,
        );
      }
    }
  }

  Future<void> _createNewUser() async {
    if (state.createUserRequest == null || state.createUserRequest?.checkDataIsNull() == true) return;

    // If user already exist in database, returned userData as response.
    final response = await appUserRepository.createUser(createUserRequest: state.createUserRequest!);

    if (response != null) {
      updateState(
        appUser: response.toAppUser(),
        signInStatus: SignInStatus.success,
      );

      // Save googleId locally for prevent overwrite as new user.
      prefManager.setString(SharedPrefKeys.googleId, state.appUser.googleId!);
    }
  }

  Future<bool> isDeviceVerified() async {
    final isVerified = await prefManager.getBool(SharedPrefKeys.deviceVerified);
    if (isVerified) {
      final androidId = await PhotoEnhancerChannelHelper.getAndroidId();
      if (androidId != null) {
        updateState(
          status: VerifyingStatus.success,
          createUserRequest: CreateUserRequest(androidId: androidId),
        );
      }
    }
    return isVerified;
  }

  Future<bool> signOut() async {
    final response = await appUserRepository.signOutFromGoogle();
    if (response) {
      await prefManager.setString(SharedPrefKeys.googleId, "");
    }

    return response;
  }

  Future<bool> checkUserLoginBefore() async {
    updateState(signInStatus: SignInStatus.loading);

    final id = await prefManager.getString(SharedPrefKeys.googleId);

    if (id.isEmpty) {
      updateState(signInStatus: SignInStatus.initial);
    }

    return id.isNotEmpty;
  }

  Future<bool> deleteAccount() async {
    if (state.appUser.googleId == null) return false;

    final response = await appUserRepository.deleteAccount(id: state.appUser.googleId!);
    if (response) {
      await prefManager.setString(SharedPrefKeys.googleId, "");
    }
    return response;
  }
}
