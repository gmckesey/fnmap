import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:provider/provider.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/utilities/scan_profile.dart';
import 'package:fnmap/widgets/quick_scan_dropdown.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/dark_mode.dart';

/*
void editProfile(BuildContext context,
    {bool edit = true,
    bool delete = false,
    TextEditingController? controller}) {
  NLog log = NLog('editProfile:');
  Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

  String titleVar;

  runApp(EditProfile(delete: delete, edit: edit));
}
*/

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
  TextEditingController controller = TextEditingController();
  late String title;

  var formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController cmdLineController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    QuickScanController qsController =
        Provider.of<QuickScanController>(context, listen: false);

    Widget deleteQuery() {
      return const Text('Please confirm deletion');
    }

    Widget optionsTabBar() {
      return const Placeholder(
        fallbackHeight: 300,
      );
    }

    Widget nameField() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          // autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: nameController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            icon: Icon(Icons.edit),
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
          controller: cmdLineController,
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
          controller: descController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            icon: Icon(Icons.edit),
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
          title = 'Edit Profile $profileName';
          cmdLineController.text =
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
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: Column(
              children: form,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
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
                    if (qsController.map != null) {
                      controller?.text = qsController.map!.values.first;
                      // controller?.text = qsController.map!.values.first;
                    } else {
                      controller?.text = '';
                    }
                    profile.save();
                    Navigator.of(context).pop();
                  } else {
                    bool isValid = formKey.currentState!.validate();
                    if (isValid) {
                      if (widget.edit) {
                        qsController.editCurrentEntry(
                            qsController.key!, cmdLineController.text);
                        if (config.hasSection(qsController.key!)) {
                          config.set(qsController.key!, 'command',
                              cmdLineController.text);
                          config.set(qsController.key!, 'description',
                              descController.text);
                        }
                      } else {
                        qsController.addEntry(
                            nameController.text, cmdLineController.text);
                        qsController.map = {
                          nameController.text: cmdLineController.text
                        };
                        if (!config.hasSection(qsController.key!)) {
                          config.addSection(qsController.key!);
                          config.set(qsController.key!, 'command',
                              cmdLineController.text);
                          config.set(qsController.key!, 'description',
                              descController.text);
                        } else {
                          log.warning('onPressed: section ${qsController.key!} '
                              'already exists');
                        }
                      }
                      controller?.text = cmdLineController
                          .text; // TODO: I don't think this does anything, Remove?
                      profile.save();
                      Navigator.of(context).pop();
                    } else {
                      log.warning('onPressed - profile ${nameController.text}: '
                          '${cmdLineController.text} not valid');
                    }
                  }
                  return;
                },
              ),
            ]),
      ]),
    ));
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
    Color buttonColor = mode.themeData.splashColor;
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
