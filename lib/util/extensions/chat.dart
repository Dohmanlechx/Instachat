import 'package:instachat/models/chat.dart';
import 'package:instachat/models/user.dart';

extension ChatExtensions on Chat? {
  List<User> friendUsers(String userId) {
    final chat = this;
    final userList = chat == null ? <String, User>{} : chat.users;
    return userList.values.where((user) => user.id != userId).toList();
  }
}
