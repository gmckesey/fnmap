import 'package:flutter/material.dart';
import 'package:ini/ini.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/utilities/scan_profile.dart';
import 'package:provider/provider.dart';
import 'package:fnmap/widgets/quick_scan_dropdown.dart';
import 'package:fnmap/utilities/logger.dart';

Future<void> editProfile(BuildContext context,
    {bool edit = true,
    bool delete = false,
    TextEditingController? controller}) {
  NLog log = NLog('editProfile:');
  Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
  QuickScanController qsController =
      Provider.of<QuickScanController>(context, listen: false);
  var formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController cmdLineController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String titleVar;

  Widget nameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: nameController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          icon: Icon(Icons.edit),
          hintText: 'Name of this profile',
          labelText: 'Name:',
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
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          icon: Icon(Icons.edit),
          hintText: 'Commandline for profile',
          labelText: 'Command:',
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
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          icon: Icon(Icons.edit),
          hintText: 'Description of profile',
          labelText: 'Description:',
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

  Widget deleteQuery() {
    return const Text('Please confirm deletion');
  }

  List<Widget> formFields = [];
  if (delete) {
    String profileName = qsController.key!;
    titleVar = 'Delete Profile $profileName';
    formFields.add(deleteQuery());
  } else {
    if (edit) {
      String profileName = qsController.key!;
      titleVar = 'Edit Profile $profileName';
      cmdLineController.text =
          qsController.value != null ? qsController.value! : '';
      formFields.add(commandField());
      formFields.add(descriptionField());
    } else {
      titleVar = 'New Profile';
      formFields.add(nameField());
      formFields.add(commandField());
      formFields.add(descriptionField());
    }
  }
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titleVar),
        titleTextStyle: kDefaultTextStyle,
        backgroundColor: backgroundColor,
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 350,
            child: Column(
              children: formFields,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Accept'),
            onPressed: () {
              log.debug('onPressed - Accept pressed.');
              ScanProfile profile =
                  Provider.of<ScanProfile>(context, listen: false);
              Config config = profile.config;
              if (delete) {
                qsController.deleteEntry(qsController.key!);
                config.removeSection(qsController.key!);
                if (qsController.map != null) {
                  controller?.text = qsController.map!.values.first;
                } else {
                  controller?.text = '';
                }
                profile.save();
                Navigator.of(context).pop();
              } else {
                bool isValid = formKey.currentState!.validate();
                if (isValid) {
                  if (edit) {
                    qsController.editEntry(
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
                  controller?.text = cmdLineController.text;
                  Provider.of<ScanProfile>(context, listen: false).save();
                  Navigator.of(context).pop();
                } else {
                  log.warning('onPressed - profile ${nameController.text}: '
                      '${cmdLineController.text} not valid');
                }
              }
              return;
            },
          ),
        ],
      );
    },
  );
}
