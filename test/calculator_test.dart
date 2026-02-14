import 'package:flutter_test/flutter_test.dart';
import 'package:calcly/calculator.dart';

void main() {
  late Calculator calc;

  setUp(() {
    calc = Calculator();
  });

  group('Базовые вычисления калькулятора', () {
    test('Сложение', () {
      expect(calc.calculate('2+3'), 5);
    });

    test('Вычитание', () {
      expect(calc.calculate('10-4'), 6);
    });

    test('Умножение', () {
      expect(calc.calculate('3*4'), 12);
    });

    test('Деление', () {
      expect(calc.calculate('12/3'), 4);
    });

    test('Возведение в степень', () {
      expect(calc.calculate('2^3'), 8);
    });
  });

  group('Продвинутые вычисления', () {
    test('Скобки', () {
      expect(calc.calculate('(2+3)*4'), 20);
    });

    test('Унарный минус в начале', () {
      expect(calc.calculate('-5+3'), -2);
    });

    test('Унарный минус после скобки', () {
      expect(calc.calculate('2*-3'), -6);
    });

    test('Сложное выражение', () {
      expect(calc.calculate('3+4*2/(1-5)^2'), 3.5);
    });
  });

  group('Обработка ошибок', () {
    test('Некорректное выражение', () {
      expect(() => calc.calculate('5+'), throwsA(isA<Exception>()));
    });

    test('Деление на ноль', () {
      expect(() => calc.calculate('5/0'), throwsA(isA<UnsupportedError>()));
    });
  });
}
