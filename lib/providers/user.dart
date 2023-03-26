import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/user.dart';
import 'package:instachat/words.dart';
import 'package:uuid/uuid.dart';

final pUser = StateNotifierProvider<UserNotifier, User>(
  (_) => UserNotifier(),
);

class UserNotifier extends StateNotifier<User> {
  UserNotifier()
      : super(
          User(
            id: const Uuid().v4(),
            name: '${randomizeColor()} ${randomizeAnimal()}',
          ),
        );

  void setName(String name) {
    state = state.copyWith(name: name);
  }
}
