import 'dart:io';
import 'package:flutter/material.dart';

Future<bool> isSudoPasswordRequired() async {
  if (Platform.isWindows) return false;
  try {
    ProcessResult result = await Process.run('sudo', ['-n', 'true']);
    return result.exitCode != 0;
  } catch (_) {
    return true;
  }
}

Future<bool> verifySudoPassword(String password) async {
  try {
    Process p = await Process.start('sudo', ['-S', '-p', '', '-v']);
    p.stdin.writeln(password);
    await p.stdin.flush();
    await p.stdin.close();
    int code = await p.exitCode;
    return code == 0;
  } catch (e) {
    return false;
  }
}

Future<String?> showRootPasswordDialog(
  BuildContext context, {
  required ThemeData themeData,
  String? title,
  String? message,
}) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Theme(
        data: themeData,
        child: _PasswordDialogContent(
          title: title ?? 'Root Privileges Required',
          message: message ??
              'Running nmap as root requires superuser privileges.\nPlease enter your password:',
          themeData: themeData,
        ),
      );
    },
  );
}

class _PasswordDialogContent extends StatefulWidget {
  final String title;
  final String message;
  final ThemeData themeData;

  const _PasswordDialogContent({
    required this.title,
    required this.message,
    required this.themeData,
  });

  @override
  State<_PasswordDialogContent> createState() => _PasswordDialogContentState();
}

class _PasswordDialogContentState extends State<_PasswordDialogContent> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password cannot be empty.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    bool isValid = await verifySudoPassword(password);
    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pop(password);
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Authentication failed. Please check your password.';
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.shield, color: widget.themeData.primaryColor),
          const SizedBox(width: 10),
          Text(widget.title),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofocus: true,
              enabled: !_isVerifying,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            if (_isVerifying) ...[
              const SizedBox(height: 12),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Verifying password...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.themeData.primaryColor,
            foregroundColor: widget.themeData.primaryColorLight,
          ),
          onPressed: _isVerifying ? null : _submit,
          child: const Text('Authenticate'),
        ),
      ],
    );
  }
}
