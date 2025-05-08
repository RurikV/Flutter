class MathExpressionInterpreter {
  final String expression;
  
  MathExpressionInterpreter(this.expression);
  
  double evaluate(Map<String, double> variables) {
    // Create a copy of the expression to work with
    String expr = expression;
    
    // Replace variables with their values
    variables.forEach((name, value) {
      // Use word boundary to ensure we're replacing whole variable names
      expr = expr.replaceAll(RegExp('\\b$name\\b'), value.toString());
    });
    
    // Parse and evaluate the expression
    return _evaluateExpression(expr);
  }
  
  double _evaluateExpression(String expr) {
    // Remove all whitespace
    expr = expr.replaceAll(RegExp(r'\s+'), '');
    
    // Parse the expression using a recursive descent parser
    return _parseAdditionSubtraction(expr);
  }
  
  // Parse addition and subtraction (lowest precedence)
  double _parseAdditionSubtraction(String expr) {
    // Find the rightmost + or - that is not inside parentheses
    int parenthesesCount = 0;
    int lastOperatorIndex = -1;
    
    for (int i = expr.length - 1; i >= 0; i--) {
      final char = expr[i];
      
      if (char == ')') {
        parenthesesCount++;
      } else if (char == '(') {
        parenthesesCount--;
      } else if ((char == '+' || char == '-') && parenthesesCount == 0) {
        // Check if it's not a unary operator
        if (i > 0 && !'+-*/('.contains(expr[i - 1])) {
          lastOperatorIndex = i;
          break;
        } else if (i == 0 && char == '-') {
          // Handle unary minus at the beginning
          return -_parseAdditionSubtraction(expr.substring(1));
        }
      }
    }
    
    if (lastOperatorIndex != -1) {
      final leftExpr = expr.substring(0, lastOperatorIndex);
      final rightExpr = expr.substring(lastOperatorIndex + 1);
      
      if (expr[lastOperatorIndex] == '+') {
        return _parseAdditionSubtraction(leftExpr) + _parseMultiplicationDivision(rightExpr);
      } else {
        return _parseAdditionSubtraction(leftExpr) - _parseMultiplicationDivision(rightExpr);
      }
    }
    
    // If no addition or subtraction operators found, move to multiplication/division
    return _parseMultiplicationDivision(expr);
  }
  
  // Parse multiplication and division (higher precedence)
  double _parseMultiplicationDivision(String expr) {
    // Find the rightmost * or / that is not inside parentheses
    int parenthesesCount = 0;
    int lastOperatorIndex = -1;
    
    for (int i = expr.length - 1; i >= 0; i--) {
      final char = expr[i];
      
      if (char == ')') {
        parenthesesCount++;
      } else if (char == '(') {
        parenthesesCount--;
      } else if ((char == '*' || char == '/') && parenthesesCount == 0) {
        lastOperatorIndex = i;
        break;
      }
    }
    
    if (lastOperatorIndex != -1) {
      final leftExpr = expr.substring(0, lastOperatorIndex);
      final rightExpr = expr.substring(lastOperatorIndex + 1);
      
      if (expr[lastOperatorIndex] == '*') {
        return _parseMultiplicationDivision(leftExpr) * _parsePrimary(rightExpr);
      } else {
        return _parseMultiplicationDivision(leftExpr) / _parsePrimary(rightExpr);
      }
    }
    
    // If no multiplication or division operators found, move to primary expressions
    return _parsePrimary(expr);
  }
  
  // Parse primary expressions (numbers, parenthesized expressions)
  double _parsePrimary(String expr) {
    expr = expr.trim();
    
    // Handle empty expression
    if (expr.isEmpty) {
      return 0;
    }
    
    // Handle parentheses
    if (expr.startsWith('(') && expr.endsWith(')')) {
      // Remove outer parentheses and evaluate the inner expression
      return _evaluateExpression(expr.substring(1, expr.length - 1));
    }
    
    // Handle unary minus
    if (expr.startsWith('-')) {
      return -_parsePrimary(expr.substring(1));
    }
    
    // Handle numbers
    try {
      return double.parse(expr);
    } catch (e) {
      // If we can't parse as a number, check for nested parentheses
      int parenthesesCount = 0;
      for (int i = 0; i < expr.length; i++) {
        if (expr[i] == '(') {
          parenthesesCount++;
        } else if (expr[i] == ')') {
          parenthesesCount--;
          if (parenthesesCount == 0 && i < expr.length - 1) {
            // Found a closing parenthesis that's not at the end, so this is a complex expression
            return _evaluateExpression(expr);
          }
        }
      }
      
      // If we get here, something went wrong
      throw FormatException('Invalid expression: $expr');
    }
  }
}