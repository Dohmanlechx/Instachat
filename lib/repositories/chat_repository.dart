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
    final chats = <Chat>[];

    await guard(() async {
      final chatsData = await ref.getDatabaseValue('chats/');

      if (chatsData != null) {
        chats.addAll(chatsData.values.map((data) => Chat.fromJson(data)));
      }
    });

    return chats;
  }

  Future<Chat> fetch(String id) async {
    Chat? chat;

    await guard(() async {
      final chatData = await ref.getDatabaseValue('chats/$id');

      if (chatData != null) {
        chat = Chat.fromJson(chatData);
      }
    });

    final c = chat;

    if (c != null) {
      return c;
    } else {
      throw Exception('No chat found!');
    }
  }

  Future<String> create() async {
    final shuffledWords = List.of(file.words.map((e) => e.toLowerCase()))
      ..shuffle();
    final word = shuffledWords.take(2);

    final chatId = word.join('-');
    final userId = ref.read(pUserId);
    final chat = Chat(id: chatId, users: {userId: User(id: userId)});

    await guard(() => ref.updateDatabaseValue('chats/$chatId', chat.toJson()));

    return chat.id;
  }

  Future<void> join(String chatId) async {
    final userId = ref.read(pUserId);

    await guard(() => ref.setDatabaseValue(
        'chats/$chatId/users/$userId', User(id: userId).toJson()));
  }

  Future<void> updateMessage(
    String id,
    String userId, {
    required String message,
  }) async {
    await guard(
      () => ref.setDatabaseValue('chats/$id/$userId/message', message),
    );
  }
}
