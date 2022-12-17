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
    final shuffledWords = List.of(file.words.map((e) => e.toLowerCase()))
      ..shuffle();
    final word = shuffledWords.take(2);

    final id = word.join('-');
    final chat = Chat(id: id);

    await guard(() => ref.updateDatabaseValue('chats/$id', chat.toJson()));

    return chat.id;
  }

  Future<void> updateHostMessage(String id, {required String message}) async {
    await guard(
      () => ref.setDatabaseValue('chats/$id/messageFromHost', message),
    );
  }

  Future<void> updateGuestMessage(String id, {required String message}) async {
    await guard(
      () => ref.setDatabaseValue('chats/$id/messageFromGuest', message),
    );
  }
}
