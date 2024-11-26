import 'package:ini/ini.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/utilities/nmap_fe.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/utilities/scan_profile.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/dark_mode.dart';
// import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/models/validity_notifier.dart';
import 'package:fnmap/controllers/edit_profile_controllers.dart';
import 'package:fnmap/models/help_text.dart';
import 'package:fnmap/widgets/quick_scan_dropdown.dart';
import 'package:fnmap/tab_screens/scan_options.dart';
import 'package:fnmap/tab_screens/ping_options.dart';
import 'package:fnmap/tab_screens/other_options.dart';
import 'package:fnmap/tab_screens/timing_options.dart';
import 'package:fnmap/tab_screens/target_options.dart';
import 'package:fnmap/tab_screens/source_options.dart';
import 'package:fnmap/widgets/help.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({
    // required this.windowController,
    // required this.args,
    required this.delete,
    required this.edit,
    super.key,
  });
  //final WindowController windowController;
  //final Map? args;
  // TODO: Refactor these flags to a single type with three values (create, update, delete)
  final bool delete;
  final bool edit;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  NLog log = NLog('_EditProfileState:');
  late String title;
  var formKey = GlobalKey<FormState>();
  bool nameFieldValid = true;
  // late bool enableAccept;

  @override
  void initState() {
    super.initState();
    // enableAccept = true;
    if (!widget.delete) /* Delete existing profile */ {
      EditProfileControllers controllers =
          Provider.of<EditProfileControllers>(context, listen: false);
      if (widget.edit) /* Edit existing profile */ {
        ScanProfile profile = Provider.of<ScanProfile>(context, listen: false);
        QuickScanController qsController =
            Provider.of<QuickScanController>(context, listen: false);

        Config config = profile.config;
        String? description = config.get(qsController.key!, 'description');
        if (description != null) {
          controllers.descController.text = description;
        }
        String rawCommand = qsController.value!;

        // All done, so we can now create a command instance
        NFECommand command = NFECommand.fromString(rawCommand);

        controllers.setCommand(command);
        String cmd = '${command.program} ${command.arguments.join(" ")}';
        controllers.cmdLineController.text = cmd;

        title = '';
      } else /* Create new Profile */ {
        String cmd = 'nmap';
        // NFECommand command = NFECommand.fromString(cmd);
        NFECommand command = NFECommand(arguments: [cmd]);
        controllers.setCommand(command);
        // controllers.cmdLineController.text = cmd;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    HelpText helpText = Provider.of<HelpText>(context, listen: true);
    EditProfileControllers controllers =
        Provider.of<EditProfileControllers>(context, listen: true);

    Color backgroundColor = mode.themeData.scaffoldBackgroundColor;
    Color titleTextColor = mode.themeData.primaryColorLight;
    Color textColor = mode.themeData.primaryColorLight;
    Color defaultColor = mode.themeData.primaryColor;
    Color disabledColor = mode.themeData.disabledColor;
    Color labelColor = mode.themeData.secondaryHeaderColor;
    Color darkColor = mode.themeData.primaryColorDark;

    QuickScanController qsController =
        Provider.of<QuickScanController>(context, listen: false);
    bool enableAccept =
        Provider.of<ValidityNotifier>(context, listen: true).isValid;
    Widget deleteQuery() {
      return const Text('Please confirm deletion');
    }

    Widget optionsTabBar() {
      return DefaultTabController(
        length: 6,
        child: Column(children: [
          TabBar(
            labelColor: mode.themeData.highlightColor, //darkColor,
            unselectedLabelColor: mode.themeData.disabledColor,
            tabs: const [
              Tab(text: 'Scan', icon: Icon(Icons.account_tree_outlined)),
              Tab(text: 'Ping', icon: Icon(Icons.network_ping_outlined)),
              Tab(
                  text: 'Source',
                  icon: Icon(Icons.arrow_circle_right_outlined)),
              Tab(text: 'Target', icon: Icon(Icons.adjust_outlined)),
              Tab(
                  text: 'Other',
                  icon: Icon(Icons.miscellaneous_services_outlined)),
              Tab(
                  text: 'Timing',
                  icon: Icon(Icons.access_time_filled_outlined)),
            ],
          ),
          SizedBox(
            height: 380,
            child: TabBarView(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child:
                    ScanOptions(scanControllers: controllers.scanControllers),
              ),
              PingOptions(pingControllers: controllers.pingControllers),
              SourceOptions(
                  sourceScanControllers: controllers.sourceScanControllers),
              TargetOptions(
                  targetScanControllers: controllers.targetScanControllers),
              OtherOptions(
                  otherScanControllers: controllers.otherScanControllers),
              TimingOptions(
                  timingScanControllers: controllers.timingScanControllers),
            ]),
          ),
        ]),
      );
    }

    Widget nameField() {
      return KriolHelp (
        help: 'The name of the profile',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: controllers.nameController,
            style: mode.themeData.textTheme.displayMedium,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              icon: const Icon(Icons.edit),
              hintText: 'Name of this profile',
              hintStyle:
                  TextStyle(color: disabledColor, fontStyle: FontStyle.italic),
              labelText: 'Name:',
              labelStyle: TextStyle(color: labelColor),
            ),
            onSaved: (String? value) {
              log.debug('onSaved - saving value $value');
            },
            validator: (String? value) {
              log.debug('validator - validating value [$value]');
              if (value == null || value.isEmpty) {
                nameFieldValid = false;
                return 'Please enter a name';
              }
              nameFieldValid = true;
              return null;
            },
            onFieldSubmitted: (String? value) {
              log.debug('onFieldSubmitted - value is $value');
            },
          ),
        ),
      );
    }

    Widget descriptionField() {
      return KriolHelp(
        help: 'A description of this profile',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: controllers.descController,
            style: mode.themeData.textTheme.displayMedium,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              icon: const Icon(Icons.edit),
              hintText: 'Description of profile',
              hintStyle:
                  TextStyle(color: disabledColor, fontStyle: FontStyle.italic),
              labelText: 'Description:',
              labelStyle: TextStyle(color: labelColor),
            ),
            validator: (String? value) {
              return null;
            },
            onFieldSubmitted: (String? value) {
              log.debug('onFieldSubmitted - value is $value');
            },
          ),
        ),
      );
    }

    List<Widget> createForm({required bool delete, required bool edit}) {
      List<Widget> formFields = [];
      if (delete) {
        String profileName = qsController.key!;
        title = 'Delete Profile $profileName';
        formFields.add(deleteQuery());
      } else {
        if (edit) {
          String profileName = qsController.key!;
          title = 'Edit Profile \'$profileName\'';
        } else {
          title = 'New Profile';
          formFields.add(nameField());
        }
        formFields.add(CommandField(
          cmdLineController: controllers.cmdLineController,
          edit: edit,
          validation: (value, isValid) {
            log.debug('validation: value = [$value] isValid = $isValid');
            // enableAccept = isValid;
            ValidityNotifier notifier =
                Provider.of<ValidityNotifier>(context, listen: false);

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              notifier.setValidity(isValid);
            });
            if (isValid) {
              return null;
            } else {
              return 'Invalid Command Syntax';
            }
          },
        ));
        formFields.add(descriptionField());
        formFields.add(optionsTabBar());
      }
      return formFields;
    }

    log.debug('build: enableAccept = $enableAccept');
    List<Widget> form = createForm(delete: widget.delete, edit: widget.edit);

    return MaterialApp(
        home: Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title),
        titleTextStyle: TextStyle(color: titleTextColor),
        // kDefaultTextStyle,
        backgroundColor: defaultColor,
      ),
      body: Column(children: <Widget>[
        Expanded(
          flex: 12,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: formKey,
              child: Column(
                children: form,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              children: [
                helpText.text.isNotEmpty
                    ? Icon(
                        Icons.info_outline,
                        color: darkColor,
                      )
                    : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Text(
                    helpText.text.isNotEmpty ? helpText.text : '',
                    style: TextStyle(
                      color: defaultColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // const Spacer(flex: 1),
        Expanded(
          flex: 1,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DialogButton(
/*            style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),*/
                  buttonName: 'Cancel',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Spacer(flex: 10),
                DialogButton(
                  /*        style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),*/
                  /*child: const Text('Accept'),*/
                  buttonName: 'Accept',
                  onPressed: !enableAccept
                      ? null
                      : () {
                          log.debug('onPressed - Accept pressed.');
                          ScanProfile profile =
                              Provider.of<ScanProfile>(context, listen: false);
                          Config config = profile.config;
                          if (widget.delete) {
                            qsController.deleteEntry(qsController.key!);
                            config.removeSection(qsController.key!);
/*                      if (qsController.map != null) {
                            controllers.controller.text =
                                qsController.map!.values.first;
                            // controller?.text = qsController.map!.values.first;
                          } else {
                            controllers.controller.text = '';
                          }*/
                            profile.save();
                            Navigator.of(context).pop();
                          } else {
                            bool isValid = formKey.currentState!.validate();
                            if (isValid) {
                              if (widget.edit) {
                                qsController.editCurrentEntry(qsController.key!,
                                    controllers.cmdLineController.text);
                                if (config.hasSection(qsController.key!)) {
                                  config.set(qsController.key!, 'command',
                                      controllers.cmdLineController.text);
                                  config.set(qsController.key!, 'description',
                                      controllers.descController.text);
                                }
                              } else {
                                qsController.addEntry(
                                    controllers.nameController.text,
                                    controllers.cmdLineController.text);
                                qsController.map = {
                                  controllers.nameController.text:
                                      controllers.cmdLineController.text
                                };
                                if (!config.hasSection(qsController.key!)) {
                                  config.addSection(qsController.key!);
                                  config.set(qsController.key!, 'command',
                                      controllers.cmdLineController.text);
                                  config.set(qsController.key!, 'description',
                                      controllers.descController.text);
                                } else {
                                  log.warning(
                                      'onPressed: section ${qsController.key!} '
                                      'already exists');
                                }
                              }
                              // Get list of arguments from controllers
                              List<String> args = controllers.arguments;
                              log.debug(
                                  'ACCEPT(onPressed)- arguments = ${args.join(" ")}');
                              profile.save();
                              Navigator.of(context).pop();
                            } else {
                              log.warning(
                                  'onPressed - profile ${controllers.nameController.text}: '
                                  '${controllers.cmdLineController.text} not valid');
                            }
                          }
                          return;
                        },
                ),
              ]),
        ),
      ]),
    ));
  }

/*  Color _getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }*/
}

