import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:menu_bar/menu_bar.dart';
import 'package:nmap_gui/models/host_record.dart';
import 'package:nmap_gui/widgets/device_details.dart';
import 'package:nmap_gui/widgets/service_view.dart';
import 'package:xml/xml.dart';
import 'package:nmap_gui/constants.dart';
import 'package:nmap_gui/widgets/device_view.dart';
import 'package:nmap_gui/widgets/port_view.dart';
import 'package:provider/provider.dart';
import 'package:glog/glog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:nmap_gui/models/nmap_command.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nmap_gui/widgets/quick_scan_dropdown.dart';
import 'package:nmap_gui/utilities/ip_address_validator.dart';
import 'package:nmap_gui/models/nmap_xml.dart';
import 'package:nmap_gui/models/dark_mode.dart';
import 'package:nmap_gui/widgets/raw_output_widget.dart';
import 'package:nmap_gui/widgets/nmap_tabular.dart';

class ExecPage extends StatefulWidget {
  const ExecPage({Key? key}) : super(key: key);

  @override
  State<ExecPage> createState() => _ExecPageState();
}

class _ExecPageState extends State<ExecPage> {
  GLog log = GLog('ExecPage', flag: gLogTRACE, package: kPackageName);
  TextEditingController ipAddressCtrl = TextEditingController();
  TextEditingController optionsCtrl = TextEditingController();
  TextEditingController targetCtrl = TextEditingController(text: 'item 3');
  final TrackingScrollController _outputCtrl =
      TrackingScrollController(keepScrollOffset: true);
  late bool _aborted;
  late bool _ipFieldFilled;
  late bool _ipIsValid;
  late double _scrollOffset;
  late NMapScrollOffset _outputPosition;
  List<String> dropdownItems = ['item 1', 'default', 'item 2', 'item 3'];
  late NMapViewController _hostViewController;
  late NMapServiceViewController _serviceViewController;
  String? saveFName;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    // log.debug('initState called.', color: LogColor.red);
    _aborted = false;
    _ipFieldFilled = false;
    _ipIsValid = false;
    _outputPosition = NMapScrollOffset(0.0);
    _hostViewController = NMapViewController();
    _serviceViewController = NMapServiceViewController();
    _darkMode = false;

