import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/controllers/edit_profile_controllers.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/models/nmap_xml.dart';
import 'package:fnmap/models/help_text.dart';
import 'package:fnmap/models/validity_notifier.dart';
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
    size: Size(1200, 900),
    minimumSize: Size(900, 880),
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
  NLog.setPackage(packageName: 'NFECommand', enabled: false);
  NLog.setPackage(packageName: 'Kriol Widgets', enabled: false);
  NLog.setPackage(packageName: 'TARGET_DEBUG', enabled: false);
  NLog.setLogFlag(flag: nLogDEFAULT);
  NLog.setLogFlag(flag: nLogTRACE);
  NLog('fnmap<main>:', type: NLogType.simple, package: kPackageName)
      .debug('fnmap started');

  ScanProfile profile = ScanProfile(fileName: kProfileFilename);
  await profile.parse();

  FnMapConfig config = FnMapConfig(fileName: kConfigFilename);
  await config.parse();

  QuickScanController qsController = QuickScanController(profile: profile);
  String commandLine = qsController.key == null
      ? qsController.choiceMap.values.first
      : qsController.choiceMap[qsController.key]!;

  NMapCommand nMapCommand =
      NMapCommand.fromCommandLine(commandLine);

  EditProfileControllers profileControllers = EditProfileControllers(nfeCommand: nMapCommand.command);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowParams().then((_) {
      runApp(MultiProvider(providers: [
        ChangeNotifierProvider.value(value: nMapCommand),
        ChangeNotifierProvider.value(value: qsController),
        ChangeNotifierProvider.value(value: profile),
        ChangeNotifierProvider.value(value: config),
        ChangeNotifierProvider.value(value: profileControllers),
        ChangeNotifierProvider(create: (_) => NMapXML()),
        ChangeNotifierProvider(create: (_) => NMapDarkMode()),
        ChangeNotifierProvider(create: (_) => HelpText()),
        ChangeNotifierProvider(create: (_) => ValidityNotifier()),
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
        theme: mode.light,
        darkTheme: mode.dark,
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
