import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sunhare_rishtey_new_admin/models/memberShip.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../main.dart';

class MoneyTrend extends StatefulWidget {
  @override
  _MoneyTrendState createState() => _MoneyTrendState();
}

class _MoneyTrendState extends State<MoneyTrend> {
  ZoomPanBehavior? _zoomPanBehavior;
  var isLoading = false;

  List<MemberShip> memberShips = [];

  Future getActivePlan() async {
    final data = await FirebaseDatabase.instance
        .reference()
        .child('ActiveMembership')
        .once();
    if (data.snapshot.value != null) {
      final subs = data.snapshot.value as Map;
      subs.forEach((key, value) {
        memberShips.add(MemberShip(
            email: value['email'],
            startTime: DateTime.parse(value['DateOfPerchase']),
            nameUser: value['name'],
            id: value['packageId'],
            phone: value['phone'],
            planName: value['packageName'],
            srId: value['srId'],
            price: value['amount'] ?? 0.0,
            imageUrl: value['imageUrl'] ?? '',
            validTill: DateTime.parse(value['ValidTill'])));
      });

      // tempUsers = [...memberShips];
      // tempUsers.sort(
      //     (MemberShip a, MemberShip b) => b.startTime.compareTo(a.startTime));
      setState(() {
        memberShips.length;
        isLoading = true;
        //  memberShips.sort();
      });
    }
  }

  int selectedYear = DateTime.now().year;

  List<MemberShip> janUsers = [];
  List<MemberShip> febUsers = [];
  List<MemberShip> marchUsers = [];
  List<MemberShip> aprilUsers = [];
  List<MemberShip> mayUsers = [];
  List<MemberShip> juneUsers = [];
  List<MemberShip> julyUsers = [];
  List<MemberShip> augUsers = [];
  List<MemberShip> septUsers = [];
  List<MemberShip> octUsers = [];
  List<MemberShip> novUsers = [];
  List<MemberShip> decUsers = [];

  calculateData(List<MemberShip> users) {
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
    users.forEach((element) {
      if (selectedYear == element.startTime!.year) {
        months[element.startTime!.month].add(element);
      }
    });
  }

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
  double totalEarned = 0;
  getMonthData(List<MemberShip> users, int month) {
    totalEarned = 0;
    for (int i = 1; i <= days[month]; i++) {
      double x = 0;
      users.forEach((element) {
        if (element.startTime!.day == i) {
          x = x + element.price! / 100;
        }
      });
      totalEarned += x;
      data.add(SalesData("$i/$month", x));
    }
    setState(() {});
  }

  List<SalesData> data = [];
  sortUsers(List<MemberShip> users) {
    users.sort(
        (MemberShip a, MemberShip b) => a.startTime!.compareTo(b.startTime!));
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

  String month = '';
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

  @override
  void initState() {
    getActivePlan().then((value) {
      calculateData(memberShips);
      sort();
      changeMonthData(DateTime.now().month);
      month = months[DateTime.now().month];
    });
    _zoomPanBehavior = ZoomPanBehavior(
        // Enables pinch zooming
        enablePinching: true);
    super.initState();
    print(janUsers);
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
                  child: Text('Choose Month'),
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
                      calculateData(memberShips);
                      changeMonthData(selectedMonth);
                    });
                  }))
        ],
        title: Text('Money trend'),
        backgroundColor: theme.colorCompanion,
      ),
      body: isLoading
          ? Center(
              child: Container(
                  child: SfCartesianChart(
                      title: ChartTitle(text: "$month $selectedYear"),
                      primaryXAxis: CategoryAxis(),
                      zoomPanBehavior: _zoomPanBehavior,
                      legend: Legend(isVisible: true),
                      // Initialize category axis.
                      series: <ChartSeries>[
                  StackedBarSeries<SalesData, String>(
                      name: "Membership Trend [$totalEarned]",
                      dataLabelSettings: DataLabelSettings(
                          isVisible: true, showZeroValue: false),
                      dataSource: data,
                      xValueMapper: (SalesData sales, _) => sales.year,
                      yValueMapper: (SalesData sales, _) => sales.sales)
                ])))
          : SpinKitThreeBounce(
              color: Colors.blue,
            ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
