import 'package:flutter/foundation.dart';
import 'package:photo_enhancer/core/widgets/base_data_holder.dart';
import 'package:photo_enhancer/features/auth/data/app_user.dart';
import 'package:photo_enhancer/features/auth/data/create_user_response.dart';

@immutable
class AuthViewDataHolder extends BaseDataHolder {
  final AppUser appUser;
  final CreateUserRequest? createUserRequest;
  final VerifyingStatus verifyingStatus;
  final SignInStatus? signInStatus;

  const AuthViewDataHolder._({
    required this.appUser,
    required this.verifyingStatus,
    this.createUserRequest,
    this.signInStatus,
  });

  factory AuthViewDataHolder.initial() => AuthViewDataHolder._(
        appUser: AppUser(),
        verifyingStatus: VerifyingStatus.initial,
        signInStatus: SignInStatus.initial,
      );

  @override
  List<Object?> get props => [appUser, verifyingStatus, createUserRequest, signInStatus];

  @override
  AuthViewDataHolder copyWith({
    AppUser? appUser,
    VerifyingStatus? verifyingStatus,
    CreateUserRequest? createUserRequest,
    SignInStatus? signInStatus,
  }) {
    return AuthViewDataHolder._(
      appUser: appUser ?? this.appUser,
      verifyingStatus: verifyingStatus ?? this.verifyingStatus,
      createUserRequest: createUserRequest ?? this.createUserRequest,
      signInStatus: signInStatus ?? this.signInStatus,
    );
  }
}

enum VerifyingStatus {
  initial,
  loading,
  success,
  rejected,
  error,
}

enum SignInStatus {
  initial,
  loading,
  success,
  error,
}
