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

class DeleteListScreen extends StatefulWidget {
  @override
  _DeleteListScreenState createState() => _DeleteListScreenState();
}

class _DeleteListScreenState extends State<DeleteListScreen> {
  String gender = "All";

  bool isLoading = false;

  Future<void> _getUserData() async {
    setState(() {
      isLoading = true;
    });
    Provider.of<AllUser>(context, listen: false).getRecentDeleteUsers().then((value) {
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
    FirebaseDatabase.instance.reference().child('PremiumPackage').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        if (data != null) {
          packageList = [];
          data.forEach((key, value) {
            packageList.add(Package(
                id: key,
                contacts: int.parse(value['contacts'].toString()),
                discount: double.tryParse(value['discount'].toString()) ?? 0,
                discountTillDateTime: DateTime.tryParse(value['months'].toString()) ?? null,
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
    if (diff.inDays > 0) return "${DateFormat.E().add_jm().format(d)}";
    if (diff.inHours > 0) return "Today ${DateFormat('jm').format(d)}";
    if (diff.inMinutes > 0) return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "Never";
  }

  AllUser res = AllUser();

  @override
  Future<void> didChangeDependencies() async {
    res = Provider.of<AllUser>(context);
    res.recentDeleteList.sort((UserInformation a, UserInformation b) => b.joinedOn!.compareTo(a.joinedOn!));
    pendingReq = res.recentDeleteList;
    allUsers = [...pendingReq];
    print("Run up side ${allUsers.length}");
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
    _getUserData();
    checkUserPremium();
    groupedUsersRef = Provider.of<GroupdedProvider>(context, listen: false);
    allUsersref = Provider.of<AllUser>(context, listen: false);
    getPackageData();
    super.initState();
  }

  checkUserPremium() async {
    checkPremiumLoad = true;
    final data = await FirebaseDatabase.instance.reference().child('ActiveMembership').once();
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
      print("tempUsers ${tempUsers.length}");
    }
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar (
          backgroundColor: HexColor('70c4bc'),
          title: Text (
            'Recent Delete',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: isLoading
            ? SpinKitThreeBounce(color: Colors.blue)
            : LiquidPullToRefresh(
                color: HexColor('70c4bc'),
                onRefresh: () {
                  return _getUserData();
                },
                child: checkPremiumLoad == true
                    ? Center(child: CircularProgressIndicator(color: HexColor('357f78')))
                    : SingleChildScrollView (
                        child: Column (
                          children: [
                            /* Padding(
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
                            SizedBox(height: height * .001),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 10),
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
                                        return DropdownMenuItem(value: e, child: Text(e));
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
                                    margin: EdgeInsets.only(left: 5, right: 10, top: 10, bottom: 10),
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
                                        return DropdownMenuItem(value: e, child: Text(e));
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
                            ),*/
                            SizedBox(width: width * .1),
                            Container (
                              width: width,
                              height: height * .85,
                              child: tempUsers.isEmpty ? const Center (
                                child: Text("No recent delete record found", style: TextStyle(fontSize: 17)),
                              ) :  ListView.builder(
                                itemCount: tempUsers.length,
                                itemBuilder: (context, index) {
                                  bool isSuspended = tempUsers[index].suspended != null ? tempUsers[index].suspended! : false;
                                  String lastLogin = (tempUsers[index].lastLogin ?? "Never") == "Never"
                                      ? "Never"
                                      : timeAgoCustom(DateTime.parse(tempUsers[index].lastLogin!));
                                  print("lastLogin====>>>>$lastLogin");
                                  print("img url===>>${tempUsers[index].imageUrl!}");
                                  return InkWell (
                                     onTap: () {
                                       print(tempUsers[index].id);
                                     },
                                    child: Card (
                                      elevation: 10,
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row (
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: width * .03),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 8,
                                              ),
                                              height: height * .15,
                                              width: width * .23,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: CachedNetworkImage(imageUrl: tempUsers[index].imageUrl!),
                                              ),
                                            ),
                                            SizedBox(width: width * .05),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tempUsers[index].name ?? "",
                                                    maxLines: 2,
                                                    style: GoogleFonts.openSans(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: checkPremiumData!.containsKey(tempUsers[index].id) ? Colors.red : black),
                                                  ),
                                                  Text(
                                                    "ID -" + (tempUsers[index].srId ?? ""),
                                                    style: GoogleFonts.openSans(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Mobile -" + (tempUsers[index].phone ?? ""),
                                                    style: GoogleFonts.openSans(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Email id - " + (tempUsers[index].email ?? "").toLowerCase(),
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
                                                    'Joined - ${tempUsers[index].joinedOn!.day}/${tempUsers[index].joinedOn!.month}/${tempUsers[index].joinedOn!.year}',
                                                    style: GoogleFonts.openSans(fontSize: 13),
                                                  ),
                                                  Text (
                                                    'User Status : ${tempUsers[index].userStatus}',
                                                    style: GoogleFonts.openSans(fontSize: 13),
                                                  ),
                                                  Text (
                                                    'Delete : ${setSubtractDateInYYYYMMDD(tempUsers[index].deletedOn ?? DateTime.now())}',
                                                    style: GoogleFonts.openSans (fontSize: 13),
                                                  ),
                                                 Text (
                                                  'Deleted By: ${tempUsers[index].deletedBy ?? ""}',
                                                   style: GoogleFonts.openSans(fontSize: 13),
                                                ),
                                                Container (
                                                  width: width * .7,
                                                  child: Text (
                                                    'Deleted Reason: ${tempUsers[index].deletedReason ?? ""}',
                                                     style: GoogleFonts.openSans(fontSize: 13),
                                                  ),
                                                )
                                                 /* Text(
                                                    'Last login : ${lastLogin}',
                                                    style: GoogleFonts.openSans(
                                                      fontSize: 13,
                                                    ),
                                                  ), */
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
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

  editAlert({String? validity, String? contacts, String? id}) {
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
                Text("Contacts", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextFormField(
                  controller: contact_controller,
                  cursorColor: HexColor('357f78'),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
                    hintText: "Enter contacts",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: HexColor('357f78')), borderRadius: BorderRadius.circular(5)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: HexColor('357f78')), borderRadius: BorderRadius.circular(5)),
                  ),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter contacts';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                Text("Validity", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
              child: Text("Update", style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                if (_key.currentState!.validate()) {
                  print("dateTime selected is===>>>$dateTime");
                  print("dateTime selected is===>>>${contact_controller.text}");
                  FirebaseDatabase.instance.reference().child('ActiveMembership').child(id!).update({
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
              child: Text("Cancel", style: TextStyle(color: white)),
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

  cancelAlert({String? id}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure to cancel this user membership?"),
          actions: [
            MaterialButton(
              child: Text("OK", style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                FirebaseDatabase.instance.reference().child('ActiveMembership').child(id!).remove().then((value) {
                  // getActivePlan();
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: 'Membership cancel Successfully');
                  checkUserPremium();
                  setState(() {});
                });
              },
            ),
            MaterialButton(
              child: Text("Cancel", style: TextStyle(color: white)),
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
