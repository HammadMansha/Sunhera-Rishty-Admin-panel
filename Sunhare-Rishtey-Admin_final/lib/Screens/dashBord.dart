import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Screens/SubscriptionScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/TrashScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/UserInformationScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/UserRequestScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/delete_list_screen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/reprotedAccountScreen.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/Widgets/DrawerWidget.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:sunhare_rishtey_new_admin/provider/groupProvider.dart';
import 'GraphScreenFemale.dart';
import 'GraphScreenMale.dart';
import 'GraphScreenPurchase.dart';
import 'GraphScreenMembership.dart';
import 'GraphScreenAll.dart';
import 'package:provider/provider.dart';

import 'PhotoVerificationScreen.dart';
import 'package:http/http.dart' as http;

class DashbordScreen extends StatefulWidget {
  @override
  _DashbordScreenState createState() => _DashbordScreenState();
}

class _DashbordScreenState extends State<DashbordScreen> {
  // MethodChannel _channel = MethodChannel('flutter/test/platformchannels');
  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
    });
    getUsers().then((value) {});
    Provider.of<AllUser>(context, listen: false).updateList();
  }

  // Future<dynamic> _handleMethod(MethodCall call) async {
  //   switch (call.method) {
  //     case 'notification':
  //       if (call.arguments != null) {
  //         final response = json.decode(call.arguments);
  //         final payloadStr = response['payload'];
  //       }
  //   }
  // }

  // Future getIntent() async {
  //   var getData = await _channel.invokeMethod('getIntent');
  //   if (getData == '{}' || getData == '') {
  //     getData = null;
  //   } else if (getData != null) {}
  // }

  int totalUsers = 0;
  int acceptedUsers = 0;
  int pendingUsers = 0;
  int allRequests = 0;
  int femaleUsers = 0;
  int maleUsers = 0;
  int activeUsers = 0;
  int unSuspended = 0;
  int suspended = 0;
  List<UserInformation> verifiedUsers = [];
  List<UserInformation> pendingUsersData = [];
  bool isLoading = true;

  Future getUsers() async {
    final ref = Provider.of<AllUser>(context, listen: false);
    ref.getAllUsers().then((value) {
      setState(() {
        isLoading = false;
        totalUsers = 0;
        acceptedUsers = 0;
        pendingUsers = 0;
        allRequests = 0;
        femaleUsers = 0;
        maleUsers = 0;
        activeUsers = 0;
        unSuspended = 0;
        suspended = 0;
        isLoading = false;
        verifiedUsers = ref.verifiedUsers.cast<UserInformation>();
        pendingUsersData = ref.notVerified.cast<UserInformation>();
        acceptedUsers = ref.verifiedUsers.length;
        pendingUsers = ref.notVerified.length;
        totalUsers = acceptedUsers + pendingUsers;
        allRequests = acceptedUsers + pendingUsers;
        ref.verifiedUsers.forEach((element) {
          if (element.userStatus == 'Active') {
            activeUsers++;
          }
          if (element.suspended!) {
            suspended++;
          }
          if (!element.suspended!) {
            unSuspended++;
          }
          if (element.gender == 'Male') {
            maleUsers++;
          } else {
            femaleUsers++;
          }
        });
        ref.notVerified.forEach((element) {
          if (element.gender == 'Male') {
            maleUsers++;
          } else {
            femaleUsers++;
          }
        });
      });
    });
  }

  void initPushNotification() async {
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();
    fbm.subscribeToTopic("admin").then((value) {
      print("::::: Subscribed to topic");
    });
    String? token = await fbm.getToken();
    print(token);
    final databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child('Push Notifications').child('Admin IDs').set({token: true});
  }

  int trashCount = 0;

  getTrashCount() async {
    final data = await FirebaseDatabase.instance.reference().child('trash').once();
    if (data.snapshot.value != null) {
      final trash = data.snapshot.value as Map;
      trashCount = trash.keys.length;
      setState(() {});
    }
  }

  @override
  void initState() {
    UserAccountDelete();
    getTrashCount();
    Provider.of<GroupdedProvider>(context, listen: false).getUsers();
    getUsers();
    super.initState();
    initPushNotification();
    initReceivePushNotifications();
  }

  Future<bool> sendPushNotificationToAdmin(String title, String body, {String target = '-1', String userId = ''}) async {
    final data = {
      "notification": {"body": body, "title": title},
      "priority": "high",
      "data": {
        "target": target,
        "userId": userId,
      },
      "android_channel_id": 'Notifications',
      "to": "/topics/admin",
    };

    final response = await http.post(Uri.parse(postUrl), body: json.encode(data), encoding: Encoding.getByName('utf-8'), headers: headers);

    return response.statusCode == 200;
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  UserAccountDelete() async {
    final dateTime = DateTime.now();
    final stringDateTime = dateTime.toIso8601String();
    final parsedDateTime = DateTime.parse(stringDateTime);

    final datas = await FirebaseDatabase.instance.reference().child('User Information').once();

    final data = datas.snapshot.value as Map;
    print("data is===>>>>${data}");

    if (data.isNotEmpty) {
      data.forEach((key, value) async {
        if (value.containsKey("AccountDeleteDate")) {
          if (parsedDateTime.isBefore(DateTime.parse(value['AccountDeleteDate']))) {

          } else {

            if(value.containsKey("inTrash") && (value["inTrash"] ?? false)) {

            } else {
              sendPushNotificationToAdmin("Account Deleted", "${value['userName']} deleted account",
                  target: Constants.ADMIN_ID_VERIFICATION, userId: key ?? "");
              final user = FirebaseAuth.instance.currentUser;
              final data = await FirebaseDatabase.instance.reference().child("User Information").child(key ?? "").once();
              final mapped = data.snapshot.value as Map;
              mapped['DeletedTime'] = DateTime.now().toIso8601String();
              mapped['Reason'] = mapped['Reason'] ?? "";
              await FirebaseDatabase.instance.reference().child('trash').update({'${data.snapshot.key}': mapped});
              print("123key====>>>${data.snapshot.key!}");
              FirebaseDatabase.instance.reference().child("User Information").child(data.snapshot.key!).update({"inTrash": true, "isDeleteByAdmin": true});
              //     .then((value) {
              //   // user?.unlink("phone").then((value) => {
              //   //       user.delete().then((value) {
              //   //
              //   //       })
              //   //     });
              //
              // });
            }
          }
        }
      });
      setState(() {});
    }
  }

  String title = '';
  String body = '';
  String target = '';
  String userId = '';

  void getNotificationData(RemoteMessage msg) {
    var noti = msg.notification;
    if (noti != null) {
      title = noti.title!;
      body = noti.body!;
    } else if (msg.data['title'] != null && msg.data['body'] != null) {
      title = msg.data['title'] as String;
      body = msg.data['body'] as String;
    }
    target = msg.data['target'] as String;
    userId = msg.data['userId'] as String;
  }

  UserInformation mappedData = UserInformation();
  List<String> blockedById = [];

  Future selectNotification(String? payload) async {
    print("::: Clicked");
    sendDataWithNotification();
  }

  sendDataWithNotification() async {
    final data = await FirebaseDatabase.instance.reference().child('User Information').child(userId).once();
    print("aaaaaaa${data.snapshot.value as Map}");
    var fdata = data.snapshot.value as Map;

    if (fdata['Blocked By'] != null) {
      fdata['Blocked By'].forEach((key, value) {
        blockedById.add(key);
      });
    }

    bool hideMobile = false;
    bool hideProfile = false;

    mappedData.name = fdata['userName'] ?? "";
    mappedData.id = userId;
    mappedData.lastLogin = fdata['Lastlogin'] ?? "Never";
    mappedData.phone = fdata['mobileNo'] ?? '';
    mappedData.srId = fdata['id'];
    mappedData.isPremium = fdata['isPremium'] ?? false;
    mappedData.email = fdata['email'] ?? '';
    mappedData.city = fdata['city'] ?? '';
    mappedData.height = fdata['personHeight'] ?? '';
    mappedData.allowMarketing = fdata['allowMarketing'] ?? true;
    mappedData.annualIncome = fdata['annualIncome'] ?? '';
    mappedData.anyDisAbility = fdata['disability'] ?? '';
    mappedData.birthTime = splitData(fdata['timeOfBirth'] ?? "");
    mappedData.blockedByList = blockedById;
    mappedData.brothers = fdata['brotherCount'] ?? '';
    mappedData.cityOfBirth = fdata['cityOfBirth'] ?? '';
    mappedData.collegeAttended = fdata['clg'] ?? '';
    mappedData.community = fdata['Community'] ?? '';
    mappedData.country = fdata['living'] ?? '';
    mappedData.dateOfBirth = fdata['DateOfBirth'] ?? '';
    mappedData.diet = fdata['diet'] ?? "";
    mappedData.employedIn = fdata['employedIn'] ?? '';
    mappedData.employerName = fdata['employerName'] ?? "";
    mappedData.familyType = fdata['familyType'] ?? '';
    mappedData.fatherGautra = fdata['fatherGotra'] ?? '';
    mappedData.fatherStatus = fdata['FatherStatus'] ?? '';
    mappedData.gender = fdata['gender'] ?? '';
    mappedData.grewUpIn = fdata['grewUpIn'] ?? '';
    mappedData.hideContact = false;
    mappedData.hideProfile = false;
    mappedData.highestQualification = fdata['qualification'] ?? '';
    mappedData.imageUrl = fdata['imageURL'] ?? '';
    mappedData.intro = fdata['intro'] ?? '';
    mappedData.iseditable = fdata['isEditable'] ?? true;
    mappedData.isOnline = fdata['isOnline'] ?? false;
    mappedData.isSuspended = fdata['isSuspended'] != null ? fdata['isSuspended'] : false;
    mappedData.isVerificationRequired = fdata['isVerificationRequired'] ?? false;
    mappedData.isVerified = fdata['isVerified'] ?? false;
    mappedData.joinedOn = DateTime.parse(fdata['DateTime']);
    mappedData.manglik = fdata['maglik'] ?? '';
    mappedData.maritalStatus = fdata['maritalStatus'] ?? "";
    mappedData.motherGautra = fdata['motherGotra'] ?? '';
    mappedData.motherStatus = fdata['MotherStatus'] ?? '';
    mappedData.motherTongue = fdata['motherTongue'] ?? '';
    mappedData.nativePlace = fdata['nativePlace'] ?? '';
    mappedData.postedBy = fdata['ProfileFor'] ?? '';
    mappedData.referCode = fdata['referCode'] ?? '';
    mappedData.religion = fdata['Religion'] ?? '';
    mappedData.residencyStatus = fdata['residency'] ?? '';
    mappedData.showHoroscope = fdata['showHoroscope'] ?? true;
    mappedData.sisters = fdata['sisterCount'] ?? '';
    mappedData.state = fdata['state'] ?? '';
    mappedData.suspended = fdata['isSuspended'] != null ? fdata['isSuspended'] : false;
    mappedData.userStatus = fdata['LastActive'] != null
        ? DateTime.parse(fdata['LastActive'].toString()).difference(DateTime.now()).inMinutes.abs() < 5
            ? 'Active'
            : 'Inactive'
        : 'Inactive';
    mappedData.visibility = fdata['visibility'] ?? 'All Member';
    mappedData.workingAs = fdata['designation'] ?? '';
    mappedData.workingWith = fdata['workAt'] ?? '';
    router(data: mappedData);
  }

  splitData(String time) {
    if (time != null) {
      try {
        List t = time.split('');
        int hr = int.parse(t[10]) * 10 + int.parse(t[11]);
        int minute = int.parse(t[13]) * 10 + int.parse(t[14]);
        //  log(TimeOfDay(hour: hr, minute: minute).toString());

        return TimeOfDay(hour: hr, minute: minute);
      } catch (e) {
        return null;
      }
    } else
      return null;
  }

  void initReceivePushNotifications() {
    var flnPlugin = FlutterLocalNotificationsPlugin();
    flnPlugin.initialize(InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
        onSelectNotification: selectNotification);

    var nDetails = NotificationDetails(
        android: AndroidNotificationDetails('Notifications', 'Notifications',
            channelDescription: 'This is primary notification channel', importance: Importance.max, priority: Priority.high, showWhen: false));

    FirebaseMessaging.instance.getInitialMessage().then((event) => {
          setState(() {
            print("::: Initial Message");
            if (event != null) getNotificationData(event);
            if (target != null && target != Constants.DEFAULT_TARGET) {
              router();
            }
          })
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("::: message recieved");
      getNotificationData(event);
      flnPlugin.show(0, title, body, nDetails);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('::::::: Message clicked!');
      getNotificationData(event);
      print('target is===>>>$target');
      sendDataWithNotification();
    });
  }

  void router({data}) {
    print('target is====>>>>$target');
    switch (target) {
      case Constants.ADMIN_ID_VERIFICATION:
        // Navigator.of(context).push(
        //     MaterialPageRoute(builder: (context) => IDVerificationScreen()));
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen(data, true, packageList: [])));
        break;
      case Constants.ADMIN_PHOTO_VERIFICATION:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => PhotoVerificationScreen()));
        break;
      case Constants.ADMIN_NEW_USER_REQUEST:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserRequestScreen()));
        break;
      case Constants.ADMIN_GOT_SUBSCRIPTION:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SubscriptionsScreen()));
        break;
      case Constants.ADMIN_ACCOUNT_DELETED:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TrashScreen()));
        break;
      case Constants.ADMIN_ACCOUNT_REPORTED:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReportedAccountScreen()));
        break;
      default:
        {}
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() async{
    res = Provider.of<AllUser>(context);
    await res.getRecentDeleteUsers();
    print("tempUsers--->>>>${res.recentDeleteList.length}");
    setState(() {

    });
    super.didChangeDependencies();
  }
  AllUser res = AllUser();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('70c4bc'),
          title: Text(
            'DashBoard',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        drawer: DrawerWidget(),
        body: isLoading
            ? SpinKitThreeBounce(
                color: Colors.blue,
              )
            : RefreshIndicator(
                color: HexColor('70c4bc'),
                onRefresh: _handleRefresh,
                child: ListView(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: height * .01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => UserGrowthGraphScreen(),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 12,
                                  color: HexColor('357f78'),
                                  child: Container(
                                    height: height * 0.14,
                                    width: width * 0.42,
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          MdiIcons.accountMultiple,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: width * 0.01,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              totalUsers.toString(),
                                              style: GoogleFonts.workSans(
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                            Container(
                                              width: width * .23,
                                              child: Text(
                                                "Total Users",
                                                style: GoogleFonts.workSans(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FemaleUsersScreen(),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 12,
                                  color: HexColor('357f78'),
                                  child: Container(
                                    height: height * 0.14,
                                    width: width * 0.45,
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          MdiIcons.accountOutline,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: width * 0.01,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              femaleUsers.toString(),
                                              style: GoogleFonts.workSans(
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                            Container(
                                              width: width * .23,
                                              child: Text(
                                                "Female Users",
                                                style: GoogleFonts.workSans(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height * .01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MaleUsersScreen(),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 12,
                                  color: HexColor('357f78'),
                                  child: Container(
                                    height: height * 0.14,
                                    width: width * 0.42,
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          MdiIcons.humanMale,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: width * 0.01,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              maleUsers.toString(),
                                              style: GoogleFonts.workSans(
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                            Container(
                                              width: width * .23,
                                              child: Text(
                                                "Male Users",
                                                style: GoogleFonts.workSans(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => TrashScreen(),
                                  ))
                                },
                                child: Card(
                                  elevation: 12,
                                  color: HexColor('357f78'),
                                  child: Container(
                                    height: height * 0.14,
                                    width: width * 0.45,
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          MdiIcons.delete,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: width * 0.01,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              trashCount.toString(),
                                              style: GoogleFonts.workSans(
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                            Container(
                                              width: width * .23,
                                              child: Text(
                                                "Trash",
                                                style: GoogleFonts.workSans(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height * .01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                elevation: 12,
                                color: HexColor('357f78'),
                                child: Container(
                                  height: height * 0.14,
                                  width: width * 0.42,
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        MdiIcons.accessPoint,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            unSuspended.toString(),
                                            style: GoogleFonts.workSans(
                                              color: Colors.white,
                                              fontSize: 24,
                                            ),
                                          ),
                                          Container(
                                            width: width * .23,
                                            child: Text(
                                              "Active",
                                              style: GoogleFonts.workSans(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserRequestScreen()));
                                },
                                child: Card(
                                  elevation: 12,
                                  color: HexColor('357f78'),
                                  child: Container(
                                    height: height * 0.14,
                                    width: width * 0.45,
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          MdiIcons.send,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: width * 0.01,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              pendingUsers.toString(),
                                              style: GoogleFonts.workSans(
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                            Container(
                                              width: width * .23,
                                              child: Text(
                                                "Pending",
                                                style: GoogleFonts.workSans(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height * .01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                elevation: 12,
                                color: HexColor('357f78'),
                                child: Container(
                                  height: height * 0.14,
                                  width: width * 0.42,
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        MdiIcons.sleep,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      SizedBox(
                                        width: width * 0.01,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            suspended.toString(),
                                            style: GoogleFonts.workSans(
                                              color: Colors.white,
                                              fontSize: 24,
                                            ),
                                          ),
                                          Container(
                                            width: width * .23,
                                            child: Text(
                                              "InActive",
                                              style: GoogleFonts.workSans(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MembershipGraphScreen(),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 12,
                                  color: HexColor('357f78'),
                                  child: Container(
                                    height: height * 0.14,
                                    width: width * 0.45,
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          MdiIcons.sale,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: width * 0.01,
                                        ),
                                        Container(
                                          width: width * .23,
                                          child: Text(
                                            "Membership Trend",
                                            style: GoogleFonts.workSans(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height * .01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeleteListScreen()));
                                },
                                child: Card(
                                  elevation: 12,
                                  color: HexColor('357f78'),
                                  child: Container(
                                    height: height * 0.14,
                                    width: width * 0.45,
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          MdiIcons.delete,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: width * 0.01,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              res.recentDeleteList.length.toString(),
                                              style: GoogleFonts.workSans(
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                            Container(
                                              width: width * .23,
                                              child: Text(
                                                "Recent Delete",
                                                style: GoogleFonts.workSans(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MoneyTrend(),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 12,
                                  color: HexColor('357f78'),
                                  child: Container(
                                    height: height * 0.14,
                                    width: width * 0.45,
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          MdiIcons.currencyInr,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        SizedBox(
                                          width: width * 0.01,
                                        ),
                                        Container(
                                          width: width * .23,
                                          child: Text(
                                            "Purchase Trend",
                                            style: GoogleFonts.workSans(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
