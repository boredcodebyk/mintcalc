import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

class StdCalc extends StatefulWidget {
  const StdCalc({Key? key}) : super(key: key);
  static String pageTitle = "Standard";

  @override
  State<StdCalc> createState() => _StdCalcState();
}

class _StdCalcState extends State<StdCalc> {
  TextEditingController input = TextEditingController();
  var output = "";

  String _formattedText(String str) {
    if (str.contains("\u00d7")) {
      return str.replaceAll("\u00d7", "*");
    } else if (str.contains("\u2013")) {
      return str.replaceAll("\u2013", "-");
    } else if (str.contains("÷")) {
      return str.replaceAll("÷", "/");
    } else {
      return str;
    }
  }

  void _doMaths(val) {
    if (val == "C") {
      setState(() {
        input.clear();
        output = "";
      });
    } else if (val == "=") {
      if (input.text.isNotEmpty) {
        var userinput = input.text;
        userinput = _formattedText(input.text.replaceAll("", ""));
        Parser P = Parser();
        try {
          Expression expression = P.parse(userinput);

          ContextModel cm = ContextModel();
          var finalvalue = expression.evaluate(EvaluationType.REAL, cm);
          setState(() {
            output = finalvalue.toString();
          });
          if (output.endsWith(".0")) {
            setState(() {
              output = output.substring(0, output.length - 2);
            });
          }
        } on Exception {
          setState(() {
            output = "Syntax Error";
          });
        }
      }
    } else {
      var valbb = "";
      if (val == "*") {
        valbb = "\u00d7";
      } else if (val == "-") {
        valbb = "\u2013";
      } else if (val == "/") {
        valbb = "÷";
      } else {
        valbb = val;
      }

      setState(() {
        input.value = TextEditingValue(
          text: input.text
              .replaceRange(input.selection.start, input.selection.end, valbb),
          selection: TextSelection.collapsed(
              offset: input.selection.baseOffset + valbb.length),
        );
      });
    }
  }

  void _bkspc() {
    if (input.text.isNotEmpty) {
      setState(() {
        input.text = input.text.substring(0, input.text.length - 1);
      });
    } else {
      setState(() {
        input.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      input.value =
          const TextEditingValue(selection: TextSelection.collapsed(offset: 0));
    });
  }

  @override
  void dispose() {
    super.dispose();
    input.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextField(
                    enableSuggestions: false,
                    autofocus: true,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: input,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(
                          RegExp(r'[a-z] [A-Z] :$'))
                    ],
                    style: const TextStyle(
                      fontSize: 48,
                    ),
                    keyboardType: TextInputType.none,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    output.toString(),
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCalcButton("C", true),
                _buildCalcButton("()", true),
                _buildCalcButton("%", true),
                _buildCalcButton("÷", true),
                _buildCalcButton("7", false),
                _buildCalcButton("8", false),
                _buildCalcButton("9", false),
                _buildCalcButton("\u00d7", true),
                _buildCalcButton("4", false),
                _buildCalcButton("5", false),
                _buildCalcButton("6", false),
                _buildCalcButton("\u2013", true),
                _buildCalcButton("1", false),
                _buildCalcButton("2", false),
                _buildCalcButton("3", false),
                _buildCalcButton("+", true),
                _buildCalcButton(".", false),
                _buildCalcButton("0", false),
                FilledButton.tonal(
                    onPressed: () => _bkspc(),
                    child: const Icon(
                      Icons.backspace_outlined,
                      size: 32,
                    )),
                _buildCalcButton("=", true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalcButton(String val, bool notTonalButton) {
    var valb;
    if (val == "\u00d7") {
      valb = "*";
    } else if (val == "\u2013") {
      valb = "-";
    } else if (val == "÷") {
      valb = "/";
    } else {
      valb = val;
    }
    return notTonalButton
        ? FilledButton(
            onPressed: () => _doMaths(valb),
            child: Text(
              val,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
          )
        : FilledButton.tonal(
            onPressed: () => _doMaths(valb),
            child: Text(
              val,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
          );
  }
}
