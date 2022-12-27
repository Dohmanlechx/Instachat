import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/error_data.dart';
import 'package:instachat/providers/app_exceptions.dart';

class GuardedRepository<T> {
  const GuardedRepository(this.ref);

  final Ref ref;

  Future<T> guard(Function fn) async {
    try {
      return await fn();
    } catch (error, stackTrace) {
      log('Something went wrong!', error: error, stackTrace: stackTrace);
      ref.read(pAppExceptions.notifier).state = ErrorData(error, stackTrace);
      return Future.error(error, stackTrace);
    }
  }
}
