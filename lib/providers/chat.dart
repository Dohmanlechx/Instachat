import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/providers/firebase.dart';
import 'package:instachat/repositories/chat_repository.dart';
import 'package:instachat/words.dart';

final pvrChats = FutureProvider<List<Chat>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return await repo.fetch();
});

final chatProvider = StateNotifierProvider<ChatNotifier, Chat?>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<Chat?> {
  ChatNotifier(this.ref) : super(null);

  final Ref ref;

  String get databasePath => 'chats/${state?.id}';

  void init() {
    final words = List.of(all)..shuffle();
    final id = words.take(3);
    final chat = Chat(id: id.join('-'));

    state = chat;
    final databaseRef = ref.read(firebaseProvider).ref(databasePath);
    databaseRef.update(chat.toJson());
  }

  Future<void> join(String id) async {
    final databaseRef = ref.read(firebaseProvider).ref('chats/');
    final event = await databaseRef.once();
    final chat = event.snapshot.value as Map<String, dynamic>;

    if (chat.containsKey(id)) {
      final chatModel = Chat.fromJson(chat[id]);
      state = chatModel;
    } else {
      return Future.error(Exception('Chat $id is not available.'));
    }
  }

  void updateHostMessage(String value) {
    state = state?.copyWith(messageFromHost: value);
  }

  void updateGuestMessage(String value) {
    state = state?.copyWith(messageFromGuest: value);
  }
}
