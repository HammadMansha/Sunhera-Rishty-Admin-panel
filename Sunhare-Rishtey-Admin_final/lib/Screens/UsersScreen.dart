import 'dart:convert';
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
import 'package:sunhare_rishtey_new_admin/main.dart';
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

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
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
    Provider.of<AllUser>(context, listen: false).getAllUsers().then((value) {
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

                      Fluttertoast.showToast(msg: 'Profile is deleting please wait');
                      final data = await FirebaseDatabase.instance
                          .reference()
                          .child("User Information")
                          .child(user.id!)
                          .once();
                      Map fdata = data.snapshot.value as Map;
                      if (fdata.isNotEmpty) {
                        // final mapped = data.value as Map;
                        fdata['DeletedTime'] = DateTime.now().toIso8601String();
                        fdata['DeletedBy'] = 'Admin';
                        fdata['Reason'] = 'Deleted By Admin';
                        fdata['AccountDeleteDate'] = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
                        ///AccountDeleteDate not uses of this key
                        await FirebaseDatabase.instance
                            .reference()
                            .child('trash')
                            .update({'${data.snapshot.key}': fdata});

                        FirebaseDatabase.instance.reference().child("User Information").
                        child(data.snapshot.key!).update({"inTrash": true, "isDeleteByAdmin":true});

                        DateTime endDate = DateTime.now().subtract(const Duration(days: 1));
                        String finalEndDate = DateFormat('yyyy-MM-dd').format(endDate);
                        FirebaseDatabase.instance
                            .reference()
                            .child('User Information')
                            .child(user.id ?? "")
                            .child('hideProfile')
                            .update({
                          '1week': false,
                          '2week': true,
                          'month': false,
                          'unHideDate': finalEndDate,
                        });

                        // await FirebaseDatabase.instance
                        //     .reference()
                        //     .child("User Information")
                        //     .child(user.id!)
                        //     .remove();
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
    pendingReq = res.verifiedUsers;
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
  Map checkPremiumData = {};
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
        .child('ActiveMembership').once();

    setState(() {
      final tempCheckPremiumData = data.snapshot.value as Map;
      tempCheckPremiumData?.forEach((key, value) {
        DateTime now = DateTime.now().subtract(const Duration(days: 0));
        DateTime validTill = value['ValidTill'] == null ? now : DateTime.parse(value['ValidTill']);
        bool valDate = now.isBefore(validTill);
        // debugPrint("User name ==> ${value['name']}");
        // debugPrint("valDate ==> ${valDate}");
        if(valDate) {
          Map tempData = {key:value};
          checkPremiumData.addAll(tempData);
        }
      });
      checkPremiumLoad = false;
    });
    print("checkPremiumData=========>>>${checkPremiumData}");
  }

  bool isLoaderShow = false;

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
            'Users',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [

            /* Padding (
              padding: const EdgeInsets.all(10.0),
              child: FloatingActionButton(
                elevation: 5,
                isExtended: true,
                onPressed: () async {
                  isLoaderShow = true;
                  setState(() {

                  });
                  final govIdData = await FirebaseDatabase.instance
                      .reference()
                      .child('Gov Id')
                      .once();
                  Map mappedDataGovData = govIdData.snapshot.value as Map;
                  debugPrint("Gove id data ==> ${mappedDataGovData.length}");
                  final userTableData = Provider.of<AllUser>(context, listen: false);
                  debugPrint("Gove id data ==> ${userTableData.allUserData.length}");

                  // "isVerificationRequiredGovId"

                  int i = 0;

                  userTableData.allUserData.forEach((key, value) {
                    if(mappedDataGovData.containsKey(key)) {
                      i = i+1;
                      FirebaseDatabase.instance
                          .reference()
                          .child('User Information')
                          .child(key)
                          .update({'isVerificationGovId': true});
                      print("Id Show : $key");
                      print("Add $i");
                    }
                  });


                  isLoaderShow = false;
                  setState(() {

                  });


                  // FirebaseDatabase.instance
                  //     .reference()
                  //     .child('User Information')
                  //     .child(widget.userInfo.id!)
                  //     .update({'isOnline': false});

                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                backgroundColor: HexColor('357f78'),
                child: isLoaderShow ? CircularProgressIndicator() : Text(
                  'Add',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                  ),
                ),
              ),
            ),*/

            Padding (
              padding: const EdgeInsets.all(10.0),
              child: FloatingActionButton(
                elevation: 5,
                isExtended: true,
                onPressed: () {
                  getExcelData();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                backgroundColor: HexColor('357f78'),
                child: Text(
                  'Export',
                  style: GoogleFonts.lato (fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? SpinKitThreeBounce (
                color: Colors.blue,
              )
            : LiquidPullToRefresh(
                color: HexColor('70c4bc'),
                onRefresh: () {
                  return _handleRefresh();
                },
                child: checkPremiumLoad == true ?
                Center(child: CircularProgressIndicator(color: HexColor('357f78'))) :
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  searchVal = value;
                                  if (value.isEmpty) {
                                    tempUsers = allUsers;
                                  }
                                  search(value.trim());
                                });
                              },
                              cursorColor: HexColor('357f78'),
                              decoration: InputDecoration(
                                hintText: "Search User",
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    search(searchVal.trim());
                                  },
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {});
                              isPhone = false;
                              isName = true;
                              isId = false;
                              tempUsers = [...allUsers];
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
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
                              tempUsers = [...allUsers];
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .15,
                              height: MediaQuery.of(context).size.height * .05,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
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
                              tempUsers = [...allUsers];
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .15,
                              height: MediaQuery.of(context).size.height * .05,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
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
                      SizedBox(
                        height: height * .001,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.only(left: 10,right: 5,top: 10,bottom: 10),
                              // width: width * .38,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  5,
                                ),
                              ),
                              child: DropdownButtonFormField(
                                value: gender,
                                validator: (val) {
                                  if (val == null) {
                                    return 'Required';
                                  } else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                hint: Text('Gender'),
                                items: genderList.map((e) {
                                  return DropdownMenuItem(
                                      value: e, child: Text(e));
                                }).toList(),
                                onChanged: (value) {
                                  gender = value!;
                                  tempUsers = [...allUsers];
                                  setState(() {
                                    if (value == 'All')
                                      tempUsers = [...allUsers];
                                    else {
                                      filterGender(gender);
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.only(left: 5,right: 10,top: 10,bottom: 10),
                              // width: width / 2,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  5,
                                ),
                              ),
                              child: DropdownButtonFormField(
                                value: suspended,
                                validator: (val) {
                                  if (val == null) {
                                    return 'Required';
                                  } else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                hint: Text('Account Type'),
                                items: suspendedFilter.map((e) {
                                  return DropdownMenuItem(
                                      value: e, child: Text(e));
                                }).toList(),
                                onChanged: (value) {
                                  suspended = value!;
                                  tempUsers = [...allUsers];
                                  setState(() {
                                    if (value == 'All')
                                      tempUsers = [...allUsers];
                                    else {
                                      suspendeFilter(value);
                                      //  filterGender(gender);
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: width * .1,
                      ),
                      Container(
                        width: width,
                        height: height * .7,
                        child: ListView.builder(
                          itemCount: tempUsers.length,
                          itemBuilder: (context, index) {
                            bool isSuspended =
                                tempUsers[index].suspended != null
                                    ? tempUsers[index].suspended!
                                    : false;
                            print("vvvvvv==>>>${tempUsers[index].id!}");
                            String lastLogin = (tempUsers[index].lastLogin ?? "Never") == "Never" ? "Never" : timeAgoCustom(DateTime.parse(tempUsers[index].lastLogin!));
                            print("lastLogin====>>>>$lastLogin");
                            print("img url===>>${tempUsers[index].imageUrl!}");
                            // DateTime now = DateTime.now();
                            // DateTime validTill = checkPremiumData?['ValidTill'] == null ? now : DateTime.parse(checkPremiumData?['ValidTill']);
                            // print("validTill====>>>>$validTill");
                            return Card (
                              elevation: 10,
                              color: Colors.white,
                              child: Padding (
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column (
                                  children: [
                                    Row (
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(width: width * .03),
                                        Container (
                                          padding: EdgeInsets.symmetric (horizontal: 8, vertical: 8),
                                          height: height * .15,
                                          width: width * .23,
                                          child: ClipRRect (
                                            borderRadius: BorderRadius.circular(8),
                                            child: Stack (
                                              children: [

                                                CachedNetworkImage(imageUrl: tempUsers[index].imageUrl!, fit: BoxFit.fitWidth, width: 100),

                                                Align (
                                                  alignment: Alignment.bottomCenter,
                                                  child: tempUsers[index].isVerificationRequiredGovId != null &&
                                                      tempUsers[index].isVerificationRequiredGovId! == true ? Container (
                                                    color: theme.colorPrimary.withOpacity(0.8),
                                                    width: 100,
                                                    height: 25,
                                                    alignment: Alignment.center,
                                                    child: const Text("Verified", style: TextStyle(color: Colors.white, fontSize: 12)),
                                                  ) : Container (
                                                    color: theme.green.withOpacity(0.9),
                                                    width: 100,
                                                    height: 25,
                                                    alignment: Alignment.center,
                                                    child: Text("Unverified", style: TextStyle(color: Colors.white, fontSize: 12)),
                                                  ),
                                                )

                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * .05,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text (
                                                tempUsers[index].name!,
                                                maxLines: 2,
                                                style: GoogleFonts.openSans (
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: (checkPremiumData?.containsKey(tempUsers[index].id) ?? false)
                                                      && (tempUsers[index].isPremium ?? false) ?
                                                    Colors.red : black
                                                ),
                                              ),
                                              Text(
                                                "ID -" + tempUsers[index].srId!,
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'No. - ${tempUsers[index].phone}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'Joined - ${tempUsers[index].joinedOn!.day}/${tempUsers[index].joinedOn!.month}/${tempUsers[index].joinedOn!.year}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'User Status : ${tempUsers[index].userStatus}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'Gender : ${tempUsers[index].gender}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'Last login : ${lastLogin}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                        Container(
                                          child: Switch(
                                          value: tempUsers[index].iseditable ?? true,
                                              onChanged: (value) {

                                                FirebaseDatabase.instance
                                                    .reference()
                                                    .child('User Information')
                                                    .child(tempUsers[index].id!)
                                                    .update({'isEditable': value});

                                                setState(() {
                                                  tempUsers[index].iseditable = value;
                                                  print(tempUsers[index].iseditable);
                                                });
                                              },
                                                activeTrackColor: HexColor('357f78'),
                                                activeColor: HexColor('357f78').withOpacity(0.8),
                                              ),
                                          height: 20,width: 25,
                                        ),
                                            SizedBox(height: 10),
                                            InkWell(
                                              child: groupedUsersRef.users
                                                      .contains(tempUsers[index].srId)
                                                  ? Icon(MdiIcons.accountMultipleRemove,
                                                      color: Colors.red)
                                                  : Icon (
                                                      MdiIcons.accountMultiplePlus,
                                                      color: HexColor('357f78')
                                              ),
                                              onTap: () {
                                                print("${tempUsers[index].id}");
                                                groupedUsersRef
                                                    .toggle(
                                                        tempUsers[index].srId)
                                                    .then((isAdded) {
                                                  setState(() {});
                                                });
                                              },
                                            ),
                                            SizedBox(height: 10),
                                            InkWell(
                                              child: Text("ID",
                                                  style: TextStyle(
                                                      color: tempUsers[index].isVerificationRequired ?? false
                                                          ? Colors.red
                                                          : HexColor('357f78'),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16)),
                                              onTap: () {
                                                allUsersref.toggleIDVerification(tempUsers[index])
                                                    .then((value) {
                                                  setState(() {});
                                                });
                                              },
                                            ),
                                            SizedBox(height: 10),
                                            InkWell(
                                              child: Icon(MdiIcons.phone,
                                                  color: tempUsers[index].hideContact  ?? false
                                                      ? Colors.red
                                                      : HexColor('357f78')),
                                              onTap: () {
                                                res.toggleHideContact(tempUsers[index]).then((isAdded) {
                                                  setState(() {});
                                                });
                                              },
                                            ),
                                            SizedBox(height: 10),
                                            InkWell(
                                              child: Icon(
                                                  MdiIcons.abacus,
                                                  // MdiIcons.face,
                                                  color: tempUsers[index].hideProfile ?? false
                                                      ? Colors.red
                                                      : HexColor('357f78')),
                                              onTap: () {
                                                res.toggleHideProfile(tempUsers[index])
                                                    .then((isAdded) {
                                                        setState(() {});
                                                    });
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                    ),
                                    SizedBox(height: height * .01),
                                    Row (
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell (
                                          onTap: () async {
                                            // final mapData = {
                                            // "name" : "Testing Account ",
                                            // "lastLogin" : "2023-05-27T12:17:45.593126",
                                            // "noOfChildren" : "1",
                                            // "newIntro" : "",
                                            // "introEdited" : 0,
                                            // "childrenLivingTogether" : "No",
                                            // "email" : "testing1346667@gmail.com",
                                            // "phone" : "+919897139499",
                                            // "imageUrl" : "https://sunharerishtey.in/image-upload/public/images/profile/1685169694_3516017.jpg",
                                            // "id" : "Tq39R5x3zrRRdjMD55FTWuKm5qn2",
                                            // "isPhone" : null,
                                            // "postedBy" : "Self",
                                            // "age" : null,
                                            // "anyDisAbility" : "",
                                            // "healthInfo" : null,
                                            // "showHoroscope" : true,
                                            // "intro" : "Glad you choose my profile and here's a quick introduction. Regarding my education, I have pursued Others. Clarity, simplicity a",
                                            // "religion" : "Mahor",
                                            // "visibility" : "Connected Members",
                                            // "motherTongue" : "Hindi",
                                            // "community" : "",
                                            // "casteNoBar" : null,
                                            // "birthTime" : null,
                                            // "gotra" : null,
                                            // "fatherStatus" : "Employed",
                                            // "motherStatus" : "Home Queen",
                                            // "nativePlace" : "Faghuy",
                                            // "brothers" : "0",
                                            // "sisters" : "0",
                                            // "familyType" : "Joint",
                                            // "manglik" : "Don't know",
                                            // "dateOfBirth" : "09/Jul/1993",
                                            // "employedIn" : "Not Working",
                                            // "suspended" : false,
                                            // "isVerificationRequired" : false,
                                            // "isVerificationRequiredGovId" : true,
                                            // "cityOfBirth" : "Chjvc",
                                            // "country" : "🇮🇳    India",
                                            // "state" : "Uttar Pradesh",
                                            // "city" : "Agra",
                                            // "residencyStatus" : "",
                                            // "zipCode" : null,
                                            // "grewUpIn" : "",
                                            // "highestQualification" : "Others",
                                            // "collegeAttended" : "Xggvx",
                                            // "workingWith" : "",
                                            // "workingAs" : "Accounts / Finance Professional",
                                            // "annualIncome" : "Not Working",
                                            // "employerName" : "",
                                            // "diet" : "Veg",
                                            // "height" : "5' 6\" - 167 cm",
                                            // "maritalStatus" : "Divorced",
                                            // "fatherGautra" : "Xjjcxfg7",
                                            // "motherGautra" : "Dyugxff",
                                            // "gender" : "Male",
                                            // "isVerified" : true,
                                            // "srId" : "SR003525",
                                            // "isOnline" : false,
                                            // // "joinedOn" : {DateTime} 2023-05-27 12:12:09.788586
                                            // "userStatus" : "Inactive",
                                            // "deletedOn" : null,
                                            // "deletedBy" : "Admin",
                                            // "reportedOn" : null,
                                            // "deletedReason" : "Deleted By Admin",
                                            // "referCode" : "",
                                            // "allowMarketing" : true,
                                            // "isPremium" : false,
                                            // "iseditable" : null,
                                            // // "blockedByList" : {_GrowableList} size = 0,
                                            // "isSuspended" : false,
                                            // "hideContact" : false,
                                            // "hideProfile" : false,
                                            // "premiumModel" : null,
                                            // "marriedBrothers" : null,
                                            // "bloodGroup" : null,
                                            // "affluenceLevel" : null,
                                            // "familyValues" : null,
                                            // "marriedSisters" : null,
                                            // "motherName" : null,
                                            // "fatherName" : null,
                                            // "partnerInfo" : null,
                                            // "verifiedBy" : null,
                                            // "isGovIdVerified" : null,
                                            // "isDeleteByAdmin" : false
                                            // };

                                            print("aaa user id ===>>>${tempUsers[index].id}");
                                            print("aaa user id ===>>>${jsonEncode(tempUsers[index].id)}");

                                            // FirebaseDatabase.instance
                                            //     .reference()
                                            //     .child('User Information')
                                            //     .child("Tq39R5x3zrRRdjMD55FTWuKm5qn2")
                                            //     .update(mapData);

                                            var isUpdated = await Navigator.of(context).push(MaterialPageRoute (
                                                      builder: (context) => HomeScreen(tempUsers[index], true,
                                                          packageList: packageList)));
                                            if (isUpdated != null && isUpdated) {
                                              tempUsers[index].isPremium = true;
                                                    checkUserPremium();
                                                  }
                                                },
                                          child: Container(
                                            width: width * .13,
                                            height: height * .05,
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius: BorderRadius.circular(6),
                                              color: HexColor('357f78'),
                                            ),
                                            child: Icon (
                                              MdiIcons.eye,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        InkWell (
                                          onTap: () {

                                            debugPrint("tempUsers ==> ${tempUsers[index].id}");
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (context) => EditProfileScreen(userInfo: tempUsers[index])),
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
                                              MdiIcons.pencil,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        InkWell (
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserHomeScreen(
                                                        tempUsers[index]),
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
                                              MdiIcons.glasses,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        InkWell (
                                          onTap: () {
                                            final ref =
                                                Provider.of<UserActions>(
                                                    context,
                                                    listen: false);
                                            ref
                                                .toggleSuspention(
                                                    tempUsers[index])
                                                .then((value) async {
                                              Provider.of<AllUser>(context,
                                                      listen: false)
                                                  .updateSuspention(
                                                      tempUsers[index].id!);
                                              setState(() {});
                                            });
                                          },
                                          child: Container(
                                            width: width * .13,
                                            height: height * .05,
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: isSuspended
                                                  ? Colors.red
                                                  : HexColor('357f78'),
                                            ),
                                            child: Icon(
                                              MdiIcons.cancel,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        InkWell (
                                          onTap: () {
                                            //  log(tempUsers[index].name);
                                            showDeleteConfirmation(tempUsers[index]);
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
                                              MdiIcons.delete,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ShareUserScreen(
                                                        user: tempUsers[index]),
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
                                              color: !(tempUsers[index].allowMarketing ?? false)
                                                  ? Colors.red
                                                  : HexColor('357f78'),
                                            ),
                                            child: Icon(
                                              MdiIcons.share,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: height * .01),
                                    checkPremiumData?.containsKey(tempUsers[index].id) ?? false  ?
                                    Row (
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        InkWell (
                                          child: Container (
                                            child: Text ('Edit',style: TextStyle(color: white)),
                                            decoration: BoxDecoration(
                                                color: HexColor('357f78'),
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            alignment: Alignment.center,
                                            height: 35,width: 70,
                                            margin: EdgeInsets.only(left: 8),
                                          ),
                                          onTap: () async {
                                            final data = await FirebaseDatabase.instance.reference()
                                                .child('ActiveMembership')
                                                .child(tempUsers[index].id!)
                                                .once();
                                            Map fdata = data.snapshot.value as Map;
                                            print("contain data is===>>${fdata.containsKey(tempUsers[index].id)}");
                                            print("data is===>>${fdata['contacts']}");
                                            print("data is===>>${fdata['ValidTill']}");
                                            print("data is===>>${tempUsers[index].id}");
                                            editAlert(validity: fdata['ValidTill'],contacts: fdata['contacts'].toString(),id: tempUsers[index].id);
                                          },
                                        ),
                                        InkWell (
                                          child: Container (
                                            child: Text (
                                              'Cancel',style: TextStyle(color: white),
                                            ),
                                            decoration: BoxDecoration (
                                                color: HexColor('357f78'),
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            alignment: Alignment.center,
                                            height: 35,width: 70,
                                            margin: EdgeInsets.only(left: 8),
                                          ),
                                          onTap: () {
                                            cancelAlert(id: tempUsers[index].id);
                                          },
                                        ),
                                      ],
                                    ) : SizedBox(),

                                    /* tempUsers[index].isVerificationRequiredGovId != null && !tempUsers[index].isVerificationRequiredGovId! ? Align (
                                      alignment: Alignment.centerRight,
                                      child: Padding (
                                          padding: EdgeInsets.only(right: 10),
                                          child: Icon(Icons.verified, color: HexColor('357f78'))),
                                    ) : SizedBox() */

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
                  checkUserPremium();
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
