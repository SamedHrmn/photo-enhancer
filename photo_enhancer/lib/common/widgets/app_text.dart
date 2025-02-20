import 'package:flutter/material.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/theme/app_theme.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.localizedKey, {
    this.localizedArg,
    super.key,
    this.size,
    this.fontWeight = FontWeight.w600,
    this.textAlign = TextAlign.start,
    this.color = AppTheme.textColorLight,
    this.hasOverflow = false,
  });

  final AppLocalizedKeys localizedKey;
  final List<String>? localizedArg;
  final double? size;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final Color color;
  final bool hasOverflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      localizedKey.toLocalized(context, args: localizedArg),
      overflow: hasOverflow ? TextOverflow.ellipsis : null,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: fontWeight,
            fontSize: size ?? 16,
            color: color,
          ),
    );
  }
}
