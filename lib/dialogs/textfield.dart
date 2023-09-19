import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KriolTextField extends StatelessWidget {
  final TextEditingController controllerP;
  final IconData? iconP;
  final String? hintP;
  final String? labelP;
  final void Function(String ?)? onSavedP;
  final String? Function(String ?)? validatorP;
  final void Function(String ?)? onSubmittedP;

  const KriolTextField({
    super.key,
    required this.controllerP, this.iconP, this.hintP, this.labelP,
    this.onSavedP, this.validatorP, this.onSubmittedP
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
