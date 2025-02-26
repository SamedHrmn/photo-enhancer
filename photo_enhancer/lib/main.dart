import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/helpers/app_file_manager.dart';
import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/common/helpers/app_permission_manager.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/helpers/iap_manager.dart';
import 'package:photo_enhancer/common/helpers/shared_pref_manager.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/enums/route_enum.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/theme/app_theme.dart';
import 'package:photo_enhancer/core/widgets/base_statefull_widget.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
import 'package:photo_enhancer/features/auth/data/app_user_repository.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_model.dart';
import 'package:photo_enhancer/features/auth/viewmodel/auth_view_state.dart';
import 'package:photo_enhancer/features/colorize-image/pick_image_view_model.dart';
import 'package:photo_enhancer/features/home/home_view_model.dart';
import 'package:photo_enhancer/features/paywall/data/photo_coins_repository.dart';
import 'package:photo_enhancer/features/paywall/paywall_view_model.dart';
import 'package:photo_enhancer/features/show-result/photo_enhancer_repository.dart';
import 'package:photo_enhancer/features/show-result/show_result_view_model.dart';
import 'package:photo_enhancer/locator.dart';

Future<void> main() async {
  await AppInitializer.initializeApp();
  runApp(
    EasyLocalization(
      path: AppAssetManager.translationsPath,
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthViewModel(
            appUserRepository: getIt<AppUserRepository>(),
            prefManager: getIt<SharedPrefManager>(),
          ),
        ),
        BlocProvider(
          create: (context) => PickImageViewModel(
            appFileManager: getIt<AppFileManager>(),
          ),
        ),
        BlocProvider(
          create: (context) => ShowResultViewModel(
            colorizeImageRepository: getIt<PhotoEnhancerRepository>(),
            appFileManager: getIt<AppFileManager>(),
            permissionManager: getIt<AppPermissionManager>(),
          ),
        ),
        BlocProvider(
          create: (context) => HomeViewModel(
            appPermissionManager: getIt<AppPermissionManager>(),
          ),
        ),
        BlocProvider(
          create: (context) => PaywallViewModel(
            iapManager: getIt<IAPManager>(),
            photoCoinsRepository: getIt<PhotoCoinsRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        navigatorKey: getIt<AppNavigator>().navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        builder: (context, child) => LoaderOverlay(
          child: child!,
          overlayWidgetBuilder: (progress) => AppLoaderOverlay(
            globalKey: getIt<AppNavigator>().overlayKey,
            onHidingAnimationComplete: () {
              getIt<AppNavigator>().navigatorKey.currentContext!.loaderOverlay.hide();
            },
          ),
        ),
        onGenerateRoute: (settings) {
          switch (RouteEnum.fromPath(settings.name!)) {
            case RouteEnum.initialView:
              return RouteEnum.initialView.toMaterialRoute(settings);
            case RouteEnum.authView:
              return RouteEnum.authView.toMaterialRoute(settings);
            case RouteEnum.homeView:
              return RouteEnum.homeView.toMaterialRoute(settings);
          }
        },
        home: ScaffoldMessenger(
          key: getIt<AppNavigator>().scaffoldMessengerKey,
          child: const InitialView(),
        ),
      ),
    );
  }
}

class InitialView extends StatefulWidget {
  const InitialView({super.key});

  @override
  State<InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends BaseStatefullWidget<InitialView> {
  @override
  Future<void> onInitAsync() async {
    AppInitializer.hideSplash();

    AppSizer.init(context, figmaWidth: 390, figmaHeight: 844);

    final authViewModel = context.read<AuthViewModel>();
    authViewModel.clearState();

    authViewModel.isDeviceVerified().then((verified) async {
      if (!verified) {
        await authViewModel.verifyIntegrity();
      }
    });

    return super.onInitAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<AuthViewModel, AuthViewDataHolder>(
          listenWhen: (previous, current) => previous.verifyingStatus != current.verifyingStatus,
          listener: (context, state) {
            if (state.verifyingStatus == VerifyingStatus.success) {
              getIt<AppNavigator>().navigateTo(RouteEnum.authView);
            }
          },
          buildWhen: (previous, current) => previous.verifyingStatus != current.verifyingStatus,
          builder: (context, state) {
            switch (state.verifyingStatus) {
              case VerifyingStatus.initial:
              case VerifyingStatus.loading:
                return CircularProgressIndicator();

              case VerifyingStatus.error:
                return AppText(AppLocalizedKeys.errorVerifyDevice);
              case VerifyingStatus.rejected:
                return AppText(AppLocalizedKeys.rejectedVerifyDevice);
              case VerifyingStatus.success:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
