import 'dart:developer';

Future<void> guard(Function fn) async {
  try {
    await fn();
  } catch (error, stackTrace) {
    log('Something went wrong!', error: error, stackTrace: stackTrace);
  }
}
