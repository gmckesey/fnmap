import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:provider/provider.dart';
import 'package:nmap_gui/constants.dart';
import 'package:nmap_gui/utilities/fnmap_config.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl;
import 'package:glog/glog.dart';
import 'package:validators/validators.dart' as valid;

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextOverflow? overflow;
  final int? maxLines;
  final GLog log = GLog('FormattedText:', properties: gLogPropALL);

  final parse = <MatchText>[
    MatchText(
      pattern: r"MAC Address:",
      renderWidget: ({required pattern, required text}) => Text(
        text,
        textDirection: TextDirection.ltr,
        style: const TextStyle(
          decoration: TextDecoration.underline,
        ),
      ),
      onTap: (String username) {
        GLog('FormattedText:', properties: gLogPropALL)
            .debug(username.substring(1));
      },
    ),
    MatchText(
      pattern: r"@([a-z][a-z0-9_]{4,31})",
      renderWidget: ({required pattern, required text}) => Text(
        text,
        textDirection: TextDirection.ltr,
        style: const TextStyle(
          decoration: TextDecoration.underline,
        ),
      ),
      onTap: (String username) {
        GLog('FormattedText:', properties: gLogPropALL)
            .debug(username.substring(1));
      },
    ),
    MatchText(
        type: ParsedType.URL,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: kDefaultTextSize,
        ),
        onTap: (url) async {
          Uri uri = Uri.parse(url);
          try {
            var a = await launchUrl(uri);
          } catch (e) {
            GLog('FormattedText', properties: gLogPropALL)
                .error('MatchText error $e launching $url');
            return;
          }

/*          if (a) {
            launchUrl(uri);
          }*/
        }),
  ];

  FormattedText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.overflow,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    // TODO: (2023-03-14) Debugging here
    FnMapConfig nmapConfig = Provider.of<FnMapConfig>(context, listen: true);

    List<HighLightConfig> hConfigs =
        nmapConfig.highlightsEnabled ? nmapConfig.highlights() : [];
    List<MatchText> matches = generateMatches(nmapConfig);

    return ParsedText(
      text: text,
      style: style ?? defaultTextStyle.style,
      alignment: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      textDirection: textDirection ?? Directionality.of(context),
      overflow: TextOverflow.clip,
      maxLines: maxLines ?? defaultTextStyle.maxLines,
      parse: matches, //parse, // matches,
      regexOptions: const RegexOptions(multiLine: true),
    );
  }

  List<MatchText> generateMatches(FnMapConfig config) {
    List<MatchText> value = [];
    for (HighLightConfig h in config.highlights()) {
      MatchText element = MatchText(
        pattern: h.regex,
        renderWidget: ({required pattern, required text}) => Text(
          text,
          textDirection: TextDirection.ltr,
          style: h.textStyle,
        ),
        onTap: (String value) async {
          if (valid.isURL(value)){
            Uri uri = Uri.parse(value);
            try {
              var a = await launchUrl(uri);
            } catch (e) {
              GLog('FormattedText', properties: gLogPropALL)
                  .error('MatchText error $e launching $value');
              return;
            }
          } else {
            GLog('MatchText:', properties: gLogPropALL)
                .debug('onTap: selected $value');
          }
        },
      );
      value.add(element);
    }

    return value;
  }
}
