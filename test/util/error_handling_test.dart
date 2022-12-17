import 'package:flutter_test/flutter_test.dart';
import 'package:instachat/util/error_handling.dart';

void main() {
  group('Guard wrapper', () {
    test('should await', () async {
      const oneSecond = Duration(seconds: 1);
      fn() async => await Future.delayed(oneSecond);

      DateTime start;
      DateTime end;

      start = DateTime.now();
      await guard(fn);
      end = DateTime.now();

      expect(start.add(oneSecond).isBefore(end), isTrue);
    });

    test('should catch error', () {
      fn() => throw Exception();
      expect(() => fn(), throwsException);
      expect(() => guard(fn), returnsNormally);
    });
  });
}
