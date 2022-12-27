import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/providers/firebase.dart';

extension RefExtensions on Ref {
  Future<Map<String, dynamic>?> getDatabaseValue(
    String path,
  ) async {
    final db = read(pFirebase).ref(path);
    final event = await db.once();
    return jsonDecode(jsonEncode(event.snapshot.value))
        as Map<String, dynamic>?;
  }

  Future<void> updateDatabaseValue(
    String path,
    Map<String, dynamic> value,
  ) async {
    final db = read(pFirebase).ref(path);
    await db.update(value);
  }

  Future<void> setDatabaseValue(
    String path,
    Object? value,
  ) async {
    final db = read(pFirebase).ref(path);
    await db.set(value);
  }

  Future<void> deleteDatabaseValue(
    String path,
  ) async {
    final db = read(pFirebase).ref(path);
    await db.set(null);
  }
}
