import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:provider/provider.dart';  // Import Provider
import 'package:uidesign/Themes/theme_provider.dart'; // Import ThemeProvider

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({Key? key}) : super(key: key);

  @override
  State<CalculatorDialog> createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  String _expression = "";
  String _result = "0";

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _expression = "";
        _result = "0";
      } else if (buttonText == "=") {
        try {
          Parser p = Parser();
          Expression exp = p.parse(_expression);
          ContextModel cm = ContextModel();
          _result = exp.evaluate(EvaluationType.REAL, cm).toString();
        } catch (e) {
          _result = "Error";
        }
      } else if (buttonText == "⌫") {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else {
        _expression += buttonText;
      }
    });
  }

  Widget _buildButton(String buttonText, {Color? color}) {
    return Consumer<ThemeProvider>(  // Use Consumer to access ThemeProvider
      builder: (context, themeProvider, child) {
        final theme = themeProvider.themeData; // Get the current theme

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(18),
                backgroundColor: color ?? theme.colorScheme.secondary, // Use theme colors
                textStyle: const TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _onButtonPressed(buttonText),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: theme.colorScheme.onSecondary,  // Use theme colors
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>( // Use Consumer to access ThemeProvider
      builder: (context, themeProvider, child) {
        final theme = themeProvider.themeData; // Get the current theme

        return Dialog(
          backgroundColor: theme.colorScheme.surface,  // Dialog background color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface,),  // Icon color
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _expression,
                    style: TextStyle(fontSize: 28, color: theme.colorScheme.onSurface),  // Text color
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _result,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,  // Text color
                    ),
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.2)),  // Divider color
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildButton("C", color: theme.colorScheme.error),  // Red Accent for C
                          _buildButton("⌫", color: Colors.orangeAccent),  // Orange Accent for Delete
                          _buildButton("%"),
                          _buildButton("/"),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton("7"),
                          _buildButton("8"),
                          _buildButton("9"),
                          _buildButton("*"),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton("4"),
                          _buildButton("5"),
                          _buildButton("6"),
                          _buildButton("-"),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton("1"),
                          _buildButton("2"),
                          _buildButton("3"),
                          _buildButton("+"),
                        ],
                      ),
                      Row(
                        children: [
                          _buildButton("0"),
                          _buildButton("."),
                          _buildButton("00"),
                          _buildButton("=", color: theme.colorScheme.primaryContainer),  // Blue Accent for =
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}