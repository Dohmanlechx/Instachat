import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:instachat/models/user.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class Chat with _$Chat {
  factory Chat({
    required String id,
    required List<User> users,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}
