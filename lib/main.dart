import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nmap_gui/models/nmap_command.dart';
import 'package:provider/provider.dart';
import 'package:glog/glog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

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
  runApp(ChangeNotifierProvider(
      create: (_) => NMapCommand(arguments: ['172.24.0.1-32']),
      child: const MyApp()));
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

class ExecPage extends StatefulWidget {
  const ExecPage({Key? key}) : super(key: key);

  @override
  State<ExecPage> createState() => _ExecPageState();
}

class _ExecPageState extends State<ExecPage> {
  GLog log = GLog('ExecPage', properties: gLogPropALL);
  TextEditingController ipAddressCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String? result = Provider.of<NMapCommand>(context, listen: true).stdOut;
    bool inProgress =
        Provider.of<NMapCommand>(context, listen: true).inProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('nmap'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Target Address(es):'),
                  ),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                        width: 120,
                        child: TextField(
                          controller: ipAddressCtrl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText:
                                'Enter an IP address, IP range or network',
                          ),
                        )),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: MouseRegion(
              cursor: inProgress
                  ? SystemMouseCursors.wait
                  : SystemMouseCursors.basic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Neumorphic(
                        style: const NeumorphicStyle(
                          border:
                              NeumorphicBorder(width: 3, color: Colors.black12),
                          shape: NeumorphicShape.convex,
                          depth: -10,
                          lightSource: LightSource.topRight,
                          color: Colors.white38,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                              child: Text(
                            result ?? '',
                            overflow: TextOverflow.visible,
                          )),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Provider.of<NMapCommand>(context, listen: false)
                                  .clear();
                            },
                            child: const Text('CLEAR')),
                        ElevatedButton(
                            onPressed: () {
                              String ipAddress = ipAddressCtrl.value.text;
                              if (ipAddress.isNotEmpty) {
                                log.debug('onPressed: setting ip address to '
                                    '$ipAddress');
                                Provider.of<NMapCommand>(context, listen: false)
                                    .arguments = [ipAddress];
                              }
                              Provider.of<NMapCommand>(context, listen: false)
                                  .clear();
                              Provider.of<NMapCommand>(context, listen: false)
                                  .start();
                            },
                            child: const Text('START'))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
