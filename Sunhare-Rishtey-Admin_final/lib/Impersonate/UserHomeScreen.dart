import 'dart:async';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/AllChatScreen.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/InboxScreen.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/MatchScreen.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/BlockedUsersProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/contactsProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/imagesProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/userRequestProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/suspendedScreen.dart';
import 'package:sunhare_rishtey_new_admin/main.dart';
import 'package:sunhare_rishtey_new_admin/models/parternerInfoModel.dart';
import 'package:sunhare_rishtey_new_admin/models/primiumModel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:provider/provider.dart';
import 'provider/ConnectionProvider.dart';
import 'hideMessageScreen.dart';

// ignore: must_be_immutable
class UserHomeScreen extends StatefulWidget {
  UserInformation userInfo;
  UserHomeScreen(this.userInfo);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  bool gotUserInfo = true;

  List<UserInformation> allUsers = [];
  List<UserInformation> tempUsers = [];

  var hide = false;
  Future getAllUsers() async {
    final ref = Provider.of<AllUser>(context, listen: false);
    allUsers = [...ref.verifiedUsers];
    setState(() {
      allUsers.removeWhere((element) =>
          element.suspended! ||
          element.gender == widget.userInfo.gender ||
          widget.userInfo.blockedByList!.contains(element.id));

      allUsers.forEach((element) {
        if (element.isPremium!) {
          tempUsers.add(element);
        }
      });
      allUsers.forEach((element) {
        if (!(element.isPremium!)) {
          tempUsers.add(element);
        }
      });
      isLoading = false;
    });
  }

  bool isMembershipLoading = true;
  getMembership() async {
    FirebaseDatabase.instance
        .reference()
        .child('ActiveMembership')
        .child(widget.userInfo.id!)
        .onValue
        .listen((event) {
      print("snapShot====>>>>>${event.snapshot.value}");
      final premi = event.snapshot.value == null ? {} : event.snapshot.value as Map;
      print("premi===>>>>${premi}");
      if (premi.isNotEmpty) {
        DateTime validTill2 = DateTime.parse("${premi['ValidTill'].split('T')[0]} 00:00:00.000");
        validTill2 = validTill2.add(Duration(days: 1));
        widget.userInfo.premiumModel = PremiumModel(
            dateOfPerchase: DateTime.parse(premi['DateOfPerchase']),
            validTill: DateTime.parse(premi['ValidTill']),
            contact: premi['contacts'],
            name: premi['name'],
            packageName: premi['packageName'],
            isActive: premi['ValidTill'] != null
                ? (validTill2.compareTo(DateTime.now()) > 0)
                    ? true
                    : false
                : false);
        FirebaseDatabase.instance
            .reference()
            .child('User Information')
            .child(widget.userInfo.id!)
            .update({'isPremium': widget.userInfo.premiumModel!.isActive});
      } else {
        widget.userInfo.premiumModel = PremiumModel();
      }
      isMembershipLoading = false;
      setState(() {});
    });
  }

  List<String> pendingList = [];
  List<String> acceptedList = [];

  getRequestedAndPendindData() async {
    final ref = Provider.of<UserRequests>(context, listen: false);
    await ref.getAllRequest(widget.userInfo.id!);
    setState(() {
      pendingList = ref.pendingUsers;
      acceptedList = ref.acceptedUsers;
    });
  }

