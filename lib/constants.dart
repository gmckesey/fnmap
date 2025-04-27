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
const String kAppVersion = '1.3.4-1';
const String kPackageName = 'com.krioltech.fnmap';
const String kProfileFilename = 'scan_profile.usp';
const String kConfigFilename = 'fnmap.conf';
const String kZenmapConfFilename = 'zenmap.conf';
const String kCustomKey = 'Custom';
//const Color kDefaultColor = Colors.teal;
const Color kDefaultColor = Colors.white70;
const Color kAccentColor = Colors.indigoAccent;
//const Color kValidColor = Color(0xff2e7d32);  // Green
const Color kValidColor = Color(0xff61B065);
const Color kInvalidColor = Color(0xffdd2c00); // Red;
const Color kTileBackgroundColor = Color(0xD6EAFBFF);
const Color kDefaultTextColor = Colors.blue;// Colors.black87;
const Color kLightTextColor = Colors.white;
const Color kDisabledColor = Colors.grey;
const Color kDividerColor = Colors.grey;
const Color kDefaultBackgroundColor = Color(0xDED5D5FF);
Color kDetailsBackgroundColor = Colors.grey;

const String gFlagTrace = 'TRACE';
const String gGPLFilename = 'gpl-2.0.md';
const List<String> kDesktopGPLPaths = [
  '/etc/fnmap',
  './meta/gui/assets',
  './assets',
  './',
  './snap/gui/assets',
  './data/flutter_assets/snap/gui/assets',
  '/snap/fnmap/current/meta/gui',
];

const String kIconPath = 'assets/fnmap.png';

const List<String> iconPaths = [
  './meta/gui/fnmap.png'
  '/tmp/fnmap.png',
  'assets/fnmap.png',
  '/usr/share/icons/fnmap.png',
  'data/flutter_assets/snap/gui/assets/fnmap.png',
  '/snap/fnmap/current/meta/gui/fnmap.png',
];

TextStyle kDefaultTextStyle = GoogleFonts.sourceCodePro(
  fontSize: 16.0,
  color: kDefaultTextColor,
);


TextStyle kDetailsTextStyle = kDefaultTextStyle.copyWith(fontSize: 14.0);
TextStyle kDetailsStringStyle = kDetailsTextStyle.copyWith(color: Colors.black);
TextStyle kDetailsKeyStyle = kDefaultTextStyle.copyWith(color: kAccentColor);

int kConfigVersionMajor = 1;
int kConfigVersionMinor = 1;
int kConfigVersionPatch = 0;
int kConfigVersionBuild = 0;
int kConfigVersionBuildType = 0; // 0 = release, 1 = debug
int kConfigVersion = (kConfigVersionMajor * 10000) +
    (kConfigVersionMinor * 1000) +
    (kConfigVersionPatch * 100) +
    kConfigVersionBuild;

const List<String> kDefaultConfigs = [
  '[version]',
  'major = 1',
  'minor = 1',
  'patch = 0',
  'build = 0',
  'build_type = release',
  '[window]',
  'theme = dark',
  '[closed_port_highlight]',
  'regex = \\d{1,5}/.{1,5}\\s+closed\\s+.*',
  'bold = 0',
  'text = [65535, 0, 0]',
  'italic = 0',
  'highlight = [65535, 65535, 65535]',
  'underline = 0',
  '[date_highlight]',
  'regex = \\d{4}-\\d{2}-\\d{2}\\s\\d{2}:\\d{2}\\s+.*',
  'bold = 1',
  'text = [0, 0, 0]',
  'italic = 0',
  'highlight = [65535, 65535, 65535]',
  'underline = 0',
  '[details_highlight]',
  'regex = ^[A-Za-z]+(\\s[A-Za-z]*){0,8}:',
  'bold = 1',
  'text = [0, 0, 0]',
  'italic = 0',
  'highlight = [65535, 65535, 65535]',
  'underline = 0',
  '[filtered_port_highlight]',
  'regex = \\d{1,5}/.{1,5}\\s+filtered\\s+.*',
  'bold = 0',
  'text = [38502, 39119, 0]',
  'italic = 0',
  'highlight = [65535, 65535, 65535]',
  'underline = 0',
  '[hostname_highlight]',
  'regex = ([-a-zA-Z]{2,}://)?\\b([-a-zA-Z0-9_]+\\.)+[a-zA-Z]{2,}\\b',
  'bold = 0',
  'text = [0, 111, 65535]',
  'italic = 0',
  'highlight = [65535, 65535, 65535]',
  'underline = 0',
  '[ip_highlight]',
  'regex = \\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}',
  'bold = 1',
  'text = [0, 0, 0]',
  'italic = 0',
  'highlight = [65535, 65535, 65535]',
  'underline = 0',
  '[open_port_highlight]',
  'regex = \\d{1,5}/.{1,5}\\s+open\\s+.*',
  'bold = 1',
  'text = [0, 41036, 2396]',
  'italic = 0',
  'highlight = [65535, 65535, 65535]',
  'underline = 0',
  '[output_highlight]',
  'enable_highlight = True',
  '[paths]',
  'nmap_command_path = nmap',
  'ndiff_command_path = ndiff',
  '[port_list_highlight]',
  'regex = ^PORT\\s+STATE\\s+SERVICE(\\s+VERSION)?.*',
  'bold = 1',
  'text = [0, 1272, 28362]',
  'italic = 0',
  'highlight = [65535, 65535, 65535]'
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
  'command = nmap -sS -sU -T4 -A -v -PE -PS 80,443 -PA 3389 -PP -PU 40125 '
      '-PY --source-port 53 --script "default or (discovery and safe)"',
  'description = This is a comprehensive, slow scan. Every TCP and UDP '
      'port is scanned. OS detection (-O), version detection (-sV), script '
      'scanning (-sC), and traceroute (--traceroute) are all enabled. Many probes are sent for host discovery. This is a highly intrusive scan.',
];
