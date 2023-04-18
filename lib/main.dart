import 'dart:io';
import 'package:nmap_gui/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:glog/glog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:window_manager/window_manager.dart';
import 'package:nmap_gui/models/nmap_command.dart';
import 'package:nmap_gui/models/nmap_xml.dart';
import 'package:nmap_gui/widgets/exec_page.dart';
import 'package:nmap_gui/widgets/quick_scan_dropdown.dart';
import 'package:nmap_gui/utilities/scan_profile.dart';
import 'package:nmap_gui/utilities/fnmap_config.dart';
import 'package:nmap_gui/models/dark_mode.dart';

Future setWindowParams() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: 'fnmap',
    size: Size(800, 600),
    minimumSize: Size(540, 540),
    center: true,
    backgroundColor: kDefaultColor,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

void main() async {
  if (kDebugMode) {
    GLog.setLevel(GLogLevel.debug);
    GLog.setLogFlag(flag: gLogTRACE);
    GLog.setLogFlag(flag: gLogDEFAULT, enabled: false);
    // Deprecated
    // GLog.setClassProperties(0);
  } else {
    GLog.setLevel(GLogLevel.info);
  }
  GLog.setPackage(packageName: kPackageName, enabled: true);
  GLog.setPackage(packageName: 'default', enabled: false);

  GLog log = GLog('fnmap<main>:', package: kPackageName);

  log.debug('fnmap started', flag: gLogALL, logType: GLogType.pretty);

  ScanProfile profile = ScanProfile(fileName: kProfileFilename);
  await profile.parse();

  FnMapConfig config = FnMapConfig(fileName: kConfigFilename);
  await config.parse();
/*  List<HighLightConfig> hConfigs =
      config.highlightsEnabled ? config.highlights() : [];*/

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowParams().then((_) {
      runApp(MultiProvider(providers: [
        ChangeNotifierProvider(
          create: (_) =>
              NMapCommand.fromCommandLine('nmap', target: '172.24.0.1-32'),
        ),
        ChangeNotifierProvider(
          create: (_) => QuickScanController(profile: profile),
        ),
        ChangeNotifierProvider.value(value: profile),
        ChangeNotifierProvider.value(value: config),
        ChangeNotifierProvider(create: (_) => NMapXML()),
        ChangeNotifierProvider(create: (_) => NMapDarkMode()),
      ],
      child: const MyApp()));
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Provider.of<NMapDarkMode>(context, listen: false).initialize(rootContext: context);
    // Provider.of<ScanProfile>(context, listen: false).parse();
    // Provider.of<NMapCommand>(context, listen: false).start();
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor getMaterialColor(Color color) {
      final int red = color.red;
      final int green = color.green;
      final int blue = color.blue;

      final Map<int, Color> shades = {
        50: Color.fromRGBO(red, green, blue, .1),
        100: Color.fromRGBO(red, green, blue, .2),
        200: Color.fromRGBO(red, green, blue, .3),
        300: Color.fromRGBO(red, green, blue, .4),
        400: Color.fromRGBO(red, green, blue, .5),
        500: Color.fromRGBO(red, green, blue, .6),
        600: Color.fromRGBO(red, green, blue, .7),
        700: Color.fromRGBO(red, green, blue, .8),
        800: Color.fromRGBO(red, green, blue, .9),
        900: Color.fromRGBO(red, green, blue, 1),
      };

      return MaterialColor(color.value, shades);
    }

    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);

    return MaterialApp(
      title: 'fnmap',
      theme: mode.themeData,
      home: const DefaultTabController(length: 5, child: ExecPage()),
    );
  }
}
