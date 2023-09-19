import 'package:args/args.dart';
import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:provider/provider.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/utilities/scan_profile.dart';
import 'package:fnmap/widgets/quick_scan_dropdown.dart';
import 'package:fnmap/tab_screens/scan_options.dart';
import 'package:fnmap/tab_screens/ping_options.dart';
import 'package:fnmap/tab_screens/other_options.dart';
import 'package:fnmap/tab_screens/timing_options.dart';
import 'package:fnmap/tab_screens/target_options.dart';
import 'package:fnmap/tab_screens/source_options.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/models/edit_profile_controllers.dart';

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
  final bool delete;
  final bool edit;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  NLog log = NLog('_EditProfileState:');
  late String title;
  late EditProfileControllers controllers;

  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    NMapCommand nMapCommand = Provider.of<NMapCommand>(context, listen: false);

    controllers = EditProfileControllers(nMapCommand: nMapCommand);
    title = '';
  }

  @override
  Widget build(BuildContext context) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);

    Color backgroundColor = mode.themeData.scaffoldBackgroundColor;
    Color titleTextColor = mode.themeData.primaryColorLight;
    Color textColor = mode.themeData.primaryColorLight;
    Color defaultColor = mode.themeData.primaryColor;
    Color disabledColor = mode.themeData.disabledColor;
    Color labelColor = mode.themeData.secondaryHeaderColor;
    Color darkColor = mode.themeData.primaryColorDark;

    QuickScanController qsController =
        Provider.of<QuickScanController>(context, listen: false);

    Widget deleteQuery() {
      return const Text('Please confirm deletion');
    }

    Widget optionsTabBar() {
      return DefaultTabController(
        length: 6,
        child: Column(children: [
          TabBar(
            labelColor: darkColor,
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
            height: 330,
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
              OtherOptions(otherScanControllers: controllers.otherScanControllers),
              TimingOptions(timingScanControllers: controllers.timingScanControllers),
            ]),
          )
        ]),
      );
    }

    Widget nameField() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: controllers.nameController,
          style: TextStyle(color: textColor),
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
              return 'Please enter a name';
            }
            return null;
          },
          onFieldSubmitted: (String? value) {
            log.debug('onFieldSubmitted - value is $value');
          },
        ),
      );
    }

    Widget commandField() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          // autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controllers.cmdLineController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            icon: const Icon(Icons.edit),
            hintText: 'Commandline for profile',
            hintStyle:
                TextStyle(color: disabledColor, fontStyle: FontStyle.italic),
            labelText: 'Command:',
            labelStyle: TextStyle(color: labelColor),
          ),
          onSaved: (String? value) {
            log.debug('onSaved - saving value $value');
          },
          validator: (String? value) {
            log.debug('validator - validating value [$value]');
            if (value == null || value.isEmpty) {
              return 'Please enter a command';
            }
            return null;
          },
          onFieldSubmitted: (String? value) {
            log.debug('onFieldSubmitted - value is $value');
          },
        ),
      );
    }

    Widget descriptionField() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          // autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controllers.descController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            icon: const Icon(Icons.edit),
            hintText: 'Description of profile',
            hintStyle:
                TextStyle(color: disabledColor, fontStyle: FontStyle.italic),
            labelText: 'Description:',
            labelStyle: TextStyle(color: labelColor),
          ),
          onSaved: (String? value) {
            log.debug('onSaved - saving value $value');
          },
          validator: (String? value) {
            return null;
          },
          onFieldSubmitted: (String? value) {
            log.debug('onFieldSubmitted - value is $value');
          },
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
          controllers.cmdLineController.text =
              qsController.value != null ? qsController.value! : '';
        } else {
          title = 'New Profile';
          formFields.add(nameField());
        }
        formFields.add(commandField());
        formFields.add(descriptionField());
        formFields.add(optionsTabBar());
      }
      return formFields;
    }

    log.debug('building widget');
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
          flex: 8,
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
                  onPressed: () {
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
                          qsController.addEntry(controllers.nameController.text,
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
/*                        controllers.controller.text = controllers
                            .cmdLineController
                            .text;*/ // TODO: I don't think this does anything, Remove?
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

  Color _getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }
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
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
          onPressed: onPressed,
          color: defaultColor,
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
