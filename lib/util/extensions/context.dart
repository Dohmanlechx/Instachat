import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instachat/models/error_data.dart';
import 'package:instachat/theme/ui.dart';

extension ContextExtensions on BuildContext {
  void _showSnackbar({
    required Icon icon,
    required String message,
    required Color color,
  }) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          content: Row(
            children: [
              icon,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(UI.p8),
                  child: Text(message, style: UI.regular20, maxLines: 5),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void showSuccessSnackbar(String message) {
    _showSnackbar(
      icon: const Icon(Icons.check_circle, color: Colors.white),
      message: message,
      color: Colors.green,
    );
  }

  void showErrorSnackbar(ErrorData errorData) {
    _showSnackbar(
      icon: const Icon(Icons.error, color: Colors.white),
      message:
          kDebugMode ? errorData.exception.toString() : 'Something went wrong!',
      color: Colors.redAccent,
    );
  }
}
