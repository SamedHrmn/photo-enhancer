import 'package:flutter/material.dart';

abstract class BaseStatefullWidget<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await onInitAsync();
    });
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  Future<void> onInitAsync() async {}
  void onInit() {}
  void onDispose() {}
  void updateState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context);
}
