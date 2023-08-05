import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/constants.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/models/nmap_xml.dart';
import 'package:fnmap/widgets/exec_page.dart';
import 'package:fnmap/widgets/quick_scan_dropdown.dart';
import 'package:fnmap/utilities/scan_profile.dart';
import 'package:fnmap/utilities/fnmap_config.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/dialogs/edit_profile.dart';

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
    NLog.setLevel(Level.debug);
  } else {
    NLog.setLevel(Level.warning);
  }

  // NLog.setPackage(packageName: nLogDEFAULT, enabled: false);
  NLog.setPackage(packageName: kPackageName, enabled: true);
  NLog.setLogFlag(flag: nLogDEFAULT);
  NLog.setLogFlag(flag: nLogTRACE);
  NLog('fnmap<main>:', type: NLogType.simple, package: kPackageName)
      .debug('fnmap started');

  ScanProfile profile = ScanProfile(fileName: kProfileFilename);
  await profile.parse();

  FnMapConfig config = FnMapConfig(fileName: kConfigFilename);
  await config.parse();

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
      ], child: const MyApp()));
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
    Provider.of<NMapDarkMode>(context, listen: false)
        .initialize(rootContext: context);
  }

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);

    return MaterialApp(
        title: 'fnmap',
        theme: mode.themeData,
        initialRoute: '/',
        routes: {
          '/': (context) =>
              const DefaultTabController(length: 5, child: ExecPage()),
          '/newProfile': (context) =>
          const EditProfile(edit: false, delete: false),
          '/editProfile': (context) =>
              const EditProfile(edit: true, delete: false),
          '/deleteProfile': (context) =>
          const EditProfile(edit: false, delete: true),
        });
  }
}
