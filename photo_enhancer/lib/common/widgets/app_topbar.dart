import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({required this.title, super.key, this.actions});

  final AppLocalizedKeys title;
  final List<AppTopBarActionButton>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: AppText(
        title,
        size: AppSizer.scaleWidth(20),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppTopBarActionButton extends StatelessWidget {
  const AppTopBarActionButton({required this.child, this.onPressed, this.onTapDown, super.key});

  final Widget child;
  final VoidCallback? onPressed;
  final void Function(TapDownDetails details)? onTapDown;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: onTapDown,
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: kMinInteractiveDimension,
        child: child,
      ),
    );
  }
}
