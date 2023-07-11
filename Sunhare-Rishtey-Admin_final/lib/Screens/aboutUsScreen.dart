import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/UserHomeScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/ShareUserScreen.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/config/theme.dart';
import 'package:sunhare_rishtey_new_admin/models/packageMadel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:sunhare_rishtey_new_admin/provider/groupProvider.dart';
import 'package:sunhare_rishtey_new_admin/provider/userActionsProvider.dart';
import 'UserProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as e;
import 'UserInformationScreen.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:open_file/open_file.dart' as open_file;

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String gender = "All";
  List<String> genderList = [
    'All',
    'Male',
    'Female',
  ];
  List<String> suspendedFilter = ['All', 'Suspended', 'Not Suspended'];

  Future getExcelData() async {
    final e.Workbook workbook = e.Workbook();
    final e.Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('Sno');
    sheet.getRangeByName('B1').setText('Name');
    sheet.getRangeByName('C1').setText('SRID');
    sheet.getRangeByName('D1').setText('Mobile No');
    sheet.getRangeByName('E1').setText('Email');
    sheet.getRangeByName('F1').setText('Religion');
    sheet.getRangeByName('G1').setText('Marital Status');
    sheet.getRangeByName('H1').setText('Mother Tongue');
    sheet.getRangeByName('I1').setText('Date of Birth');
    sheet.getRangeByName('J1').setText('Community');
    sheet.getRangeByName('K1').setText('Diet');
    sheet.getRangeByName('L1').setText('Gender');
    sheet.getRangeByName('M1').setText('Profassion');
    sheet.getRangeByName('N1').setText('Company name');
    sheet.getRangeByName('O1').setText('Annual Income');
    sheet.getRangeByName('P1').setText('Highest Qualification');
    sheet.getRangeByName('Q1').setText('College Name');
    sheet.getRangeByName('R1').setText('Father Status');
    sheet.getRangeByName('S1').setText('Born In');
    sheet.getRangeByName('T1').setText('Manglik');
    int index = 2;
    tempUsers.forEach((element) {
      sheet.getRangeByName('A$index').setText((index - 1).toString());
      sheet.getRangeByName('B$index').setText(element.name);
      sheet.getRangeByName('C$index').setText(element.srId);
      sheet.getRangeByName('D$index').setText(element.phone);
      sheet.getRangeByName('E$index').setText(element.email);
      sheet.getRangeByName('F$index').setText(element.religion);
      sheet.getRangeByName('G$index').setText(element.maritalStatus);
      sheet.getRangeByName('H$index').setText(element.motherTongue);
      sheet.getRangeByName('I$index').setText(element.dateOfBirth);
      sheet.getRangeByName('J$index').setText(element.community);
      sheet.getRangeByName('K$index').setText(element.diet);
      sheet.getRangeByName('L$index').setText(element.gender);
      sheet.getRangeByName('M$index').setText(element.workingAs);
      sheet.getRangeByName('N$index').setText(element.workingWith);
      sheet.getRangeByName('O$index').setText(element.annualIncome);
      sheet.getRangeByName('P$index').setText(element.highestQualification);
      sheet.getRangeByName('Q$index').setText(element.collegeAttended);
      sheet.getRangeByName('R$index').setText(element.fatherStatus);
      sheet.getRangeByName('S$index').setText(element.cityOfBirth);
      sheet.getRangeByName('T$index').setText(element.manglik);

      index++;
    });
    final List<int> bytes = workbook.saveAsStream();

    workbook.dispose();
    final Directory directory =
    await path_provider.getApplicationDocumentsDirectory();
    final String path = directory.path;
    final File file = File('$path/usersData.xlsx');

    await file.writeAsBytes(bytes);
    await open_file.OpenFile.open(file.path);
  }

  bool isLoading = false;
  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
    });
    Provider.of<AllUser>(context, listen: false).getAllUsers(isAbout: 1).then((value) {
      setState(() {
        isLoading = false;
        isRefreshed = true;
      });
      Provider.of<AllUser>(context, listen: false).updateList();
    });
  }

  bool isRefreshed = false;

  List<Package> packageList = [];
  getPackageData() {
    FirebaseDatabase.instance
        .reference()
        .child('PremiumPackage')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        if (data != null) {
          packageList = [];
          data.forEach((key, value) {
            packageList.add(Package(
                id: key,
                contacts: int.parse(value['contacts'].toString()),
                discount: double.tryParse(value['discount'].toString()) ?? 0,
                discountTillDateTime:
                DateTime.tryParse(value['months'].toString()) ?? null,
                price: double.parse(value['price'].toString()),
                name: value['name'],
                timeDuration: double.parse(value['timeDuration'].toString()),
                isHide: value['isHide']));
          });

          setState(() {});
        }
      }
    });
  }

  List<UserInformation> pendingReq = [];
  List<UserInformation> allUsers = [];
  List<UserInformation> tempUsers = [];
  bool run = true;
  bool isPhone = false;
  bool isName = true;
  bool isId = false;
  String suspended = "All";

  TextEditingController contact_controller = TextEditingController();
  TextEditingController validity_controller = TextEditingController();
  DateTime dateTime = DateTime.now();
  final _key = GlobalKey<FormState>();

  String timeAgoCustom(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    // if (diff.inDays > 365)
    //   return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    // if (diff.inDays > 30)
    //   return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    // if (diff.inDays > 7)
    //   return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    return "${(diff.inDays).floor()} ${(diff.inDays).floor() == 1 ? "Days" : "Days"} ago";
    if (diff.inDays > 0)
      return "${DateFormat.E().add_jm().format(d)}";
    if (diff.inHours > 0)
      return "Today ${DateFormat('jm').format(d)}";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "Never";
  }

  showDeleteConfirmation(UserInformation user) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No')),
            TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  Fluttertoast.showToast(
                      msg: 'Profile is deleting please wait');
                  final data = await FirebaseDatabase.instance
                      .reference()
                      .child("User Information")
                      .child(user.id!)
                      .once().then((value){});
                  if (data.value != null) {
                    final mapped = data.value as Map;
                    mapped['DeletedTime'] =
                        DateTime.now().toIso8601String();
                    mapped['DeletedBy'] = 'Admin';
                    await FirebaseDatabase.instance
                        .reference()
                        .child('trash')
                        .update({'${data.key}': mapped});
                    await FirebaseDatabase.instance
                        .reference()
                        .child("User Information")
                        .child(user.id!)
                        .remove();
                    setState(() async {
                      await sendPushNotificationsByID(user.id!,
                          title: "Account Deleted",
                          subject: "Your account has been deleted by Admin",
                          target: Constants.USER_ACCOUNT_DELETED);
                      Fluttertoast.showToast(
                          msg: 'Profile removed Successfully');
                      res.verifiedUsers
                          .removeWhere((element) => element.id == user.id);
                      tempUsers.remove(user);
                      allUsers.remove(user);
                    });
                  }
                },
                child: Text('Yes')),
          ],
          content: Container(
            child: Text('Do you really wants to delete user?'),
          ),
        ));
  }

  AllUser res = AllUser();
  @override
  Future<void> didChangeDependencies() async {
    res = Provider.of<AllUser>(context);
    res.verifiedUsers.sort((UserInformation a, UserInformation b) => b.joinedOn!.compareTo(a.joinedOn!));
    List<UserInformation> tempPendingReq = res.verifiedUsers;

    pendingReq = tempPendingReq.where((element) => element.introEdited == 1).toList();
    allUsers = [...pendingReq];
    if (run) {
      tempUsers = [...allUsers];
      run = false;
    }

    super.didChangeDependencies();
  }

  search(String a) {
    tempUsers = [...allUsers];
    if (isName) {
      allUsers.forEach((element) {
        if (!element.name!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    } else if (isPhone) {
      allUsers.forEach((element) {
        if (!element.phone!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    } else if (isId) {
      allUsers.forEach((element) {
        if (!element.srId!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    }
  }

  filterGender(String gender) {
    allUsers.forEach((element) {
      if (!(element.gender!.toLowerCase() == gender.toLowerCase())) {
        tempUsers.remove(element);
      }
    });
  }

  suspendeFilter(String suspended) {
    if (suspended == 'Suspended')
      allUsers.forEach((element) {
        if (!(element.suspended!)) {
          tempUsers.remove(element);
        }
      });
    else {
      allUsers.forEach((element) {
        if ((element.suspended!)) {
          tempUsers.remove(element);
        }
      });
    }
  }

  String searchVal = "";
  var groupedUsersRef;
  var allUsersref;
  Map? checkPremiumData;
  bool checkPremiumLoad = false;

  @override
  void initState() {
    checkUserPremium();
    groupedUsersRef = Provider.of<GroupdedProvider>(context, listen: false);
    allUsersref = Provider.of<AllUser>(context, listen: false);
    getPackageData();
    super.initState();
  }

  checkUserPremium() async{
    checkPremiumLoad = true;
    final data = await FirebaseDatabase.instance.reference()
        .child('ActiveMembership')
        .once();
    setState(() {
      checkPremiumData = data.snapshot.value as Map;
      checkPremiumLoad = false;
    });
    print("checkPremiumData=========>>>${checkPremiumData}");
  }

  @override
  Widget build(BuildContext context) {
    if (isRefreshed) {
      tempUsers = [...allUsers];
      isRefreshed = false;
    }
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('70c4bc'),
          title: Text(
            'About us',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: isLoading
            ? SpinKitThreeBounce(
          color: Colors.blue,
        )
            : LiquidPullToRefresh(
          color: HexColor('70c4bc'),
          onRefresh: () {
            return _handleRefresh();
          },
          child: checkPremiumLoad == true ? Center(child: CircularProgressIndicator(color: HexColor('357f78'))) : SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: width,
                  height: height,
                  child: ListView.builder(
                    itemCount: tempUsers.length,
                    padding: EdgeInsets.only(left: 10,right: 10,top: 10),
                    itemBuilder: (context, index) {
                      bool isSuspended = tempUsers[index].suspended != null ? tempUsers[index].suspended! : false;
                      print("vvvvvv==>>>${tempUsers[index].id!}");
                      String lastLogin = tempUsers[index].lastLogin! == "Never" ? "Never" : timeAgoCustom(DateTime.parse(tempUsers[index].lastLogin!));
                      print("lastLogin====>>>>$lastLogin");
                      return Card(
                        elevation: 10,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: width * .03
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    height: height * .15,
                                    width: width * .30,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                          imageUrl: tempUsers[index].imageUrl!,fit: BoxFit.fill),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * .02
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tempUsers[index].name!,
                                          maxLines: 2,
                                          style: GoogleFonts.openSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,color: checkPremiumData!.containsKey(tempUsers[index].id) ? Colors.red : black
                                          ),
                                        ),
                                       Text(
                                        "About -" + tempUsers[index].newIntro!,
                                        style: GoogleFonts.openSans(
                                          fontSize: 13,
                                        ),
                                      ),
                                        // Text(
                                        //   "ID -" + tempUsers[index].srId!,
                                        //   style: GoogleFonts.openSans(
                                        //     fontSize: 13,
                                        //   ),
                                        // ),
                                        // Text(
                                        //   'No. - ${tempUsers[index].phone}',
                                        //   style: GoogleFonts.openSans(
                                        //     fontSize: 13,
                                        //   ),
                                        // ),
                                        // Text(
                                        //   'Joined - ${tempUsers[index].joinedOn!.day}/${tempUsers[index].joinedOn!.month}/${tempUsers[index].joinedOn!.year}',
                                        //   style: GoogleFonts.openSans(
                                        //     fontSize: 13,
                                        //   ),
                                        // ),
                                        // Text(
                                        //   'User Status : ${tempUsers[index].userStatus}',
                                        //   style: GoogleFonts.openSans(
                                        //     fontSize: 13,
                                        //   ),
                                        // ),
                                        // Text(
                                        //   'Gender : ${tempUsers[index].gender}',
                                        //   style: GoogleFonts.openSans(
                                        //     fontSize: 13,
                                        //   ),
                                        // ),
                                        // Text(
                                        //   'Last login : ${lastLogin}',
                                        //   style: GoogleFonts.openSans(
                                        //     fontSize: 13,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  // Column(
                                  //   crossAxisAlignment:
                                  //   CrossAxisAlignment.center,
                                  //   children: [
                                  //     Container(
                                  //       child: Switch(
                                  //         value: tempUsers[index].iseditable ?? true,
                                  //         onChanged: (value) {
                                  //
                                  //           FirebaseDatabase.instance
                                  //               .reference()
                                  //               .child('User Information')
                                  //               .child(tempUsers[index].id!)
                                  //               .update({'isEditable': value});
                                  //
                                  //           setState(() {
                                  //             tempUsers[index].iseditable = value;
                                  //             print(tempUsers[index].iseditable);
                                  //           });
                                  //         },
                                  //         activeTrackColor: HexColor('357f78'),
                                  //         activeColor: HexColor('357f78').withOpacity(0.8),
                                  //       ),
                                  //       height: 20,width: 25,
                                  //     ),
                                  //     SizedBox(height: 10),
                                  //     InkWell(
                                  //       child: groupedUsersRef.users
                                  //           .contains(
                                  //           tempUsers[index].srId)
                                  //           ? Icon(
                                  //           MdiIcons
                                  //               .accountMultipleRemove,
                                  //           color: Colors.red)
                                  //           : Icon(
                                  //           MdiIcons
                                  //               .accountMultiplePlus,
                                  //           color:
                                  //           HexColor('357f78')),
                                  //       onTap: () {
                                  //         print("${tempUsers[index].id}");
                                  //         groupedUsersRef
                                  //             .toggle(
                                  //             tempUsers[index].srId)
                                  //             .then((isAdded) {
                                  //           setState(() {});
                                  //         });
                                  //       },
                                  //     ),
                                  //     SizedBox(height: 10),
                                  //     InkWell(
                                  //       child: Text("ID",
                                  //           style: TextStyle(
                                  //               color: tempUsers[index]
                                  //                   .isVerificationRequired!
                                  //                   ? Colors.red
                                  //                   : HexColor('357f78'),
                                  //               fontWeight:
                                  //               FontWeight.bold,
                                  //               fontSize: 16)),
                                  //       onTap: () {
                                  //         allUsersref
                                  //             .toggleIDVerification(
                                  //             tempUsers[index])
                                  //             .then((value) {
                                  //           setState(() {});
                                  //         });
                                  //       },
                                  //     ),
                                  //     SizedBox(height: 10),
                                  //     InkWell(
                                  //       child: Icon(MdiIcons.phone,
                                  //           color: tempUsers[index].hideContact!
                                  //               ? Colors.red
                                  //               : HexColor('357f78')),
                                  //       onTap: () {
                                  //         res.toggleHideContact(tempUsers[index]).then((isAdded) {
                                  //           setState(() {});
                                  //         });
                                  //       },
                                  //     ),
                                  //     SizedBox(height: 10),
                                  //     InkWell(
                                  //       child: Icon(
                                  //           MdiIcons.abacus,
                                  //           // MdiIcons.face,
                                  //           color: tempUsers[index].hideProfile!
                                  //               ? Colors.red
                                  //               : HexColor('357f78')),
                                  //       onTap: () {
                                  //         res.toggleHideProfile(
                                  //             tempUsers[index])
                                  //             .then((isAdded) {
                                  //           setState(() {});
                                  //         });
                                  //       },
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   width: 12,
                                  // ),
                                ],
                              ),
                              SizedBox(height: height * .01),
                              Row (
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell (
                                    onTap: () async {
                                      final data = await FirebaseDatabase.instance.reference()
                                          .child('User Information')
                                          .child(tempUsers[index].id!)
                                          .update({
                                        'introEdited': 0,
                                        'intro': tempUsers[index].newIntro ?? ""
                                      });

                                      Fluttertoast.showToast(msg: "User Request Approved");

                                      // Map fdata = data.snapshot.value as Map;
                                      // print("contain data is===>>${fdata.containsKey(tempUsers[index].id)}");
                                      // print("data is===>>${fdata['contacts']}");
                                      // print("data is===>>${fdata['ValidTill']}");
                                      // print("data is===>>${tempUsers[index].id}");
                                      // editAlert(validity: fdata['ValidTill'],contacts: fdata['contacts'].toString(),id: tempUsers[index].id);
                                    },
                                    child: Container(
                                      child: Text(
                                        'Approved',style: TextStyle(color: white),
                                      ),
                                      decoration: BoxDecoration(
                                          color: HexColor('357f78'),
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      alignment: Alignment.center,
                                      height: 35,width: 90,
                                      margin: EdgeInsets.only(left: 8),
                                    ),
                                  ),
                                  InkWell (
                                    onTap: () {
                                      FirebaseDatabase.instance
                                          .reference()
                                          .child('User Information')
                                          .child(tempUsers[index].id!)
                                          .update({'introEdited': 2});
                                      Fluttertoast.showToast(msg: "User Request Rejected");
                                    // cancelAlert(id: tempUsers[index].id);
                                  },
                                    child: Container (
                                                        child: Text(
                                                          'Reject',
                                                          style: TextStyle(
                                                              color: white),
                                                        ),
                                                        decoration: BoxDecoration(
                                                            color: HexColor(
                                                                '357f78'),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        alignment:
                                                            Alignment.center,
                                                        height: 35,
                                                        width: 90,
                                                        margin: EdgeInsets.only(
                                                            left: 8),
                                                      ),

                                  ),
                                ],
                              )

                              // checkPremiumData!.containsKey(tempUsers[index].id) ?
                              //     : SizedBox(),
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
      ),
    );
  }

  editAlert({String? validity,String? contacts,String? id}){
    contact_controller.text = contacts!;
    print("contacts=========>>>>$contacts");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit membership validity"),
          content: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Contacts",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextFormField(
                  controller: contact_controller,
                  cursorColor: HexColor('357f78'),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 5),
                    hintText: "Enter contacts",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor('357f78')),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor('357f78')),
                        borderRadius: BorderRadius.circular(5)
                    ),
                  ),
                  validator: (val){
                    if(val!.isEmpty){
                      return 'Enter contacts';
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                Text("Validity",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                DateTimePicker(
                  type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'd MMM, yyyy',
                  initialValue: validity,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialTime: TimeOfDay(hour: 23, minute: 59),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Date',
                  timeLabelText: "Hour",
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'req';
                    } else {
                      dateTime = DateTime.parse(val);
                      return null;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            MaterialButton(
              child: Text("Update",style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                if(_key.currentState!.validate()){
                  print("dateTime selected is===>>>$dateTime");
                  print("dateTime selected is===>>>${contact_controller.text}");
                  FirebaseDatabase.instance
                      .reference()
                      .child('ActiveMembership')
                      .child(id!)
                      .update({
                    "ValidTill": dateTime.toString(),
                    "contacts": int.parse(contact_controller.text),
                  }).then((value) {
                    // getActivePlan();
                    Navigator.of(context).pop(true);
                    setState(() {});
                  });
                }
              },
            ),
            MaterialButton(
              child: Text("Cancel",style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  cancelAlert({String? id}){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure to cancel this user membership?"),
          actions: [
            MaterialButton(
              child: Text("OK",style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                FirebaseDatabase.instance
                    .reference()
                    .child('ActiveMembership')
                    .child(id!)
                    .remove().then((value){
                  // getActivePlan();
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: 'Membership cancel Successfully');
                  setState(() {});
                });
              },
            ),
            MaterialButton(
              child: Text("Cancel",style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
