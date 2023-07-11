import 'package:flutter/material.dart';
import 'package:sunhare_rishtey_new_admin/Screens/GraphScreenAll.dart';
import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../main.dart';

class FemaleUsersScreen extends StatefulWidget {
  @override
  _FemaleUsersScreenState createState() => _FemaleUsersScreenState();
}

class _FemaleUsersScreenState extends State<FemaleUsersScreen> {
  List<UserInformation> allUsers = [];
  getFemales() {
    allUsers.addAll(Provider.of<AllUser>(context, listen: false).verifiedUsers as Iterable<UserInformation>);
    allUsers.removeWhere((element) => element.gender == 'Male');
    calculateData(allUsers);
  }

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
  ZoomPanBehavior? _zoomPanBehavior;

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

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

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
  int totalFemale = 0;
  getMonthData(List<UserInformation> users, int month) {
    totalFemale = 0;
    for (int i = 1; i <= days[month]; i++) {
      int female = 0;
      users.forEach((element) {
        if (element.joinedOn!.day == i) female++;
      });
      totalFemale += female;
      data.add(ChartData("$i/$month", 0, female));
    }
    setState(() {});
  }

  List<ChartData> data = [];
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
    getFemales();
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
        title: Text('Female Users'),
        backgroundColor: theme.colorCompanion,
      ),
      body: Center(
          child: Container(
              child: SfCartesianChart(
        palette: <Color>[
          Colors.red,
          Colors.green,
        ],
        legend: Legend(isVisible: true),
        zoomPanBehavior: _zoomPanBehavior,
        // enableAxisAnimation: false,
        title: ChartTitle(text: "$month $selectedYear"),
        primaryXAxis: CategoryAxis(),
        // isTransposed: true,
        series: <ChartSeries>[
          StackedBarSeries<ChartData, String>(
              name: "Female [$totalFemale]",
              // animationDuration: 0,
              dataLabelSettings:
                  DataLabelSettings(isVisible: true, showZeroValue: false),
              dataSource: data,
              xValueMapper: (ChartData sales, _) => sales.day,
              yValueMapper: (ChartData sales, _) => sales.females),
        ],
      ))),
    );
  }
}
