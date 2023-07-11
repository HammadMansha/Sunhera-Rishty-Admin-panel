import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/PersonCard.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/contactsProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/favouriteUserProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/userRequestProvider.dart';
import 'package:sunhare_rishtey_new_admin/main.dart';
import 'package:sunhare_rishtey_new_admin/models/parternerInfoModel.dart';
import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class MatchScreen extends StatefulWidget {
  final List<UserInformation> allUsers;
  final List<UserInformation> allUsersForBlocked;
  final Map requestStatus;
  final List blockedUsers;
  final UserInformation userInfo;

  MatchScreen(this.userInfo, this.allUsers, this.requestStatus,
      this.blockedUsers, this.allUsersForBlocked);
  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  bool isPremium = false;

  bool isLoading = true;
  List<UserInformation> reqUser = [];
  List<UserInformation> allUsers = [];
  List<UserInformation> allUsersWithoutBlocked = [];
  List<UserInformation> acceptedUser = [];
  List<UserInformation> nearMeUsers = [];
  List<UserInformation> intrestedInMeUsers = [];
  List<String> profileVistors = [];
  List<UserInformation> visistorUsers = [];
  List<String> visitorsId = [];
  List<UserInformation> shortListedUsers = [];
  List<UserInformation> blockedUsers = [];
  List<UserInformation> newMatches = [];

  Future increaseContactAndUpdate(String id) async {
    FirebaseDatabase.instance
        .reference()
        .child('Contacts viewed')
        .child(widget.userInfo.id!)
        .update({'$id': true});
  }

  showPopUp(String id) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Container(
                child: Text(
                    'Do you really wants to use your one cotanct to see .'),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    increaseContactAndUpdate(id).then((value) {
                      Provider.of<ContactProvider>(context, listen: false)
                          .addContacts(id);
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(msg: 'Contact Unlocked');
                    });
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
              ],
            ));
  }

  getFavourites() {
    FirebaseDatabase.instance
        .reference()
        .child('FavUsers')
        .child(widget.userInfo.id!)
        .onValue
        .listen((event) {
      final snapShot = event.snapshot.value == null ? {} : event.snapshot.value as Map;
      if (snapShot.isNotEmpty) {
        favIds.clear();
        snapShot.forEach((key, value) {
          favIds.add(key);
        });
        shortListedUsers = [];
        widget.allUsers.forEach((element) {
          if (favIds.contains(element.id)) shortListedUsers.add(element);
        });
        setState(() {});
      } else {
        setState(() {
          favIds = [];
          shortListedUsers = [];
        });
      }
    });
  }

  setNewMatches() {
    DateTime dateTime = DateTime.now();
    widget.allUsers.forEach((element) {
      if (element.joinedOn!.difference(dateTime).inDays.abs() < 15) {
        newMatches.add(element);
      }
    });
  }

  setBlockedUsers() {
    blockedUsers = [];
    widget.allUsersForBlocked.forEach((element) {
      if (widget.blockedUsers.contains(element.id)) {
        blockedUsers.add(element);
      }
    });
  }

  Future getVisitors() async {
    final dta = await FirebaseDatabase.instance
        .reference()
        .child('Visitors')
        .child(widget.userInfo.id!)
        .once();

    if (dta.snapshot.value != null) {
      final usersId = dta.snapshot.value as Map;
      usersId.forEach((key, value) {
        visitorsId.add(key);
      });
      setState(() {});
    }
  }

  setProfileVisitors() {
    widget.allUsers.forEach((element) {
      if (visitorsId.contains(element.id)) visistorUsers.add(element);
    });
  }

  setNearMeUsers() {
    widget.allUsers.forEach((element) {
      if (element.state == currentUser!.state) {
        nearMeUsers.add(element);
      }
    });
  }

  removeBlockedUsers() {
    widget.allUsers.removeWhere((element) => widget.blockedUsers.contains(element.id));
  }

  UserInformation? currentUser;
  String id = "";
  bool fabIsVisible = false;
  bool isVerified = true;
  int matchLength = 0;
  @override
  void initState() {
    setData();
    isVerified = widget.userInfo.isVerified ?? true;
    setNewMatches();
    setIntrestedInMe();
    matchLength = matchedUsers.length;
    // adAt = random(startIndex, endIndex);
    tabController = new TabController(length: 8, vsync: this);
    tabController!.animateTo(1, duration: Duration(milliseconds: 0));
    controller = ScrollController();
    // isPremium = currentUser.premiumModel.isActive ?? false;
    controller!.addListener(() {
      if (fabIsVisible != controller!.offset > 55) {
        setState(() {
          fabIsVisible = controller!.offset > 55;
        });
      }
    });
    super.initState();
  }

  List<UserInformation> matchedUsers = [];

  List<UserInformation> filterPrefs() {
    List<UserInformation> users = [...widget.allUsers];
    for (UserInformation element in allUsers) {
      if (!PartnerInfo.matchPreferences(currentUser!.partnerInfo!, element)) {
        users.remove(element);
      }
    }
    return users;
  }

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
  }

  List favIds = [];
  String verifiedBy = "";
  List<String> acceptedUserIds = [];
  List<dynamic> contacts = [];
  setData() {
    id = widget.userInfo.id!;

    allUsers = widget.allUsers;
    final ref = Provider.of<UserRequests>(context, listen: false);
    currentUser = widget.userInfo;
    favIds = Provider.of<FavUsers>(context, listen: false).favUserIds;
    getFavourites();
    ref.setPendingData(allUsers);
    ref.setAcceptedData(allUsers);
    reqUser = ref.pendingUserData;
    acceptedUser = ref.acceptedUserData;
    acceptedUserIds = ref.acceptedUsers;
    getData();
    // setMatches();
    matchedUsers = filterPrefs();
    contacts = Provider.of<ContactProvider>(context, listen: false).contacts;
    setNearMeUsers();
    getVisitors().then((value) {
      setProfileVisitors();
    });
    setBlockedUsers();
    allUsersWithoutBlocked = [...allUsers];
  }

  void _showPopupMenu(double width, double height, List<PopupMenuItem> popupItem) async {
    await showMenu(
      color: Colors.black,
      context: context,
      position: RelativeRect.fromLTRB(
          width * .1, height * .57, width * .8, height * .08),
      items: popupItem,
      elevation: 8.0,
    );
  }

  random(min, max) {
    return min + Random().nextInt(max - min);
  }

  unblockBottomSheet(String blockId, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18), topRight: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 23, vertical: 12),
          child: GestureDetector(
            onTap: () {
              print(":::: $blockId");
              FirebaseDatabase.instance
                  .reference()
                  .child('User Information')
                  .child(blockId)
                  .child('Blocked By')
                  .child(widget.userInfo.id!)
                  .remove();

              FirebaseDatabase.instance
                  .reference()
                  .child('BlockedUsers')
                  .child(widget.userInfo.id!)
                  .child(blockId)
                  .remove()
                  .then((value) {
                Navigator.of(context).pop();
                Fluttertoast.showToast(msg: 'Successfully Removed');
              });
            },
            child: Row(
              children: [
                Icon(
                  MdiIcons.cancel,
                  size: 28,
                ),
                SizedBox(
                  width: 18,
                ),
                Text(
                  'UnBlock this Profile',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  setIntrestedInMe() {
    widget.allUsers.forEach((element) {
      if (element.manglik == currentUser!.manglik &&
          element.diet == element.diet &&
          element.motherTongue == element.motherTongue &&
          element.annualIncome == currentUser!.annualIncome) {
        intrestedInMeUsers.add(element);
      }
    });
  }

  ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
          backgroundColor: theme.colorBackground,
          body: NestedScrollView(
            controller: controller,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  actions: [
                    InkWell(
                      onTap: () {
                        Fluttertoast.showToast(msg: 'Waiting for Approval');
                      },
                      child: Icon(
                        MdiIcons.magnify,
                        size: 26,
                      ),
                    ),
                    SizedBox(
                      width: width * .04,
                    ),
                  ],
                  backgroundColor: theme.colorCompanion,
                  leading: InkWell(
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => DataScreen(),
                      //   ),
                      // );
                    },
                    child: Icon(
                      MdiIcons.genderMaleFemale,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Find Your Soulmate',
                    style: GoogleFonts.karla(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  pinned: false,
                  floating: false,
                  forceElevated: innerBoxIsScrolled,
                ),
                SliverAppBar(
                  toolbarHeight: (isVerified ? height * .05 + 36 : 20),
                  backgroundColor: theme.colorBackground,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: Column(
                    children: [
                      !isVerified
                          ? Container()
                          : Container(
                              padding:
                                  const EdgeInsets.only(bottom: 18, top: 6),
                              child: TabBar(
                                isScrollable: true,
                                labelPadding: EdgeInsets.only(
                                  left: 6,
                                  right: 6,
                                ),
                                unselectedLabelColor: Colors.black54,
                                labelColor: Colors.white,
                                indicatorSize: TabBarIndicatorSize.label,
                                indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: theme.colorCompanion,
                                ),
                                tabs: [
                                  Tab(
                                    child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorCompanion,
                                          width: 1,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            "All Users (${allUsersWithoutBlocked.length})"),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorCompanion,
                                          width: 1,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            "New Matches (${newMatches.length})"),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: theme.colorCompanion,
                                            width: 1),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child:
                                            Text("My Matches ($matchLength)"),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: theme.colorCompanion,
                                            width: 1),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            "Near Me (${nearMeUsers.length})"),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorCompanion,
                                          width: 1,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            "Profile Visitor (${visistorUsers.length})"),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorCompanion,
                                          width: 1,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            "Intrested in me (${intrestedInMeUsers.length})"),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    child: Container(
                                      height: 40,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.colorCompanion,
                                          width: 1,
                                        ),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            "Shortlisted (${shortListedUsers.length})"),
                                      ),
                                    ),
                                  ),
                                  Tab(
                                      child: Container(
                                    height: 40,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorCompanion,
                                        width: 1,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          "Blocked (${blockedUsers.length})"),
                                    ),
                                  )),
                                ],
                                controller: tabController,
                              ),
                            ),
                    ],
                  ),
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                ),
              ];
            },
            body: !isVerified
                ? Center(
                    child: Container(
                      child: Text(
                        'Waiting for Approval',
                        style: theme.text12bold,
                      ),
                    ),
                  )
                : Container(
                    child: Column(
                      children: [
                        Expanded(
                          child: TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              allUsersFunction(),
                              matches(),
                              myMatches(),
                              nearMe(),
                              profileVisitor(),
                              intrestedInMe(),
                              shortedListed(),
                              blockedUser(),
                            ],
                            controller: tabController,
                          ),
                        ),
                      ],
                    ),
                  ),
          )),
    );
  }

  removeBlocked() {
    allUsersWithoutBlocked
        .removeWhere((element) => widget.blockedUsers.contains(element.id));
  }

  // int startIndex = 5, endIndex = 8;
  allUsersFunction() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    removeBlocked();
    var users = allUsersWithoutBlocked;

    return Container(
      width: width,
      height: height * .8,
      child: users.length == 0
          ? Container(
              child: Center(
                child: Container(
                  child: Text(
                    'No Users as of now !',
                    style: theme.text12bold,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                List<PopupMenuItem> popupItem = [];
                popupItem = [];
                if (true) {
                  popupItem.add(
                    PopupMenuItem(
                        child: Text(
                          "Verified by",
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'verify'),
                  );
                }

                return PersonCard(
                  user: users[index],
                  users: users,
                  currentUserInfo: currentUser!,
                  isFavourite: favIds.contains(users[index].id),
                  isRequestSent:
                      widget.requestStatus.keys.contains(users[index].id),
                  index: index,
                );
              },
            ),
    );
  }

  removeMatches() {
    newMatches
        .removeWhere((element) => widget.blockedUsers.contains(element.id));
  }

  matches() {
    removeMatches();
    newMatches.sort((a, b) {
      return b.joinedOn!.compareTo(a.joinedOn!);
    });
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height * .8,
      child: newMatches.length == 0
          ? Container(
              child: Center(
                child: Container(
                  child: Text(
                    'No New Matches as of now !',
                    style: theme.text12bold,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: newMatches.length,
              itemBuilder: (context, index) {
                List<PopupMenuItem> popupItem = [];
                popupItem = [];
                if (newMatches[index].verifiedBy != null) {
                  popupItem.add(
                    PopupMenuItem(
                        child: Text(
                          newMatches[index].verifiedBy!,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'verify'),
                  );
                }

                return PersonCard(
                  user: newMatches[index],
                  users: newMatches,
                  currentUserInfo: currentUser!,
                  isFavourite: favIds.contains(newMatches[index].id),
                  isRequestSent:
                      widget.requestStatus.keys.contains(newMatches[index].id),
                  index: index,
                );
              },
            ),
    );
  }

  removeMatchedUsers() {
    matchedUsers
        .removeWhere((element) => widget.blockedUsers.contains(element.id));
  }

  myMatches() {
    removeMatchedUsers();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height * .8,
      child: matchedUsers.length == 0
          ? Container(
              child: Center(
                child: Container(
                  child: Text(
                    'No Matches as of now !',
                    style: theme.text12bold,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: matchLength,
              itemBuilder: (context, index) {
                List<PopupMenuItem> popupItem = [];
                popupItem = [];
                if (matchedUsers[index].verifiedBy != null) {
                  popupItem.add(
                    PopupMenuItem(
                        child: Text(
                          matchedUsers[index].verifiedBy!,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'Doge'),
                  );
                }

                return PersonCard(
                  user: matchedUsers[index],
                  users: matchedUsers,
                  currentUserInfo: currentUser!,
                  isFavourite: favIds.contains(matchedUsers[index].id),
                  isRequestSent: widget.requestStatus.keys
                      .contains(matchedUsers[index].id),
                  index: index,
                );
              },
            ),
    );
  }

  removeNearMeIfBlocked() {
    nearMeUsers
        .removeWhere((element) => widget.blockedUsers.contains(element.id));
  }

  nearMe() {
    removeNearMeIfBlocked();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height * .8,
      child: nearMeUsers.length == 0
          ? Container(
              child: Center(
                child: Container(
                  child: Text(
                    'No Nearby as of now !',
                    style: theme.text12bold,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: nearMeUsers.length,
              itemBuilder: (context, index) {
                List<PopupMenuItem> popupItem = [];
                popupItem = [];
                if (nearMeUsers[index].verifiedBy != null) {
                  popupItem.add(
                    PopupMenuItem(
                        child: Text(
                          nearMeUsers[index].verifiedBy!,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'verify'),
                  );
                }

                return PersonCard(
                  user: nearMeUsers[index],
                  users: nearMeUsers,
                  currentUserInfo: currentUser!,
                  isFavourite: favIds.contains(nearMeUsers[index].id),
                  isRequestSent:
                      widget.requestStatus.keys.contains(nearMeUsers[index].id),
                  index: index,
                );
              },
            ),
    );
  }

  removeProfileVisitors() {
    visistorUsers
        .removeWhere((element) => widget.blockedUsers.contains(element.id));
  }

  profileVisitor() {
    removeProfileVisitors();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height * .8,
      child: visistorUsers.length == 0
          ? Container(
              child: Center(
                child: Container(
                  child: Text(
                    'No Matches as of now !',
                    style: theme.text12bold,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: visistorUsers.length,
              itemBuilder: (context, index) {
                List<PopupMenuItem> popupItem = [];
                popupItem = [];
                if (visistorUsers[index].verifiedBy != null) {
                  popupItem.add(
                    PopupMenuItem(
                        child: Text(
                          visistorUsers[index].verifiedBy!,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'Doge'),
                  );
                }
                return PersonCard(
                  user: visistorUsers[index],
                  users: visistorUsers,
                  currentUserInfo: currentUser!,
                  isFavourite: favIds.contains(visistorUsers[index].id),
                  isRequestSent: widget.requestStatus.keys
                      .contains(visistorUsers[index].id),
                  index: index,
                );
              },
            ),
    );
  }

  removeFromIntrestedinMe() {
    intrestedInMeUsers
        .removeWhere((element) => widget.blockedUsers.contains(element.id));
  }

  intrestedInMe() {
    removeFromIntrestedinMe();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height * .8,
      child: intrestedInMeUsers.length == 0
          ? Container(
              child: Center(
                child: Container(
                  child: Text(
                    'No Matches as of now !',
                    style: theme.text12bold,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: intrestedInMeUsers.length,
              itemBuilder: (context, index) {
                List<PopupMenuItem> popupItem = [];
                popupItem = [];
                if (intrestedInMeUsers[index].verifiedBy != null) {
                  popupItem.add(
                    PopupMenuItem(
                        child: Text(
                          intrestedInMeUsers[index].verifiedBy!,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'Doge'),
                  );
                }

                return PersonCard(
                  user: intrestedInMeUsers[index],
                  users: intrestedInMeUsers,
                  currentUserInfo: currentUser!,
                  isFavourite: favIds.contains(intrestedInMeUsers[index].id),
                  isRequestSent: widget.requestStatus.keys
                      .contains(intrestedInMeUsers[index].id),
                  index: index,
                );
              },
            ),
    );
  }

  removeFromShortlisted() {
    shortListedUsers
        .removeWhere((element) => widget.blockedUsers.contains(element.id));
  }

  shortedListed() {
    removeFromShortlisted();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height * .8,
      child: shortListedUsers.length == 0
          ? Container(
              child: Center(
                child: Container(
                  child: Text(
                    'No Matches as of now !',
                    style: theme.text12bold,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: shortListedUsers.length,
              itemBuilder: (context, index) {
                List<PopupMenuItem> popupItem = [];
                popupItem = [];
                if (shortListedUsers[index].verifiedBy != null) {
                  popupItem.add(
                    PopupMenuItem(
                        child: Text(
                          shortListedUsers[index].verifiedBy!,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'Doge'),
                  );
                }

                return PersonCard(
                  user: shortListedUsers[index],
                  users: shortListedUsers,
                  currentUserInfo: currentUser!,
                  isFavourite: favIds.contains(shortListedUsers[index].id),
                  isRequestSent: widget.requestStatus.keys
                      .contains(shortListedUsers[index].id),
                  index: index,
                );
              },
            ),
    );
  }

  blockedUser() {
    setBlockedUsers();
    removeBlockedUsers();

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height * .8,
      child: blockedUsers.length == 0
          ? Container(
              child: Center(
                child: Container(
                  child: Text(
                    'No Blocked users as of now !',
                    style: theme.text12bold,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                List<PopupMenuItem> popupItem = [];
                popupItem = [];
                if (blockedUsers[index].verifiedBy != null) {
                  popupItem.add(
                    PopupMenuItem(
                        child: Text(
                          blockedUsers[index].verifiedBy!,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'Doge'),
                  );
                }
                String visibility;
                visibility = blockedUsers[index].visibility != null
                    ? blockedUsers[index].visibility!
                    : 'All Member';

                return Padding(
                  padding: EdgeInsets.only(
                    top: height * .01,
                    bottom: height * .01,
                    left: width * .04,
                    right: width * .04,
                  ),
                  child: InkWell(
                    onTap: () {
                      // if (visibility == 'All Member' ||
                      //     (visibility == 'Premium Members only' && isPremium)) {
                      //  }
                    },
                    child: visibility == 'All Member' ||
                            (visibility == 'Premium Members only' && isPremium)
                        ? Container(
                            height: height * .63,
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    blockedUsers[index].imageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [Colors.black12, Colors.black54],
                                  begin: Alignment.center,
                                  stops: [0.4, 1],
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  blockedUsers[index].isPremium!
                                      ? Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10)),
                                                color: theme.colorPrimary),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Icon(MdiIcons.crown,
                                                      color: Colors.white),
                                                  Text('Premium',
                                                      style:
                                                          GoogleFonts.workSans(
                                                              color: Colors
                                                                  .white)),
                                                ],
                                              ),
                                            ),
                                          ))
                                      : Container(),
                                  Positioned(
                                    right: 25,
                                    top: height * .07,
                                    child: InkWell(
                                      onTap: () {
                                        // unblockBottomSheet(
                                        //     blockedUsers[index].id, index);
                                        bottomSheet(context,
                                            blockedUsers[index], currentUser!,
                                            isBlocked: true);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          color: Colors.black45,
                                        ),
                                        child: Icon(
                                          MdiIcons.dotsHorizontal,
                                          color: Colors.white,
                                          size: 23,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 10,
                                    left: 20,
                                    bottom: 10,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            blockedUsers[index].isGovIdVerified!
                                                ? InkWell(
                                                    onTap: () {
                                                      _showPopupMenu(width,
                                                          height, popupItem);
                                                    },
                                                    child: Container(
                                                      height: height * .04,
                                                      width: width * .1,
                                                      child: Image.asset(
                                                        'assets/govVerifycheck.png',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  )
                                                : InkWell(
                                                    onTap: () {
                                                      _showPopupMenu(width,
                                                          height, popupItem);
                                                    },
                                                    child: Container(
                                                      height: height * .04,
                                                      width: width * .1,
                                                      child: Image.asset(
                                                        'assets/verified.png',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              blockedUsers[index]
                                                      .name!
                                                      .toUpperCase() ??
                                                  "",
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: height * .005,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              blockedUsers[index].height ?? '',
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * .03,
                                            ),
                                            Text(
                                              calculateAge(blockedUsers[index]
                                                          .dateOfBirth!)
                                                      .toString() +
                                                  " yrs",
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * .03,
                                            ),
                                            Text(
                                              blockedUsers[index].city ?? '',
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: height * .005,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              blockedUsers[index]
                                                      .highestQualification ??
                                                  '',
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * .03,
                                            ),
                                            Text(
                                              blockedUsers[index].workingAs ??
                                                  '',
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: height * .015,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              blockedUsers[index]
                                                      .maritalStatus ??
                                                  '',
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * .03,
                                            ),
                                            Text(
                                              blockedUsers[index].religion ??
                                                  '',
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
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
                          )
                        : visibility == 'Connected Members'
                            ? Container(
                                height: height * .63,
                                width: width * .92,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        blockedUsers[index].imageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10)),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10.0, sigmaY: 10.0),
                                        child: Container(),
                                      ),
                                    ),
                                    Positioned(
                                      top: height * .2,
                                      left: width * .13,
                                      child: Column(
                                        children: [
                                          Icon(
                                            MdiIcons.lock,
                                            color: Colors.white60,
                                            size: 50,
                                          ),
                                          SizedBox(
                                            height: height * .02,
                                          ),
                                          Text(
                                            'Images will be Visible\nAfter you Connect with Each Other',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(
                                            height: height * .02,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: height * .63,
                                      width: width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black12,
                                              Colors.black54
                                            ],
                                            begin: Alignment.center,
                                            stops: [0.4, 1],
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            blockedUsers[index].isPremium!
                                                ? Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10)),
                                                          color: theme
                                                              .colorPrimary),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: [
                                                            Icon(MdiIcons.crown,
                                                                color: Colors
                                                                    .white),
                                                            Text('Premium',
                                                                style: GoogleFonts
                                                                    .workSans(
                                                                        color: Colors
                                                                            .white)),
                                                          ],
                                                        ),
                                                      ),
                                                    ))
                                                : Container(),
                                            Positioned(
                                              right: 25,
                                              top: height * .07,
                                              child: InkWell(
                                                onTap: () {
                                                  /* unblockBottomSheet(
                                                      blockedUsers[index].id,
                                                      index); */
                                                  bottomSheet(
                                                      context,
                                                      blockedUsers[index],
                                                      currentUser!,
                                                      isBlocked: true);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      30,
                                                    ),
                                                    color: Colors.black45,
                                                  ),
                                                  child: Icon(
                                                    MdiIcons.dotsHorizontal,
                                                    color: Colors.white,
                                                    size: 23,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 10,
                                              left: 20,
                                              bottom: 10,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        blockedUsers[index]
                                                            .name!
                                                            .toUpperCase(),
                                                        style:
                                                            GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * .03,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: height * .005,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        blockedUsers[index]
                                                                .height ??
                                                            '',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * .03,
                                                      ),
                                                      Text(
                                                        calculateAge(blockedUsers[
                                                                            index]
                                                                        .dateOfBirth ??
                                                                    '')
                                                                .toString() +
                                                            " yrs",
                                                        style:
                                                            GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * .03,
                                                      ),
                                                      Text(
                                                        blockedUsers[index]
                                                                .city ??
                                                            '',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: height * .005,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        blockedUsers[index]
                                                                .highestQualification ??
                                                            '',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * .03,
                                                      ),
                                                      Text(
                                                        blockedUsers[index]
                                                                .workingAs ??
                                                            '',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: height * .015,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        blockedUsers[index]
                                                                .maritalStatus ??
                                                            '',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: width * .03,
                                                      ),
                                                      Text(
                                                        blockedUsers[index]
                                                                .religion ??
                                                            '',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14,
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
                                  ],
                                ),
                              )
                            : Container(
                                height: height * .63,
                                width: width * .92,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        blockedUsers[index].imageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 10.0, sigmaY: 10.0),
                                        child: Container(),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          MdiIcons.lock,
                                          color: Colors.white60,
                                          size: 50,
                                        ),
                                        SizedBox(
                                          height: height * .02,
                                        ),
                                        Text(
                                          'To Unlock Photos',
                                          style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * .02,
                                        ),
                                        isPremium
                                            ? Container()
                                            : InkWell(
                                                onTap: () {},
                                                child: Center(
                                                  child: Container(
                                                    width: width * .45,
                                                    height: height * .053,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            theme.colorPrimary,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      'Go Premium Now',
                                                      style: GoogleFonts.ptSans(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            theme.colorPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                  ),
                );
              },
            ),
    );
  }

  bool gotData = false;

  getData() async {
    final data = await FirebaseDatabase.instance
        .reference()
        .child('trash')
        .orderByChild('mobileNo')
        .equalTo('+917828464204')
        .once();
    if (data.snapshot.value != null) {
      gotData = true;
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

}

int calculateAge(String dobirth) {
  var now = DateTime.now();
  final DateFormat format = new DateFormat("dd/MMM/yyyy");
  var dob = format.parse(dobirth);
  return (now.difference(dob).inDays ~/ 365);
}
