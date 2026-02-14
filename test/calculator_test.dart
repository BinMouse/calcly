import 'package:flutter_test/flutter_test.dart';
import 'package:calcly/logic/calculator.dart';

void main() {
  late Calculator calc;

  setUp(() {
    calc = Calculator();
  });

  group('Базовые операции', () {
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

    test('Степень', () {
      expect(calc.calculate('2^3'), 8);
    });
  });

  group('Приоритет операторов', () {
    test('Умножение выше сложения', () {
      expect(calc.calculate('2+3*4'), 14);
    });

    test('Степень выше умножения', () {
      expect(calc.calculate('2*3^2'), 18);
    });

    test('Факториал выше степени', () {
      expect(calc.calculate('2^3!'), 64);
    });

    test('Несколько факториалов подряд', () {
      expect(calc.calculate('3!!'), 720);
    });
  });

  group('Дробные числа', () {
    test('Сложение дробей', () {
      expect(calc.calculate('2.5+0.5'), closeTo(3, 1e-10));
    });

    test('Дробное деление', () {
      expect(calc.calculate('5/2'), closeTo(2.5, 1e-10));
    });

    test('Отрицательная степень', () {
      expect(calc.calculate('2^-1'), closeTo(0.5, 1e-10));
    });
  });

  group('Корень', () {
    test('Квадратный корень', () {
      expect(calc.calculate('√9'), 3);
    });

    test('Корень в выражении', () {
      expect(calc.calculate('2+√16'), 6);
    });

    test('Корень из отрицательного', () {
      expect(
        () => calc.calculate('√-9'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('Скобки и унарные операторы', () {
    test('Скобки', () {
      expect(calc.calculate('(2+3)*4'), 20);
    });

    test('Глубокая вложенность', () {
      expect(calc.calculate('((2+3)*(4+1))'), 25);
    });

    test('Унарный минус в начале', () {
      expect(calc.calculate('-5+3'), -2);
    });

    test('Унарный минус после оператора', () {
      expect(calc.calculate('2*-3'), -6);
    });

    test('Сложное выражение', () {
      expect(
        calc.calculate('3+4*2/(1-5)^2'),
        closeTo(3.5, 1e-10),
      );
    });
  });

  group('Факториал', () {
    test('5!', () {
      expect(calc.calculate('5!'), 120);
    });

    test('0!', () {
      expect(calc.calculate('0!'), 1);
    });

    test('Факториал в выражении', () {
      expect(calc.calculate('3!+2'), 8);
    });

    test('Факториал после скобки', () {
      expect(calc.calculate('(3+2)!'), 120);
    });

    test('Отрицательный факториал', () {
      expect(
        () => calc.calculate('-5!'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('Дробный факториал', () {
      expect(
        () => calc.calculate('3.5!'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('Ошибки и синтаксис', () {
    test('Несбалансированные скобки', () {
      expect(
        () => calc.calculate('(2+3'),
        throwsA(isA<FormatException>()),
      );
    });

    test('Лишняя закрывающая скобка', () {
      expect(
        () => calc.calculate('2+3)'),
        throwsA(isA<FormatException>()),
      );
    });

    test('Два оператора подряд', () {
      expect(
        () => calc.calculate('5++3'),
        throwsA(isA<Exception>()),
      );
    });

    test('Пустая строка', () {
      expect(
        () => calc.calculate(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Деление на ноль', () {
      expect(
        () => calc.calculate('5/0'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
