import 'package:flutter_dart/math_expression_interpreter.dart';

void main() {
  print('Testing MathExpressionInterpreter');
  print('================================');
  
  // Test case 1: 10*5+4/2-1 (result: 51)
  testExpression('10*5+4/2-1', {}, 51);
  
  // Test case 2: (x*3-5)/5 (result: 5 when x=10)
  testExpression('(x*3-5)/5', {'x': 10}, 5);
  
  // Test case 3: 3*x+15/(3+2) (result: 33 when x=10)
  testExpression('3*x+15/(3+2)', {'x': 10}, 33);
  
  // Additional test cases
  testExpression('2+3*4', {}, 14);
  testExpression('(2+3)*4', {}, 20);
  testExpression('2*(3+4)', {}, 14);
  testExpression('10-2*3', {}, 4);
  
  // Test with variables
  testExpression('a+b*c', {'a': 2, 'b': 3, 'c': 4}, 14);
  testExpression('(a+b)*c', {'a': 2, 'b': 3, 'c': 4}, 20);
  
  // Test with unary minus
  testExpression('-5', {}, -5);
  testExpression('2*-3', {}, -6);
  testExpression('-x', {'x': 7}, -7);
  testExpression('5+(-3)', {}, 2);
  testExpression('5*(-3+2)', {}, -5);
  
  // Test with whitespace
  testExpression('10 * 5 + 4 / 2 - 1', {}, 51);
  testExpression(' ( x * 3 - 5 ) / 5 ', {'x': 10}, 5);
  
  print('\nAll tests completed.');
}

void testExpression(String expression, Map<String, double> variables, double expectedResult) {
  try {
    final interpreter = MathExpressionInterpreter(expression);
    final actualResult = interpreter.evaluate(variables);
    final isCorrect = (actualResult - expectedResult).abs() < 0.0001;
    
    String variablesText = '';
    if (variables.isNotEmpty) {
      variablesText = ' with ${variables.entries.map((e) => '${e.key}=${e.value}').join(', ')}';
    }
    
    print('${isCorrect ? '✓' : '✗'} $expression$variablesText = $actualResult (Expected: $expectedResult)');
    
    if (!isCorrect) {
      print('  ERROR: Result does not match expected value!');
    }
  } catch (e) {
    print('✗ $expression: Error - ${e.toString()}');
  }
}