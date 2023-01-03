import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:instachat/secrets.dart';

final _encrypter =
    Encrypter(AES(Key.fromBase64(Secrets.encryptionKey), mode: AESMode.cbc));

String encrypted(String message) {
  if (message.isEmpty) {
    return '';
  }
  final iv = IV.fromSecureRandom(Secrets.encryptionIvLength);
  final encrypted = _encrypter.encrypt(message, iv: iv);
  return base64.encode(List.from(iv.bytes)..addAll(encrypted.bytes));
}

String decrypted(String encryptedMessage) {
  if (encryptedMessage.isEmpty) {
    return '';
  }
  final bytesToken = base64.decode(encryptedMessage);
  final iv = IV(bytesToken.sublist(0, Secrets.encryptionIvLength));
  final encrypted = Encrypted(bytesToken.sublist(Secrets.encryptionIvLength));
  return _encrypter.decrypt(encrypted, iv: iv);
}
