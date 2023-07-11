import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../main.dart';

class UserGrowthGraphScreen extends StatefulWidget {
  @override
  _UserGrowthGraphScreenState createState() => _UserGrowthGraphScreenState();
}

class _UserGrowthGraphScreenState extends State<UserGrowthGraphScreen> {
  List<UserInformation> allUsers = [];
  getData() {
    allUsers = Provider.of<AllUser>(context, listen: false).verifiedUsers.cast<UserInformation>();
    calculateData(allUsers);
  }

  ZoomPanBehavior? _zoomPanBehavior;

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
  List<ChartData> temp = [];

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
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  var days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  int totalMale = 0, totalFemale = 0;
  getMonthData(List<UserInformation> users, int month) {
    totalMale = 0;
    totalFemale = 0;
    for (int i = 1; i <= days[month]; i++) {
      int male = 0;
      int female = 0;
      users.forEach((element) {
        if (element.joinedOn!.day == i) {
          if (element.gender == "Male") {
            male++;
          } else {
            female++;
          }
        }
      });
      totalMale += male;
      totalFemale += female;
      data.add(ChartData("$i/$month", male, female));
    }
    setState(() {});
  }

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
    // temp = [...data];
    // removeZeroData(temp);
  }

  // removeZeroData(List<ChartData> list) {
  //   list.forEach((element) {
  //     if (element.sales == 0) {
  //       data.remove(element);
  //     }
  //   });
  // }

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

  @override
  void initState() {
    getData();
    sort();
    changeMonthData(selectedMonth);
    month = months[DateTime.now().month];
    _zoomPanBehavior = ZoomPanBehavior(enablePinching: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Users'),
        backgroundColor: theme.colorCompanion,
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
                      month = months[monthIndex];
                      changeMonthData(selectedMonth);
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
      ),
      body: Center(
        child: Container(
          child: SfCartesianChart(
            palette: <Color>[
              Colors.green,
              Colors.red,
            ],
            zoomPanBehavior: _zoomPanBehavior,
            legend: Legend(isVisible: true),
            title: ChartTitle(text: "$month $selectedYear"),
            primaryXAxis: CategoryAxis(),
            series: <ChartSeries>[
              StackedBarSeries<ChartData, String>(
                  name: "Male [$totalMale]",
                  dataLabelSettings:
                      DataLabelSettings(isVisible: true, showZeroValue: false),
                  dataSource: data,
                  xValueMapper: (ChartData sales, _) => sales.day,
                  yValueMapper: (ChartData sales, _) => sales.males),
              StackedBarSeries<ChartData, String>(
                  name: "Female [$totalFemale]",
                  dataLabelSettings:
                      DataLabelSettings(isVisible: true, showZeroValue: false),
                  dataSource: data,
                  xValueMapper: (ChartData sales, _) => sales.day,
                  yValueMapper: (ChartData sales, _) => sales.females),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.day, this.males, this.females);
  final String day;
  final int males;
  final int females;
}