    optionsCtrl.addListener(_commandLineChanged);
    _outputCtrl.addListener(() {
      _outputPosition.offset = _outputCtrl.offset;
      log.debug('scrollController<listener>: position is '
          '${_outputCtrl.offset}');
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    ipAddressCtrl.dispose();
    optionsCtrl.dispose();
    targetCtrl.dispose();
    _outputCtrl.dispose();
    _hostViewController.dispose();
    _serviceViewController.dispose();
    super.dispose();
  }

  void _commandLineChanged() {
    QuickScanController qsController =
        Provider.of<QuickScanController>(context, listen: false);

    log.debug('_commandLineChanged: command line ="${optionsCtrl.text}"');

    // Check if Quick Options and Command Line Options are in Sync
    if (qsController.key != null &&
        qsController.choiceMap[qsController.key] != optionsCtrl.text) {
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
    NMapCommand nMapCommand = Provider.of<NMapCommand>(context, listen: true);
    String? result = nMapCommand.stdOut;
    QuickScanController qsController =
        Provider.of<QuickScanController>(context, listen: true);
    bool inProgress = nMapCommand.inProgress;
    NMapXML nMapXML = Provider.of<NMapXML>(context, listen: true);
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    Color foregroundColor = Theme.of(context).secondaryHeaderColor;
    Color defaultColor = Theme.of(context).primaryColor;
    Color textColor = Theme.of(context).primaryColorLight;

    // If the drop down has a value then set the commandLine to that value
    // String commandLine = qsController.value == null ? '' : qsController.value!;
    String commandLine = optionsCtrl.text;
    // Set the command line option text field value
    // optionsCtrl.text = commandLine;
    log.debug('build: dropdown = "${qsController.key}" '
        'command line = "$commandLine"');

    if (_aborted && result != null) {
      result += '\nAborted by user.';
    }

    Widget scaffold = Scaffold(
/*      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('nmap'),
        ),
      ),*/
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
                      optionsCtrl.text = qsController.choiceMap[option]!;
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
                          controller: optionsCtrl,
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
          TabBar(
            labelColor: Theme.of(context).primaryColorDark,
            tabs: const [
              Tab(text: 'Raw Output', icon: Icon(Icons.wysiwyg)),
              Tab(text: 'Tabular Output', icon: Icon(Icons.grid_on)),
              Tab(text: 'Device Details', icon: Icon(Icons.computer_outlined)),
              Tab(
                  text: 'Ports View',
                  icon: Icon(Icons.space_dashboard_outlined)),
              Tab(text: 'Service View', icon: Icon(Icons.view_quilt_outlined)),
            ],
          ),
          Expanded(
            flex: 5,
            child: Builder(
              builder: (context) {
                return MouseRegion(
                  cursor: inProgress
                      ? SystemMouseCursors.wait
                      : SystemMouseCursors.basic,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 10,
                        child: TabBarView(children: [
                          NMapRawOutputWidget(
                            key: const Key('Output Widget'),
                            outputCtrl: _outputCtrl,
                            result: result,
                            initialPosition: _outputPosition,
                          ),
                          const NMapTabularWidget(
                            placeholder: Icon(Icons.do_not_disturb_sharp),
                            implementation: NMAPTabImplementation.plutoGrid,
                          ),
                          NMapDeviceView(
                            placeholder: const Icon(Icons.do_not_disturb),
                            viewFunction: (
                                {required NMapHostRecord selectedHost}) {
                              return NMapDeviceDetails(
                                  hostRecord: selectedHost);
                            },
                            controller: _hostViewController,
                          ),
                          NMapDeviceView(
                            placeholder: const Icon(Icons.do_not_disturb),
                            viewFunction: (
                                {required NMapHostRecord selectedHost}) {
                              return NMapPortGrid(hostRecord: selectedHost);
                            },
                            controller: _hostViewController,
                          ),
                          NMapServiceView(
                              placeholder: const Icon(Icons.do_not_disturb),
                            controller: _serviceViewController,
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                                color: defaultColor,
                                hoverColor: kAccentColor,
                                disabledColor: kDisabledColor,
                                textColor: kLightTextColor,
                                onPressed: !inProgress
                                    ? null
                                    : () {
                                        _aborted = true;
                                        nMapCommand.stop();
                                      },
                                child: const Text('ABORT')),
                            MaterialButton(
                                color: defaultColor, //color: backgroundColor,
                                hoverColor: kAccentColor,
                                disabledColor: kDisabledColor,
                                textColor: kLightTextColor,
                                onPressed: inProgress
                                    ? null
                                    : () {
                                        _aborted = false;
                                        _outputPosition.offset = 0.0;
                                        nMapCommand.clear();
                                        nMapXML.clear();
                                      },
                                child: const Text('CLEAR')),
                            MaterialButton(
                                color: defaultColor,
                                hoverColor: kAccentColor,
                                disabledColor: kDisabledColor,
                                textColor: kLightTextColor,
                                onPressed: inProgress || !_ipIsValid
                                    ? null
                                    : () {
                                        // Get Command Line from Controller
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
                                              cmdList = List<String>.filled(
                                                  args.length - 1, '')
                                                ..setRange(0, args.length - 1,
                                                    args, 1);
                                            } else {
                                              cmdList = [];
                                            }
                                            nMapCommand.setArguments(cmdList,
                                                notify: false);
                                          }
                                        }
                                        _outputPosition.offset = 0.0;
                                        nMapCommand.clear();
                                        nMapXML.clear();
                                        _hostViewController.clear();
                                        _serviceViewController.clear();
                                        saveFName = null;
                                        nMapCommand.start(context);
                                      },
                                child: const Text('SCAN'))
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    Widget w;
    if (Platform.isLinux || Platform.isWindows) {
      String reXMLFile = r'^.+\.xml$';
      DateFormat formatter = DateFormat('yyyy-MM-dd-HHmm');
      w = MenuBar(
        barStyle: BarStyle(
            backgroundColor: Theme.of(context).primaryColor), //kDefaultColor),
        menuStyle: MenuStyle(backgroundColor: backgroundColor),
        menuButtonStyle: MenuButtonStyle(backgroundColor: backgroundColor),
        barButtons: [
          BarButton(
            text: Text('Scan', style: TextStyle(color: textColor)),
            submenu: SubMenu(
              menuItems: [
                MenuButton(
                  text: const Text('Save Scan',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),
                  // Disable onTap if scan is in progress or there is no XML scan result
                  onTap: inProgress || !nMapXML.xmlDocumentExists
                      ? null
                      : () async {
                          log.debug('OnTap<Save Scan> called');
                          DateTime now = DateTime.now();
                          // saveFName contains the filename of the last scan saved
                          if (saveFName == null) {
                            // If it is not set, create a default name based on
                            // datetime
                            String defaultFName =
                                'nmap_scan-${formatter.format(now)}.xml';
                            saveFName = await FilePicker.platform.saveFile(
                              dialogTitle: 'Save Scan',
                              fileName: defaultFName,
                              type: FileType.custom,
                              allowedExtensions: ['xml'],
                            );
                            // If the chosen file has been set check if
                            // it ends in .xml
                            if (saveFName != null) {
                              bool hasDotXML =
                                  RegExp(reXMLFile).hasMatch(saveFName!);
                              // if it doesn't end in .xml then add .xml
                              if (!hasDotXML) {
                                saveFName = '$saveFName.xml';
                              }
                            } else {
                              log.debug('onTap<SaveScan> cancelled.');
                            }
                          }
                          if (saveFName != null && context.mounted) {
                            XmlDocument? document = nMapXML.document;
                            if (document == null) {
                              log.warning(
                                  'OnTap<Save Scan>: XML document is null');
                            } else {
                              log.debug('OnTap<Save Scan>: XML document found');
                              // TODO: Add code to save a scan
                              File file = File(saveFName!);
                              file.writeAsString(document.toXmlString(
                                  pretty: true, indent: '  '));
                            }
                          }
                          log.debug('onTap<SaveScan> selected $saveFName');
                        },
                  icon: Icon(FontAwesomeIcons.solidFloppyDisk,
                      color: inProgress || !nMapXML.xmlDocumentExists
                          ? kDisabledColor
                          : null,
                      size: kDefaultIconSize), //const Icon(Icons.save),
                  shortcutText: 'Ctrl+S',
                ),
                MenuButton(
                  text: const Text('Save Scan As',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),
                  // Disable onTap if scan is in progress or there is no XML scan result
                  onTap: inProgress || !nMapXML.xmlDocumentExists
                      ? null
                      : () async {
                          log.debug('OnTap<Save Scan As> called');
                          DateTime now = DateTime.now();
                          // create a default name based on
                          // datetime
                          String defaultFName =
                              'nmap_scan-${formatter.format(now)}.xml';
                          saveFName = await FilePicker.platform.saveFile(
                            dialogTitle: 'Save Scan',
                            fileName: defaultFName,
                            type: FileType.custom,
                            allowedExtensions: ['xml'],
                          );
                          // If the chosen file has been set check if
                          // it ends in .xml
                          if (saveFName != null) {
                            bool hasDotXML =
                                RegExp(reXMLFile).hasMatch(saveFName!);
                            // if it doesn't end in .xml then add .xml
                            if (!hasDotXML) {
                              saveFName = '$saveFName.xml';
                            }

                            log.debug('onTap<SaveScanAs> selected $saveFName');
                            // TODO: Add code to save a scan
                            File file = File(saveFName!);
                          } else {
                            log.debug('onTap<SaveScanAs> cancelled.');
                          }
                        },
                  icon: Icon(FontAwesomeIcons.floppyDisk,
                      color: inProgress || !nMapXML.xmlDocumentExists
                          ? kDisabledColor
                          : null,
                      size: kDefaultIconSize), //const Icon(Icons.save),
                  shortcutText: 'Ctrl+Alt+S',
                ),
                MenuButton(
                  text: const Text('Load Scan',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),
                  // Disable on tap if a scan is in progress
                  onTap: inProgress
                      ? null
                      : () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['xml'],
                          );
                          if (result != null) {
                            String? path = result!.files.single.path;
                            if (path != null) {
                              log.debug('onTap<LoadScan> selected $path');
                              // Clear host records, but don't notify because we are going
                              // to open right after
                              _outputPosition.offset = 0.0;
                              _hostViewController.clear();
                              _serviceViewController.clear();
                              nMapCommand.clear();
                              nMapXML.clear(notify: false);
                              nMapXML.open(path);
                              saveFName = null;
                              List<NMapHostRecord> activeHosts =
                                  NMapHostRecord.getActiveHosts(
                                      nMapXML.hostRecords);
                              int numRecords = activeHosts.length;
                              String version = nMapXML.nMapVersion;
                              String scanDate = nMapXML.scanDate;
                              String scanner = nMapXML.scanner;
                              List<String> arguments = nMapXML.nMapArgs;
                              String target = nMapXML.target;
                              nMapCommand.program = scanner;
                              nMapCommand.target = target;
                              // setState(() {
                              ipAddressCtrl.text = target;
                              // Can set this directly because setting the
                              // nMapCommand.target already checks that
                              // the ip is valid
                              _ipIsValid = true;
                              _ipFieldFilled = true;
                              optionsCtrl.text = nMapXML.options;
                              qsController.map = {'Custom': ''};

                              // });
                              nMapCommand.setArguments(arguments);
                              nMapCommand.consoleOutput = 'Scan file: ($path)\n'
                                  'taken on: $scanDate.\n'
                                  'with arguments $arguments\n'
                                  'on target: $target\n'
                                  'with: $scanner $version\n'
                                  '$numRecords hosts loaded\n';
                            }
                          } else {
                            log.debug('onTap<LoadScan> cancelled.');
                          }
                        },
                  icon: Icon(FontAwesomeIcons.solidFolderOpen,
                      color: inProgress ? kDisabledColor : null,
                      size: kDefaultIconSize), //const Icon(Icons.save),
                  shortcutText: 'Ctrl+L',
                ),
                const MenuDivider(),
                MenuButton(
                  text: const Text('Quit',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),

                  onTap: () {
                    // SystemNavigator.pop(animated: true);
                    log.debug('Quit: exiting app');
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                    exit(0);
                  },
                  icon: const Icon(FontAwesomeIcons.rightFromBracket,
                      size: kDefaultIconSize), //const Icon(Icons.exit_to_app),
                  shortcutText: 'Ctrl+Q',
                ),
              ],
            ),
          ),
          BarButton(
            text: Text('Profile',
                style: TextStyle(
                    color:
                        textColor)), //style: TextStyle(color: kLightTextColor)),
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
                MenuButton(
                  text: const Text(
                    'Toggle Dark Mode',
                    style: TextStyle(fontSize: kDefaultMenuFontSize),
                  ),
                  onTap: () {
                    Provider.of<NMapDarkMode>(context, listen: false)
                        .toggleMode();
                  },
                  icon: const Icon(FontAwesomeIcons.yinYang,
                      size: kDefaultIconSize), // const Icon(Icons.info),
                ),
              ],
            ),
          ),
          BarButton(
            text: Text('Help',
                style: TextStyle(
                    color:
                        textColor)), //style: TextStyle(color: kLightTextColor)),
            submenu: SubMenu(
              menuItems: [
                MenuButton(
                  text: const Text('View License',
                      style: TextStyle(fontSize: kDefaultMenuFontSize)),
                  onTap: () {},
                  icon: const Icon(
                    FontAwesomeIcons.solidCopyright,
                    size: kDefaultIconSize,
                  ), //const Icon(Icons.copyright),
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

class AppDropdownInput<T> extends StatelessWidget {
  final String hintText;
  final List<T> options;
  final T value;
  final String Function(T?)? getLabel;
  final void Function(T?)? onChanged;

  const AppDropdownInput({
    super.key,
    this.hintText = 'Please select an Option',
    this.options = const [],
    this.getLabel,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      builder: (FormFieldState<T> state) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            labelText: hintText,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          ),
          isEmpty: value == null || value == '',
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              onChanged: onChanged,
              items: options.map((T value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: (getLabel != null)
                      ? Text(getLabel!(value))
                      : const Text(''),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
