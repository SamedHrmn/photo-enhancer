import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';

class AppActionTooltip {
  static void showTooltip(
    BuildContext context, {
    required GlobalKey parentKey,
    required AppLocalizedKeys content,
    double rightPadding = 0,
    double bottomPadding = 0,
  }) {
    final renderBox = (parentKey.currentContext!.findRenderObject()! as RenderBox);
    final tapPosition = renderBox.localToGlobal(Offset.zero);
    final parentHeight = renderBox.size.height;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: tapPosition.dx - rightPadding,
        top: tapPosition.dy - parentHeight / 2 - bottomPadding,
        child: Material(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: AppSizer.borderRadius,
          child: _AnimatedTooltip(
            content: content,
            onTooltipEnd: () {
              if (overlayEntry.mounted) {
                overlayEntry.remove();
              }
            },
          ),
        ),
      ),
    );

    // Insert the overlay entry into the overlay
    Overlay.of(context).insert(overlayEntry);

    // Optionally remove the overlay after a certain duration
    Future.delayed(Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _AnimatedTooltip extends StatefulWidget {
  final AppLocalizedKeys content;
  final VoidCallback onTooltipEnd;

  const _AnimatedTooltip({
    required this.content,
    required this.onTooltipEnd,
  });

  @override
  _AnimatedTooltipState createState() => _AnimatedTooltipState();
}

class _AnimatedTooltipState extends State<_AnimatedTooltip> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _fadeIn();
  }

  void _fadeIn() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Future.delayed(Duration(seconds: 2), () {
      _fadeOut();
    });
  }

  void _fadeOut() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 0.0;
      });

      widget.onTooltipEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: Duration(milliseconds: 300),
      child: Tooltip(
        message: "",
        child: Padding(
          padding: EdgeInsets.all(8),
          child: AppText(
            widget.content,
            size: AppSizer.scaleWidth(13),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
