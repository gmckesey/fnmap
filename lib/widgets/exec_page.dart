import 'dart:io';
import 'package:menu_bar/menu_bar.dart';
import 'package:nmap_gui/constants.dart';
import 'package:provider/provider.dart';
import 'package:glog/glog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:nmap_gui/models/nmap_command.dart';
import 'package:nmap_gui/widgets/formatted_text.dart';
import 'package:nmap_gui/widgets/quick_scan_dropdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nmap_gui/utilities/ip_address_validator.dart';

class ExecPage extends StatefulWidget {
  const ExecPage({Key? key}) : super(key: key);

  @override
  State<ExecPage> createState() => _ExecPageState();
}

class _ExecPageState extends State<ExecPage> {
  GLog log = GLog('ExecPage', properties: gLogPropALL);
  TextEditingController ipAddressCtrl = TextEditingController();
  TextEditingController cmdLineTextCtrl = TextEditingController();
  final ScrollController _outputCtrl = ScrollController();
  late bool _aborted;
  late bool _ipFieldFilled;
  late bool _ipIsValid;

  @override
  void initState() {
    super.initState();
    _aborted = false;
    _ipFieldFilled = false;
    _ipIsValid = false;

    cmdLineTextCtrl.addListener(_commandLineChanged);
    QuickScanController qsController =
    Provider.of<QuickScanController>(context, listen: false);
    if (qsController.value != null) {
      cmdLineTextCtrl.text = qsController.value!;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    ipAddressCtrl.dispose();
    cmdLineTextCtrl.dispose();
    _outputCtrl.dispose();
    super.dispose();
  }

  // Scroll output window to the end
  _scrollToEnd() async {
    var scrollPosition = _outputCtrl.position;
    bool needScroll =
        scrollPosition.viewportDimension < scrollPosition.maxScrollExtent;
    if (needScroll) {
      _outputCtrl.animateTo(scrollPosition.maxScrollExtent,
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    }
  }

  void _commandLineChanged() {
    QuickScanController qsController =
        Provider.of<QuickScanController>(context, listen: false);

    log.debug('_commandLineChanged: command line ="${cmdLineTextCtrl.text}"');

    // Check if Quick Options and Command Line Options are in Sync
    if (qsController.key != null &&
        qsController.choiceMap[qsController.key] != cmdLineTextCtrl.text) {
      // Set qsController point to kCustomKey
      if (qsController.key != kCustomKey) {
        log.debug('_commandLineChanged: set '
            '"${qsController.key}" to "$kCustomKey"');
        if (qsController.choiceMap.containsKey(kCustomKey)) {
          qsController.map = {kCustomKey: qsController.choiceMap[kCustomKey]!};
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? result = Provider.of<NMapCommand>(context, listen: true).stdOut;
    QuickScanController qsController =
        Provider.of<QuickScanController>(context, listen: true);
    bool inProgress =
        Provider.of<NMapCommand>(context, listen: true).inProgress;

    // If the drop down has a value then set the commandLine to that value
    // String commandLine = qsController.value == null ? '' : qsController.value!;
    String commandLine = cmdLineTextCtrl.text;
    // Set the command line option text field value
    // optionsCtrl.text = commandLine;
/*    log.debug('build: dropdown = "${qsController.key}" '
        'command line = "$commandLine"');*/

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 100,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Target Address(es):'),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                      width: 120,
                      child: TextField(
                        controller: ipAddressCtrl,
                        decoration: InputDecoration(
                          filled: _ipFieldFilled,
                          fillColor: _ipIsValid ? kValidColor : kInvalidColor,
                          border: const OutlineInputBorder(),
                          hintText: 'Enter an IP address, IP range or network',
                        ),
                        onChanged: ((value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              _ipIsValid = isValidIPAddress(value);
                              _ipFieldFilled = true;
                            } else {
                              _ipFieldFilled = false;
                            }
                          });
                        }),
                      )),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(width: 80, child: Text('Quick Options:')),
                ),
                QuickScanDropDown(
                  controller: qsController,
                  onChanged: (option) {
                    log.debug(
                        'QuickScanDropDown - onChanged: Quick Options changed to "$option"');
                    setState(() {
                      cmdLineTextCtrl.text = qsController.choiceMap[option]!;
                    });
                  },
                ),
                const Spacer(flex: 2),
              ],
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
                          controller: cmdLineTextCtrl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Command Line Options',
                          ),
                          onChanged: (cmd) {
                            setState(() {
                              log.debug(
                                  'TextField - onChanged: text=$cmd dropdown = ${qsController.key}');
/*                              optionsCtrl.value = TextEditingValue(
                                  text: cmd, selection: TextSelection());*/
                              if (qsController.key != 'Custom') {
                                qsController.map = {'Custom': ''};
                              }
                            });
                          },
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
                              child: FormattedText(
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
                            onPressed: !inProgress
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
                            disabledColor: Colors.grey,
                            onPressed: inProgress
                                ? null
                                : () {
                                    _aborted = false;
                                    Provider.of<NMapCommand>(context,
                                            listen: false)
                                        .clear();
                                  },
                            child: const Text('CLEAR')),
                        MaterialButton(
                            color: Colors.lightBlue,
                            hoverColor: Colors.lightBlueAccent,
                            disabledColor: Colors.grey,
                            onPressed: inProgress || !_ipIsValid
                                ? null
                                : () {
                                    NMapCommand nMapCommand =
                                        Provider.of<NMapCommand>(context,
                                            listen: false);

                                    // Get Command Line from Controller
                                    String argumentText =
                                        cmdLineTextCtrl.value.text;
                                    _aborted = false;
                                    String ipAddress = ipAddressCtrl.value.text;
                                    List<String> args;
                                    if (argumentText.isNotEmpty) {
                                      args = cmdLineTextCtrl.value.text
                                          .split(RegExp(r' +'));
                                    } else {
                                      args = [];
                                    }
                                    if (ipAddress.isNotEmpty) {
                                      log.debug(
                                          'MaterialButton - onPressed: setting ip address to '
                                          '$ipAddress');
                                      if (ipAddress.isNotEmpty) {
                                        nMapCommand.target = ipAddress;
                                      } /*else {
                                        // TODO: Get rid of default address
                                        // TODO: Disable Scan button until a target address is chosen
                                        ipAddress = '172.24.0.1-100';
                                      }*/
                                      if (args.isNotEmpty) {
                                        nMapCommand.program = args.first;
                                        // Trying .. for the first time
                                        List<String> cmdList;
                                        if (args.length > 1) {
                                          cmdList = List<String>
                                              .filled(args.length - 1, '')
                                            ..setRange(
                                                0, args.length - 1, args, 1
                                            );
                                        } else {
                                          cmdList = [];
                                        }
                                        nMapCommand.setArguments(cmdList, notify: false);
                                      }
                                    }
                                    nMapCommand.clear();
                                    nMapCommand.start();
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
            text: const Text('Scan', style: TextStyle(color: Colors.white)),
            submenu: SubMenu(
              menuItems: [
                MenuButton(
                  text: const Text('Save Scan',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),
                  onTap: () {},
                  icon: const Icon(FontAwesomeIcons.solidFloppyDisk,
                      size: kDefaultIconSize), //const Icon(Icons.save),
                  shortcutText: 'Ctrl+S',
                ),
                MenuButton(
                  text: const Text('Load Scan',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),
                  onTap: () {},
                  icon: const Icon(FontAwesomeIcons.solidFolderOpen,
                      size: kDefaultIconSize), //const Icon(Icons.save),
                  shortcutText: 'Ctrl+L',
                ),
                const MenuDivider(),
                MenuButton(
                  text: const Text('Quit',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),

                  onTap: () {},
                  icon: const Icon(FontAwesomeIcons.rightFromBracket,
                      size: kDefaultIconSize), //const Icon(Icons.exit_to_app),
                  shortcutText: 'Ctrl+Q',
                ),
              ],
            ),
          ),
          BarButton(
            text: const Text('Profile', style: TextStyle(color: Colors.white)),
            submenu: SubMenu(
              menuItems: [
                MenuButton(
                  text: const Text('New Profile',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),
                  onTap: () {},
                  icon: const Icon(FontAwesomeIcons.arrowUpRightFromSquare,
                      size: kDefaultIconSize), //const Icon(Icons.copyright),
                ),
                MenuButton(
                  text: const Text(
                    'Edit Selected Profile',
                    style: TextStyle(fontSize: kDefaultMenuFontSize),
                  ),
                  onTap: () {},
                  icon: const Icon(FontAwesomeIcons.solidPenToSquare,
                      size: kDefaultIconSize), // const Icon(Icons.info),
                ),
              ],
            ),
          ),
          BarButton(
            text: const Text('Help', style: TextStyle(color: Colors.white)),
            submenu: SubMenu(
              menuItems: [
                MenuButton(
                  text: const Text('View License',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),
                  onTap: () {},
                  icon: const Icon(FontAwesomeIcons.solidCopyright,
                      size: kDefaultIconSize), //const Icon(Icons.copyright),
                ),
                MenuButton(
                  text: const Text('About',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),
                  onTap: () {},
                  icon: const Icon(FontAwesomeIcons.circleInfo,
                      size: kDefaultIconSize),
                  /*const FaIcon(
                      FontAwesomeIcons.circleInfo, size: kDefaultIconSize), */ // const Icon(Icons.info),
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
