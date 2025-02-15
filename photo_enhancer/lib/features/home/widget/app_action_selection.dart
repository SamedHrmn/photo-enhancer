import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';

class AppActionSelection extends StatelessWidget {
  const AppActionSelection({
    super.key,
    required this.title,
    required this.onIconTapped,
    required this.value,
    required this.onChanged,
  });

  final AppLocalizedKeys title;
  final VoidCallback onIconTapped;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: AppSizer.borderRadius,
          ),
          onTap: onIconTapped,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              right: 8.0,
              bottom: 8,
              left: 4,
            ),
            child: Row(
              spacing: 6,
              children: [
                Expanded(
                  child: AppText(
                    title,
                    size: AppSizer.scaleWidth(12),
                  ),
                ),
                Icon(
                  Icons.info,
                  size: AppSizer.scaleWidth(16),
                )
              ],
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        )
      ],
    );
  }
}
