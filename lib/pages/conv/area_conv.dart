import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:units_converter/units_converter.dart';

import '../../models/settings_model.dart';
import '../settings_page.dart';

class AreaConv extends StatefulWidget {
  const AreaConv({Key? key}) : super(key: key);

  static String pageTitle = "Area";
  @override
  State<AreaConv> createState() => _AreaConvState();
}

class _AreaConvState extends State<AreaConv> {
  TextEditingController inputA = TextEditingController();
  FocusNode inputAFN = FocusNode();
  TextEditingController inputB = TextEditingController();
  FocusNode inputBFN = FocusNode();

  var selectedareaA;
  var selectedareaB;
  var selectedareaSymbolA;
  var selectedareaSymbolB;
  var area = Area(significantFigures: 7, removeTrailingZeros: true);
  var units = [];

  void _bkspc() {
    if (inputAFN.hasFocus) {
      if (inputA.text.isNotEmpty) {
        if (inputA.selection.isCollapsed) {
          if (inputA.selection.baseOffset == inputA.text.length) {
            setState(() {
              inputA.text = inputA.text.substring(0, inputA.text.length - 1);
            });
            inputA.selection = TextSelection.fromPosition(
                TextPosition(offset: inputA.text.length));
          } else {
            setState(() {
              inputA.value = inputA.value.replaced(
                  TextRange(
                      start: inputA.selection.baseOffset - 1,
                      end: inputA.selection.baseOffset),
                  "");
            });
            inputA.selection = TextSelection.fromPosition(
                TextPosition(offset: inputA.selection.start));
          }
        } else {
          setState(() {
            inputA.value = inputA.value.replaced(
                TextRange(
                    start: inputA.selection.start, end: inputA.selection.end),
                "");
          });
          inputA.selection = TextSelection.fromPosition(
              TextPosition(offset: inputA.selection.end));
        }
        if (inputA.text.isNotEmpty) {
          area.convert(selectedareaA, double.parse(inputA.text));

          units = area.getAll();

          _convValueBuild(units);
          inputB.text = unitDetails[selectedareaB] ?? "";
        } else {
          setState(() {
            inputA.clear();
            inputB.clear();
          });
        }
      }
    } else if (inputBFN.hasFocus) {
      if (inputB.text.isNotEmpty) {
        if (inputB.selection.isCollapsed) {
          if (inputB.selection.baseOffset == inputB.text.length) {
            setState(() {
              inputB.text = inputB.text.substring(0, inputB.text.length - 1);
            });
            inputB.selection = TextSelection.fromPosition(
                TextPosition(offset: inputB.text.length));
          } else {
            setState(() {
              inputB.value = inputB.value.replaced(
                  TextRange(
                      start: inputB.selection.baseOffset - 1,
                      end: inputB.selection.baseOffset),
                  "");
            });
            inputB.selection = TextSelection.fromPosition(
                TextPosition(offset: inputB.selection.start));
          }
        } else {
          setState(() {
            inputB.value = inputB.value.replaced(
                TextRange(
                    start: inputB.selection.start, end: inputB.selection.end),
                "");
          });
          inputB.selection = TextSelection.fromPosition(
              TextPosition(offset: inputB.selection.end));
        }
        if (inputB.text.isNotEmpty) {
          area.convert(selectedareaB, double.parse(inputB.text));
          units = area.getAll();

          _convValueBuild(units);
          inputA.text = unitDetails[selectedareaA] ?? "";
        } else {
          setState(() {
            inputA.clear();
            inputB.clear();
          });
        }
      }
    }
  }

  Map<dynamic, String> unitDetails = {};

  void _convValueBuild(unitsconv) {
    for (Unit unit in unitsconv) {
      if (unit.name == selectedareaA) {
        setState(() {
          selectedareaSymbolA = unit.symbol;
        });
      } else if (unit.name == selectedareaB) {
        setState(() {
          selectedareaSymbolB = unit.symbol;
        });
      }
      unitDetails.addAll({unit.name: unit.stringValue ?? ""});
    }
  }

  void _conv(selectedUnit, val, TextEditingController input) {
    area.convert(selectedUnit, val);

    units = area.getAll();

    _convValueBuild(units);
    input.text = unitDetails[selectedUnit] ?? "";
  }

  void _convFunc(val) {
    if (val == "C") {
      inputA.clear();
      inputB.clear();
    } else {
      setState(() {
        if (inputAFN.hasFocus) {
          inputA.value = TextEditingValue(
            text: inputA.text.replaceRange(
                inputA.selection.start, inputA.selection.end, val),
            selection: TextSelection.collapsed(
                offset: inputA.selection.baseOffset + val.toString().length),
          );
          area.convert(selectedareaA, double.parse(inputA.text));

          units = area.getAll();

          _convValueBuild(units);
          inputB.text = unitDetails[selectedareaB] ?? "";
        } else if (inputBFN.hasFocus) {
          inputB.value = TextEditingValue(
            text: inputB.text.replaceRange(
                inputB.selection.start, inputB.selection.end, val),
            selection: TextSelection.collapsed(
                offset: inputB.selection.baseOffset + val.toString().length),
          );
          area.convert(selectedareaB, double.parse(inputB.text));

          units = area.getAll();

          _convValueBuild(units);
          inputA.text = unitDetails[selectedareaA] ?? "";
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      units = area.getAll();
      selectedareaA = AREA.acres;
      selectedareaB = AREA.squareMeters;
    });
    inputAFN.requestFocus();
    _convValueBuild(units);
  }

  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);
    area.significantFigures = settings.sigFig;
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
                          child: _inputView(context, 48),
                        ),
                        Expanded(child: _keypad(context, 1.42))
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _inputView(context, 48),
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
                      Expanded(child: _inputView(context, 32)),
                      Expanded(child: _keypad(context, 2.4)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _inputView(context, 48),
                      ),
                      _keypad(context, 1.8)
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

