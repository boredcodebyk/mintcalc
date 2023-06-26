import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:units_converter/units_converter.dart';

import '../../models/settings_model.dart';
import '../settings_page.dart';

class MassConv extends StatefulWidget {
  const MassConv({Key? key}) : super(key: key);
  static String pageTitle = "Mass";

  @override
  State<MassConv> createState() => _MassConvState();
}

class _MassConvState extends State<MassConv> {
  TextEditingController inputA = TextEditingController();
  FocusNode inputAFN = FocusNode();
  TextEditingController inputB = TextEditingController();
  FocusNode inputBFN = FocusNode();

  var selectedMassA;
  var selectedMassB;
  var selectedMassSymbolA;
  var selectedMassSymbolB;
  var mass = Mass(significantFigures: 7, removeTrailingZeros: true);
  var units = [];

  void _bkspc() {
    if (inputAFN.hasFocus) {
      if (inputA.text.isNotEmpty) {
        setState(() {
          inputA.text = inputA.text.substring(0, inputA.text.length - 1);
        });
        if (inputA.text.isNotEmpty) {
          mass.convert(selectedMassA, double.parse(inputA.text));

          units = mass.getAll();

          _convValueBuild(units);
          inputB.text = unitDetails[selectedMassB] ?? "";
        } else {
          setState(() {
            inputA.text = "";
            inputB.text = "";
          });
        }
      }
    } else if (inputBFN.hasFocus) {
      if (inputB.text.isNotEmpty) {
        setState(() {
          inputB.text = inputB.text.substring(0, inputB.text.length - 1);
        });

        if (inputA.text.isNotEmpty) {
          mass.convert(selectedMassB, double.parse(inputB.text));
          units = mass.getAll();

          _convValueBuild(units);
          inputA.text = unitDetails[selectedMassA] ?? "";
        } else {
          setState(() {
            inputA.text = "";
            inputB.text = "";
          });
        }
      }
    }
  }

  Map<dynamic, String> unitDetails = {};

  void _convValueBuild(unitsconv) {
    for (Unit unit in unitsconv) {
      if (unit.name == selectedMassA) {
        setState(() {
          selectedMassSymbolA = unit.symbol;
        });
      } else if (unit.name == selectedMassB) {
        setState(() {
          selectedMassSymbolB = unit.symbol;
        });
      }
      unitDetails.addAll({unit.name: unit.stringValue ?? ""});
    }
  }

  void _conv(selectedUnit, val, TextEditingController input) {
    mass.convert(selectedUnit, val);

    units = mass.getAll();

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
          mass.convert(selectedMassA, double.parse(inputA.text));

          units = mass.getAll();

          _convValueBuild(units);
          inputB.text = unitDetails[selectedMassB] ?? "";
        } else if (inputBFN.hasFocus) {
          inputB.value = TextEditingValue(
            text: inputB.text.replaceRange(
                inputB.selection.start, inputB.selection.end, val),
            selection: TextSelection.collapsed(
                offset: inputB.selection.baseOffset + val.toString().length),
          );
          mass.convert(selectedMassB, double.parse(inputB.text));

          units = mass.getAll();

          _convValueBuild(units);
          inputA.text = unitDetails[selectedMassA] ?? "";
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      units = mass.getAll();
      selectedMassA = MASS.kilograms;
      selectedMassB = MASS.grams;
    });
    inputAFN.requestFocus();
    _convValueBuild(units);
  }

  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);
    mass.significantFigures = settings.sigFig;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
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
                        label: unit.name
                            .toString()
                            .split("MASS.")
                            .last
                            .capitalize(),
                      );
                    },
                  ),
                  initialSelection: selectedMassA,
                  onSelected: (value) {
                    setState(() {
                      selectedMassA = value;
                    });
                    if (inputAFN.hasFocus) {
                      if (inputA.text.isNotEmpty) {
                        mass.convert(value, double.parse(inputA.text));
                        units = mass.getAll();

                        _convValueBuild(units);
                        inputB.text = unitDetails[selectedMassB] ?? "";
                      }
                    } else if (inputBFN.hasFocus) {
                      if (inputB.text.isNotEmpty) {
                        mass.convert(selectedMassB, double.parse(inputB.text));
                        units = mass.getAll();

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
                    suffixText: selectedMassSymbolA.toString(),
                  ),
                  controller: inputA,
                  focusNode: inputAFN,
                  onChanged: (value) {
                    if (inputAFN.hasFocus) {
                      _conv(selectedMassA, value, inputB);
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[a-z] [A-Z] :$'))
                  ],
                  style: const TextStyle(
                    fontSize: 48,
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
                        label: unit.name
                            .toString()
                            .split("MASS.")
                            .last
                            .capitalize(),
                      );
                    },
                  ),
                  initialSelection: selectedMassB,
                  onSelected: (value) {
                    setState(() {
                      selectedMassB = value;
                    });
                    if (inputBFN.hasFocus) {
                      if (inputB.text.isNotEmpty) {
                        mass.convert(value, double.parse(inputB.text));
                        units = mass.getAll();

                        _convValueBuild(units);
                        inputA.text = unitDetails[selectedMassA] ?? "";
                      }
                    } else if (inputAFN.hasFocus) {
                      if (inputA.text.isNotEmpty) {
                        mass.convert(selectedMassA, double.parse(inputA.text));
                        units = mass.getAll();

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
                    suffixText: selectedMassSymbolB.toString(),
                  ),
                  controller: inputB,
                  focusNode: inputBFN,
                  onChanged: (value) {
                    if (inputBFN.hasFocus) {
                      _conv(selectedMassB, value, inputA);
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[a-z] [A-Z] :$'))
                  ],
                  style: const TextStyle(
                    fontSize: 48,
                  ),
                  keyboardType: TextInputType.none,
                ),
              ],
            ),
          ),
          GridView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.8),
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
                  onPressed: () => _bkspc(),
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
          )
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
                onPressed: () => _convFunc(label),
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
                onPressed: () => _convFunc(label),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                )),
          );
  }
}