import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fnmap/models/dark_mode.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:fnmap/utilities/logger.dart';
import 'package:fnmap/models/host_record.dart';
import 'package:fnmap/constants.dart';

class NMapPortGrid extends StatelessWidget {
  const NMapPortGrid({super.key, required this.hostRecord});
  final NMapHostRecord hostRecord;

  @override
  Widget build(BuildContext context) {
    NLog trace = NLog('NMapPortGrid:', flag: nLogTRACE, package: kPackageName);
    trace.debug('rebuild'); //, color: NLogColor.magenta);
    NMapDarkMode mode = Provider.of<NMapDarkMode>(context, listen: true);
    final bool isDark = mode.isDarkMode;
    final ColorScheme colorScheme = mode.themeData.colorScheme;

    final Color headerBgColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainer;
    final Color headerTextColor = colorScheme.primary;
    final Color cellTextColor = colorScheme.onSurface;

    Widget renderFunction(PlutoColumnRendererContext renderContext) {
      return Text(
        '${renderContext.cell.value}',
        style: TextStyle(color: cellTextColor, fontSize: 14),
      );
    }

    Widget portStateRenderer(PlutoColumnRendererContext renderContext) {
      String state = renderContext.cell.value.toString();
      Color color;
      switch (state) {
        case 'filtered':
          color = Colors.orange;
          break;
        case 'closed':
          color = Colors.redAccent;
          break;
        case 'open':
          color = isDark ? Colors.greenAccent : Colors.green.shade700;
          break;
        default:
          color = cellTextColor;
          break;
      }
      return Text(
        state,
        style: TextStyle(fontSize: 14.0, color: color, fontWeight: FontWeight.w600),
      );
    }

    List<PlutoColumn> columns = [
      PlutoColumn(
          title: 'Port',
          field: 'port',
          type: PlutoColumnType.number(defaultValue: 0, format: '####'),
          backgroundColor: headerBgColor,
          renderer: renderFunction,
          width: 80,
          minWidth: 60,
          readOnly: true),
      PlutoColumn(
          title: 'Service',
          field: 'service',
          type: PlutoColumnType.text(),
          backgroundColor: headerBgColor,
          renderer: renderFunction,
          width: 100,
          minWidth: 60,
          readOnly: true),
      PlutoColumn(
          title: 'Protocol',
          field: 'protocol',
          type: PlutoColumnType.text(),
          backgroundColor: headerBgColor,
          renderer: renderFunction,
          width: 90,
          minWidth: 60,
          readOnly: true),
      PlutoColumn(
          title: 'State',
          field: 'state',
          type: PlutoColumnType.text(),
          backgroundColor: headerBgColor,
          width: 100,
          minWidth: 60,
          renderer: portStateRenderer,
          readOnly: true),
    ];

    final PlutoGridStyleConfig styleConfig = isDark
        ? PlutoGridStyleConfig.dark(
            gridBackgroundColor: colorScheme.surface,
            rowColor: colorScheme.surface,
            evenRowColor: colorScheme.surfaceContainerLow,
            oddRowColor: colorScheme.surface,
            gridBorderColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
            borderColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
            iconColor: headerTextColor,
            columnTextStyle: TextStyle(
              color: headerTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            cellTextStyle: TextStyle(
              color: cellTextColor,
              fontSize: 14,
            ),
            menuBackgroundColor: colorScheme.surfaceContainerHigh,
            activatedColor: colorScheme.primary.withValues(alpha: 0.25),
            activatedBorderColor: colorScheme.primary,
            inactivatedBorderColor: colorScheme.outlineVariant,
          )
        : PlutoGridStyleConfig(
            gridBackgroundColor: colorScheme.surface,
            rowColor: colorScheme.surface,
            evenRowColor: colorScheme.surfaceContainerLowest,
            oddRowColor: colorScheme.surface,
            gridBorderColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
            borderColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
            iconColor: headerTextColor,
            columnTextStyle: TextStyle(
              color: headerTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            cellTextStyle: TextStyle(
              color: cellTextColor,
              fontSize: 14,
            ),
            menuBackgroundColor: colorScheme.surfaceContainerHigh,
            activatedColor: colorScheme.primary.withValues(alpha: 0.2),
            activatedBorderColor: colorScheme.primary,
            inactivatedBorderColor: colorScheme.outlineVariant,
          );

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: hostRecord.ports.isEmpty
            ? const Center(child: Text('No Ports Found'))
            : PlutoGrid(
                key: UniqueKey(),
                columns: columns,
                rows: _generateRows(),
                configuration: isDark
                    ? PlutoGridConfiguration.dark(style: styleConfig)
                    : PlutoGridConfiguration(style: styleConfig),
              ));
  }

  List<PlutoRow> _generateRows() {
    NLog trace = NLog('NMapPortGrid:', flag: nLogTRACE, package: kPackageName);
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
    trace.debug('_generateRows returning ${list.length} rows');
    return list;
  }
}
