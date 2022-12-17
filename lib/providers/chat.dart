import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';
import 'package:instachat/repositories/chat_repository.dart';

final pAllChats = FutureProvider<List<Chat>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return await repo.fetchAll();
});

final pChatById =
    FutureProvider.family.autoDispose<Chat?, String?>((ref, chatId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return chatId == null ? null : await repo.fetch(chatId);
});
