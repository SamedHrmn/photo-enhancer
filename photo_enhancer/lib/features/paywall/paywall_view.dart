import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/core/widgets/app_loader_overlay_manager.dart';
import 'package:photo_enhancer/locator.dart';

class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQueryData.fromView(View.of(context)).padding.top,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                AppLoaderOverlayManager.showOverlay();
                Future.delayed(
                  const Duration(seconds: 5),
                  () {
                    AppLoaderOverlayManager.hideOverlay();
                  },
                );
                getIt<AppNavigator>().goBack(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                size: 24,
              ),
            ),
            const Spacer(),
            AppText(AppLocalizedKeys.appName),
            const Spacer(),
            const SizedBox(width: 32),
          ],
        ),
        Center(
          child: Text(
            "Coming soon",
          ),
        ),
      ],
    );
  }
}