class DialogButton extends StatelessWidget {
  final String buttonName;
  final void Function()? onPressed;

  const DialogButton(
      {Key? key, required this.buttonName, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    Color defaultColor = mode.themeData.primaryColor;
    Color disabledColor = mode.themeData.disabledColor;

    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
          onPressed: onPressed,
          color: defaultColor,
          disabledColor: disabledColor,
          hoverColor: kAccentColor,
          textColor: kLightTextColor,
          child: Text(buttonName.toUpperCase()),
        ),
      ),
    );
  }
}

class TextOption extends StatelessWidget {
  const TextOption({
    super.key,
    required this.controllerP,
    required this.enabledP,
    required this.titleP,
    this.textColor,
  });

  final TextEditingController controllerP;
  final bool enabledP;
  final String titleP;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: false);
    Color defaultTextColor = mode.themeData.primaryColorLight;

    return Row(children: [
      Text(
        titleP,
        style: TextStyle(
          color: textColor ?? defaultTextColor,
        ),
      ),
      SizedBox(
        width: 150,
        child: TextField(
          controller: controllerP,
          enabled: enabledP,
        ),
      ),
    ]);
  }
}

class CommandField extends StatefulWidget {
  final TextEditingController cmdLineController;
  final bool edit;
  final void Function(String? value, bool isValid)? onChanged;
  final String? Function(String? value, bool isValid)? validation;
  const CommandField({
    super.key,
    required this.cmdLineController,
    required this.edit,
    this.onChanged,
    this.validation,
  });

