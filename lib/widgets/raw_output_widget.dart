import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:nmap_gui/constants.dart';
import 'package:nmap_gui/widgets/formatted_text.dart';
import 'package:glog/glog.dart';
import 'package:nmap_gui/models/nmap_command.dart';

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
  GLog log = GLog('_NMapOutputWidgetState:',
      flag: gLogTRACE, package: kPackageName);
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
    int length = widget.result != null ? widget.result!.length : 0;
    if (length != lastLength) {
      lastLength = length;
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      }
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    log.debug('build: initialPosition = ${widget.initialPosition}');
    // TODO: Temporary call just to work on the initial scroll position
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPosition());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Neumorphic(
        style: const NeumorphicStyle(
          border: NeumorphicBorder(width: 3, color: Colors.black12),
          shape: NeumorphicShape.convex,
          depth: -10,
          lightSource: LightSource.topRight,
          color: Colors.white38,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
              key: const Key('OutputScrollView'),
              controller: widget.outputCtrl,
              child: FormattedText(
                widget.result ?? '',
                overflow: TextOverflow.visible,
              )),
        ),
      ),
    );
  }

  void scroll(double position) {
    widget.outputCtrl.jumpTo(position);
  }

  // TODO: Temporary call to work on the scroll postion
  void _showPosition() {
    // if (outputCtrl.positions.isNotEmpty &&  outputCtrl.position.hasPixels) {
    log.debug('showPosition: scroll controller position is '
        '${widget.outputCtrl.offset}');
    // }
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
