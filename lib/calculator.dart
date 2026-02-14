import 'dart:math';

class Calculator {
  final Map<String, int> operationPriority = {
    '(': 0,
    '+': 1,
    '-': 1,
    '*': 2,
    '/': 2,
    '^': 3,
    '~': 4, // Унарный минус
  };

  Calculator();

  /// Вычисляет результат выражения, переданного в виде строки  
  double calculate(String expression) {
    if (expression.trim().isEmpty) {
      throw ArgumentError('Выражение пустое');
    }

    final postfix = _infixToPostfix(expression);
    return _evaluatePostfix(postfix);
  }

  /// Преобразует инфиксное выражение в постфиксное (обратная польская нотация)
  List<String> _infixToPostfix(String infix) {
    List<String> input = [];
    List<String> stack = [];
    List<String> output = [];
    RegExp numberRegExp = RegExp(r'\d+(?:\.\d+)?|[+\-*\/^()]');

    input = numberRegExp.allMatches(infix).map((m) => m[0]!).toList();

    for (int i = 0; i < input.length; i++) {
      String token = input[i];
      // Если токен - число, добавляем его в выходной список
      if (!operationPriority.containsKey(token) && token != ')') {
        output.add(token);
      } 
      // Если токен - открывающая скобка, помещаем её в стек
      else if (token == '(') {
        stack.add(token);
      } 
      // Если токен - закрывающая скобка, извлекаем из стека до открывающей скобки
      else if (token == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          output.add(stack.removeLast());
        }
        if (stack.isEmpty) {
          throw FormatException('Несбалансированные скобки');
        }
        stack.removeLast();
      } 
      // Если токен - оператор, извлекаем из стека операторы с большим или равным приоритетом
      else if (operationPriority.containsKey(token)) {
        String op = token;
        if (op == '-' &&
            (i == 0 || input[i - 1] == '(' || operationPriority.containsKey(input[i - 1]))) {
          op = '~'; // унарный минус
        }
        while (stack.isNotEmpty &&
            (operationPriority[stack.last]! >= operationPriority[op]!)) {
          output.add(stack.removeLast());
        }
        stack.add(op);
      }
    }
    // После обработки всех токенов извлекаем оставшиеся операторы из стека
    while (stack.isNotEmpty) {
      if (stack.last == '(' || stack.last == ')') {
        throw FormatException('Несбалансированные скобки');
      }
      output.add(stack.removeLast());
    }
    
    return output;
  }

  /// Выполняет операцию над двумя числами
  double _execute(String operator, double a, double b) => switch (operator) {
    '+' => a + b,
    '-' => a - b,
    '*' => a * b,
    '/' => b == 0
        ? throw UnsupportedError('Деление на ноль')
        : a / b,
    '^' => pow(a, b).toDouble(),
    _ => throw ArgumentError('Неизвестный оператор: $operator'),
  };

  /// Вычисляет результат постфиксного выражения
  double _evaluatePostfix(List<String> postfixExpression) {
    List<double> stack = [];

    for (var token in postfixExpression) {
      if (!operationPriority.containsKey(token)) {
        stack.add(double.parse(token));
      } else if (token == '~') {
        if (stack.isEmpty) throw FormatException('Некорректное выражение');
        stack.add(-stack.removeLast());
      } else {
        if (stack.length < 2) throw FormatException('Некорректное выражение');
        double b = stack.removeLast();
        double a = stack.removeLast();
        stack.add(_execute(token, a, b));
      }
    }

    if (stack.length != 1) throw FormatException('Некорректное выражение');
    return stack.first;
  }
}
