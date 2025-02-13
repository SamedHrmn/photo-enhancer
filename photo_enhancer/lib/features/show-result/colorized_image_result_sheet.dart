import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/features/colorize-image/pick_image_view_model.dart';
import 'package:photo_enhancer/features/home/home_view_model.dart';
import 'package:photo_enhancer/features/show-result/show_result_view_model.dart';
import 'package:photo_enhancer/locator.dart';

class ColorizedImageResultSheet extends StatelessWidget {
  const ColorizedImageResultSheet({super.key, required this.result});

  final ColorizedImageResult result;

  Future<void> _onSave(BuildContext context) async {
    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;
    final result = await context.read<ShowResultViewModel>().saveResultImage();

    if (!globalContext.mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(globalContext).showSnackBar(
        SnackBar(
          content: Text("Image saved successfully to: $result"),
        ),
      );
    }

    globalContext.read<ShowResultViewModel>().clearState();
    globalContext.read<PickImageViewModel>().clearState();
    getIt<AppNavigator>().goBack(globalContext);
  }

  void _onDiscard(BuildContext context) {
    context.read<ShowResultViewModel>().clearState();
    context.read<PickImageViewModel>().clearState();
    getIt<AppNavigator>().goBack(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.memory(result.bytes!),
        BlocBuilder<HomeViewModel, HomeViewDataHolder>(
          builder: (context, state) {
            if (state.permissionStatus == AppStoragePermissionStatus.requestedAndDenied) {
              return Column(
                children: [
                  Text("Storage permission is needed to download the photo to your device."),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await context.read<HomeViewModel>().openAppSettingsForPermission();
                        },
                        child: Text("Open Settings"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ShowResultViewModel>().clearState();
                          context.read<PickImageViewModel>().clearState();
                          getIt<AppNavigator>().goBack(context);
                        },
                        child: Text("No, continue"),
                      )
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _onSave(context);
                  },
                  child: Text("Save"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => ContinueDiscardDialog(
                        onSave: () async {
                          await _onSave(context);
                        },
                        onDiscard: () async {
                          _onDiscard(context);
                        },
                      ),
                    );
                  },
                  child: Text("Discard"),
                ),
              ],
            );
          },
        )
      ],
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
      title: Text("Are you sure?"),
      content: Text("Unsaved photos are destroyed. Are you sure you want to continue without saving?"),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await onSave();
          },
          child: Text("Save"),
        ),
        ElevatedButton(
          onPressed: () async {
            await onDiscard();
          },
          child: Text("Discard and Continue"),
        ),
      ],
    );
  }
}
