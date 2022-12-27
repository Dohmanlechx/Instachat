import 'package:instachat/models/chat.dart';

extension ChatExtensions on Chat? {
  List<String> friendUserIds(String userId) {
    final chat = this;
    final userList = chat == null ? <String, dynamic>{} : chat.users;
    return userList.keys.where((id) => id != userId).toList();
  }
}
