import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instachat/models/chat.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, Chat>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<Chat> {
  ChatNotifier() : super(Chat(id: '1337'));

  void updateHostMessage(String value) {
    state = state.copyWith(messageFromHost: value);
  }

  void updateGuestMessage(String value) {
    state = state.copyWith(messageFromGuest: value);
  }
}
