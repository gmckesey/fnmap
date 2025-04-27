import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:provider/provider.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/utilities/fnmap_config.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;
import 'package:fnmap/utilities/logger.dart';
import 'package:validators/validators.dart' as valid;

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? _style;
  final TextAlign? _textAlign;
  final TextDirection? _textDirection;
  final TextOverflow? _overflow;
  final int? _maxLines;
  final NLog _log =
      NLog('FormattedText:', flag: nLogTRACE, package: kPackageName);



  FormattedText(
    this.text, {
    Key? key,
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    TextOverflow? overflow,
    int? maxLines,
  }) : _maxLines = maxLines, _overflow = overflow, _textDirection = textDirection, _textAlign = textAlign, _style = style, super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    FnMapConfig nmapConfig = Provider.of<FnMapConfig>(context, listen: true);
    List<MatchText> matches = generateMatches(nmapConfig);

    return ParsedText(
      text: text,
      style: _style ?? defaultTextStyle.style,
      alignment: _textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      textDirection: _textDirection ?? Directionality.of(context),
      overflow: _overflow ?? TextOverflow.clip,
      maxLines: _maxLines ?? defaultTextStyle.maxLines,
      parse: matches, //parse, // matches,
      selectable: false,
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
          selectionColor: Colors.grey,
        ),
        onTap: (String value) async {
          if (valid.isURL(value, protocols: ['http', 'https'], requireProtocol: true)) {
            Uri uri = Uri.parse(value);
            try {
              await launchUrl(uri);
            } catch (e) {
              NLog('FormattedText', flag: nLogTRACE, package: kPackageName)
                  .error('MatchText error $e launching $value');
              return;
            }
          } else {
            NLog('MatchText:', package: kPackageName)
                .debug('onTap: selected $value');
          }
        },
      );
      value.add(element);
    }

    return value;
  }
}
