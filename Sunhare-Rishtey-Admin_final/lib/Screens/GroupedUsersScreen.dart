import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/UserHomeScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/ShareUserScreen.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
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

class GroupedUsersScreen extends StatefulWidget {
  @override
  _GroupedUsersScreenState createState() => _GroupedUsersScreenState();
}

class _GroupedUsersScreenState extends State<GroupedUsersScreen> {
  String gender = 'All';
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
            ));
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
  String suspended = 'All';
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
                          .once();
                      if (data.snapshot.value != null) {
                        final mapped = data.snapshot.value as Map;
                        mapped['DeletedTime'] =
                            DateTime.now().toIso8601String();
                        mapped['DeletedBy'] = 'Admin';
                        await FirebaseDatabase.instance
                            .reference()
                            .child('trash')
                            .update({'${data.snapshot.key}': mapped});
                        FirebaseDatabase.instance
                            .reference()
                            .child("User Information")
                            .child(user.id!)
                            .remove()
                            .then((value) {
                          setState(() async {
                            await sendPushNotificationsByID(user.id!,
                                title: "Account Deleted",
                                subject:
                                    "Your account has been deleted by Admin",
                                target: Constants.USER_ACCOUNT_DELETED);
                            final res =
                                Provider.of<AllUser>(context, listen: false);
                            Fluttertoast.showToast(
                                msg: 'Profile removed Successfully');
                            res.verifiedUsers.removeWhere(
                                (element) => element.id == user.id);
                            tempUsers.remove(user);
                            allUsers.remove(user);
                          });
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

  @override
  Future<void> didChangeDependencies() async {
    final res = Provider.of<AllUser>(context);

    res.verifiedUsers.sort((UserInformation a, UserInformation b) => b.joinedOn!.compareTo(a.joinedOn!));
    pendingReq = res.verifiedUsers.cast<UserInformation>();
    allUsers = [...pendingReq];
    allUsers.removeWhere(
        (element) => !groupedUsersRef.users.contains(element.srId));
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

  String searchVal = '';
  var groupedUsersRef, res;
  @override
  void initState() {
    groupedUsersRef = Provider.of<GroupdedProvider>(context, listen: false);
    res = Provider.of<AllUser>(context, listen: false);
    getPackageData();
    super.initState();
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
            'Grouped Users',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(
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
                  style: GoogleFonts.lato(
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
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
                child: SingleChildScrollView(
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 18),
                              width: width * .38,
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 18),
                              width: width / 2,
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
                                        SizedBox(
                                          width: width * .03,
                                        ),
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
                                              imageUrl:
                                                  tempUsers[index].imageUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * .05,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tempUsers[index].name!,
                                                maxLines: 2,
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
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
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            InkWell(
                                              child: groupedUsersRef.users
                                                      .contains(
                                                          tempUsers[index].srId)
                                                  ? Icon(
                                                      MdiIcons
                                                          .accountMultipleRemove,
                                                      color: Colors.red)
                                                  : Icon(
                                                      MdiIcons
                                                          .accountMultiplePlus,
                                                      color:
                                                          HexColor('357f78')),
                                              onTap: () {
                                                groupedUsersRef
                                                    .toggle(
                                                        tempUsers[index].srId)
                                                    .then((isAdded) {
                                                  if (!isAdded) {
                                                    allUsers.remove(
                                                        tempUsers[index]);
                                                    tempUsers.remove(
                                                        tempUsers[index]);
                                                  }
                                                  setState(() {});
                                                });
                                              },
                                            ),
                                            SizedBox(height: 10),
                                            InkWell(
                                              child: Text("ID",
                                                  style: TextStyle(
                                                      color: tempUsers[index].isVerificationRequired!
                                                          ? Colors.red
                                                          : HexColor('357f78'),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16)),
                                              onTap: () {
                                                res.toggleIDVerification(
                                                        tempUsers[index])
                                                    .then((value) {
                                                  setState(() {});
                                                });
                                              },
                                            ),
                                            SizedBox(height: 10),
                                            InkWell(
                                              child: Icon(MdiIcons.phone,
                                                  color: tempUsers[index]
                                                          .hideContact!
                                                      ? Colors.red
                                                      : HexColor('357f78')),
                                              onTap: () {
                                                res.toggleHideContact(
                                                        tempUsers[index])
                                                    .then((isAdded) {
                                                  setState(() {});
                                                });
                                              },
                                            ),
                                            SizedBox(height: 10),
                                            InkWell(
                                              child: Icon(
                                                  MdiIcons.abacus,
                                                  // MdiIcons.face,
                                                  color: tempUsers[index]
                                                          .hideProfile!
                                                      ? Colors.red
                                                      : HexColor('357f78')),
                                              onTap: () {
                                                res
                                                    .toggleHideProfile(
                                                        tempUsers[index])
                                                    .then((isAdded) {
                                                  setState(() {});
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: height * .01,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            print(tempUsers[index].id);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(
                                                  tempUsers[index],
                                                  true,
                                                  packageList: packageList,
                                                ),
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
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfileScreen(
                                                          userInfo:
                                                              tempUsers[index],
                                                        )));
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
                                        InkWell(
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
                                        InkWell(
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
                                        InkWell(
                                          onTap: () {
                                            //  log(tempUsers[index].name);
                                            showDeleteConfirmation(
                                                tempUsers[index]);
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
                                              color: !tempUsers[index]
                                                      .allowMarketing!
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
}
