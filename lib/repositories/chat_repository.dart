import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/repositories/guarded_repository.dart';
import 'package:instachat/util/extensions.dart';
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

  Future<Chat?> fetch(String id) async {
    Chat? chat;

    await guard(() async {
      final chatData = await ref.getDatabaseValue('chats/$id');

      if (chatData != null) {
        chat = Chat.fromJson(chatData);
      }
    });

    return chat;
  }

  Future<String> create() async {
    final shuffledWords = List.of(file.words)..shuffle();
    final word = shuffledWords.take(1);

    final id = word.join('-');
    final chat = Chat(id: id);

    await guard(() => ref.updateDatabaseValue('chats/$id', chat.toJson()));

    return chat.id;
  }
}
