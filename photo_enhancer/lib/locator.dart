import 'package:get_it/get_it.dart';
import 'package:photo_enhancer/common/helpers/app_device_manager.dart';
import 'package:photo_enhancer/common/helpers/app_file_manager.dart';
import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/common/helpers/app_package_manager.dart';
import 'package:photo_enhancer/common/helpers/app_permission_manager.dart';
import 'package:photo_enhancer/common/helpers/shared_pref_manager.dart';
import 'package:photo_enhancer/core/api/dio_api_client.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/features/auth/data/app_user_repository.dart';
import 'package:photo_enhancer/features/show-result/photo_enhancer_repository.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  getIt.registerSingleton<AppPackageManager>(AppPackageManager());
  getIt.registerSingleton<AppFileManager>(AppFileManager());
  getIt.registerSingleton<AppDeviceManager>(AppDeviceManager());
  getIt.registerSingleton<SharedPrefManager>(SharedPrefManager());
  getIt.registerSingleton<AppPermissionManager>(
    AppPermissionManager(
      appDeviceManager: getIt<AppDeviceManager>(),
    ),
  );

  getIt.registerSingletonAsync<DioApiClient>(
    () async {
      final appCheckToken = await AppInitializer.getAppCheckToken();
      return DioApiClient(
        appCheckToken: appCheckToken,
      );
    },
  );
  getIt.registerSingleton<AppNavigator>(AppNavigator());
  getIt.registerSingleton<AppUserRepository>(
    AppUserRepository(
      dioApiClient: await getIt.getAsync<DioApiClient>(),
    ),
  );
  getIt.registerSingleton<PhotoEnhancerRepository>(
    PhotoEnhancerRepository(
      appFileManager: getIt<AppFileManager>(),
      sharedPrefManager: getIt<SharedPrefManager>(),
      dioApiClient: await getIt.getAsync<DioApiClient>(),
    ),
  );
}
