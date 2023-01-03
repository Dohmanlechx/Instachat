import 'package:flutter_test/flutter_test.dart';
import 'package:instachat/util/encryption.dart';

void main() {
  group('Encrypt and decrypt', () {
    test('normal text', () {
      const message = 'Hello, World!';
      final encryptedMessage = encrypted(message);
      expect(encryptedMessage, isNot(message));
      final decryptedMessage = decrypted(encryptedMessage);
      expect(decryptedMessage, message);
    });

    test('strange text', () {
      const message = '21328 &&& M(({{!!€ /(" )===????';
      final encryptedMessage = encrypted(message);
      expect(encryptedMessage, isNot(message));
      final decryptedMessage = decrypted(encryptedMessage);
      expect(decryptedMessage, message);
    });
  });
}
