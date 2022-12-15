import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseProvider =
    Provider<FirebaseDatabase>((_) => FirebaseDatabase.instance);
