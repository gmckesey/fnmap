import 'package:provider/provider.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/utilities/scan_profile.dart';
import 'package:fnmap/utilities/fnmap_config.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0;

  void askToOverwrite(int version, bool overwrite) {
    NLog log = NLog('SplashScreen', flag: nLogTRACE, package: kPackageName);
    FnMapConfig config = Provider.of<FnMapConfig>(context, listen: false);

    if (overwrite) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        String? value = await showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Configuration File Update'),
            content: Text(
                'Your configuration file\'s version $version is out of date. '
                'Would you like to update it to the latest version? '
                'WARNING: This will overwrite any custom configurations you have made.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                  log.debug('User chose to overwrite the configuration file.');
                  config.defaultOverwrite();
                  //setState(() {
                    NMapDarkMode darkMode =
                        Provider.of<NMapDarkMode>(context, listen: false);
                    darkMode.mode = config.isDark()
                        ? NMapThemeMode.dark
                        : NMapThemeMode.light;
                    opacity = 1;
                  //});
                },
                child: const Text('OVERWRITE'),
              ),
            ],
          ),
        );

        if (value != null) {
          log.debug('User chose $value.');
        } else {
          log.debug('User did not choose to overwrite the configuration file.');
        }
      });
    }
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ScanProfile profile = Provider.of<ScanProfile>(context, listen: false);

    return FlutterSplashScreen(
      //duration: const Duration(seconds: 5),
      onEnd: () async {
        // NLog log = NLog('SplashScreen', flag: nLogTRACE, package: kPackageName);
        // log.debug('Splash screen ended.');
        // await profile.parse();
        // setState(() {
        //   opacity = 1;
        // });
      },
      onInit: () async {
       // await Future.delayed(const Duration(milliseconds: 2000));
        // await profile.parse();
      },
      asyncNavigationCallback: () async {
        FnMapConfig config = Provider.of<FnMapConfig>(context, listen: false);

        await Future.delayed(const Duration(milliseconds: 5000));
        await config
            .parse(overwriteCallback: askToOverwrite)
            .catchError((error) {
          NLog log =
              NLog('SplashScreen', flag: nLogTRACE, package: kPackageName);
          log.error('Error parsing config file: $error');
        });
      },
      backgroundColor: Colors.black,
      splashScreenBody: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            const Text(
              "Fnmap is starting...",
              style: TextStyle(color: Colors.white70, fontSize: 24),
            ),
            const Spacer(),
            SizedBox(
              width: 514,
              child: Image.asset('assets/hero.jpg', scale: 0.5),
            ),
            const Spacer(),
            const Text(
              "Fnmap - An Nmap GUI",
              style: TextStyle(color: Color(0xFF333FFF), fontSize: 20),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
