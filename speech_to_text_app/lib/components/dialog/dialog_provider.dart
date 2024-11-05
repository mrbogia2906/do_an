import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/dialog/error_dialog.dart';

final alertDialogProvider = Provider<AlertDialog>((ref) => AlertDialog(ref));

class AlertDialog {
  AlertDialog(this.ref);

  final Ref ref;

  int _numberOfShowedAlertDialogs = 0;

  Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    VoidCallback? onClosed,
  }) async {
    while (_numberOfShowedAlertDialogs > 0) {
      _numberOfShowedAlertDialogs--;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    _numberOfShowedAlertDialogs++;
    await showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: title,
          onClosed: () {
            onClosed != null ? onClosed.call() : Navigator.of(context).pop();
            _numberOfShowedAlertDialogs--;
          },
        );
      },
    );
  }
}
