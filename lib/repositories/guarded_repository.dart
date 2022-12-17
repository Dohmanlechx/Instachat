import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/main.dart';
import 'package:instachat/models/error_data.dart';

class GuardedRepository {
  const GuardedRepository(this.ref);

  final Ref ref;

  Future<void> guard(Function fn) async {
    try {
      await fn();
    } catch (error, stackTrace) {
      log('Something went wrong!', error: error, stackTrace: stackTrace);
      ref.read(pvrAppException.notifier).state = ErrorData(error, stackTrace);
    }
  }
}
