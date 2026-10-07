import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fnmap/constants.dart';
import 'package:fnmap/widgets/formatted_text.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/models/dark_mode.dart';

class NMapRawOutputWidget extends StatefulWidget {
  const NMapRawOutputWidget({
    super.key,
    required this.outputCtrl,
    required this.result,
    required this.initialPosition,
  });

  final ScrollController outputCtrl;
  final String? result;
  final NMapScrollOffset initialPosition;

  @override
  State<NMapRawOutputWidget> createState() => _NMapRawOutputWidgetState();
}

class _NMapRawOutputWidgetState extends State<NMapRawOutputWidget> {
  NLog log = NLog('_NMapRawOutputWidgetState:',
      flag: nLogTRACE, package: kPackageName);
  late int lastLength;

  @override
  void initState() {
    super.initState();
    lastLength = 0;
    // Need to initialize the scroll position
    // log.debug('initState: scroll position is: ${widget.outputCtrl.offset}');
    if (widget.initialPosition.offset != 0.0) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        log.debug('initState<postFrameCallback>: initialPosition = '
            '${widget.initialPosition}');
        scroll(widget.initialPosition.offset);
      });
    } else {
      log.debug('initState: initialPosition is 0.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    /*    if (outputCtrl.positions.isNotEmpty &&  outputCtrl.position.hasPixels) {
      log.debug('build: scroll controller position is '
          '${outputCtrl.position.pixels}');
    }*/
    // If the current result length has changed, scroll to the end
    // TODO:  will have to see if we really want this or need a
    ///       a more complicated decision process for scrolling

    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    int length = widget.result != null ? widget.result!.length : 0;
    if (length != lastLength) {
      lastLength = length;
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      }
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    log.debug('build: initialPosition = ${widget.initialPosition}');

    final bool isDark = mode.isDarkMode;
    final Color selectionColor = isDark
        ? mode.themeData.colorScheme.primary.withValues(alpha: 0.45)
        : mode.themeData.colorScheme.primary.withValues(alpha: 0.35);

    return TextSelectionTheme(
      data: TextSelectionThemeData(
        selectionColor: selectionColor,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              key: const Key('OutputScrollView'),
              controller: widget.outputCtrl,
              child: FormattedText(
                widget.result ?? '',
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.none,
                  color: mode.themeData.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (widget.result != null && widget.result!.trim().isNotEmpty)
            Positioned(
              top: 8,
              right: 16,
              child: Material(
                color: mode.themeData.colorScheme.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.result!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Raw output copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy,
                            size: 16,
                            color: mode.themeData.colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Copy All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mode.themeData.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void scroll(double position) {
    widget.outputCtrl.jumpTo(position);
  }

  // Scroll output window to the end
  _scrollToEnd() async {
    var scrollPosition = widget.outputCtrl.position;
    bool needScroll =
        scrollPosition.viewportDimension < scrollPosition.maxScrollExtent;
    if (needScroll) {
      widget.outputCtrl.animateTo(scrollPosition.maxScrollExtent,
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    }
  }
}