  @override
  State<CommandField> createState() => _CommandFieldState();
}

class _CommandFieldState extends State<CommandField> {
  NLog log = NLog('CommandFieldState:', package: 'TARGET_DEBUG');
  late List<String> args;

  @override
  void initState() {
    super.initState();
/*    EditProfileControllers profileControllers = Provider.of<EditProfileControllers>(context, listen: false;
    args = profileControllers.arguments;*/
  }

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    EditProfileControllers profileControllers =
        Provider.of<EditProfileControllers>(context, listen: true);
    Color disabledColor = mode.themeData.disabledColor;
    Color labelColor = mode.themeData.secondaryHeaderColor;

    return KriolHelp(
      help: 'The nmap command line',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: widget.cmdLineController,
          style: mode
              .themeData.textTheme.displayMedium, //TextStyle(color: textColor),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            icon: const Icon(Icons.edit),
            hintText: 'Commandline for profile',
            hintStyle:
                TextStyle(color: disabledColor, fontStyle: FontStyle.italic),
            labelText: 'Command:',
            labelStyle: TextStyle(color: labelColor),
          ),
          onChanged: (String? value) {
            log.debug('(onChanged) - command line field changed to $value');
            setState(() {
              NFECommand command = NFECommand.fromString(value!);
              if (command.isValid) {
                profileControllers.command = command;
                widget.onChanged?.call(value, false);
              }
            });
          },
          validator: (String? value) {
            String? response;
            bool isValid = true;
            if (value == null || value.isEmpty) {
              isValid = false;
              response = 'Please enter a valid nmap command';
            } else {
              NFECommand command = NFECommand.fromString(value);
              if (!command.isValid) {
                response = 'Please enter a valid nmap command';
                isValid = false;
              }
            }
            if (widget.validation != null) {
              widget.validation!(value, isValid);
            }
            return response;
          },
        ),
      ),
    );
  }
}
