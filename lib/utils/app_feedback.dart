import 'package:flutter/material.dart';

void showAppToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
      duration: const Duration(milliseconds: 1000),
    ),
    snackBarAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 120),
      reverseDuration: Duration(milliseconds: 700),
    ),
  );
}
