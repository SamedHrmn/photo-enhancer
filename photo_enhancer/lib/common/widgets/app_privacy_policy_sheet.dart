import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/locator.dart';

class AppPrivacyPolicySheet extends StatelessWidget {
  const AppPrivacyPolicySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: FutureBuilder(
            future: NetworkAssetBundle(Uri.parse(AppAssetManager.privacyPolicySource)).load(''),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: AppText(AppLocalizedKeys.somethingWentWrong),
                );
              }

              final data = snapshot.requireData;
              final response = String.fromCharCodes(data.buffer.asUint8List());

              return Markdown(data: response);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            onPressed: () {
              getIt<AppNavigator>().goBack(context);
            },
            child: const AppText(
              AppLocalizedKeys.okay,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
