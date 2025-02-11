import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_enhancer/core/navigation/app_navigator.dart';
import 'package:photo_enhancer/locator.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({
    super.key,
    required this.onConfirm,
  });

  final AsyncCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning,
        color: Colors.red,
      ),
      title: Text("Account Deletion"),
      actionsAlignment: MainAxisAlignment.center,
      content: Text("This operation cannot be undone. Can you confirm to delete your account?"),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await onConfirm();
          },
          child: Text("Im sure"),
        ),
        ElevatedButton(
          onPressed: () {
            getIt<AppNavigator>().goBack(context);
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}
