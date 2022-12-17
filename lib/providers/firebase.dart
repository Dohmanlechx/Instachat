import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pFirebase = Provider<FirebaseDatabase>((_) => FirebaseDatabase.instance);
