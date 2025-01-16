// File: test/counter_test.dart
import 'package:flutter_test/flutter_test.dart';

class Counter {
  int value = 0;

  void increment() => value++;
  void decrement() => value--;
}

void main() {
  group('Counter', () {
    test('value should start at 0', () {
      final counter = Counter();
      expect(counter.value, 0);
    });

    test('value should increment', () {
      final counter = Counter();
      counter.increment();
      expect(counter.value, 1);
    });

    test('value should decrement', () {
      final counter = Counter();
      counter.decrement();
      expect(counter.value, -1);
    });
  });
}
