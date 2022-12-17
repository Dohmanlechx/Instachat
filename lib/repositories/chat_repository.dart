import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/util/error_handling.dart';
import 'package:instachat/util/extensions.dart';

final chatRepositoryProvider = Provider<_ChatRepository>(_ChatRepository.new);

class _ChatRepository {
  const _ChatRepository(this.ref);

  final Ref ref;

  Future<List<Chat>> fetch() async {
    final chats = <Chat>[];

    await guardedFuture(() async {
      final chatData = await ref.getDatabaseValue('chats/');
      chats.addAll(chatData.values.map((data) => Chat.fromJson(data)));
    });

    return chats;
  }
}
