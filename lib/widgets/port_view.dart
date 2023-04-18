import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart'
    hide MenuBar
    hide MenuStyle;
import 'package:glog/glog.dart';
import 'package:nmap_gui/models/host_record.dart';
import 'package:nmap_gui/constants.dart';

class NMapPortGrid extends StatelessWidget {
  const NMapPortGrid({Key? key, required this.hostRecord}) : super(key: key);
  final NMapHostRecord hostRecord;

  @override
  Widget build(BuildContext context) {
    GLog log =
        GLog('NMapPortGrid:', flag: gLogTRACE, package: kPackageName);
    log.debug('rebuild', color: GLogColor.magenta);
    Color backgroundColor = Theme.of(context).canvasColor;
    Color textColor = Theme.of(context).primaryColorDark;

    Widget renderFunction(PlutoColumnRendererContext renderContext) {
      return Text(
        '${renderContext.cell.value}',
        style: TextStyle(color: textColor),
      );
    }

    List<PlutoColumn> columns = [
      PlutoColumn(
          title: 'Port',
          field: 'port',
          type: PlutoColumnType.number(defaultValue: 0, format: '####'),
          backgroundColor: backgroundColor,
          renderer: renderFunction,
          width: 80,
          minWidth: 60,
          readOnly: true),
      PlutoColumn(
          title: 'Service',
          field: 'service',
          type: PlutoColumnType.text(),
          backgroundColor: backgroundColor,
          renderer: renderFunction,
          width: 100,
          minWidth: 60,
          readOnly: true),
      PlutoColumn(
          title: 'Protocol',
          field: 'protocol',
          type: PlutoColumnType.text(),
          backgroundColor: backgroundColor,
          renderer: renderFunction,
          width: 90,
          minWidth: 60,
          readOnly: true),
      PlutoColumn(
          title: 'State',
          field: 'state',
          type: PlutoColumnType.text(),
          backgroundColor: backgroundColor,
          width: 100,
          minWidth: 60,
          renderer: portStateRenderer,
          readOnly: true),
    ];

    // List<PlutoRow> rows = _generateRows();
    Color colorCallback(PlutoRowColorContext colorContext) {
      return Theme.of(context).primaryColorLight;
    }

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: hostRecord.ports.isEmpty
            ? const Center(child: Text('No Ports Found'))
            : PlutoGrid(
                key: Key(hostRecord.firstHostname),
                columns: columns,
                rows: _generateRows(),
                rowColorCallback: colorCallback,
              ));
  }

  List<PlutoRow> _generateRows() {
    GLog log =
        GLog('NMapPortGrid:', flag: gLogTRACE, package: kPackageName);
    List<PlutoRow> list = [];
    for (int row = 0; row < hostRecord.ports.length; row++) {
      NMapPort port = hostRecord.ports[row];
      if (port.state != 'closed') {
        PlutoRow r = PlutoRow(cells: {
          'port': PlutoCell(value: port.number),
          'service': PlutoCell(value: port.name),
          'protocol': PlutoCell(value: port.protocol),
          'state': PlutoCell(value: port.state),
        });
        list.add(r);
      }
    }
    log.debug('_generateRows returning ${list.length} rows');
    return list;
  }

  Widget portStateRenderer(PlutoColumnRendererContext context) {
    GLog log =
        GLog('NMapPortGrid:', flag: gLogTRACE, package: kPackageName);

    String state = context.cell.value;
    log.debug('rendering state = $state');
    Color color;
    switch (state) {
      case 'filtered':
        color = Colors.orange;
        break;
      case 'closed':
        color = Colors.red;
        break;
      case 'open':
        color = Colors.green;
        break;
      default:
        color = kDefaultTextColor;
        break;
    }
    return Text(
      state,
      style: kDefaultTextStyle.copyWith(fontSize: 14.0, color: color),
    );
  }
}
