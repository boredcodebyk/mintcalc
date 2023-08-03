import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import './pages/pages.dart';
import 'models/settings_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsmodel = SettingsModel();
  settingsmodel.load();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: settingsmodel),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
    ));

    final defaultLightColorScheme = ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 217, 229, 129));

    final defaultDarkColorScheme = ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 217, 229, 129),
        brightness: Brightness.dark);

    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'Mint Calc',
          theme: ThemeData(
            colorScheme: settings.isSystemColor
                ? lightColorScheme
                : defaultLightColorScheme,
            fontFamily: 'Manrope',
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: settings.isSystemColor
                ? darkColorScheme
                : defaultDarkColorScheme,
            fontFamily: 'Manrope',
            useMaterial3: true,
          ),
          themeMode: settings.themeMode,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List _pages = [
    StdCalc(),
    SciCalc(),
    DateCalc(),
    AngleConv(),
    TemperatureConv(),
    DataConv(),
    TimeConv(),
    AreaConv(),
    LengthConv(),
    VolumeConv(),
    MassConv(),
    PressureConv(),
    SpeedConv(),
    PowerConv(),
    EnergyConv(),
  ];
  final _pageTitles = {
    StdCalc: StdCalc.pageTitle,
    SciCalc: SciCalc.pageTitle,
    DateCalc: DateCalc.pageTitle,
    AngleConv: AngleConv.pageTitle,
    TemperatureConv: TemperatureConv.pageTitle,
    DataConv: DataConv.pageTitle,
    TimeConv: TimeConv.pageTitle,
    AreaConv: AreaConv.pageTitle,
    LengthConv: LengthConv.pageTitle,
    VolumeConv: VolumeConv.pageTitle,
    MassConv: MassConv.pageTitle,
    PressureConv: PressureConv.pageTitle,
    SpeedConv: SpeedConv.pageTitle,
    PowerConv: PowerConv.pageTitle,
    EnergyConv: EnergyConv.pageTitle
  };
  int selectedIndex = 0;

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
    String appBarText = _pageTitles[_pages[selectedIndex].runtimeType] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.push(context, _createRoute(SettingsPage())),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: _pages.elementAt(selectedIndex),
      drawer: NavigationDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() {
          selectedIndex = value;
          Navigator.pop(context);
        }),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Calculator',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: Text("Standard"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: Text("Scientific"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.date_range_outlined),
            selectedIcon: Icon(Icons.date_range),
            label: Text("Date"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Converter',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.architecture),
            selectedIcon: Icon(Icons.architecture),
            label: Text("Angle"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.thermostat),
            selectedIcon: Icon(Icons.thermostat),
            label: Text("Temperature"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.sd_card_outlined),
            selectedIcon: Icon(Icons.sd_card),
            label: Text("Data"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.watch_later_outlined),
            selectedIcon: Icon(Icons.watch_later),
            label: Text("Time"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.crop),
            selectedIcon: Icon(Icons.crop),
            label: Text("Area"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.straighten),
            selectedIcon: Icon(Icons.straighten),
            label: Text("Length"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.free_breakfast_outlined),
            selectedIcon: Icon(Icons.free_breakfast),
            label: Text("Volume"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.scale_outlined),
            selectedIcon: Icon(Icons.scale),
            label: Text("Mass"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.speed),
            selectedIcon: Icon(Icons.speed),
            label: Text("Pressure"),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.run_circle_outlined),
            selectedIcon: Icon(Icons.run_circle),
            label: Text("Speed"),
          ),
        ],
      ),
    );
  }
}
