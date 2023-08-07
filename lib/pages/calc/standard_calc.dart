import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StdCalc extends StatefulWidget {
  const StdCalc({Key? key}) : super(key: key);
  static String pageTitle = "Standard";

  @override
  State<StdCalc> createState() => _StdCalcState();
}

class _StdCalcState extends State<StdCalc> {
  TextEditingController input = TextEditingController();
  final ScrollController _inputScroll = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  RegExp bracketsCheck = RegExp(r'(?<=\d)(?=\()|(?<=\))(?=\d)|(?<=\))(?=\()');
  var output = "";
  void addToHistory(input, output) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var historyData = {
      "datetime": DateTime.now().toString(),
      "input": input,
      "output": output,
    };
    List _history = jsonDecode(prefs.getString("history_key") ?? "[]");
    if (_history.length >= 20) {
      _history.removeAt(20);
      _history.add(historyData);
    } else {
      _history.add(historyData);
    }
    String history = jsonEncode(_history);
    await prefs.setString("history_key", history);
  }

  Future<List> listHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List listHistory = jsonDecode(prefs.getString("history_key") ?? "[]");

    return listHistory;
  }

  void scrollWithCursor(String val) {
    String blankText = "";
    final isLong = val.length > blankText.length;
    if (isLong) {
      _inputScroll.animateTo(_inputScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
    print(_inputScroll.position.maxScrollExtent);
    print(input.selection.extentOffset);
  }

  void _doMath(String val) {
    if (val == "=") {
      if (input.text.isNotEmpty) {
        var userinput = input.text
            .replaceAll("\u00d7", "*")
            .replaceAll("÷", "/")
            .replaceAll(bracketsCheck, "*");
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
          addToHistory(userinput, output);
          input.clear();
          input.value = TextEditingValue(
            text: input.text.replaceRange(
                input.selection.start.abs(), input.selection.end.abs(), output),
            selection: TextSelection.collapsed(
                offset: input.selection.baseOffset + output.length),
          );
        } on Exception catch (e) {
          setState(() {
            output = "Syntax Error $e";
          });
        }
      }
      listHistory();
    } else if (val == "()") {
      if (input.selection.isCollapsed) {
        setState(() {
          input.value = input.value
              .replaced(TextRange.collapsed(input.selection.baseOffset), val);
        });
      } else {
        setState(() {
          input.value = input.value.replaced(
              TextRange(start: input.selection.start, end: input.selection.end),
              '(${input.text.substring(input.selection.start, input.selection.end)})');
        });
        input.selection = TextSelection.fromPosition(
            TextPosition(offset: input.selection.end - 1));
      }
    } else {
      if (input.selection.isCollapsed) {
        setState(() {
          input.value = input.value
              .replaced(TextRange.collapsed(input.selection.baseOffset), val);
        });
      } else {
        setState(() {
          input.value = input.value.replaced(
              TextRange(start: input.selection.start, end: input.selection.end),
              val);
        });
        input.selection = TextSelection.fromPosition(
            TextPosition(offset: input.selection.end));
      }
    }
    _inputScroll.animateTo(_inputScroll.position.maxScrollExtent + 1,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void _bkspc() {
    if (input.text.isNotEmpty) {
      if (input.selection.isCollapsed) {
        if (input.selection.baseOffset == input.text.length) {
          setState(() {
            input.value = TextEditingValue(
                text: input.text.substring(0, input.text.length - 1));
          });
          input.selection = TextSelection.fromPosition(
              TextPosition(offset: input.text.length));
        } else {
          setState(() {
            input.value = input.value.replaced(
                TextRange(
                    start: input.selection.baseOffset - 1,
                    end: input.selection.baseOffset),
                "");
          });
          input.selection = TextSelection.fromPosition(
              TextPosition(offset: input.selection.start));
        }
      } else {
        setState(() {
          input.value = input.value.replaced(
              TextRange(start: input.selection.start, end: input.selection.end),
              "");
        });
        input.selection = TextSelection.fromPosition(
            TextPosition(offset: input.selection.end));
      }
    } else {
      setState(() {
        input.clear();
        output = input.text;
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
    _inputScroll.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: _inputView(context),
                              ),
                              Expanded(
                                child: _history(context, false),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _keypad(context, 1.046))
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _history(context, false),
                              ),
                              Expanded(
                                child: _inputView(context),
                              ),
                            ],
                          ),
                        ),
                        _keypad(context, 2)
                      ],
                    );
                  }
                },
              );
            }
            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return Row(
                    children: [
                      Expanded(child: _inputView(context)),
                      Expanded(child: _keypad(context, 1.8)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _inputView(context),
                      ),
                      _keypad(context, (1 / 1))
                    ],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _inputView(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                focusNode: _inputFocus,
                scrollController: _inputScroll,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[a-z] [A-Z] :$'))
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
        getDeviceType(Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height)) ==
                DeviceScreenType.tablet
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog.fullscreen(
                            child: Column(
                          children: [
                            AppBar(
                              leading: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close)),
                            ),
                            Expanded(child: _history(context, true)),
                          ],
                        )),
                      );
                    },
                    icon: const Icon(Icons.history)),
              ),
      ],
    );
  }

  Widget _keypad(BuildContext context, double cellSizeRatio) {
    return GridView(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: cellSizeRatio),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FilledButton(
            onPressed: () {
              setState(() {
                input.clear();
                output = input.text;
                HapticFeedback.lightImpact();
              });
            },
            child: const Text(
              "C",
              style: TextStyle(fontSize: 32),
            )),
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
            onPressed: () {
              _bkspc();

              HapticFeedback.lightImpact();
            },
            child: const Icon(
              Icons.backspace_outlined,
              size: 32,
            )),
        _buildCalcButton("=", true),
      ],
    );
  }

  Widget _history(BuildContext context, bool isPhone) {
    bool isPhone = true;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: FutureBuilder(
          future: listHistory(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text("History is Empty"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                var math = snapshot.data?[index];
                return ListTile(
                  title: InkWell(
                    onTap: () {
                      input.clear();

                      setState(() {
                        output = "";
                        input.value = input.value.replaced(
                            TextRange.collapsed(input.selection.baseOffset),
                            math["input"]);
                      });
                      if (isPhone) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      math["input"],
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  subtitle: Text(
                    math["output"],
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                );
              },
            );
          }),
    );
  }

  Widget _buildCalcButton(String val, bool notTonalButton) {
    String valb;
    if (val == "\u2013") {
      valb = "-";
    } else if (val == "÷") {
      valb = "/";
    } else {
      valb = val;
    }
    return notTonalButton
        ? FilledButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _doMath(valb);
            },
            child: Text(
              val,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
          )
        : FilledButton.tonal(
            onPressed: () {
              HapticFeedback.lightImpact();
              _doMath(valb);
            },
            child: Text(
              val,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
          );
  }
}
