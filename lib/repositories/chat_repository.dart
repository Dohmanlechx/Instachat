import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/util/error_handling.dart';
import 'package:instachat/util/extensions.dart';

final chatRepositoryProvider = Provider<_ChatRepository>(_ChatRepository.new);

class _ChatRepository {
  const _ChatRepository(this.ref);

  final Ref ref;

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
}
