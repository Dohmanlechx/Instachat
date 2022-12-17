import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/error_data.dart';

final pAppExceptions = StateProvider<ErrorData?>((_) => null);
