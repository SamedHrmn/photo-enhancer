import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/common/widgets/app_topbar.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/core/enums/app_topbar_actions.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    required this.topBarTitle,
  });

  final Widget child;
  final AppLocalizedKeys topBarTitle;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppTopBar(
          title: topBarTitle,
          actions: [
            AppTopBarActionButton(
              child: const Icon(Icons.more_vert),
              onTapDown: (details) async {
                final offset = details.globalPosition;

                await showMenu<void>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    offset.dx,
                    offset.dy,
                    AppSizer.screenWidth - offset.dx,
                    AppSizer.screenHeight - offset.dy,
                  ),
                  items: AppTopBarActions.values
                      .map(
                        (e) => PopupMenuItem<void>(
                          onTap: () async {
                            final actionFunc = e.action();
                            await actionFunc();
                          },
                          child: AppText(
                            e.toLocalizedKey(),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
