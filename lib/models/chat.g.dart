// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Chat _$$_ChatFromJson(Map<String, dynamic> json) => _$_Chat(
      id: json['id'] as String,
      users: (json['users'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, User.fromJson(e as Map<String, dynamic>)),
          ) ??
          const <String, User>{},
    );

Map<String, dynamic> _$$_ChatToJson(_$_Chat instance) => <String, dynamic>{
      'id': instance.id,
      'users': instance.users.map((k, e) => MapEntry(k, e.toJson())),
    };
