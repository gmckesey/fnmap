import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart' show MatchText;
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
  final bool selectable;
  final NLog _log =
      NLog('FormattedText:', flag: nLogTRACE, package: kPackageName);

  FormattedText(
    this.text, {
    super.key,
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    TextOverflow? overflow,
    int? maxLines,
    this.selectable = true,
  })  : _maxLines = maxLines,
        _overflow = overflow,
        _textDirection = textDirection,
        _textAlign = textAlign,
        _style = style;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final theme = Theme.of(context);

    FnMapConfig nmapConfig = Provider.of<FnMapConfig>(context, listen: true);
    List<MatchText> matches =
        generateMatches(nmapConfig, theme.colorScheme.primary);

    Map<String, MatchText> mapping = {};
    for (var e in matches) {
      if (e.pattern != null && e.pattern!.isNotEmpty) {
        mapping[e.pattern!] = e;
      }
    }

    List<InlineSpan> spans = [];
    if (mapping.isEmpty || text.isEmpty) {
      spans.add(TextSpan(text: text));
    } else {
      final combinedPattern = '(${mapping.keys.join('|')})';
      try {
        final regExp = RegExp(combinedPattern, multiLine: true);
        text.splitMapJoin(
          regExp,
          onMatch: (Match match) {
            final matchText = match[0] ?? '';
            MatchText? matchConfig = mapping[matchText];
            if (matchConfig == null) {
              for (var key in mapping.keys) {
                if (RegExp(key, multiLine: true).hasMatch(matchText)) {
                  matchConfig = mapping[key];
                  break;
                }
              }
            }
            if (valid.isURL(matchText)) {
              spans.add(TextSpan(
                text: matchText,
                style: matchConfig?.style ?? _style,
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    try {
                      await launchUrl(Uri.parse(matchText));
                    } catch (e) {
                      _log.error('Error launching URL $matchText: $e');
                    }
                  },
              ));
            } else {
              spans.add(TextSpan(
                text: matchText,
                style: matchConfig?.style ?? _style,
              ));
            }
            return '';
          },
          onNonMatch: (String nonMatch) {
            spans.add(TextSpan(text: nonMatch));
            return '';
          },
        );
      } catch (e) {
        _log.warning('Regex parse error: $e');
        spans.add(TextSpan(text: text));
      }
    }

    if (selectable) {
      return SelectableText.rich(
        TextSpan(children: spans, style: _style ?? defaultTextStyle.style),
        textAlign: _textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
        textDirection: _textDirection ?? Directionality.of(context),
        maxLines: _maxLines,
        scrollPhysics: const NeverScrollableScrollPhysics(),
      );
    }

    return Text.rich(
      TextSpan(children: spans, style: _style ?? defaultTextStyle.style),
      textAlign: _textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      textDirection: _textDirection ?? Directionality.of(context),
      overflow: _overflow ?? TextOverflow.clip,
      maxLines: _maxLines ?? defaultTextStyle.maxLines,
    );
  }

  List<MatchText> generateMatches(FnMapConfig config, [Color? colorSchemeColor]) {
    List<MatchText> value = [];
    for (HighLightConfig h in config.highlights(colorSchemeColor: colorSchemeColor)) {
      MatchText element = MatchText(
        pattern: h.regex,
        style: h.textStyle,
      );
      value.add(element);
    }

    return value;
  }
}
