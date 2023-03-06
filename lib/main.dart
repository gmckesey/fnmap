import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:glog/glog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:window_manager/window_manager.dart';
import 'package:nmap_gui/models/nmap_command.dart';
import 'package:nmap_gui/widgets/exec_page.dart';

Future setWindowParams() async {
  WidgetsFlutterBinding.ensureInitialized();
/*
  await DesktopWindow.setWindowSize(const Size(800,600));
  await DesktopWindow.setMinWindowSize(const Size(480,420));
  // await DesktopWindow.setMaxWindowSize(Size.infinite);*/
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    title: 'nmap',
    size: Size(600, 600),
    minimumSize: Size(480, 420),
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

void main() {
  if (kDebugMode) {
    GLog.setLevel(LogLevel.debug);
    GLog.setLogFlags(gLogPropCondition |
        gLogPropTrace |
        gLogUtilityTrace /* | gLogPropBugFix*/);
    GLog.setClassProperties(0);
  } else {
    GLog.setLevel(LogLevel.info);
  }

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowParams().then((_) {
      runApp(ChangeNotifierProvider(
          create: (_) => NMapCommand(arguments: ['172.24.0.1-32']),
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
    Provider.of<NMapCommand>(context, listen: false).start();
  }

  @override
  Widget build(BuildContext context) {
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
