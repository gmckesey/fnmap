import 'dart:io';
import 'package:menu_bar/menu_bar.dart';
import 'package:provider/provider.dart';
import 'package:glog/glog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:nmap_gui/models/nmap_command.dart';

class ExecPage extends StatefulWidget {
  const ExecPage({Key? key}) : super(key: key);

  @override
  State<ExecPage> createState() => _ExecPageState();
}

class _ExecPageState extends State<ExecPage> {
  GLog log = GLog('ExecPage', properties: gLogPropALL);
  TextEditingController ipAddressCtrl = TextEditingController();
  TextEditingController optionsCtrl = TextEditingController();
  final ScrollController _outputCtrl = ScrollController();
  late bool _aborted;

  @override
  void initState() {
    super.initState();
    _aborted = false;
  }

  _scrollToEnd() async {
    var scrollPosition = _outputCtrl.position;
    bool needScroll =
        scrollPosition.viewportDimension < scrollPosition.maxScrollExtent;
    if (needScroll) {
      _outputCtrl.animateTo(scrollPosition.maxScrollExtent,
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? result = Provider.of<NMapCommand>(context, listen: true).stdOut;
    bool inProgress =
        Provider.of<NMapCommand>(context, listen: true).inProgress;

    if (_aborted && result != null) {
      result += '\nAborted by user.';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());

    Widget scaffold = Scaffold(
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
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Command Line Options:'),
                  ),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                        width: 120,
                        child: TextField(
                          controller: optionsCtrl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Command Line Options',
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
                              controller: _outputCtrl,
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
                        MaterialButton(
                            color: Colors.lightBlue,
                            hoverColor: Colors.lightBlueAccent,
                            disabledColor: Colors.grey,
                            onPressed: !(Provider.of<NMapCommand>(context,
                                listen: true)
                                .inProgress)
                                ? null
                                : () {
                              _aborted = true;
                              Provider.of<NMapCommand>(context,
                                  listen: false)
                                  .stop();
                            },
                            child: const Text('ABORT')),
                        MaterialButton(
                            color: Colors.lightBlue,
                            hoverColor: Colors.lightBlueAccent,
                            onPressed: () {
                              _aborted = false;
                              Provider.of<NMapCommand>(context, listen: false)
                                  .clear();
                            },
                            child: const Text('CLEAR')),
                        MaterialButton(
                            color: Colors.lightBlue,
                            hoverColor: Colors.lightBlueAccent,
                            disabledColor: Colors.grey,
                            onPressed:
                            (Provider.of<NMapCommand>(context, listen: true)
                                .inProgress)
                                ? null
                                : () {
                              String argumentText =
                                  optionsCtrl.value.text;
                              _aborted = false;
                              String ipAddress =
                                  ipAddressCtrl.value.text;
                              List<String> args;
                              if (argumentText.isNotEmpty) {
                                args = optionsCtrl.value.text
                                    .split(RegExp(r' +'));
                              } else {
                                args = [];
                              }
                              if (ipAddress.isNotEmpty) {
                                log.debug(
                                    'onPressed: setting ip address to '
                                        '$ipAddress');
                                if (ipAddress.isNotEmpty) {
                                  Provider.of<NMapCommand>(context,
                                      listen: false)
                                      .arguments = [ipAddress];
                                } else {
                                  ipAddress = '172.24.0.1-100';
                                }
                                if (args.isNotEmpty) {
                                  Provider.of<NMapCommand>(context,
                                      listen: false)
                                      .arguments!
                                      .addAll(args);
                                }
                              }
                              Provider.of<NMapCommand>(context,
                                  listen: false)
                                  .clear();
                              Provider.of<NMapCommand>(context,
                                  listen: false)
                                  .start();
                            },
                            child: const Text('SCAN'))
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
    Widget w;
    if (Platform.isLinux || Platform.isWindows) {
      w = MenuBar(
        barButtons: [
          BarButton(
            text: const Text('File', style: TextStyle(color: Colors.white)),
            submenu: SubMenu(
              menuItems: [
                MenuButton(
                  text: const Text('Save'),
                  onTap: () {},
                  icon: const Icon(Icons.save),
                  shortcutText: 'Ctrl+S',
                ),
                const MenuDivider(),
                MenuButton(
                  text: const Text('Exit'),
                  onTap: () {},
                  icon: const Icon(Icons.exit_to_app),
                  shortcutText: 'Ctrl+Q',
                ),
              ],
            ),
          ),
          BarButton(
            text: const Text('Help', style: TextStyle(color: Colors.white)),
            submenu: SubMenu(
              menuItems: [
                MenuButton(
                  text: const Text('View License'),
                  onTap: () {},
                ),
                MenuButton(
                  text: const Text('About'),
                  onTap: () {},
                  icon: const Icon(Icons.info),
                ),
              ],
            ),
          ),
        ],
        child: scaffold,
      );
    } else {
      w = scaffold;
    }
    return w;
  }
}
