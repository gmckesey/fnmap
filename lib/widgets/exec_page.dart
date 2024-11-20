import 'dart:io';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:menu_bar/menu_bar.dart';
import 'package:fnmap/utilities/nmap_fe.dart';
import 'package:fnmap/models/host_record.dart';
import 'package:fnmap/widgets/device_details.dart';
import 'package:fnmap/widgets/service_view.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/widgets/device_view.dart';
import 'package:fnmap/widgets/port_view.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/widgets/quick_scan_dropdown.dart';
import 'package:fnmap/utilities/ip_address_validator.dart';
import 'package:fnmap/models/nmap_xml.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/widgets/raw_output_widget.dart';
import 'package:fnmap/widgets/nmap_tabular.dart';
import 'package:fnmap/dialogs/show_about.dart';
import 'package:fnmap/dialogs/report_error.dart';

class ExecPage extends StatefulWidget {
  const ExecPage({Key? key}) : super(key: key);

  @override
  State<ExecPage> createState() => _ExecPageState();
}

class _ExecPageState extends State<ExecPage> {
  NLog log = NLog('ExecPage', package: kPackageName);
  NLog trace = NLog('ExecPage', flag: nLogTRACE, package: kPackageName);
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );
  late TextEditingController ipAddressCtrl;
  late TextEditingController optionsCtrl;
  // TextEditingController targetCtrl = TextEditingController(text: 'item 3');
  final TrackingScrollController _outputCtrl =
      TrackingScrollController(keepScrollOffset: true);
  late bool _aborted;
  late bool _ipFieldFilled;
  late bool _ipIsValid;
  //late double _scrollOffset;
  late NMapScrollOffset _outputPosition;
  List<String> dropdownItems = ['item 1', 'default', 'item 2', 'item 3'];
  late NMapViewController _hostViewController;
  late NMapServiceViewController _serviceViewController;
  String? saveFName;
  // late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    // log.debug('initState called.', color: LogColor.red);
    _aborted = false;
    _ipFieldFilled = false;
    _ipIsValid = false;
    _outputPosition = NMapScrollOffset(0.0);
    _hostViewController = NMapViewController();
    _serviceViewController = NMapServiceViewController();

    NMapCommand nMapCommand = Provider.of<NMapCommand>(context, listen: false);
    ipAddressCtrl = TextEditingController(text: nMapCommand.target);
    if (nMapCommand.target != '') {
      _ipFieldFilled = true;
      _ipIsValid = isValidIPAddressList(nMapCommand.target);
    }

    // Reconstruct initial command line from the arguments list
    String options = nMapCommand.arguments != null
        ? '${nMapCommand.program} ${nMapCommand.arguments!.join(" ")}'
        : '';
    optionsCtrl = TextEditingController(text: options);

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
    _outputCtrl.dispose();
    _hostViewController.dispose();
    _serviceViewController.dispose();
    super.dispose();
  }

  List<String> commandToList({required String cmd, required String ipAddress}) {
    // Get Command Line from Controller
    String argumentText = cmd;
    // _aborted = false;
    List<String> args;
    if (argumentText.isNotEmpty) {
      args = optionsCtrl.value.text.split(RegExp(r' +'));
    } else {
      args = [];
    }
    return args;
  }

  List<String> stripTarget(List<String> args) {
    List<String> cmdList;
    if (args.isNotEmpty) {
      if (args.length > 1) {
        cmdList = List<String>.filled(args.length - 1, '')
          ..setRange(0, args.length - 1, args, 1);
      } else {
        cmdList = [];
      }
    } else {
      cmdList = [];
    }
    return cmdList;
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _commandLineChanged() {
    QuickScanController qsController =
        Provider.of<QuickScanController>(context, listen: false);

    trace.debug('_commandLineChanged: command line ="${optionsCtrl.text}"');

    // Check if Quick Options and Command Line Options are in Sync
    if (qsController.key != null &&
        qsController.choiceMap[qsController.key] != optionsCtrl.text) {
      // Set qsController point to kCustomKey
      if (qsController.key != kCustomKey) {
        trace.debug('_commandLineChanged: set '
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
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    Color backgroundColor = mode.themeData.scaffoldBackgroundColor;
    Color defaultColor = mode.themeData.primaryColor;
    Color textColor = mode.themeData.primaryColorLight;
    bool isTargetEnabled = true;

    // If the drop down has a value then set the commandLine to that value
    String commandLine = optionsCtrl.text;

    void initCommand({bool notify = true}) {
      // Get Command Line from Controller
      NFECommand nfeCommand = NFECommand.fromString(optionsCtrl.text);
      String? target = nfeCommand.target;
      String ipAddress;

      if (target != null) {
        // Disable target field if the target is in the profile
        isTargetEnabled = false;
        // Fill the target field with the value from the profile
        if (isValidIPAddressList(target)) {
          ipAddressCtrl.text = target;
        }
        ipAddress = ipAddressCtrl.text;
      } else {
        // Enable the target field if the target is not in the profile
        isTargetEnabled = true;
        // Set the ip address with the value in the target field
        ipAddress = ipAddressCtrl.value.text;
      }
      List<String> args = nfeCommand.arguments;
      // Add the target to the list of arguments
      if (!isTargetEnabled && target != null) {
        args.add(target);
      }
      // commandToList(cmd: optionsCtrl.value.text, ipAddress: ipAddress);
      _aborted = false;

      if (ipAddress.isNotEmpty) {
        log.debug('build(initCommand) - setting ip address to '
            '$ipAddress');
        if (ipAddress.isNotEmpty) {
          nMapCommand.setTarget(ipAddress, notify: notify);
          _ipIsValid = isValidIPAddressList(ipAddress);
        } else {
          _ipIsValid = false;
        }
        nMapCommand.setProgram(nfeCommand.program, notify: false);
        if (args.isNotEmpty) {
          // Trying .. for the first time
          nMapCommand.setArguments(args, notify: false);
        }
      }
    }

    // String commandLine = optionsCtrl.text;
    // Set the command line option text field value
    // optionsCtrl.text = commandLine;
    trace.debug('build: dropdown = "${qsController.key}" '
        'command line = "$commandLine"');

    // if (nMapCommand.arguments == )

    if (_aborted && result != null) {
      result += '\nAborted by user.';
    }

    initCommand(notify: false);

    Widget scaffold = Scaffold(
      backgroundColor: backgroundColor,
/*      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('nmap'),
        ),
      ),*/
      body: DefaultTextStyle(
        style: mode.themeData.textTheme.bodyMedium!,
        child: Column(
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
                          enabled: isTargetEnabled,
                          style: mode.themeData.textTheme.displayMedium,
                          controller: ipAddressCtrl,
                          decoration: InputDecoration(
                            filled: _ipFieldFilled,
                            fillColor: _ipIsValid ? kValidColor : kInvalidColor,
                            border: const OutlineInputBorder(),
                            hintStyle:
                                mode.themeData.inputDecorationTheme.hintStyle,
                            hintText:
                                'Enter an IP address, IP range or network',
                          ),
                          onChanged: ((value) {
                            setState(() {
                              if (value.isNotEmpty) {
                                _ipIsValid = isValidIPAddressList(value);
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
                    key: Key('QSDropDown - ${qsController.choiceMap.length}'),
                    width: 260,
                    controller: qsController,
                    onChanged: (option) {
                      trace.debug(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Command Line Options:',
                        style: mode.themeData.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                          width: 120,
                          child: TextField(
                            controller: optionsCtrl,
                            style: mode.themeData.textTheme.displayMedium,
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
              labelColor: mode.themeData.highlightColor, //darkColor,
              unselectedLabelColor: mode.themeData.disabledColor,
              tabs: const [
                Tab(text: 'Raw Output', icon: Icon(Icons.wysiwyg)),
                Tab(text: 'Tabular Output', icon: Icon(Icons.grid_on)),
                Tab(
                    text: 'Device Details',
                    icon: Icon(Icons.computer_outlined)),
                Tab(
                    text: 'Ports View',
                    icon: Icon(Icons.space_dashboard_outlined)),
                Tab(
                    text: 'Service View',
                    icon: Icon(Icons.view_quilt_outlined)),
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
                                  color: mode.themeData.primaryColor,
                                  hoverColor: mode.themeData.hoverColor,
                                  disabledColor: mode.themeData.disabledColor,
                                  textColor:
                                      mode.themeData.textTheme.displayMedium ==
                                              null
                                          ? null
                                          : mode.themeData.textTheme
                                              .displayMedium!.color,
                                  onPressed: !inProgress
                                      ? null
                                      : () {
                                          _aborted = true;
                                          nMapCommand.stop();
                                        },
                                  child: const Text('ABORT')),
                              MaterialButton(
                                  color: mode.themeData.primaryColor,
                                  hoverColor: mode.themeData.hoverColor,
                                  disabledColor: mode.themeData.disabledColor,
                                  textColor:
                                      mode.themeData.textTheme.displayMedium ==
                                              null
                                          ? null
                                          : mode.themeData.textTheme
                                              .displayMedium!.color,
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
                                  color: mode.themeData.primaryColor,
                                  hoverColor: mode.themeData.hoverColor,
                                  disabledColor: mode.themeData.disabledColor,
                                  textColor:
                                      mode.themeData.textTheme.displayMedium ==
                                              null
                                          ? null
                                          : mode.themeData.textTheme
                                              .displayMedium!.color,
                                  onPressed: inProgress || !_ipIsValid
                                      ? null
                                      : () {
                                          initCommand();
                                          _outputPosition.offset = 0.0;
                                          nMapCommand.clear();
                                          nMapXML.clear();
                                          _hostViewController.clear();
                                          _serviceViewController.clear();
                                          saveFName = null;
                                          nMapCommand.start(context,
                                              onError: (msg) {
                                            reportError(context,
                                                errorMsg: msg,
                                                themeData: mode.themeData);
                                          });
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
      ),
    );
    Widget w;
    if (Platform.isLinux || Platform.isWindows) {
      String reXMLFile = r'^.+\.xml$';
      DateFormat formatter = DateFormat('yyyy-MM-dd-HHmm');
      w = MenuBarWidget(
        barStyle: MenuStyle(
            backgroundColor:
                WidgetStatePropertyAll(defaultColor)), //kDefaultColor),
        barButtonStyle: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(defaultColor)),
        menuButtonStyle: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(backgroundColor)),
        barButtons: [
          BarButton(
            text: Text('Scan', style: TextStyle(color: textColor)),
            submenu: SubMenu(
              menuItems: [
                MenuButton(
                  text: Text(
                    'Save Scan',
                    // style: TextStyle(fontSize: kDefaultMenuFontSize)),
                    style: mode.themeData.textTheme.labelMedium,
                  ),
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
                              File file = File(saveFName!);
                              file.writeAsString(document.toXmlString(
                                  pretty: true, indent: '  '));
                            }
                          }
                          log.debug('onTap<SaveScan> selected $saveFName');
                        },
                  icon: Icon(FontAwesomeIcons.solidFloppyDisk,
                      color: inProgress || !nMapXML.xmlDocumentExists
                          ? mode.themeData.disabledColor
                          : mode.themeData.primaryColor,
                      size: kDefaultIconSize), //const Icon(Icons.save),
                  shortcutText: 'Ctrl+S',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyS,
                      control: true),
                ),
                MenuButton(
                  text: Text(
                    'Save Scan As',
                    style: mode.themeData.textTheme.labelMedium,
                  ),
                  // style: TextStyle(fontSize: kDefaultMenuFontSize)),
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
                            if (saveFName != null && context.mounted) {
                              XmlDocument? document = nMapXML.document;
                              if (document == null) {
                                log.warning(
                                    'OnTap<Save Scan>: XML document is null');
                              } else {
                                log.debug(
                                    'OnTap<Save Scan>: XML document found');
                                File file = File(saveFName!);
                                file.writeAsString(document.toXmlString(
                                    pretty: true, indent: '  '));
                              }
                            }
                          } else {
                            log.debug('onTap<SaveScanAs> cancelled.');
                          }
                        },
                  icon: Icon(FontAwesomeIcons.floppyDisk,
                      color: inProgress || !nMapXML.xmlDocumentExists
                          ? mode.themeData.disabledColor
                          : mode.themeData.primaryColor,
                      size: kDefaultIconSize), //const Icon(Icons.save),
                  shortcutText: 'Ctrl+Alt+S',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyS,
                      control: true, alt: true),
                ),
                MenuButton(
                  text: Text(
                    'Load Scan',
                    // style: TextStyle(fontSize: kDefaultMenuFontSize)),
                    style: mode.themeData.textTheme.labelMedium,
                  ),
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
                            String? path = result.files.single.path;
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
                      color: inProgress
                          ? mode.themeData.disabledColor
                          : mode.themeData.primaryColor,
                      size: kDefaultIconSize), //const Icon(Icons.save),
                  shortcutText: 'Ctrl+L',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyL,
                      control: true),
                ),
                const MenuDivider(height: 2),
                MenuButton(
                  text: Text(
                    'Quit',
                    // style: TextStyle(fontSize: kDefaultMenuFontSize)),
                    style: mode.themeData.textTheme.labelMedium,
                  ),
                  onTap: () async {
                    // SystemNavigator.pop(animated: true);
                    log.debug('Quit: exiting app');
                    await SystemChannels.platform
                        .invokeMethod<void>('SystemNavigator.pop', false);
                    if (Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS) {
                      exit(0);
                    }
                  },
                  icon: Icon(FontAwesomeIcons.rightFromBracket,
                      color: mode.themeData.primaryColor,
                      size: kDefaultIconSize), //const Icon(Icons.exit_to_app),
                  shortcutText: 'Ctrl+Q',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyQ,
                      control: true),
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
                  text: Text(
                    'New Profile',
                    style: mode.themeData.textTheme.labelMedium,
                  ),
                  onTap: inProgress
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            '/newProfile',
                            arguments: qsController,
                          ).then((value) {
                            setState(() {
                              // Make sure that the updated Command Line gets
                              // updated with the edited value, which is now already
                              // saved on file and in qsController
                              optionsCtrl.text =
                                  qsController.choiceMap[qsController.key!]!;
                            });
                          });
                          // editProfile(context, edit: false, controller: optionsCtrl);
                        },
                  icon: Icon(
                    FontAwesomeIcons.arrowUpRightFromSquare,
                    size: kDefaultIconSize,
                    color: mode.themeData.primaryColor,
                  ), //const Icon(Icons.copyright),
                ),
                MenuButton(
                    text: Text(
                      'Edit Selected Profile',
                      //style: TextStyle(fontSize: kDefaultMenuFontSize),
                      style: mode.themeData.textTheme.labelMedium,
                    ),
                    onTap: inProgress
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              '/editProfile',
                              arguments: qsController,
                            ).then((value) {
                              setState(() {
                                // Make sure that the updated Command Line gets
                                // updated with the edited value, which is now already
                                // saved on file and in qsController
                                optionsCtrl.text =
                                    qsController.choiceMap[qsController.key!]!;
                              });
                            });
                            //editProfile(context, edit: true, controller: optionsCtrl);
                          },
                    icon: Icon(FontAwesomeIcons.solidPenToSquare,
                        size: kDefaultIconSize,
                        color: mode.themeData.primaryColor)),
                MenuButton(
                  text: Text(
                    'Delete Selected Profile',
                    // style: TextStyle(fontSize: kDefaultMenuFontSize),
                    style: mode.themeData.textTheme.labelMedium,
                  ),
                  onTap: inProgress
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            '/deleteProfile',
                            arguments: qsController,
                          );
                          // editProfile(context,
                          //    edit: false, delete: true, controller: optionsCtrl);
                        },
                  icon: Icon(
                    FontAwesomeIcons.solidPenToSquare,
                    size: kDefaultIconSize,
                    color: mode.themeData.primaryColor,
                  ), // const Icon(Icons.info),
                ),
                MenuButton(
                  text: Text(
                    'Toggle Dark Mode',
                    // style: TextStyle(fontSize: kDefaultMenuFontSize),
                    style: mode.themeData.textTheme.labelMedium,
                  ),
                  onTap: () {
                    Provider.of<NMapDarkMode>(context, listen: false)
                        .toggleMode();
                  },
                  icon: Icon(FontAwesomeIcons.yinYang,
                      color: mode.themeData.primaryColor,
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
                  text: Text(
                    'About',
                    // style: TextStyle(fontSize: kDefaultMenuFontSize)),
                    style: mode.themeData.textTheme.labelMedium,
                  ),
                  onTap: () {
                    showAbout(context, packageInfo: _packageInfo);
                  },
                  icon: Icon(FontAwesomeIcons.circleInfo,
                      color: mode.themeData.primaryColor,
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
