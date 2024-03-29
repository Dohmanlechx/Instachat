import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/providers/user.dart';
import 'package:instachat/repositories/guarded_repository.dart';
import 'package:instachat/util/encryption.dart';
import 'package:instachat/util/extensions/ref.dart';
import 'package:instachat/words.dart' as file;

final chatRepositoryProvider = Provider<_ChatRepository>(_ChatRepository.new);

class _ChatRepository extends GuardedRepository {
  const _ChatRepository(Ref ref) : super(ref);

  Future<List<Chat>> fetchAll() async {
    return await guard(() async {
      final chatsData = await ref.getDatabaseValue('chats/');

      return chatsData == null
          ? List.empty()
          : List.of(chatsData.values.map((data) => Chat.fromJson(data)));
    });
  }

  Future<Chat?> fetch(String chatId) async {
    return await guard(() async {
      final chatData = await ref.getDatabaseValue('chats/$chatId');

      return chatData == null ? null : Chat.fromJson(chatData);
    });
  }

  Future<String> create() async {
    String chatId;
    List<Chat> allChats;

    do {
      allChats = await fetchAll();
      chatId = file.randomizedId();
    } while (allChats.any((chat) => chat.id == chatId));

    final user = ref.read(pUser);
    final chat = Chat(id: chatId, users: {user.id: user});

    return await guard(() async {
      await ref.setDatabaseValue('chats/$chatId', chat.toJson());
      return chatId;
    });
  }

  Future<void> join(String chatId) async {
    final user = ref.read(pUser);

    return await guard(() async {
      await ref.setDatabaseValue(
        'chats/$chatId/users/${user.id}',
        user.toJson(),
      );
    });
  }

  Future<void> leave(String chatId) async {
    final userId = ref.read(pUser).id;

    return await guard(() async {
      await ref.deleteDatabaseValue('chats/$chatId/users/$userId');

      final chat = await fetch(chatId);

      if (chat?.users.isEmpty ?? false) {
        await ref.deleteDatabaseValue('chats/$chatId');
      }
    });
  }

  Future<void> updateMessage(
    String chatId,
    String userId, {
    required String message,
  }) async {
    return await guard(() async {
      await ref.setDatabaseValue(
        'chats/$chatId/users/$userId/message',
        encrypted(message),
      );
    });
  }
}
