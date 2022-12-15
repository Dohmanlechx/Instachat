import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/providers/firebase.dart';
import 'package:uuid/uuid.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, Chat?>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<Chat?> {
  ChatNotifier(this.ref) : super(null);

  final Ref ref;

  String get databasePath => 'chats/${state?.id}';

  void init() {
    final id = const Uuid().v4();
    final chat = Chat(id: id);

    state = chat;
    final databaseRef = ref.read(firebaseProvider).ref(databasePath);
    databaseRef.update(chat.toJson());
  }

  void updateHostMessage(String value) {
    state = state?.copyWith(messageFromHost: value);
  }

  void updateGuestMessage(String value) {
    state = state?.copyWith(messageFromGuest: value);
  }
}
