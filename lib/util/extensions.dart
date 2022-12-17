import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/providers/firebase.dart';

extension RefExtensions on Ref {
  Future<Map<String, dynamic>> getDatabaseValue(String path) async {
    final db = read(firebaseProvider).ref(path);
    final event = await db.once();
    return event.snapshot.value as Map<String, dynamic>;
  }
}
