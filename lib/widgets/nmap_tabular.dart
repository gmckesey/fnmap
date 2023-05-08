import 'package:fnmap/models/nmap_command.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:provider/provider.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/nmap_xml.dart';
import 'package:fnmap/models/host_record.dart';
import 'package:fnmap/constants.dart';

const int gColumnCount = 5;

enum NMAPTabImplementation {
  gridView,
  plutoGrid,
}

class NMapTabularWidget extends StatelessWidget {
  final Widget placeholder;
  final NMAPTabImplementation implementation;

  const NMapTabularWidget({
    Key? key,
    required this.placeholder,
    this.implementation = NMAPTabImplementation.gridView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NMapXML nMapXML = Provider.of<NMapXML>(context, listen: true);
    NMapCommand command = Provider.of<NMapCommand>(context, listen: true);
    NLog log = NLog('NMapTabularWidget',
        flag: nLogTRACE, package: kPackageName);
    List<NMapHostRecord> hostRecords = nMapXML.hostRecords;

    log.debug('build: nMapXML state is ${nMapXML.state}');
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
      // processXML(xml: nMapXML, hostRecords: hostRecords, log: log);
      Widget gridImplementation =
          implementation == NMAPTabImplementation.plutoGrid
              ? NMapPlutoGrid(
                  key: const Key('PlutoGrid-all'), hostRecords: hostRecords)
              : NMapGridview(hostRecords: hostRecords);
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
          child: gridImplementation,
        ),
      );
    }
  }
}

class NMapPlutoGrid extends StatelessWidget {
  const NMapPlutoGrid({
    super.key,
    required this.hostRecords,
  });
  final List<NMapHostRecord> hostRecords;

  @override
  Widget build(BuildContext context) {
    NLog log =
    NLog('NMapPlutoGrid:', package: kPackageName);
    Color backgroundColor = Theme.of(context).canvasColor;
    Color textColor = Theme.of(context).primaryColorDark;

    Widget renderFunction(PlutoColumnRendererContext renderContext) {
      return Text(
        renderContext.cell.value as String,
        style: TextStyle(color: textColor),
      );
    }

    List<PlutoColumn> columns = [
      PlutoColumn(
          title: 'Host',
          field: 'hostname',
          type: PlutoColumnType.text(),
          backgroundColor: backgroundColor,
          renderer: renderFunction,
          readOnly: true),
      PlutoColumn(
          title: 'IP Address',
          field: 'ip_address',
          type: PlutoColumnType.text(),
          backgroundColor: backgroundColor,
          renderer: renderFunction,
          readOnly: true),
      PlutoColumn(
          title: 'Mac Address',
          field: 'mac_address',
          type: PlutoColumnType.text(),
          backgroundColor: backgroundColor,
          renderer: renderFunction,
          readOnly: true),
      PlutoColumn(
          title: 'Vendor',
          field: 'vendor',
          type: PlutoColumnType.text(),
          backgroundColor: backgroundColor,
          renderer: renderFunction,
          readOnly: true),
    ];

    List<PlutoRow> rows = _generateRows();

    Color colorCallback(PlutoRowColorContext colorContext) {
      return Theme.of(context).primaryColorLight;
      //return kDefaultBackgroundColor;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PlutoGrid(
        columns: columns,
        rows: rows,
        onSelected: (event) {
          log.debug('PlutoGrid<onSelected>: event is $event');
        },
        onSorted: (event) {
          log.debug('PlutoGrid<onSorted>: event is $event');
        },
        rowColorCallback: colorCallback,
      ),
    );
  }

  List<PlutoRow> _generateRows() {
    List<PlutoRow> list = [];
    for (int row = 0; row < hostRecords.length; row++) {
      NMapHostRecord record = hostRecords[row];
      // Only display devices that are up
      if (record.deviceStatus != NMapDeviceStatus.up) {
        continue;
      }
      PlutoRow r = PlutoRow(cells: {
        'hostname': PlutoCell(value: record.firstHostname),
        'ip_address': PlutoCell(value: record.ipAddress),
        'mac_address': PlutoCell(value: record.macAddress),
        'vendor': PlutoCell(value: record.vendor),
      });
      list.add(r);
    }
    return list;
  }
}

class NMapGridview extends StatelessWidget {
  const NMapGridview({
    super.key,
    required this.hostRecords,
  });

  final List<NMapHostRecord> hostRecords;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: hostRecords.length * gColumnCount,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gColumnCount,
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
          childAspectRatio: 10,
        ),
        itemBuilder: (context, index) {
          int column = index % gColumnCount;
          int row = index ~/ gColumnCount;
          String value;
          if (row > hostRecords.length - 1) {
            return const Placeholder();
          }
          NMapHostRecord record = hostRecords[row];
          switch (column) {
            case 0:
              value = '$row';
              break;
            case 1:
              value = record.firstHostname;
              break;
            case 2:
              value = record.ipAddress;
              break;
            case 3:
              value = record.macAddress;
              break;
            case 4:
              value = record.vendor;
              break;
            default:
              value = 'N/A';
              break;
          }
          return Text(value, style: kDefaultTextStyle);
        },
      ),
    );
  }
}
