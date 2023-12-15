import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fnmap/models/nmap_command.dart';
import 'package:fnmap/widgets/nmap_tabular.dart';
import 'package:split_view/split_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/nmap_xml.dart';
import 'package:fnmap/models/service_record.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:fnmap/constants.dart';

class NMapServiceViewController with ChangeNotifier {
  late ScrollController _serviceScrollController;
  late List<double?> splitViewWeights;
  late NMapScrollOffset _initialPosition;
  int? _selected;

  NLog log = NLog('NMapServiceViewController:', flag: nLogTRACE);

  NMapScrollOffset get initialPosition => _initialPosition;

  NMapServiceViewController() {
    clear();
    _serviceScrollController = TrackingScrollController(keepScrollOffset: true);
    _serviceScrollController.addListener(_scrollListener);
  }

  void clear() {
    _selected = null;
    _initialPosition = NMapScrollOffset(0.0);
    splitViewWeights = [0.5, 0.5];
  }

  void _scrollListener() {
    _initialPosition.offset = _serviceScrollController.offset;
    log.debug('scrollController: offset is ${_serviceScrollController.offset}');
  }

  ScrollController get serviceScrollController => _serviceScrollController;
  bool get isSelected => _selected != null && _selected != -1;
  int get selected => _selected != null ? _selected! : -1;
  set selected(int value) {
    log.debug('selected set to $value');
    _selected = value;
    notifyListeners();
  }
}

class NMapServiceView extends StatelessWidget {
  const NMapServiceView({Key? key, required this.placeholder, this.controller})
      : super(key: key);
  final Widget placeholder;
  final NMapServiceViewController? controller;

  @override
  Widget build(BuildContext context) {
    NMapXML nMapXML = Provider.of<NMapXML>(context, listen: true);
    List<NMapServiceRecord> serviceRecords = nMapXML.serviceRecords;
    NMapCommand command = Provider.of<NMapCommand>(context, listen: true);
    NLog log = NLog('NMapServiceView', flag: nLogTRACE);

    if (controller != null && controller!.isSelected) {
      log.debug('build: nMapXML state is ${nMapXML.state} selected record is '
          '${controller!.selected}');
    } else {
      log.debug('build: nMapXML state is ${nMapXML.state}');
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
      // Color backgroundColor = mode.themeData.scaffoldBackgroundColor;

      return Padding(
        padding: const EdgeInsets.all(8.0),
 /*       child: Neumorphic(
          style: NeumorphicStyle(
            border: const NeumorphicBorder(width: 3, color: Colors.black12),
            shape: NeumorphicShape.convex,
            depth: -10,
            lightSource: LightSource.topRight,
            color: backgroundColor, //Colors.white38,
          ),*/
          child: SelectedServiceWidget(
            serviceRecords: serviceRecords,
            serviceViewController: controller,
          ),
 //       ),
      );
    }
  }
}

class SelectedServiceWidget extends StatefulWidget {
  const SelectedServiceWidget(
      {Key? key,
      required this.serviceRecords,
      this.serviceViewController,
      this.splitViewController})
      : super(key: key);

  final List<NMapServiceRecord> serviceRecords;
  final NMapServiceViewController? serviceViewController;
  final SplitViewController? splitViewController;

  @override
  State<SelectedServiceWidget> createState() => _SelectedServiceWidgetState();
}

class _SelectedServiceWidgetState extends State<SelectedServiceWidget> {
  NLog trace = NLog('_SelectedServiceWidgetState', flag: nLogTRACE);
  NLog log = NLog('_SelectedServiceWidgetState');
  late NMapServiceViewController _selectedServiceController;
  late SplitViewController _svController;

  @override
  void initState() {
    trace.debug('initState called'); //, color: NLogColor.red);
    super.initState();

    _selectedServiceController =
        widget.serviceViewController ?? NMapServiceViewController();
    if (_selectedServiceController.initialPosition.offset != 0.0) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        trace.debug('initState<postFrameCallback>: initialPosition = '
            '${_selectedServiceController.initialPosition.offset}');
        scroll(_selectedServiceController.initialPosition.offset);
      });
    }
    _svController = widget.splitViewController ??
        SplitViewController(
          weights: _selectedServiceController.splitViewWeights,
          limits: [WeightLimit(min: 0.25, max: 0.75), null],
        );
    _svController.addListener(() {
      log.debug('_svController<Listener>: '
          'limits = ${_svController.limits}'
          'weights = ${_svController.weights}');
      _selectedServiceController.splitViewWeights = _svController.weights;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<NMapServiceRecord> serviceRecords = widget.serviceRecords;
    // Sort the service records by port number
    serviceRecords.sort((a, b) => a.port.number.compareTo(b.port.number));
    NMapServiceRecord? selectedService =
        _selectedServiceController.selected != -1
            ? serviceRecords[_selectedServiceController.selected]
            : null;

    return SplitView(
      controller: _svController,
      viewMode: SplitViewMode.Horizontal,
      indicator: const SplitIndicator(viewMode: SplitViewMode.Horizontal),
      activeIndicator: const SplitIndicator(
          viewMode: SplitViewMode.Horizontal, isActive: true),
      children: [
        Container(
          // flex: 5,
          child: buildReorderableListView(serviceRecords),
        ),
/*        const VerticalDivider(
          color: kDividerColor,
          width: 20,
          thickness: 2,
          indent: 20,
          endIndent: 20,
        ),*/
        selectedService != null
            ? NMapPlutoGrid(
                key: Key('PlutoGrid-${selectedService.port.number}'),
                hostRecords: selectedService.hosts)
            : const Center(child: Text('Select a service')),
      ],
    );
  }

  ReorderableListView buildReorderableListView(
      List<NMapServiceRecord> serviceRecords) {
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: false);
    return ReorderableListView.builder(
        //padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          NMapServiceRecord record = serviceRecords[index];
          String portName = record.port.longName;
          return ListTile(
            title: Text(
              portName,
              style: GoogleFonts.lato(fontSize: 14.0),
            ),
            key: Key('ListTile-${record.port.number.toString()}'),
            selected: _selectedServiceController.selected == index,
            // selectedColor: const Color(0xF8C465FF),
            // tileColor: kTileBackgroundColor,
            textColor: mode.themeData.secondaryHeaderColor,
            selectedColor: mode.themeData.splashColor,
            dense: true,
            contentPadding: const EdgeInsets.only(left: 8.0),
            onTap: () {
              log.debug('build<onTap>: tapped $portName');
              setState(() {
                if (_selectedServiceController.selected == index) {
                  _selectedServiceController.selected = -1;
                } else {
                  _selectedServiceController.selected = index;
                }
              });
            },
          );
        },
        scrollController: _selectedServiceController.serviceScrollController,
        //itemExtent: 25.0,
        itemCount: serviceRecords.length,
        shrinkWrap: true,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final NMapServiceRecord item = serviceRecords.removeAt(oldIndex);
            serviceRecords.insert(newIndex, item);
          });
        });
  }

  void scroll(double position) {
    _selectedServiceController.serviceScrollController.jumpTo(position);
  }
}
