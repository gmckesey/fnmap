import 'package:google_fonts/google_fonts.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:split_view/split_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:provider/provider.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/nmap_xml.dart';
import 'package:fnmap/models/host_record.dart';
import 'package:fnmap/constants.dart';

class NMapViewController with ChangeNotifier {
  late ScrollController _hostScrollController;
  late List<double?> splitViewWeights;

  late NMapScrollOffset _initialPosition;
  int? _selected;

  NLog log = NLog(
    'NMapViewController:',
    flag: nLogTRACE,
    package: kPackageName,
  );

  NMapScrollOffset get initialPosition => _initialPosition;

  NMapViewController() {
    log.debug('default constructor called');
    clear();
    _hostScrollController = TrackingScrollController(keepScrollOffset: true);
    _hostScrollController.addListener(_scrollListener);
  }

  NMapViewController.withScrollController(ScrollController controller) {
    log.debug('withScrollController constructor called - offset = '
        '${_hostScrollController.offset}');
    clear();
    _hostScrollController = controller;
    _hostScrollController.addListener(_scrollListener);
  }

  void clear() {
    _initialPosition = NMapScrollOffset(0.0);
    splitViewWeights = [0.5, 0.5];
    _selected = null;
  }

  void _scrollListener() {
    _initialPosition.offset = _hostScrollController.offset;
    log.debug(
      'scrollController: offset is ${_hostScrollController.offset}',
      flag: nLogTRACE,
    );
  }

  ScrollController get hostScrollController => _hostScrollController;
  bool get isSelected => _selected != null && _selected != -1;
  int get selected => _selected != null ? _selected! : -1;
  set selected(int value) {
    log.debug('selected set to $value');
    _selected = value;
    notifyListeners();
  }
}

class NMapDeviceView extends StatelessWidget {
  const NMapDeviceView(
      {Key? key,
      required this.placeholder,
      required this.viewFunction,
      this.controller})
      : super(key: key);

  final Widget placeholder;
  final Widget Function({required NMapHostRecord selectedHost}) viewFunction;
  final NMapViewController? controller;

  @override
  Widget build(BuildContext context) {
    NMapXML nMapXML = Provider.of<NMapXML>(context, listen: true);
    NMapCommand command = Provider.of<NMapCommand>(context, listen: true);
    NLog trace = NLog(
      'NMapDeviceView',
      flag: nLogTRACE,
      package: kPackageName,
    );
    List<NMapHostRecord> hostRecords = nMapXML.hostRecords;
    trace.debug('build: nMapXML state is ${nMapXML.state}');

    if (controller != null && controller!.isSelected) {
      trace.debug('build: nMapXML state is ${nMapXML.state} selected record is '
          '${controller!.selected}');
    } else {
      trace.debug('build: nMapXML state is ${nMapXML.state}');
    }
    if (!nMapXML.isProcessed) {
      if (nMapXML.error) {
        return const Center(child: Text('Error processing XML'));
      } else if (command.inProgress) {
        return Center(
          child: LoadingAnimationWidget.stretchedDots(
              color: kAccentColor, size: 85.0),
        );
      } else {
        return placeholder;
      }
    } else {
      // Color textColor = Theme.of(context).primaryColorLight;
      // Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
      Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Neumorphic(
          style: NeumorphicStyle(
            border: const NeumorphicBorder(width: 3, color: Colors.black12),
            shape: NeumorphicShape.convex,
            depth: -10,
            lightSource: LightSource.topRight,
            // color: Colors.white38,
            // color: Colors.black54,
            color: backgroundColor,
          ),
          child: SelectedDeviceWidget(
            viewFunction: viewFunction,
            hostRecords: hostRecords,
            hostViewController: controller,
          ),
        ),
      );
    }
  }
}

class SelectedDeviceWidget extends StatefulWidget {
  const SelectedDeviceWidget(
      {Key? key,
      required this.hostRecords,
      this.hostViewController,
      required this.viewFunction,
      this.splitViewController})
      : super(key: key);
  final List<NMapHostRecord> hostRecords;
  final NMapViewController? hostViewController;
  final SplitViewController? splitViewController;
  final Widget Function({required NMapHostRecord selectedHost}) viewFunction;

