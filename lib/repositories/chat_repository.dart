import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/models/user.dart';
import 'package:instachat/providers/user_id.dart';
import 'package:instachat/repositories/guarded_repository.dart';
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

  Future<Chat> fetch(String chatId) async {
    return await guard(() async {
      final chatData = await ref.getDatabaseValue('chats/$chatId');

      return chatData == null
          ? throw Exception('No chat found!')
          : Chat.fromJson(chatData);
    });
  }

  Future<String> create() async {
    final chatId = file.randomizedId();
    final userId = ref.read(pUserId);
    final chat = Chat(id: chatId, users: {userId: User(id: userId)});

    return await guard(() async {
      await ref.setDatabaseValue('chats/$chatId', chat.toJson());
      return chatId;
    });
  }

  Future<void> join(String chatId) async {
    final userId = ref.read(pUserId);

    return await guard(() async {
      final user = User(id: userId).toJson();
      await ref.setDatabaseValue('chats/$chatId/users/$userId', user);
    });
  }

  Future<void> leave(String chatId) async {
    final userId = ref.read(pUserId);

    return await guard(() async {
      await ref.setDatabaseValue('chats/$chatId/users/$userId', null);
    });
  }

  Future<void> updateMessage(
    String chatId,
    String userId, {
    required String message,
  }) async {
    return await guard(() async {
      await ref.setDatabaseValue(
          'chats/$chatId/users/$userId/message', message);
    });
  }
}
