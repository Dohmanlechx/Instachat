import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instachat/models/error_data.dart';
import 'package:instachat/theme/ui.dart';

extension ContextExtensions on BuildContext {
  void showPositiveSnackbar(String message) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(UI.p8),
                  child: Text(
                    message,
                    style: UI.regular20,
                    maxLines: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void showNegativeSnackBar(ErrorData errorData) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(UI.p8),
                  child: Text(
                    kDebugMode
                        ? errorData.exception.toString()
                        : 'Something went wrong!',
                    style: UI.regular20,
                    maxLines: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
