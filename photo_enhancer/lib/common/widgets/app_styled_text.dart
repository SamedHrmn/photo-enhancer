import 'package:flutter/material.dart';
import 'package:photo_enhancer/core/theme/app_theme.dart';
import 'package:styled_text/styled_text.dart';

class AppStyledText extends StatelessWidget {
  const AppStyledText({
    super.key,
    required this.text,
    this.colorBuilder,
    this.fontWeight,
    this.tags,
  });

  final String text;
  final Color Function(Color current)? colorBuilder;
  final FontWeight? fontWeight;
  final Map<String, StyledTextTagBase>? tags;

  @override
  Widget build(BuildContext context) {
    final _color = AppTheme.textColorLight;

    return StyledText(
      text: text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorBuilder?.call(_color) ?? _color,
            fontWeight: fontWeight,
          ),
      textAlign: TextAlign.center,
      tags: tags,
    );
  }
}
