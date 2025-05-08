import 'package:flutter/material.dart';
import 'math_expression_interpreter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Expression Interpreter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Math Expression Interpreter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _expressionController = TextEditingController();
  final TextEditingController _variableController = TextEditingController();
  String _result = '';

  void _evaluateExpression() {
    try {
      final expression = _expressionController.text;
      final variableText = _variableController.text;

      // Parse variables
      final Map<String, double> variables = {};
      if (variableText.isNotEmpty) {
        final variablePairs = variableText.split(',');
        for (final pair in variablePairs) {
          final keyValue = pair.split('=');
          if (keyValue.length == 2) {
            final key = keyValue[0].trim();
            final value = double.tryParse(keyValue[1].trim());
            if (value != null) {
              variables[key] = value;
            }
          }
        }
      }

      // Evaluate the expression
      final interpreter = MathExpressionInterpreter(expression);
      final result = interpreter.evaluate(variables);

      setState(() {
        _result = 'Result: $result';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _expressionController,
              decoration: const InputDecoration(
                labelText: 'Enter mathematical expression',
                hintText: 'Example: 10*5+4/2-1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _variableController,
              decoration: const InputDecoration(
                labelText: 'Enter variables (optional)',
                hintText: 'Example: x=10, y=5',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _evaluateExpression,
              child: const Text('Evaluate'),
            ),
            const SizedBox(height: 16),
            Text(
              _result,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            const Text(
              'Test Cases:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            _buildTestCase('10*5+4/2-1', {}, 51),
            _buildTestCase('(x*3-5)/5', {'x': 10}, 5),
            _buildTestCase('3*x+15/(3+2)', {'x': 10}, 33),
            _buildTestCase('2*(3+4*(5-1))', {}, 38),
            _buildTestCase('-5+10', {}, 5),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCase(String expression, Map<String, double> variables, double expectedResult) {
    final interpreter = MathExpressionInterpreter(expression);
    final actualResult = interpreter.evaluate(variables);
    final isCorrect = (actualResult - expectedResult).abs() < 0.0001;

    String variablesText = '';
    if (variables.isNotEmpty) {
      variablesText = ' with ${variables.entries.map((e) => '${e.key}=${e.value}').join(', ')}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        '$expression$variablesText = $actualResult (Expected: $expectedResult) ${isCorrect ? '✓' : '✗'}',
        style: TextStyle(
          color: isCorrect ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
