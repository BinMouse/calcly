import 'package:flutter/material.dart';
import 'package:calcly/calculator.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> 
  with TickerProviderStateMixin {

  // Логика калькулятора
  final Calculator _calculator = Calculator();
  String _expression = '';
  String _display = '0';
  String _result = '';
  bool _hasError = false;
  bool _justEvaluated = false;

  // Анимации
  late AnimationController _resultAnimController;
  late Animation<double> _resultFadeAnim;
  late AnimationController _errorShakeController;
  late Animation<double> _errorShakeAnim;

  // Инициализация и очистка ресурсов
  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _resultFadeAnim = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOut,
    );

    _errorShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _errorShakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(_errorShakeController);
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    _errorShakeController.dispose();
    super.dispose();
  }

  // Обработка нажатий на кнопки
  void _onInput(String value) {
    // HapticFeedback.lightImpact();
    setState(() {
      _hasError = false;

      if (value == 'C') {
        _clearAll();
        return;
      }

      if (value == '⌫') {
        _clearLast();
        return;
      }

      if (value == '=') {
        _evaluate();
        return;
      }
      _appendInput(value);
      return;
    });
  }

  // Очистка всего выражения
  void _clearAll() {
    _expression = '';
    _display = '0';
    _result = '';
    _justEvaluated = false;
    _resultAnimController.reset();
    return;
  }

  // Очистка последнего символа
  void _clearLast() {
    if (_justEvaluated) {
          _expression = '';
          _display = '0';
          _result = '';
          _justEvaluated = false;
          _resultAnimController.reset();
          return;
        }
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _display = _expression.isEmpty ? '0' : _expression;
        }
        _tryPreview();
        return;
  }

  void _appendInput(String value) {
    if (_justEvaluated) {
        // Если после = нажали оператор — продолжаем с результата
        if (['+', '-', '*', '/', '^', '(', ')'].contains(value)) {
          _expression = _result.isNotEmpty ? _result : _display;
        } else {
          _expression = '';
          _result = '';
          _resultAnimController.reset();
        }
        _justEvaluated = false;
      }

      // Запрещаем вторую точку в одном числе
      if (value == '.') {
        final lastSegment = _expression.split(RegExp(r'[+\-*/^()]')).last;
        if (lastSegment.contains('.')) return;
      }

      _expression += value;
      _display = _expression;
      _tryPreview();
  }

  // Предпросмотр результата при вводе
  void _tryPreview() {
    if (_expression.isEmpty) {
      _result = '';
      _resultAnimController.reset();
      return;
    }
    try {
      final val = _calculator.calculate(_expression);
      _result = _formatResult(val);
      _resultAnimController.forward(from: 0);
    } catch (_) {
      _result = '';
      _resultAnimController.reset();
    }
  }

  // Вычисление результата
  void _evaluate() {
    if (_expression.isEmpty) return;
    try {
      final val = _calculator.calculate(_expression);
      setState(() {
        _result = _formatResult(val);
        _display = _result;
        _expression = _result;
        _justEvaluated = true;
        _hasError = false;
        _resultAnimController.forward(from: 0);
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _result = '';
        _display = _expression;
      });
      _errorShakeController.forward(from: 0);
      // HapticFeedback.heavyImpact();
    }
  }

  // Форматирование результата для отображения
  String _formatResult(double val) {
    if (val == val.truncateToDouble() && val.abs() < 1e15) {
      return val.toInt().toString();
    }
    // Убираем лишние нули
    String s = val.toStringAsPrecision(10);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  // Экран калькулятора
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Column(
              children: [
                // Дисплей
                Expanded(
                  flex: isWide ? 3 : 4,
                  child: _buildDisplay(),
                ),
                // Кнопки
                Expanded(
                  flex: isWide ? 7 : 6,
                  child: _buildKeypad(isWide),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return AnimatedBuilder(
      animation: _errorShakeAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_errorShakeAnim.value, 0),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0F),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Выражение
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: _hasError ? 18 : 22,
                  color: _hasError
                      ? const Color(0xFFFF5F5F)
                      : const Color(0xFF888899),
                  letterSpacing: 0.5,
                ),
                child: Text(
                  _hasError
                      ? 'Ошибка: $_expression'
                      : (_expression.isEmpty ? '' : _expression),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Главный дисплей
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w300,
                  fontSize: _justEvaluated ? 52 : 44,
                  color: _hasError
                      ? const Color(0xFFFF5F5F)
                      : Colors.white,
                  letterSpacing: -1,
                ),
                child: Text(_display.isEmpty ? '0' : _display),
              ),
            ),
            const SizedBox(height: 6),
            // Превью результата
            FadeTransition(
              opacity: _resultFadeAnim,
              child: Text(
                _justEvaluated ? '' : _result,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  color: Color(0xFFE8C547),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKeypad(bool isWide) {
    // Раскладка кнопок
    final rows = [
      ['(', ')', '^', '⌫'],
      ['7', '8', '9', '/'],
      ['4', '5', '6', '*'],
      ['1', '2', '3', '-'],
      ['C', '0', '.', '+'],
      ['='],
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111116),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        isWide ? 24 : 16,
        20,
        isWide ? 24 : 16,
        isWide ? 20 : 12,
      ),
      child: Column(
        children: [
          // Тонкая полоска-индикатор
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A38),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              children: rows.map((row) {
                return Expanded(
                  flex: row.first == '=' ? 1 : 1,
                  child: Row(
                    children: row.map((label) {
                      return Expanded(
                        flex: label == '=' ? 1 : 1,
                        child: Padding(
                          padding: EdgeInsets.all(isWide ? 6 : 4),
                          child: _CalcButton(
                            label: label,
                            onTap: () => _onInput(label),
                            type: _buttonType(label),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  _ButtonType _buttonType(String label) {
    if (label == '=') return _ButtonType.equals;
    if (label == 'C') return _ButtonType.clear;
    if (label == '⌫') return _ButtonType.backspace;
    if (['+', '-', '*', '/', '^'].contains(label)) return _ButtonType.operator;
    if (['(', ')'].contains(label)) return _ButtonType.bracket;
    return _ButtonType.digit;
  }
}

enum _ButtonType { digit, operator, equals, clear, backspace, bracket }

class _CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final _ButtonType type;

  const _CalcButton({
    required this.label,
    required this.onTap,
    required this.type,
  });

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.type) {
      case _ButtonType.equals:
        return const Color(0xFFE8C547);
      case _ButtonType.clear:
        return const Color(0xFF3A1A1A);
      case _ButtonType.backspace:
        return const Color(0xFF1E1E2A);
      case _ButtonType.operator:
        return const Color(0xFF1E2030);
      case _ButtonType.bracket:
        return const Color(0xFF1A1E2A);
      case _ButtonType.digit:
        return const Color(0xFF1C1C24);
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case _ButtonType.equals:
        return const Color(0xFF0D0D0F);
      case _ButtonType.clear:
        return const Color(0xFFFF6B6B);
      case _ButtonType.backspace:
        return const Color(0xFFAAABBB);
      case _ButtonType.operator:
        return const Color(0xFF7EA8F8);
      case _ButtonType.bracket:
        return const Color(0xFF9B7EF8);
      case _ButtonType.digit:
        return Colors.white;
    }
  }

  double get _fontSize {
    switch (widget.type) {
      case _ButtonType.equals:
        return 28;
      default:
        return widget.label == '⌫' ? 22 : 22;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.type == _ButtonType.equals
                ? [
                    BoxShadow(
                      color: const Color(0xFFE8C547).withAlpha(40),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: _fontSize,
                fontWeight: widget.type == _ButtonType.equals
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: _textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}