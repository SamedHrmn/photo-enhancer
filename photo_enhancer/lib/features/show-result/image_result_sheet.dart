import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_primary_button.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/enums/route_enum.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/theme/app_theme.dart';
import 'package:photo_enhancer/core/widgets/app_snackbar_manager.dart';
import 'package:photo_enhancer/core/widgets/base_statefull_widget.dart';
import 'package:photo_enhancer/features/colorize-image/pick_image_view_model.dart';
import 'package:photo_enhancer/features/home/home_view_model.dart';
import 'package:photo_enhancer/features/show-result/show_result_view_model.dart';
import 'package:photo_enhancer/locator.dart';

class ImageResultSheet extends StatefulWidget {
  const ImageResultSheet({super.key, required this.bytes});

  final Uint8List bytes;

  @override
  State<ImageResultSheet> createState() => _ImageResultSheetState();
}

class _ImageResultSheetState extends BaseStatefullWidget<ImageResultSheet> {
  late final AppLifecycleListener lifecycleListener;

  Future<void> _onSave() async {
    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;
    final result = await globalContext.read<ShowResultViewModel>().saveResultImage(
          widget.bytes,
        );

    if (!globalContext.mounted) return;

    if (result != null) {
      AppSnackbarManager.show(
        content: AppText(
          AppLocalizedKeys.imageSavedSuccessfullyTo,
          localizedArg: [result],
          color: AppTheme.textColorDark,
        ),
      );
    }

    globalContext.read<ShowResultViewModel>().clearState();
    globalContext.read<PickImageViewModel>().clearState();
    getIt<AppNavigator>().replaceWith(RouteEnum.homeView);
  }

  void _onDiscard() {
    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;

    globalContext.read<ShowResultViewModel>().clearState();
    globalContext.read<PickImageViewModel>().clearState();

    getIt<AppNavigator>().replaceWith(RouteEnum.homeView);
  }

  Future<void> _showDiscardContinueDialog() async {
    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;

    await showDialog(
      context: globalContext,
      barrierDismissible: false,
      builder: (_) => ContinueDiscardDialog(
        onSave: () async {
          await _onSave();
        },
        onDiscard: () async {
          _onDiscard();
        },
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();

    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;

    lifecycleListener = AppLifecycleListener(
      onResume: () {
        globalContext.read<ShowResultViewModel>().updateStoragePermissionGranted(
              globalContext.read<HomeViewModel>(),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await _showDiscardContinueDialog();
      },
      child: Padding(
        padding: AppSizer.verticallPadding(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: AppSizer.borderRadius,
                child: Image.memory(widget.bytes),
              ),
            ),
            BlocBuilder<HomeViewModel, HomeViewDataHolder>(
              builder: (context, state) {
                if (state.permissionStatus == AppStoragePermissionStatus.requestedAndDenied) {
                  return Column(
                    children: [
                      AppText(AppLocalizedKeys.storagePermissionNeeded),
                      Row(
                        children: [
                          AppPrimaryButton(
                            onPressed: () async {
                              await context.read<HomeViewModel>().openAppSettingsForPermission();
                            },
                            localizedKey: AppLocalizedKeys.openSettings,
                          ),
                          AppPrimaryButton(
                            onPressed: () async {
                              await _showDiscardContinueDialog();
                            },
                            localizedKey: AppLocalizedKeys.noContinue,
                          )
                        ],
                      ),
                    ],
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    spacing: 24,
                    children: [
                      Expanded(
                        child: AppPrimaryButton(
                          onPressed: () async {
                            await _onSave();
                          },
                          localizedKey: AppLocalizedKeys.save,
                        ),
                      ),
                      Expanded(
                        child: AppPrimaryButton(
                          variant: AppPrimaryButtonVariant.negativeVariant,
                          onPressed: () async {
                            await _showDiscardContinueDialog();
                          },
                          localizedKey: AppLocalizedKeys.discard,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class ContinueDiscardDialog extends StatelessWidget {
  const ContinueDiscardDialog({super.key, required this.onSave, required this.onDiscard});

  final AsyncCallback onSave;
  final AsyncCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppText(
        AppLocalizedKeys.continueDiscardDialogTitle,
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.center,
      ),
      content: AppText(
        AppLocalizedKeys.continueDiscardDialogContent,
        fontWeight: FontWeight.w500,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: AppPrimaryButton(
            onPressed: () async {
              await onSave();
            },
            localizedKey: AppLocalizedKeys.continueDiscardDialogAction1,
          ),
        ),
        AppPrimaryButton(
          variant: AppPrimaryButtonVariant.negativeVariant,
          onPressed: () async {
            await onDiscard();
          },
          localizedKey: AppLocalizedKeys.continueDiscardDialogAction2,
        ),
      ],
    );
  }
}