  Map requestStatus = {};
  getRequests() async {
    FirebaseDatabase.instance
        .reference()
        .child('userReq')
        .child(widget.userInfo.id!)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        requestStatus = event.snapshot.value as Map;
        setState(() {});
      }
    });
  }

  List blockedId = [];
  getBlockedId() {
    var ref = Provider.of<BlockedUsersProvider>(context, listen: false);
    ref.getBlockedUsers(widget.userInfo.id!);
    ref.addListener(() {
      print("ref.blockedUsers===>>>${ref.blockedUsers}");
      blockedId.addAll(ref.blockedUsers);
      setState(() {});
    });
  }

  @override
  dispose() {
    FirebaseDatabase.instance
        .reference()
        .child('User Information')
        .child(widget.userInfo.id!)
        .update({'isOnline': false});
    Provider.of<BlockedUsersProvider>(context, listen: false)
        .listener
        .dispose();
    super.dispose();
  }

  void setupOnlineStatus() {
    FirebaseDatabase.instance
        .reference()
        .child('User Information')
        .child(widget.userInfo.id!)
        .update({'isOnline': true});
  }

  bool isLoading = true;
  bool isLoadingPartnerInfo = true;
  bool isSuspended = false;
  @override
  void initState() {
    print(
        "~~~~~~~~~~~~~~~~ User: ${widget.userInfo.name}, ${widget.userInfo.id}");
    getMembership();
    isSuspended = widget.userInfo.isSuspended!;
    getAllUsers().then((value) {
      final ref = Provider.of<UserRequests>(context, listen: false);
      ref.setPendingData(allUsers);
      getPendingRequest();
    });
    getRequestedAndPendindData();
    getPartnerInfo();
    Provider.of<ImageListProvider>(context, listen: false)
        .getImages(widget.userInfo.id!);
    getRequests();
    getBlockedId();
    Provider.of<ContactProvider>(context, listen: false)
        .getContacts(widget.userInfo.id!)
        .then((value) => setState(() {}));

    setupOnlineStatus();
    super.initState();
  }

  Future getPartnerInfo() async {
    final pref = await FirebaseDatabase.instance
        .reference()
        .child('Partner Prefrence')
        .child(widget.userInfo.id!)
        .once().then((value){});
    bool maritalStatusForAll = widget.userInfo.maritalStatus != "Never Married";
    List selectedMaritalStatusList = [];
    if (!maritalStatusForAll) selectedMaritalStatusList = ["Never Married"];
    print("pref=====>>>>>${pref}");
    if (pref != null) {
      widget.userInfo.partnerInfo = PartnerInfo(
          maritalStatusForAll:
              pref.value['maritalStatusForAll'] ?? maritalStatusForAll,
          selectedMaritalStatusList:
              pref.value['maritalStatusList'] ?? selectedMaritalStatusList,
          motherToungueForAll: pref.value['motherToungeForAll'] ?? true,
          selectedMotherToungueList: pref.value['motherToungueList'] ?? [],
          manglikForAll: pref.value['manglikForAll'] ?? true,
          selectedManglikList: pref.value['selectedManglikList'] ?? [],
          employedInForAll: pref.value['employedInForAll'] ?? true,
          selectedEmployedInList: pref.value['emplyedInList'] ?? [],
          religionForAll: pref.value['religionForAll'] ?? true,
          selectedReligionList: pref.value['religionList'] ?? [],
          city: pref.value['city'] ?? '',
          country: pref.value['country'],
          workingWith: pref.value['workingWith'],
          workingAs: pref.value['designation'],
          diet: pref.value['diet'],
          maritalStatus: pref.value['maritalStatus'],
          maxAge: pref.value['maxAge'],
          minAge: pref.value['minAge'],
          maxIncome: pref.value['maxIncome'],
          minIncome: pref.value['minIncome'],
          motherTong: pref.value['motherTounge'],
          qualification: pref.value['qualification'],
          community: pref.value['community'],
          religion: pref.value['religion'],
          state: pref.value['state'],
          selectedDesignation: pref.value['designationList'] ?? [],
          maxHeight: pref.value['maxHeight'],
          selectedDietList: pref.value['dietList'] ?? [],
          selectedQualificationList: pref.value['qualificationList'] ?? [],
          designationOpenForAll: pref.value['desigForAll'] ?? true,
          dietForAll: pref.value['dietForAll'] ?? true,
          qualificationOpenForAll: pref.value['qualificationForAll'] ?? true,
          locationForAll: pref.value['locationForAll'] ?? true,
          selectedLocationList: pref.value['locationList'] ?? [],
          minHeight: pref.value['minHeight']);
    } else {
      widget.userInfo.partnerInfo = PartnerInfo(
          maritalStatusForAll: maritalStatusForAll,
          selectedMaritalStatusList: selectedMaritalStatusList,
          motherToungueForAll: true,
          selectedMotherToungueList: [],
          religionForAll: true,
          selectedReligionList: [],
          city: '',
          selectedDesignation: [],
          selectedDietList: [],
          selectedQualificationList: [],
          designationOpenForAll: true,
          dietForAll: true,
          qualificationOpenForAll: true,
          locationForAll: true,
          manglikForAll: true,
          selectedManglikList: [],
          employedInForAll: true,
          selectedEmployedInList: [],
          selectedLocationList: []);
    }
    isLoadingPartnerInfo = false;
    setState(() {});
  }

  List<String> accepted = [];
  List<String> pending = [];
  List<UserInformation> acceptedUsers = [];
  List<UserInformation> pendingUsers = [];
  getPendingRequest() {
    FirebaseDatabase.instance
        .reference()
        .child('Connection Requests')
        .child(widget.userInfo.id!)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        List sortable = [];
        final data = event.snapshot.value as Map;
        Provider.of<ConnectionProvider>(context, listen: false)
            .setConnection(data);
        data.forEach((key, value) {
          if (value is bool) {
            if (value) {
              accepted.add(key);
            } else {
              pending.add(key);
            }
          } else {
            Map data = value as Map;
            data['uid'] = key;
            sortable.add(data);
          }
        });

        sortable.sort((a, b) => a['time'].compareTo(b['time']));
        sortable.forEach((data) {
          if (data['accepted']) {
            accepted.insert(0, data['uid']);
          } else {
            pending.insert(0, data['uid']);
          }
        });

        allUsers.forEach((element) {
          if (accepted.contains(element.id)) {
            acceptedUsers.add(element);
          }
        });
        allUsers.forEach((element) {
          if (pending.contains(element.id)) {
            pendingUsers.add(element);
          }
        });
        setState(() {});
      }
    });
  }

  int barIndex = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorBackground,
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          buttonBackgroundColor: theme.colorBackground,
          index: barIndex,
          height: 50,
          color: theme.colorCompanion,
          backgroundColor: theme.colorBackground!,
          onTap: (selectedindex) {
            setState(() {
              barIndex = selectedindex;
            });
          },
          items: [
            Icon(
              MdiIcons.accountMultiple,
              color: barIndex == 0 ? theme.colorCompanion : Colors.black,
            ),
            Icon(
              MdiIcons.inboxFull,
              color: barIndex == 1 ? theme.colorCompanion : Colors.black,
            ),
            Icon(
              MdiIcons.chat,
              color: barIndex == 2 ? theme.colorCompanion : Colors.black,
            )
          ],
        ),
        body: isSuspended
            ? SuspendedScreen()
            : isLoading || isLoadingPartnerInfo || isMembershipLoading
                ? SpinKitThreeBounce(
                    color: theme.colorPrimary,
                  )
                : hide
                    ? HideMessageScreen()
                    : (barIndex == 0
                        ? MatchScreen(widget.userInfo, tempUsers, requestStatus,
                            blockedId, allUsers)
                        : barIndex == 1
                            ? InboxScreen(
                                widget.userInfo,
                                allUsers,
                                accepted: acceptedUsers,
                                pending: pendingUsers,
                              )
                            : AllChatScreen(widget.userInfo)),
      ),
    );
  }
}
