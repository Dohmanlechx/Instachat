import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final pUserId = Provider<String>((_) => const Uuid().v4());
