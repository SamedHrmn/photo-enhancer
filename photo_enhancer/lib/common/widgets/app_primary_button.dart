import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/extension/theme_extensions.dart';
import 'package:photo_enhancer/core/theme/app_theme.dart';

enum AppPrimaryButtonVariant {
  defaultVariant,
  negativeVariant,
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.localizedKey,
    required this.onPressed,
    this.variant = AppPrimaryButtonVariant.defaultVariant,
    this.minimumSize,
  });

  final AppLocalizedKeys localizedKey;
  final VoidCallback onPressed;
  final AppPrimaryButtonVariant variant;
  final Size? minimumSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _backgroundColor(context),
        minimumSize: minimumSize ??
            Size.fromHeight(
              AppSizer.scaleHeight(55),
            ),
      ),
      child: AppText(
        localizedKey,
        color: AppTheme.textColorDark,
      ),
    );
  }

  Color? _backgroundColor(BuildContext context) {
    switch (variant) {
      case AppPrimaryButtonVariant.defaultVariant:
        return null;
      case AppPrimaryButtonVariant.negativeVariant:
        return context.isDarkTheme() ? AppTheme.elevatedButtonNegativeVariantBackgroundDark : AppTheme.elevatedButtonNegativeVariantBackgroundLight;
    }
  }
}
