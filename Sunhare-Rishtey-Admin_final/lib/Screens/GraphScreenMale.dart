import 'package:flutter/material.dart';
import 'package:sunhare_rishtey_new_admin/Screens/GraphScreenAll.dart';
import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../main.dart';

class MaleUsersScreen extends StatefulWidget {
  @override
  _MaleUsersScreenState createState() => _MaleUsersScreenState();
}

class _MaleUsersScreenState extends State<MaleUsersScreen> {
  ZoomPanBehavior? _zoomPanBehavior;
  List<UserInformation> allUsers = [];
  getMales() {
    allUsers.addAll(Provider.of<AllUser>(context, listen: false).verifiedUsers as Iterable<UserInformation>);
    allUsers.removeWhere((element) => element.gender != 'Male');
    calculateData(allUsers);
  }

  List<ChartData> data = [];

  List<UserInformation> janUsers = [];
  List<UserInformation> febUsers = [];
  List<UserInformation> marchUsers = [];
  List<UserInformation> aprilUsers = [];
  List<UserInformation> mayUsers = [];
  List<UserInformation> juneUsers = [];
  List<UserInformation> julyUsers = [];
  List<UserInformation> augUsers = [];
  List<UserInformation> septUsers = [];
  List<UserInformation> octUsers = [];
  List<UserInformation> novUsers = [];
  List<UserInformation> decUsers = [];
  List<SalesData> temp = [];

  calculateData(List<UserInformation> users) {
    Map months = {
      1: janUsers,
      2: febUsers,
      3: marchUsers,
      4: aprilUsers,
      5: mayUsers,
      6: juneUsers,
      7: julyUsers,
      8: augUsers,
      9: septUsers,
      10: octUsers,
      11: novUsers,
      12: decUsers
    };
    months.forEach((key, value) {
      value.clear();
    });
    users.forEach((element) {
      if (selectedYear == element.joinedOn!.year) {
        months[element.joinedOn!.month].add(element);
      }
    });
  }

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  changeMonthData(int month) {
    data.clear();
    Map months = {
      1: janUsers,
      2: febUsers,
      3: marchUsers,
      4: aprilUsers,
      5: mayUsers,
      6: juneUsers,
      7: julyUsers,
      8: augUsers,
      9: septUsers,
      10: octUsers,
      11: novUsers,
      12: decUsers
    };
    getMonthData(months[month], month);
  }

  var days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  int totalMale = 0;
  getMonthData(List<UserInformation> users, int month) {
    totalMale = 0;
    for (int i = 1; i <= days[month]; i++) {
      int male = 0;
      users.forEach((element) {
        if (element.joinedOn!.day == i) {
          male++;
        }
      });
      totalMale += male;
      data.add(ChartData("$i/$month", male, 0));
    }
    setState(() {});
  }

  sortUsers(List<UserInformation> users) {
    users.sort((UserInformation a, UserInformation b) =>
        a.joinedOn!.compareTo(b.joinedOn!));
  }

  sort() {
    sortUsers(janUsers);
    sortUsers(febUsers);
    sortUsers(marchUsers);
    sortUsers(aprilUsers);
    sortUsers(mayUsers);
    sortUsers(juneUsers);
    sortUsers(julyUsers);
    sortUsers(augUsers);
    sortUsers(septUsers);
    sortUsers(octUsers);
    sortUsers(novUsers);
    sortUsers(decUsers);
  }

  final List<String> months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  String month = "";

  @override
  void initState() {
    getMales();
    sort();
    changeMonthData(DateTime.now().month);
    month = months[DateTime.now().month];
    _zoomPanBehavior = ZoomPanBehavior(
        // Enables pinch zooming
        enablePinching: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
              padding: const EdgeInsets.only(top: 20, right: 10),
              child: PopupMenuButton<int>(
                  elevation: 50,
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text('Month'),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                        PopupMenuItem<int>(
                          value: 1,
                          child: Text('Jan'),
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: Text('Feb'),
                        ),
                        PopupMenuItem<int>(
                          value: 3,
                          child: Text("March"),
                        ),
                        PopupMenuItem<int>(
                          value: 4,
                          child: Text("April"),
                        ),
                        PopupMenuItem<int>(
                          value: 5,
                          child: Text("May"),
                        ),
                        PopupMenuItem<int>(
                          value: 6,
                          child: Text("June"),
                        ),
                        PopupMenuItem<int>(
                          value: 7,
                          child: Text("July"),
                        ),
                        PopupMenuItem<int>(
                          value: 8,
                          child: Text("Aug"),
                        ),
                        PopupMenuItem<int>(
                          value: 9,
                          child: Text("Sep"),
                        ),
                        PopupMenuItem<int>(
                          value: 10,
                          child: Text("Oct"),
                        ),
                        PopupMenuItem<int>(
                          value: 11,
                          child: Text("Nov"),
                        ),
                        PopupMenuItem<int>(
                          value: 12,
                          child: Text("Dec"),
                        )
                      ],
                  onSelected: (int monthIndex) {
                    setState(() {
                      selectedMonth = monthIndex;
                      changeMonthData(monthIndex);
                      month = months[monthIndex];
                    });
                  })),
          Padding(
              padding: const EdgeInsets.only(top: 20, right: 10),
              child: PopupMenuButton<int>(
                  elevation: 50,
                  padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text(' Year '),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                        PopupMenuItem<int>(
                          value: 2020,
                          child: Text('2020'),
                        ),
                        PopupMenuItem<int>(
                          value: 2021,
                          child: Text('2021'),
                        ),
                        PopupMenuItem<int>(
                          value: 2022,
                          child: Text('2022'),
                        ),
                      ],
                  onSelected: (int year) {
                    setState(() {
                      selectedYear = year;
                      calculateData(allUsers);
                      changeMonthData(selectedMonth);
                    });
                  }))
        ],
        backgroundColor: theme.colorCompanion,
        title: Text('Male Users'),
      ),
      body: Center(
          child: Container(
              child: SfCartesianChart(
        palette: <Color>[
          Colors.green,
          Colors.red,
        ],
        legend: Legend(isVisible: true),
        // enableAxisAnimation: false,
        zoomPanBehavior: _zoomPanBehavior,
        title: ChartTitle(text: "$month $selectedYear"),
        primaryXAxis: CategoryAxis(),
        // isTransposed: true,
        series: <ChartSeries>[
          StackedBarSeries<ChartData, String>(
              name: "Male [$totalMale]",
              // animationDuration: 0,
              dataLabelSettings:
                  DataLabelSettings(isVisible: true, showZeroValue: false),
              dataSource: data,
              xValueMapper: (ChartData sales, _) => sales.day,
              yValueMapper: (ChartData sales, _) => sales.males),
        ],
      ))),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final int sales;
}
