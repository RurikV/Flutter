import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dart/math_expression_interpreter.dart';

void main() {
  testWidgets('MathExpressionInterpreter - evaluates simple expressions correctly', (WidgetTester tester) async {
    // Test basic operations
    expect(MathExpressionInterpreter('2+3').evaluate({}), 5);
    expect(MathExpressionInterpreter('5-2').evaluate({}), 3);
    expect(MathExpressionInterpreter('4*3').evaluate({}), 12);
    expect(MathExpressionInterpreter('10/2').evaluate({}), 5);
  });

  testWidgets('MathExpressionInterpreter - respects operator precedence', (WidgetTester tester) async {
    // Test operator precedence
    expect(MathExpressionInterpreter('2+3*4').evaluate({}), 14);
    expect(MathExpressionInterpreter('2*3+4').evaluate({}), 10);
    expect(MathExpressionInterpreter('10-2*3').evaluate({}), 4);
    expect(MathExpressionInterpreter('10/2+3').evaluate({}), 8);
  });

  testWidgets('MathExpressionInterpreter - handles parentheses correctly', (WidgetTester tester) async {
    // Test parentheses
    expect(MathExpressionInterpreter('(2+3)*4').evaluate({}), 20);
    expect(MathExpressionInterpreter('2*(3+4)').evaluate({}), 14);
    expect(MathExpressionInterpreter('(10-2)*3').evaluate({}), 24);
    expect(MathExpressionInterpreter('10/(2+3)').evaluate({}), 2);
    expect(MathExpressionInterpreter('(2+3)*(4+5)').evaluate({}), 45);
  });

  testWidgets('MathExpressionInterpreter - handles variables correctly', (WidgetTester tester) async {
    // Test variables
    expect(MathExpressionInterpreter('x+5').evaluate({'x': 10}), 15);
    expect(MathExpressionInterpreter('2*y').evaluate({'y': 7}), 14);
    expect(MathExpressionInterpreter('a+b*c').evaluate({'a': 2, 'b': 3, 'c': 4}), 14);
    expect(MathExpressionInterpreter('(a+b)*c').evaluate({'a': 2, 'b': 3, 'c': 4}), 20);
  });

  testWidgets('MathExpressionInterpreter - handles unary minus correctly', (WidgetTester tester) async {
    // Test unary minus
    expect(MathExpressionInterpreter('-5').evaluate({}), -5);
    expect(MathExpressionInterpreter('2*-3').evaluate({}), -6);
    expect(MathExpressionInterpreter('-x').evaluate({'x': 7}), -7);
    expect(MathExpressionInterpreter('5+(-3)').evaluate({}), 2);
    expect(MathExpressionInterpreter('5*(-3+2)').evaluate({}), -5);
  });

  testWidgets('MathExpressionInterpreter - handles complex expressions correctly', (WidgetTester tester) async {
    // Test complex expressions
    expect(MathExpressionInterpreter('10*5+4/2-1').evaluate({}), 51);
    expect(MathExpressionInterpreter('(x*3-5)/5').evaluate({'x': 10}), 5);
    expect(MathExpressionInterpreter('3*x+15/(3+2)').evaluate({'x': 10}), 33);
    expect(MathExpressionInterpreter('2*(3+4*(5-1))').evaluate({}), 38);
    expect(MathExpressionInterpreter('(2+3)*(4+5)/3').evaluate({}), 15);
  });

  testWidgets('MathExpressionInterpreter - handles whitespace correctly', (WidgetTester tester) async {
    // Test expressions with whitespace
    expect(MathExpressionInterpreter('10 * 5 + 4 / 2 - 1').evaluate({}), 51);
    expect(MathExpressionInterpreter(' ( x * 3 - 5 ) / 5 ').evaluate({'x': 10}), 5);
    expect(MathExpressionInterpreter('3 * x + 15 / (3 + 2)').evaluate({'x': 10}), 33);
  });

  testWidgets('MathExpressionInterpreter - handles edge cases correctly', (WidgetTester tester) async {
    // Test edge cases
    expect(MathExpressionInterpreter('0').evaluate({}), 0);
    expect(MathExpressionInterpreter('').evaluate({}), 0);
    expect(MathExpressionInterpreter('(0)').evaluate({}), 0);
    expect(MathExpressionInterpreter('((10))').evaluate({}), 10);
  });
}
