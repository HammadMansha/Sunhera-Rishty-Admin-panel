import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/models/reprortModel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:provider/provider.dart';

import 'UserInformationScreen.dart';

class ReportedAccountScreen extends StatefulWidget {
  @override
  _ReportedAccountScreenState createState() => _ReportedAccountScreenState();
}

class _ReportedAccountScreenState extends State<ReportedAccountScreen> {
  bool isLoading = true;
  List<ReportModel> reportedUsers = [];
  getData() async {
    FirebaseDatabase.instance
        .reference()
        .child('Reported Id')
        .onValue
        .listen((event) {
      final snapShot = event.snapshot.value as Map;
      if (snapShot.isNotEmpty) {
        reportedUsers = [];
        snapShot.forEach((key, value) {
          if(key == "ssYXB8erJ3UnWmwG8r5RJZOaBRO2"){
            print("val--->>>${value}");
          }
          reportedUsers.add(ReportModel(
              imageUrl: value['imageUrl'],
              name: value['name'],
              reportedGender: value['gender'],
              reportedMobileNo: value['reportedMobile'],
              reportedName: value['nameOfReporter'] ?? "",
              reportedOn: DateTime.parse(value['reportedOn']),
              reportedSrId: value['srId'],
              srId: value['srIdOfReporter'],
              reason: value['reason'],
              uid: key));
        });
        setState(() {
          trashUsers = reportedUsers;
          tempUsers = [...trashUsers];
          tempUsers.sort((ReportModel a, ReportModel b) =>
              b.reportedOn!.compareTo(a.reportedOn!));
          isLoading = false;
        });
      }
    });
  }

  // List<UserInformation> memberShips = [];
  List<ReportModel> tempUsers = [];
  bool isPhone = false;
  bool isId = false;
  bool isName = true;

  List<ReportModel> trashUsers = [];
  search(String a) {
    tempUsers = [...trashUsers];
    if (isName) {
      trashUsers.forEach((element) {
        if (!element.name!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    } else if (isPhone) {
      trashUsers.forEach((element) {
        if (!element.reportedMobileNo!
            .toLowerCase()
            .contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    } else if (isId) {
      trashUsers.forEach((element) {
        if (!element.srId!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('70c4bc'),
          title: Text(
            'Reported Account',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            // Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: FloatingActionButton(
            //     elevation: 5,
            //     isExtended: true,
            //     onPressed: () {},
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(2),
            //     ),
            //     backgroundColor: HexColor('357f78'),
            //     child: Text(
            //       'Export',
            //       style: GoogleFonts.lato(
            //         fontSize: 13,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
        body: isLoading
            ? SpinKitThreeBounce(
                color: Colors.blue,
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                if (value.isEmpty) {
                                  tempUsers.clear();
                                  getData();
                                }
                                search(value.trim());
                              });
                            },
                            cursorColor: HexColor('357f78'),
                            decoration: InputDecoration(
                              hintText: "Search User",
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {});
                            isPhone = false;
                            isName = true;
                            isId = false;
                            tempUsers = [...trashUsers];
                            tempUsers.sort((ReportModel a, ReportModel b) =>
                                b.reportedOn!.compareTo(a.reportedOn!));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: isName ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            width: MediaQuery.of(context).size.width * .15,
                            height: MediaQuery.of(context).size.height * .05,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(child: Text('Name')),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {});
                            isPhone = true;
                            isName = false;
                            isId = false;
                            tempUsers = [...trashUsers];
                            tempUsers.sort((ReportModel a, ReportModel b) =>
                                b.reportedOn!.compareTo(a.reportedOn!));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .15,
                            height: MediaQuery.of(context).size.height * .05,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: isPhone ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(child: Text('Phone')),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {});
                            isPhone = false;
                            isName = false;
                            isId = true;
                            tempUsers = [...trashUsers];
                            tempUsers.sort((ReportModel a, ReportModel b) =>
                                b.reportedOn!.compareTo(a.reportedOn!));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .15,
                            height: MediaQuery.of(context).size.height * .05,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: isId ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(child: Text('Id')),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 5.0,
                    ),
                    // Card(
                    //   margin: EdgeInsets.symmetric(
                    //     horizontal: 20,
                    //     vertical: 15,
                    //   ),
                    //   elevation: 10,
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(35),
                    //   ),
                    //   child: Container(
                    //     height: 55,
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: 20,
                    //       vertical: 8,
                    //     ),
                    //     alignment: Alignment.centerLeft,
                    //     child: TextFormField(
                    //       cursorColor: HexColor('357f78'),
                    //       decoration: InputDecoration(
                    //         hintText: "Search User",
                    //         border: InputBorder.none,
                    //         suffixIcon: IconButton(
                    //           onPressed: () {},
                    //           icon: Icon(
                    //             Icons.search,
                    //             color: Colors.black,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Container(
                      width: width,
                      height: height * .7,
                      child: ListView.builder(
                        itemCount: tempUsers.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 10,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        height: height * .15,
                                        width: width * .23,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: tempUsers[index].imageUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .03,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tempUsers[index].name!,
                                            overflow: TextOverflow.clip,
                                            style: GoogleFonts.openSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'ID - ${tempUsers[index].reportedSrId}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Reason - ${tempUsers[index].reason}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'No. - ${tempUsers[index].reportedMobileNo}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Reporter Name - ${tempUsers[index].reportedName}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Reported SrId - ${tempUsers[index].srId}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Gender - ${tempUsers[index].reportedGender}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Reported on - ${tempUsers[index].reportedOn!.day}/${tempUsers[index].reportedOn!.month}/${tempUsers[index].reportedOn!.year}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .001,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          print("user is===>>>${tempUsers[index].uid}");
                                          List<UserInformation> allUsers =
                                              Provider.of<AllUser>(context,
                                                      listen: false)
                                                  .verifiedUsers;

                                          print("user is===>>>${allUsers}");
                                          UserInformation user =
                                              allUsers.firstWhere((element) => element.id == tempUsers[index].uid);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (contecct) =>
                                                  HomeScreen(user, true, packageList: []),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: width * .13,
                                          height: height * .05,
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: HexColor('357f78'),
                                          ),
                                          child: Icon(
                                            MdiIcons.eye,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: width * .1,
                                      // ),
                                      // Container(
                                      //   width: width * .17,
                                      //   height: height * .05,
                                      //   decoration: BoxDecoration(
                                      //     border: Border.all(),
                                      //     borderRadius:
                                      //         BorderRadius.circular(6),
                                      //     color: HexColor('357f78'),
                                      //   ),
                                      //   alignment: Alignment.center,
                                      //   child: Text(
                                      //     'Restore',
                                      //     style: GoogleFonts.lato(
                                      //       color: Colors.white,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