  Widget _keypad(BuildContext context, double cellSizeRatio) {
    return GridView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: cellSizeRatio),
      children: [
        FilledButton(
            onPressed: () {
              if (inputBFN.hasFocus) {
                inputBFN.unfocus();
                inputAFN.requestFocus();
              } else if (inputAFN.hasFocus) {
                inputAFN.unfocus();
                inputBFN.requestFocus();
              }
            },
            child: Transform.rotate(
              angle: 90 * pi / 180,
              child: const Icon(
                Icons.compare_arrows,
                size: 32,
              ),
            )),
        _buildButtons("C", false),
        FilledButton(
            onPressed: () {
              _bkspc();

              HapticFeedback.lightImpact();
            },
            child: const Icon(
              Icons.backspace_outlined,
              size: 32,
            )),
        _buildButtons("7", true),
        _buildButtons("8", true),
        _buildButtons("9", true),
        _buildButtons("4", true),
        _buildButtons("5", true),
        _buildButtons("6", true),
        _buildButtons("1", true),
        _buildButtons("2", true),
        _buildButtons("3", true),
        const FilledButton.tonal(
            onPressed: null,
            child: Text(
              "\u00b1",
              style: TextStyle(
                fontSize: 32,
              ),
            )),
        _buildButtons("0", true),
        _buildButtons(".", true),
      ],
    );
  }

  Widget _inputView(BuildContext context, double fontsize) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          DropdownMenu(
            dropdownMenuEntries: List.generate(
              units.length,
              growable: false,
              (index) {
                var unit = units[index];
                return DropdownMenuEntry(
                  value: unit.name,
                  label: unit.name.toString().split("AREA.").last.capitalize(),
                );
              },
            ),
            initialSelection: selectedareaA,
            onSelected: (value) {
              setState(() {
                selectedareaA = value;
              });
              if (inputAFN.hasFocus) {
                if (inputA.text.isNotEmpty) {
                  area.convert(value, double.parse(inputA.text));
                  units = area.getAll();

                  _convValueBuild(units);
                  inputB.text = unitDetails[selectedareaB] ?? "";
                }
              } else if (inputBFN.hasFocus) {
                if (inputB.text.isNotEmpty) {
                  area.convert(selectedareaB, double.parse(inputB.text));
                  units = area.getAll();

                  _convValueBuild(units);
                  inputA.text = unitDetails[value] ?? "";
                }
              }
            },
          ),
          TextField(
            enableSuggestions: false,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixText: selectedareaSymbolA.toString(),
            ),
            controller: inputA,
            focusNode: inputAFN,
            onChanged: (value) {
              if (inputAFN.hasFocus) {
                _conv(selectedareaA, value, inputB);
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[a-z] [A-Z] :$'))
            ],
            style: TextStyle(
              fontSize: fontsize,
            ),
            keyboardType: TextInputType.none,
          ),
          const Divider(),
          DropdownMenu(
            dropdownMenuEntries: List.generate(
              units.length,
              growable: false,
              (index) {
                var unit = units[index];
                return DropdownMenuEntry(
                  value: unit.name,
                  label: unit.name.toString().split("AREA.").last.capitalize(),
                );
              },
            ),
            initialSelection: selectedareaB,
            onSelected: (value) {
              setState(() {
                selectedareaB = value;
              });
              if (inputBFN.hasFocus) {
                if (inputB.text.isNotEmpty) {
                  area.convert(value, double.parse(inputB.text));
                  units = area.getAll();

                  _convValueBuild(units);
                  inputA.text = unitDetails[selectedareaA] ?? "";
                }
              } else if (inputAFN.hasFocus) {
                if (inputA.text.isNotEmpty) {
                  area.convert(selectedareaA, double.parse(inputA.text));
                  units = area.getAll();

                  _convValueBuild(units);
                  inputB.text = unitDetails[value] ?? "";
                }
              }
            },
          ),
          TextField(
            enableSuggestions: false,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixText: selectedareaSymbolB.toString(),
            ),
            controller: inputB,
            focusNode: inputBFN,
            onChanged: (value) {
              if (inputBFN.hasFocus) {
                _conv(selectedareaB, value, inputA);
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[a-z] [A-Z] :$'))
            ],
            style: TextStyle(
              fontSize: fontsize,
            ),
            keyboardType: TextInputType.none,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(String label, bool tonal) {
    return tonal
        ? SizedBox(
            height: 32,
            width: 72,
            child: FilledButton.tonal(
                onPressed: () {
                  _convFunc(label);
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                )),
          )
        : SizedBox(
            height: 32,
            width: 72,
            child: FilledButton(
                onPressed: () {
                  _convFunc(label);
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                )),
          );
  }
}
