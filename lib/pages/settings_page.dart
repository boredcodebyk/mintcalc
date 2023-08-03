import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/settings_model.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});
  final TextEditingController sigFigInput = TextEditingController();
  Route _createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("Settings"),
          ),
          SliverToBoxAdapter(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text("Theme"),
                  onTap: () =>
                      Navigator.push(context, _createRoute(const ThemePage())),
                ),
                ListTile(
                  leading: const Icon(Icons.exposure_zero_outlined),
                  title: const Text("Set Significant Figures"),
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        sigFigInput.text = settings.sigFig.toString();
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AlertDialog(
                            title: Text(
                              "Set significant figures",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                    "This settings is exclusively for unit convertors"),
                                TextField(
                                  textAlign: TextAlign.end,
                                  keyboardType: TextInputType.number,
                                  controller: sigFigInput,
                                  onChanged: (value) => value.isNotEmpty
                                      ? settings.sigFig = int.parse(value)
                                      : settings.sigFig = 7,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  settings.sigFig = int.parse(sigFigInput.text);
                                  Navigator.pop(context);
                                },
                                child: const Text("Set"),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("About"),
                  onTap: () =>
                      Navigator.push(context, _createRoute(const About())),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  static const platform =
      MethodChannel('bored.codebyk.mintcalc/androidversion');

  int av = 0;
  Future<int> androidVersion() async {
    final result = await platform.invokeMethod('getAndroidVersion');
    return await result;
  }

  void fetchVersion() async {
    final v = await androidVersion();
    setState(() {
      av = v;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchVersion();
  }

  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("Theme"),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SegmentedButton(
                    segments: const [
                      ButtonSegment(
                          value: ThemeMode.system, label: Text("System")),
                      ButtonSegment(
                          value: ThemeMode.light, label: Text("Light")),
                      ButtonSegment(value: ThemeMode.dark, label: Text("Dark")),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (p0) {
                      settings.themeMode = p0.first;
                    },
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    SwitchListTile(
                      value: settings.isSystemColor,
                      onChanged: av >= 31
                          ? (value) => settings.isSystemColor = value
                          : null,
                      title: const Text("Use system color scheme"),
                      subtitle: Text(settings.isSystemColor
                          ? "Using system dynamic color"
                          : "Using default color scheme"),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar.large(
          title: const Text("About"),
        ),
        SliverToBoxAdapter(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("App Version"),
                subtitle: Text("1.1.0"),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("Licenses"),
                onTap: () => showLicensePage(
                    context: context,
                    applicationName: "Mint Calculator",
                    applicationVersion: "1.1.0"),
              ),
              ListTile(
                leading: SvgPicture.asset(
                  Theme.of(context).brightness == Brightness.light
                      ? "assets/github-mark.svg"
                      : "assets/github-mark-white.svg",
                  semanticsLabel: 'Github',
                  height: 24,
                  width: 24,
                ),
                title: const Text("Github"),
                onTap: () async {
                  const url = 'https://github.com/boredcodebyk/mintcalc';
                  if (!await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

extension StringExtension on String {
  /// Capitalize the first letter of a word
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
