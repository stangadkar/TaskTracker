/*
 * Copyright (c) 2020 by Botorabi. All rights reserved.
 * https://github.com/botorabi/TaskTracker
 *
 * License: MIT License (MIT), read the LICENSE text in
 *          main directory for more details.
 */

import 'package:TaskTracker/common/button.circle.dart';
import 'package:TaskTracker/common/button.id.dart';
import 'package:TaskTracker/config.dart';
import 'package:TaskTracker/dialog/dialog.modal.dart';
import 'package:TaskTracker/dialog/dialogtwobuttons.modal.dart';
import 'package:TaskTracker/navigation.links.dart';
import 'package:TaskTracker/service/report.configuration.dart';
import 'package:TaskTracker/service/service.report.configuration.dart';
import 'package:TaskTracker/service/service.team.dart';
import 'package:TaskTracker/service/team.dart';
import 'package:flutter/material.dart';


class WidgetReportMailConfigurationList extends StatefulWidget {
  WidgetReportMailConfigurationList({Key key, this.title = 'Report Mail Configuration'}) : super(key: key);

  final String title;
  final _WidgetReportMailConfigurationListState _widgetReportConfigurationListState = _WidgetReportMailConfigurationListState();

  @override
  _WidgetReportMailConfigurationListState createState() => _widgetReportConfigurationListState;

  WidgetReportMailConfigurationList setExpanded(bool expanded) {
    _widgetReportConfigurationListState.setExpanded(expanded);
    return this;
  }
}

class _WidgetReportMailConfigurationListState extends State<WidgetReportMailConfigurationList> {

  final _serviceReportConfiguration = ServiceReportConfiguration();
  PaginatedDataTable _dataTable;
  List<ReportMailConfiguration> _reportConfigurations = [];
  bool _expanded = false;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _retrieveConfigurations();
  }

  void setExpanded(bool expanded) {
    _expanded = expanded;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Config.authStatus.isAdmin() && !Config.authStatus.isTeamLead()) {
      print("ERROR: admin/team lead corner!");
      return Column();
    }
    else {
      _dataTable = _createDataTable();
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Card(
            elevation: 5,
            margin: EdgeInsets.all(10.0),
            child:
            ExpansionTile(
                title: Text(widget.title),
                initiallyExpanded: _expanded,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: _dataTable,
                    ),
                  )
                ]
            ),
          ),
        ),
      );
    }
  }

  void _addConfiguration() async {
    await Navigator.pushNamed(context, NavigationLinks.NAV_NEW_REPORT_CFG);
    _retrieveConfigurations();
  }

  void _deleteConfiguration(int id, String name) async {
    var button = await DialogTwoButtonsModal(context)
        .show('Attention', "You really want to delete configuration '$name'?", ButtonID.YES, ButtonID.NO);

    if (button != ButtonID.YES) {
      return;
    }

    _serviceReportConfiguration
      .deleteConfiguration(id)
      .then((status) {
          DialogModal(context).show('Configuration Deletion', 'Report configuration was successfully deleted.', false);
          _retrieveConfigurations();
        },
        onError: (err) {
          print('Failed to delete report configuration, reason: ' + err.toString());
      });
  }

  void _sortConfigurations(bool ascending) {
    _reportConfigurations.sort((configA, configB) => configA.name?.compareTo(configB?.name));
    if (!ascending) {
      _reportConfigurations = _reportConfigurations.reversed.toList();
    }
  }

  void _retrieveConfigurations() {
    _serviceReportConfiguration
        .getConfigurations()
        .then((listConfiguration) {
            _reportConfigurations = listConfiguration;
            _sortConfigurations(_sortAscending);
            setState(() {});
          },
          onError: (err) {
            print("Failed to retrieve report configuration, reason: " + err.toString());
          });
  }

  PaginatedDataTable _createDataTable() {
    PaginatedDataTable dataTable = PaginatedDataTable(
      header: Text(''),
      columns: <DataColumn>[
        DataColumn(
          label: Text(
            'Name',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          onSort:(columnIndex, ascending) {
            setState(() {
              _sortAscending = !_sortAscending;
              _sortConfigurations(_sortAscending);
              _dataTable = _createDataTable();
            });
          },
        ),
        DataColumn(
          label: Text(
            'Subject',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        DataColumn(
          label: Text(''),
        ),
      ],
      rowsPerPage: 5,
      onRowsPerPageChanged: null,
      source: _DataProvider(this),
      sortColumnIndex: 0,
      sortAscending: _sortAscending,
      actions: [
        CircleButton.create(24, Icons.add, () => _addConfiguration(), 'Add New Report Mail Configuration'),
      ],
    );

    return dataTable;
  }
}

class _DataProvider extends DataTableSource {

  _WidgetReportMailConfigurationListState parent;

  _DataProvider(this.parent);

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(parent._reportConfigurations[index].name)),
        DataCell(Text(parent._reportConfigurations[index].mailSubject)),
        DataCell(
          Row(
            children: [
              Spacer(),
              Padding(
                padding: EdgeInsets.all(4.0),
                child:
                  CircleButton.create(20, Icons.edit, () {
                    Navigator.pushNamed(parent.context, NavigationLinks.NAV_EDIT_REPORT_CFG, arguments: parent._reportConfigurations[index].id)
                        .then((value) {
                            if (value != ButtonID.CANCEL) {
                              parent._retrieveConfigurations();
                            }
                          }
                        );
                  }, "Edit Report Configuration"
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
                child:
                  CircleButton.create(20, Icons.delete,
                          () => parent._deleteConfiguration(parent._reportConfigurations[index].id, parent._reportConfigurations[index].name),
                          "Delete Report Mail Configuration"
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => parent._reportConfigurations.length;

  @override
  int get selectedRowCount => 0;
}
