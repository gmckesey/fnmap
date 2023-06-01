import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const String knMAPCommand = 'nmap';
const String knMAPPing = '-sP';
const String knXMLOut = '-oX';
const double kDefaultTextSize = 14;
const double kDefaultIconSize = 16;
// const double kDefaultMenuFont =
const double kDefaultMenuFontSize = 12;
const String kProgramName = 'fnmap';
const String kAppVersion = 'beta-0.1.10';
const String kPackageName = 'com.krioltech.fnmap';
const String kProfileFilename = 'scan_profile.usp';
const String kConfigFilename = 'fnmap.conf';
const String kZenmapConfFilename = 'zenmap.conf';
const String kCustomKey = 'Custom';
//const Color kDefaultColor = Colors.teal;
const Color kDefaultColor = Colors.indigo;
const Color kAccentColor = Colors.indigoAccent;
const Color kValidColor = Colors.green;
const Color kInvalidColor = Colors.red;
const Color kTileBackgroundColor = Color(0xD6EAFBFF);
const Color kDefaultTextColor = Colors.black87;
const Color kLightTextColor = Colors.white;
const Color kDisabledColor = Colors.grey;
const Color kDividerColor = Colors.grey;
const Color kDefaultBackgroundColor = Color(0xDED5D5FF);
Color kDetailsBackgroundColor = Colors.grey;

const String gFlagTrace = 'TRACE';
const List<String> kLinuxGPLPaths = [
  '/etc/fnmap/gpl-2.0.md',
  './meta/gui/gpl-2.0.md',
  './gpl-2.0.md',
  './snap/gui/gpl-2.0.md',
  '/snap/fnmap/current/meta/gui/gpl-2.0.md',
];

const List<String> iconPaths = [
  './meta/gui/fnmap.png'
  '/tmp/fnmap.png',
  'assets/fnmap.png',
  './assets/fnmap.png',
  '/usr/share/icons/fnmap.png',
  '/snap/fnmap/current/meta/gui/fnmap.png',
];

TextStyle kDefaultTextStyle = GoogleFonts.sourceCodePro(
  fontSize: 16.0,
  color: kDefaultTextColor,
);


TextStyle kDetailsTextStyle = kDefaultTextStyle.copyWith(fontSize: 14.0);
TextStyle kDetailsStringStyle = kDetailsTextStyle.copyWith(color: Colors.black);
TextStyle kDetailsKeyStyle = kDefaultTextStyle.copyWith(color: kDefaultColor);


const List<String> kDefaultConfigs = [
  '[hostname_highlight]',
  'regex = ([-a-zA-Z]{2,}://)?\\b([-a-zA-Z0-9_]+\\.)+[a-zA-Z]{2,}\\b',
  'bold = 0',
  'text = [0, 111, 65535]',
  'italic = 0',
  'highlight = [65535, 65535, 65535]',
  'underline = 0',
];
const List<String> kDefaultProfiles = [
  '[Intense scan]',
  'command = nmap -T4 -A -v',
  'description = An intense, comprehensive scan. '
      'The -A option enables OS detection (-O), version detection (-sV), '
      'script scanning (-sC), and traceroute (--traceroute). '
      'Without root privileges only version detection and script '
      'scanning are run. This is considered an intrusive scan.',
  '[Intense scan plus UDP]',
  'command = nmap -sS -sU -T4 -A -v',
  'description = Does OS detection (-O), version detection (-sV), '
      'script scanning (-sC), and traceroute (--traceroute) '
      'in addition to scanning TCP and UDP ports.',
  '[Intense scan, all TCP ports]',
  'command = nmap -p 1-65535 -T4 -A -v',
  'description = Scans all TCP ports, then does OS detection (-O), '
      'version detection (-sV), script scanning (-sC), '
      'and traceroute (--traceroute).',
  '[Intense scan, no ping]',
  'command = nmap -T4 -A -v -Pn',
  'description = Does an intense scan without checking to see if '
      'targets are up first. This can be useful when a target seems to ignore '
      'the usual host discovery probes.',
  '[Ping scan]',
  'command = nmap -sn',
  'description = This scan only finds which targets are up and does not '
      'port scan them.',
  '[Quick scan]',
  'command = nmap -T4 -F',
  'description = This scan is faster than a normal scan because it '
      'uses the aggressive timing template and scans fewer ports.',
  '[Quick scan plus]',
  'command = nmap -sV -T4 -O -F --version-light',
  'description = A quick scan plus OS and version detection.',
  '[Quick traceroute]',
  'command = nmap -sn --traceroute',
  'description = Traces the paths to targets without '
      'doing a full port scan on them.',
  '[Regular scan]',
  'command = nmap',
  'description = A basic port scan with no extra options.',
  '[Slow comprehensive scan]',
  'command = nmap -sS -sU -T4 -A -v -PE -PS80,443 -PA3389 -PP -PU40125 '
      '-PY --source-port 53 --script "default or (discovery and safe)"',
  'description = This is a comprehensive, slow scan. Every TCP and UDP '
      'port is scanned. OS detection (-O), version detection (-sV), script '
      'scanning (-sC), and traceroute (--traceroute) are all enabled. Many probes are sent for host discovery. This is a highly intrusive scan.',
];
