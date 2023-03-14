import 'dart:io';
import 'package:nmap_gui/constants.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:nmap_gui/utilities/ip_address_validator.dart';
import 'package:provider/provider.dart';
import 'package:glog/glog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:window_manager/window_manager.dart';
import 'package:nmap_gui/models/nmap_command.dart';
import 'package:nmap_gui/widgets/exec_page.dart';
import 'package:nmap_gui/widgets/quick_scan_dropdown.dart';
import 'package:nmap_gui/utilities/scan_profile.dart';
import 'package:nmap_gui/utilities/fnmap_config.dart';
import 'package:nmap_gui/utilities/cidr_address.dart';
import 'package:validators/validators.dart' as valid;
import 'package:nmap_gui/utilities/ip_address_validator.dart';

Future setWindowParams() async {
  WidgetsFlutterBinding.ensureInitialized();
/*
  await DesktopWindow.setWindowSize(const Size(800,600));
  await DesktopWindow.setMinWindowSize(const Size(480,420));
  // await DesktopWindow.setMaxWindowSize(Size.infinite);*/
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: 'nmap',
    size: Size(800, 600),
    minimumSize: Size(540, 540),
    center: true,
    backgroundColor: Colors.teal,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

void testCidr() async {
  List<String> testData = <String>[
    '172.24.0.1',
    '172.24.0.1-64',
    '127.0.0.1',
    '10.23.0',
    '172.24.0.0/22',
    '192.168.4.0/24',
    '172.24.0.0/255.255.0.0',
    'google.com',
    'news.com',
    'finance.google.com',
  ];
  GLog log = GLog('testCidr:', properties: gLogPropALL);
  for (var address in testData) {
    AddressType t = addressType(address);
    switch (t) {
      case AddressType.cidr:
        log.debug('address [$address] is a valid CIDR');
        break;
      case AddressType.ipAddress:
        log.debug('address [$address] is a valid an IP address');
        break;
      case AddressType.fqdn:
        log.debug('address [$address] is a valid FQDN');
        break;
      case AddressType.ipRange:
        log.debug('address [$address] is a valid IP address range');
        break;
      default:
        log.debug('address [$address] is an unrecognized format');
        break;
    }
  }
}

void main() async {
  if (kDebugMode) {
    GLog.setLevel(LogLevel.debug);
    GLog.setLogFlags(gLogPropCondition |
        gLogPropTrace |
        gLogUtilityTrace /* | gLogPropBugFix*/);
    GLog.setClassProperties(0);
  } else {
    GLog.setLevel(LogLevel.info);
  }

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
    // Provider.of<ScanProfile>(context, listen: false).parse();
    // Provider.of<NMapCommand>(context, listen: false).start();
  }

  @override
  Widget build(BuildContext context) {
    ScanProfile profile = Provider.of<ScanProfile>(context, listen: true);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lightBlue,
      ),
      home: const ExecPage(),
    );
  }
}