  @override
  State<SelectedDeviceWidget> createState() => _SelectedDeviceWidgetState();
}

class _SelectedDeviceWidgetState extends State<SelectedDeviceWidget> {
  NLog trace = NLog(
    '_PortsViewWidgetState',
    flag: nLogTRACE,
    package: kPackageName,
  );
  NLog log = NLog(
    '_PortsViewWidgetState',
    package: kPackageName,
  );
  late NMapViewController _selectedHostController;
  late SplitViewController _svController;

  @override
  void initState() {
    trace.debug('initState called'); //, color: nLogColor.red);
    super.initState();

    _selectedHostController = widget.hostViewController ?? NMapViewController();
    if (_selectedHostController.initialPosition.offset != 0.0) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        trace.debug('initState<postFrameCallback>: initialPosition = '
            '${_selectedHostController.initialPosition.offset}');
        scroll(_selectedHostController.initialPosition.offset);
      });
    }
    _svController = widget.splitViewController ??
        SplitViewController(
          weights: _selectedHostController.splitViewWeights,
          limits: [WeightLimit(min: 0.25, max: 0.75), null],
        );
    _svController.addListener(() {
      trace.debug('_svController<Listener>: '
          'limits = ${_svController.limits}'
          'weights = ${_svController.weights}');
      _selectedHostController.splitViewWeights = _svController.weights;
    });
  }

  @override
  Widget build(BuildContext context) {
    // log.debug('rebuild with selected = ${_controller.selected}', color: LogColor.magenta);
    List<NMapHostRecord> activeHosts =
        NMapHostRecord.getActiveHosts(widget.hostRecords);
    return SplitView(
      controller: _svController,
      viewMode: SplitViewMode.Horizontal,
      indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
      activeIndicator: const SplitIndicator(
          viewMode: SplitViewMode.Horizontal, isActive: true),
      children: [
        Container(
          // flex: 5,
          child: buildReorderableListView(activeHosts),
        ),
/*        const VerticalDivider(
          color: kDividerColor,
          width: 20,
          thickness: 2,
          indent: 20,
          endIndent: 20,
        ),*/
        _selectedHostController.selected != -1
            ? Container(
                // flex: 9,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: widget.viewFunction(
                    selectedHost:
                        activeHosts[_selectedHostController.selected]))
            : const Center(child: Text('Select a host')),
      ],
    );
  }

  ReorderableListView buildReorderableListView(
      List<NMapHostRecord> activeHosts) {
    return ReorderableListView.builder(
        //padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          NMapHostRecord record = activeHosts[index];
          String hostname = record.firstHostname;
          return ListTile(
            title: Text(
              hostname,
              style: GoogleFonts.lato(fontSize: 14.0),
            ),
            key: Key(hostname),
            selected: _selectedHostController.selected == index,
            // selectedColor: const Color(0xF8C465FF),
            // tileColor: kTileBackgroundColor,
            textColor: Theme.of(context).primaryColor,
            selectedColor: Theme.of(context).highlightColor,
            dense: true,
            contentPadding: const EdgeInsets.only(left: 8.0),
            onTap: () {
              log.debug('build<onTap>: tapped $hostname');
              setState(() {
                if (_selectedHostController.selected == index) {
                  _selectedHostController.selected = -1;
                } else {
                  _selectedHostController.selected = index;
                }
              });
            },
          );
        },
        scrollController: _selectedHostController.hostScrollController,
        //itemExtent: 25.0,
        itemCount: activeHosts.length,
        shrinkWrap: true,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final NMapHostRecord item = activeHosts.removeAt(oldIndex);
            activeHosts.insert(newIndex, item);
          });
        });
  }

  void scroll(double position) {
    _selectedHostController.hostScrollController.jumpTo(position);
  }
}
