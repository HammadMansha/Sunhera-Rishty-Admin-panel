import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/PersonCard.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/SocialMediaChatRoom.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/BlockedUsersProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/contactsProvider.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

class InboxScreen extends StatefulWidget {
  final List<UserInformation>? accepted;
  final List<UserInformation>? pending;
  final int? initialIndex;
  final UserInformation? userInfo;
  final List<UserInformation>? allUsers;
  InboxScreen(this.userInfo, this.allUsers,
      {this.accepted, this.pending, this.initialIndex = 0});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  bool isLoading = false;
  List<UserInformation> reqUser = [];
  String? id;
  List<UserInformation> allUsers = [];
  UserInformation? userInfo;
  bool isPremium = false;

  BlockedUsersProvider? blockedUsersProvider;
  @override
  void initState() {
    setData();
    blockedUsersProvider =
        Provider.of<BlockedUsersProvider>(context, listen: false);
    tabController = new TabController(
        length: 4, vsync: this, initialIndex: widget.initialIndex!);
    super.initState();
  }

  _acceptReject(double width, double height, String id, String name) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      // ignore: deprecated_member_use
      MaterialButton(
        color: Colors.green[400],
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          FirebaseDatabase.instance
              .reference()
              .child('Connection Requests')
              .child(widget.userInfo!.id!)
              .update({id: true});
          FirebaseDatabase.instance
              .reference()
              .child('Connection Requests')
              .child(id)
              .update({widget.userInfo!.id!: true}).then((value) {
            setState(() {
              isLoading = false;
            });
            sendNotificationsByUserID(id, name, 'Accepted your request',
                userId: widget.userInfo!.id!,
                target: Constants.USER_ACCEPT_REQUEST);
            if (reqUser.length == 1) {
              setState(() {
                reqUser.clear();
              });
            }
          });
        },
        child: Text(
          'Accept',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      // ignore: deprecated_member_use
      MaterialButton(
        color: Colors.red[400],
        onPressed: () {
          FirebaseDatabase.instance
              .reference()
              .child('Connection Requests')
              .child(widget.userInfo!.id!)
              .child(id)
              .remove()
              .then((value) {
            setState(() {
              sendNotificationsByUserID(
                  id, 'Declined', userInfo!.name! + ' declined your request');
              isLoading = false;
            });
            if (reqUser.length == 1) {
              setState(() {
                reqUser.clear();
              });
            }
          });
          FirebaseDatabase.instance
              .reference()
              .child('deleted')
              .child(id)
              .update({widget.userInfo!.id!: true});
        },
        child: Text(
          'Reject',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    ]);
  }

  List<String> sentIDs = [];
  List<UserInformation> sentRequestUsers = [];
  getSentRequest() {
    FirebaseDatabase.instance
        .reference()
        .child('userReq')
        .child(widget.userInfo!.id!)
        .onValue
        .listen((event) {
      sentIDs.clear();
      sentRequestUsers.clear();
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        data.forEach((key, value) {
          sentIDs.add(key);
        });
        sentIDs.removeWhere((element) =>
            acceptedIDs.contains(element) || pendingIDs.contains(element));
        allUsers.forEach((element) {
          if (sentIDs.contains(element.id)) {
            sentRequestUsers.add(element);
          }
        });
      }
      setState(() {});
    });
  }

  List<String> deletedIDs = [];
  List<UserInformation> deletedUsers = [];
  getDeletedRequest() {
    FirebaseDatabase.instance
        .reference()
        .child('deleted')
        .child(widget.userInfo!.id!)
        .onValue
        .listen((event) {
      deletedIDs.clear();
      deletedUsers.clear();
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        data.forEach((key, value) {
          deletedIDs.add(key);
        });
        allUsers.forEach((element) {
          if (deletedIDs.contains(element.id)) {
            deletedUsers.add(element);
          }
        });
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
  }

  List<dynamic> contacts = [];

  List<String> acceptedIDs = [];
  List<String> pendingIDs = [];
  List<UserInformation> acceptedUsers = [];
  List<UserInformation> pendingUsers = [];
  getRequestStatus() {
    acceptedUsers.addAll(widget.accepted!);
    pendingUsers.addAll(widget.pending!);
    FirebaseDatabase.instance
        .reference()
        .child('Connection Requests')
        .child(widget.userInfo!.id!)
        .onValue
        .listen((event) {
      pendingUsers.clear();
      acceptedUsers.clear();
      acceptedIDs.clear();
      pendingIDs.clear();
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;

        data.forEach((key, value) {
          if (value is bool) {
            if (value) {
              acceptedIDs.add(key);
            } else {
              pendingIDs.add(key);
            }
          } else {
            Map data = value as Map;
            if (data['accepted']) {
              pendingIDs.add(key);
            } else {
              pendingIDs.add(key);
            }
          }
        });
        allUsers.forEach((element) {
          if (acceptedIDs.contains(element.id)) {
            acceptedUsers.add(element);
          } else if (pendingIDs.contains(element.id)) {
            pendingUsers.add(element);
          }
        });
      }
      setState(() {});

      sentIDs.removeWhere((element) =>
          acceptedIDs.contains(element) || pendingIDs.contains(element));
      sentRequestUsers.clear();
      allUsers.forEach((element) {
        if (sentIDs.contains(element.id)) {
          sentRequestUsers.add(element);
        }
      });
      setState(() {});
    });
  }

  setData() {
    id = widget.userInfo!.id;
    allUsers = widget.allUsers!;
    userInfo = widget.userInfo;
    getRequestStatus();
    getSentRequest();
    getDeletedRequest();

    contacts = Provider.of<ContactProvider>(context, listen: false).contacts;
    isPremium = userInfo!.premiumModel!.isActive != null
        ? userInfo!.premiumModel!.isActive!
        : false;
  }

  Future increaseContactAndUpdate(String id) async {
    FirebaseDatabase.instance
        .reference()
        .child('Contacts viewed')
        .child(widget.userInfo!.id!)
        .update({'$id': true});
  }

  showPopUp(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Container(
          child: Text('Do you really wants to use your one cotanct to see .'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              increaseContactAndUpdate(id).then((value) {
                //  contacts.add(id);
                log('working');
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
      ),
    );
  }

  Widget _removePopup(String acceptedUserId) => ElevatedButton(
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          final db = FirebaseDatabase.instance.reference();

          db.child('userReq').child(id!).child(acceptedUserId).remove();

          db
              .child('deleted')
              .child(acceptedUserId)
              .update({'${widget.userInfo!.id}': true});
          db.child('userReq').child(acceptedUserId).child(id!).remove();
          db.child('myMatches').child(id!).update({"$acceptedUserId": true});
          db.child('myMatches').child(acceptedUserId).update({id!: true});
          db
              .child('Connection Requests')
              .child(acceptedUserId)
              .child(id!)
              .remove()
              .then((value) {
            setState(() {
              isLoading = false;
            });
          });
          db
              .child('Connection Requests')
              .child(id!)
              .child(acceptedUserId)
              .remove()
              .then((value) {
            setState(() {
              if (acceptedUsers.length == 1 && pendingUsers.length == 0) {
                acceptedUsers.clear();
              }
            });
          });
        },
        child: Text("Remove"),
      );

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  bottom: 12,
                  top: height * .015,
                ),
                width: width,
                color: Colors.white,
                alignment: Alignment.center,
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
                        height: height * .05,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorCompanion,
                            width: 1,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Received (${pendingUsers.length})"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        height: height * .05,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: theme.colorCompanion, width: 1),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("Accepted (${acceptedUsers.length})"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        height: height * .05,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: theme.colorCompanion, width: 1),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              "Sent requests (${sentRequestUsers.length})"),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        height: height * .05,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: theme.colorCompanion, width: 1)),
                        child: Align(
                          alignment: Alignment.center,
                          child:
                              Text("Deleted requests (${deletedUsers.length})"),
                        ),
                      ),
                    ),
                  ],
                  controller: tabController,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: HexColor('b3e5fc'),
                ),
                width: width,
                height: height * .045,
                alignment: Alignment.center,
                child: Text(
                  'IF YOU HAVEN’T FOUND IT YET, KEEP LOOKING.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    requestCard(),
                    acceptedCard(),
                    sentRequest(),
                    deletedRequest()
                  ],
                  controller: tabController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  acceptedCard() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return acceptedUsers.length == 0
        ? Center(
            child: Text(
              'No requests as of now !',
              style: GoogleFonts.ptSans(
                fontSize: 14,
              ),
            ),
          )
        : Container(
            width: width,
            height: height * .742,
            child: ListView.builder(
              itemCount: acceptedUsers.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (blockedUsersProvider!
                        .isBlocked(acceptedUsers[index].id!)) {
                      Fluttertoast.showToast(
                          msg: "You've been blocked by this user");
                      return;
                    }
                  },
                  child: Stack(
                    children: [
                      Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * .015,
                              ),
                              CircleAvatar(
                                radius: 80,
                                backgroundImage: CachedNetworkImageProvider(
                                    acceptedUsers[index].imageUrl ?? ""),
                              ),
                              SizedBox(
                                height: height * .02,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    acceptedUsers[index].name!.toUpperCase() ??
                                        '',
                                    style: GoogleFonts.ptSans(
                                      color: theme.colorPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${acceptedUsers[index].height ?? 'height'} ',
                                    style: GoogleFonts.ptSans(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * .03,
                                  ),
                                  Text(
                                    ' ${acceptedUsers[index].workingAs ?? 'designation'}',
                                    style: GoogleFonts.ptSans(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .005,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${acceptedUsers[index].motherTongue ?? 'not provided'}',
                                    style: GoogleFonts.ptSans(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * .03,
                                  ),
                                  Text(
                                    '${acceptedUsers[index].state ?? 'State'}, ${acceptedUsers[index].city ?? 'City'}',
                                    style: GoogleFonts.ptSans(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .01,
                              ),
                              Divider(
                                thickness: 1,
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
                                      if (isPremium) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SocialMediaChat(
                                                      uid: widget
                                                          .accepted![index].id!,
                                                      data: widget
                                                          .accepted![index],thisUser: UserInformation(),
                                                    )));
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Not a premium user");
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              MdiIcons.chat,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Text',
                                          style: GoogleFonts.workSans(
                                              fontSize: 13),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (acceptedUsers[index].hideContact!) {
                                        Fluttertoast.showToast(
                                            msg: 'Contact is hidden by user');
                                        return;
                                      }
                                      if (blockedUsersProvider!
                                          .isBlocked(acceptedUsers[index].id!)) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "You've been blocked by this user");
                                        return;
                                      }

                                      if (contacts.contains(
                                              acceptedUsers[index].id) &&
                                          isPremium) {
                                        if ((contacts != null &&
                                                contacts.length <
                                                    userInfo!.premiumModel!
                                                        .contact!) ||
                                            contacts.contains(
                                                acceptedUsers[index].id))
                                          launchWhatsApp(
                                              acceptedUsers[index].phone!,
                                              widget.userInfo!);
                                        else {
                                          Fluttertoast.showToast(
                                              msg: 'You have exceed the plan');
                                        }
                                      } else if (isPremium) {
                                        if (contacts != null &&
                                            contacts.length <
                                                userInfo!.premiumModel!.contact!)
                                          showPopUp(acceptedUsers[index].id!);
                                        else
                                          Fluttertoast.showToast(
                                              msg: 'You have exceed the plan');
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Not a premium user");
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              MdiIcons.whatsapp,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'WhatsApp',
                                          style: GoogleFonts.workSans(
                                              fontSize: 13),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (acceptedUsers[index].hideContact!) {
                                        Fluttertoast.showToast(
                                            msg: 'Contact is hidden by user');
                                        return;
                                      }
                                      if (blockedUsersProvider!
                                          .isBlocked(acceptedUsers[index].id!)) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "You've been blocked by this user");
                                        return;
                                      }
                                      if (contacts.contains(
                                              acceptedUsers[index].id) &&
                                          isPremium) {
                                        if ((contacts != null &&
                                                contacts.length <
                                                    userInfo!.premiumModel!
                                                        .contact!) ||
                                            contacts.contains(
                                                acceptedUsers[index].id))
                                          launch(
                                              "tel://${acceptedUsers[index].phone}");
                                        else {
                                          Fluttertoast.showToast(
                                              msg: 'You have exceed the plan');
                                        }
                                      } else if (isPremium) {
                                        if (contacts != null &&
                                            contacts.length <
                                                userInfo!.premiumModel!.contact!)
                                          showPopUp(acceptedUsers[index].id!);
                                        else
                                          Fluttertoast.showToast(
                                              msg: 'You have exceed the plan');
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Not a premium user");
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.blue[300],
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              MdiIcons.phone,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Call',
                                          style: GoogleFonts.workSans(
                                              fontSize: 13),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: height * .02,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                          top: height * .02,
                          right: width * .09,
                          child: _removePopup(acceptedUsers[index].id!)),
                    ],
                  ),
                );
              },
            ),
          );
  }

  deletedRequest() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return deletedUsers.length == 0
        ? Center(
            child: Text(
              'No requests sent !',
              style: GoogleFonts.ptSans(
                // color: Colors.white,
                fontSize: 14,
              ),
            ),
          )
        : Container(
            width: width,
            height: height * .742,
            child: ListView.builder(
              itemCount: deletedUsers.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (blockedUsersProvider!
                        .isBlocked(deletedUsers[index].id!)) {
                      Fluttertoast.showToast(
                          msg: "You've been blocked by this user");
                      return;
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(
                            height: height * .015,
                          ),
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: CachedNetworkImageProvider(
                                deletedUsers[index].imageUrl ?? ""),
                          ),
                          SizedBox(
                            height: height * .02,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                deletedUsers[index].name!.toUpperCase() ?? '',
                                style: GoogleFonts.ptSans(
                                  color: theme.colorPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${deletedUsers[index].height ?? 'height'} ',
                                style: GoogleFonts.ptSans(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: width * .03,
                              ),
                              Text(
                                ' ${deletedUsers[index].workingAs ?? 'designation'}',
                                style: GoogleFonts.ptSans(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height * .005,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${deletedUsers[index].motherTongue ?? 'not provided'}',
                                style: GoogleFonts.ptSans(
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: width * .03,
                              ),
                              Text(
                                '${deletedUsers[index].state ?? 'State'}, ${deletedUsers[index].city ?? 'City'}',
                                style: GoogleFonts.ptSans(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (isPremium) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SocialMediaChat(
                                                  uid: deletedUsers[index].id!,
                                                  data: deletedUsers[index],
                                                    thisUser: UserInformation()
                                                )));
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Not a premium user");
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          MdiIcons.chat,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Text',
                                      style: GoogleFonts.workSans(fontSize: 13),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (deletedUsers[index].hideContact!) {
                                    Fluttertoast.showToast(
                                        msg: 'Contact is hidden by user');
                                    return;
                                  }
                                  if (blockedUsersProvider!
                                      .isBlocked(deletedUsers[index].id!)) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You've been blocked by this user");
                                    return;
                                  }

                                  if (contacts
                                          .contains(deletedUsers[index].id) &&
                                      isPremium) {
                                    if ((contacts != null &&
                                            contacts.length <
                                                userInfo!
                                                    .premiumModel!.contact!) ||
                                        contacts
                                            .contains(deletedUsers[index].id))
                                      launchWhatsApp(deletedUsers[index].phone!,
                                          widget.userInfo!);
                                    else {
                                      Fluttertoast.showToast(
                                          msg: 'You have exceed the plan');
                                    }
                                  } else if (isPremium) {
                                    if (contacts != null &&
                                        contacts.length <
                                            userInfo!.premiumModel!.contact!)
                                      showPopUp(deletedUsers[index].id!);
                                    else
                                      Fluttertoast.showToast(
                                          msg: 'You have exceed the plan');
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Not a premium user");
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          MdiIcons.whatsapp,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'WhatsApp',
                                      style: GoogleFonts.workSans(fontSize: 13),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (deletedUsers[index].hideContact!) {
                                    Fluttertoast.showToast(
                                        msg: 'Contact is hidden by user');
                                    return;
                                  }
                                  if (blockedUsersProvider!
                                      .isBlocked(deletedUsers[index].id!)) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You've been blocked by this user");
                                    return;
                                  }
                                  if (contacts
                                          .contains(deletedUsers[index].id) &&
                                      isPremium) {
                                    if ((contacts != null &&
                                            contacts.length <
                                                userInfo!
                                                    .premiumModel!.contact!) ||
                                        contacts
                                            .contains(deletedUsers[index].id))
                                      launch(
                                          "tel://${deletedUsers[index].phone}");
                                    else {
                                      Fluttertoast.showToast(
                                          msg: 'You have exceed the plan');
                                    }
                                  } else if (isPremium) {
                                    if (contacts != null &&
                                        contacts.length <
                                            userInfo!.premiumModel!.contact!)
                                      showPopUp(deletedUsers[index].id!);
                                    else
                                      Fluttertoast.showToast(
                                          msg: 'You have exceed the plan');
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Not a premium user");
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.blue[300],
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          MdiIcons.phone,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Call',
                                      style: GoogleFonts.workSans(fontSize: 13),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: height * .02,
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

  sentRequest() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return sentRequestUsers.length == 0
        ? Center(
            child: Text(
              'No requests sent !',
              style: GoogleFonts.ptSans(
                // color: Colors.white,
                fontSize: 14,
              ),
            ),
          )
        : Container(
            width: width,
            height: height * .742,
            child: ListView.builder(
              itemCount: sentRequestUsers.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (blockedUsersProvider!
                        .isBlocked(sentRequestUsers[index].id!)) {
                      Fluttertoast.showToast(
                          msg: "You've been blocked by this user");
                      return;
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(
                            height: height * .015,
                          ),
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: CachedNetworkImageProvider(
                                sentRequestUsers[index].imageUrl ?? ""),
                          ),
                          SizedBox(
                            height: height * .02,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sentRequestUsers[index].name!.toUpperCase() ??
                                    '',
                                style: GoogleFonts.ptSans(
                                  color: theme.colorPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${sentRequestUsers[index].height ?? 'height'} ',
                                style: GoogleFonts.ptSans(
                                  // color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: width * .03,
                              ),
                              Text(
                                ' ${sentRequestUsers[index].workingAs ?? 'designation'}',
                                style: GoogleFonts.ptSans(
                                  // color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: height * .005,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${sentRequestUsers[index].motherTongue ?? 'not provided'}',
                                style: GoogleFonts.ptSans(
                                  // color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: width * .03,
                              ),
                              Text(
                                '${sentRequestUsers[index].state ?? 'State'}, ${sentRequestUsers[index].city ?? 'City'}',
                                style: GoogleFonts.ptSans(
                                  // color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: height * .01,
                          ),
                          MaterialButton(
                            color: Colors.red[400],
                            onPressed: () {
                              final String id = widget.userInfo!.id!;
                              bool? req1, req2, req3;
                              FirebaseDatabase.instance
                                  .reference()
                                  .child('Connection Requests')
                                  .child(sentRequestUsers[index].id!)
                                  .child(id)
                                  .remove()
                                  .then((value) {
                                req1 = true;
                                if (req1! && req2! && req3!) {
                                  Fluttertoast.showToast(
                                      msg: 'Request cancelled.');
                                }
                              });
                              FirebaseDatabase.instance
                                  .reference()
                                  .child('userReq')
                                  .child(sentRequestUsers[index].id!)
                                  .child(id)
                                  .remove()
                                  .then((value) {
                                req2 = true;
                                if (req1! && req2! && req3!) {
                                  Fluttertoast.showToast(
                                      msg: 'Request cancelled.');
                                }
                              });
                              FirebaseDatabase.instance
                                  .reference()
                                  .child('userReq')
                                  .child(id)
                                  .child(sentRequestUsers[index].id!)
                                  .remove()
                                  .then((value) {
                                req3 = true;
                                if (req1! && req2! && req3!) {
                                  Fluttertoast.showToast(
                                      msg: 'Request cancelled.');
                                }
                              });
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: height * .01,
                          ),
                          Divider(thickness: 1),
                          // SizedBox(
                          //   height: height * .03,
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (isPremium) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SocialMediaChat(
                                                  uid: sentRequestUsers[index].id!,
                                                  data: sentRequestUsers[index],
                                                  thisUser: UserInformation(),
                                                )));
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Not a premium user");
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          MdiIcons.chat,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Text',
                                      style: GoogleFonts.workSans(fontSize: 13),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (sentRequestUsers[index].hideContact!) {
                                    Fluttertoast.showToast(
                                        msg: 'Contact is hidden by user');
                                    return;
                                  }
                                  if (blockedUsersProvider!
                                      .isBlocked(sentRequestUsers[index].id!)) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You've been blocked by this user");
                                    return;
                                  }
                                  if (contacts.contains(
                                          sentRequestUsers[index].id) &&
                                      isPremium) {
                                    if ((contacts != null &&
                                            contacts.length <
                                                userInfo!
                                                    .premiumModel!.contact!) ||
                                        contacts.contains(
                                            sentRequestUsers[index].id))
                                      launchWhatsApp(
                                          sentRequestUsers[index].phone!,
                                          widget.userInfo!);
                                    else {
                                      Fluttertoast.showToast(
                                          msg: 'You have exceed the plan');
                                    }
                                  } else if (isPremium) {
                                    if (contacts != null &&
                                        contacts.length <
                                            userInfo!.premiumModel!.contact!)
                                      showPopUp(sentRequestUsers[index].id!);
                                    else
                                      Fluttertoast.showToast(
                                          msg: 'You have exceed the plan');
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Not a premium user");
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          MdiIcons.whatsapp,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'WhatsAppp',
                                      style: GoogleFonts.workSans(fontSize: 13),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (sentRequestUsers[index].hideContact!) {
                                    Fluttertoast.showToast(
                                        msg: 'Contact is hidden by user');
                                    return;
                                  }
                                  if (blockedUsersProvider!
                                      .isBlocked(sentRequestUsers[index].id!)) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "You've been blocked by this user");
                                    return;
                                  }
                                  if (contacts.contains(
                                          sentRequestUsers[index].id) &&
                                      isPremium) {
                                    if ((contacts != null &&
                                            contacts.length <
                                                userInfo!
                                                    .premiumModel!.contact!) ||
                                        contacts.contains(
                                            sentRequestUsers[index].id))
                                      launch(
                                          "tel://${sentRequestUsers[index].phone}");
                                    else {
                                      Fluttertoast.showToast(
                                          msg: 'You have exceed the plan');
                                    }
                                  } else if (isPremium) {
                                    if (contacts != null &&
                                        contacts.length <
                                            userInfo!.premiumModel!.contact!)
                                      showPopUp(sentRequestUsers[index].id!);
                                    else
                                      Fluttertoast.showToast(
                                          msg: 'You have exceed the plan');
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Not a premium user");
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.blue[300],
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          MdiIcons.phone,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Call',
                                      style: GoogleFonts.workSans(fontSize: 13),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),

                          SizedBox(
                            height: height * .02,
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

  requestCard() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return pendingUsers.length == 0
        ? Center(
            child: Text(
              'No requests as of now !',
              style: GoogleFonts.ptSans(
                fontSize: 14,
              ),
            ),
          )
        : Container(
            width: width,
            height: height * .8,
            child: ListView.builder(
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (blockedUsersProvider!
                        .isBlocked(pendingUsers[index].id!)) {
                      Fluttertoast.showToast(
                          msg: "You've been blocked by this user");
                      return;
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 140,
                                backgroundImage: CachedNetworkImageProvider(
                                    pendingUsers[index].imageUrl ?? ""),
                              ),
                              SizedBox(
                                height: height * .02,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    pendingUsers[index].name!.toUpperCase() ??
                                        '',
                                    style: GoogleFonts.ptSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${pendingUsers[index].height ?? 'height'} ',
                                    style: GoogleFonts.ptSans(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * .03,
                                  ),
                                  Container(
                                    width: width * .5,
                                    child: Text(
                                      ' ${pendingUsers[index].workingAs ?? 'designation'}',
                                      overflow: TextOverflow.fade,
                                      maxLines: 1,
                                      style: GoogleFonts.ptSans(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .005,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${pendingUsers[index].motherTongue ?? 'not provided'}',
                                    style: GoogleFonts.ptSans(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * .03,
                                  ),
                                  Text(
                                    '${pendingUsers[index].state ?? 'State'}, ${pendingUsers[index].city ?? 'City'}',
                                    style: GoogleFonts.ptSans(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              _acceptReject(height, width,
                                  pendingUsers[index].id!, userInfo!.name!),
                              Divider(
                                thickness: 1,
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
                                      if (isPremium) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SocialMediaChat(
                                              uid: pendingUsers[index].id!,
                                              data: pendingUsers[index],
                                              thisUser: UserInformation(),
                                            ),
                                          ),
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Not a premium user");
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              MdiIcons.chat,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Text',
                                          style: GoogleFonts.workSans(
                                              fontSize: 13),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (pendingUsers[index].hideContact!) {
                                        Fluttertoast.showToast(
                                            msg: 'Contact is hidden by user');
                                        return;
                                      }
                                      if (blockedUsersProvider!
                                          .isBlocked(pendingUsers[index].id!)) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "You've been blocked by this user");
                                        return;
                                      }

                                      if (contacts.contains(
                                              pendingUsers[index].id) &&
                                          isPremium) {
                                        if ((contacts != null &&
                                                contacts.length <
                                                    userInfo!.premiumModel!
                                                        .contact!) ||
                                            contacts.contains(
                                                pendingUsers[index].id))
                                          launchWhatsApp(
                                              pendingUsers[index].phone!,
                                              widget.userInfo!);
                                        else {
                                          Fluttertoast.showToast(
                                              msg: 'You have exceed the plan');
                                        }
                                      } else if (isPremium) {
                                        if (contacts != null &&
                                            contacts.length <
                                                userInfo!.premiumModel!.contact!)
                                          showPopUp(pendingUsers[index].id!);
                                        else
                                          Fluttertoast.showToast(
                                              msg: 'You have exceed the plan');
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Not a premium user");
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              MdiIcons.whatsapp,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'WhatsApp',
                                          style: GoogleFonts.workSans(
                                              fontSize: 13),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (pendingUsers[index].hideContact!) {
                                        Fluttertoast.showToast(
                                            msg: 'Contact is hidden by user');
                                        return;
                                      }
                                      if (blockedUsersProvider!
                                          .isBlocked(pendingUsers[index].id!)) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "You've been blocked by this user");
                                        return;
                                      }

                                      if (contacts.contains(
                                              pendingUsers[index].id) &&
                                          isPremium) {
                                        if ((contacts != null &&
                                                contacts.length <
                                                    userInfo!.premiumModel!
                                                        .contact!) ||
                                            contacts.contains(
                                                pendingUsers[index].id))
                                          launch(
                                              "tel://${pendingUsers[index].phone}");
                                        else {
                                          Fluttertoast.showToast(
                                              msg: 'You have exceed the plan');
                                        }
                                      } else if (isPremium) {
                                        if (contacts != null &&
                                            contacts.length <
                                                userInfo!.premiumModel!.contact!)
                                          showPopUp(pendingUsers[index].id!);
                                        else
                                          Fluttertoast.showToast(
                                              msg: 'You have exceed the plan');
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Not a premium user");
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue[300],
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              MdiIcons.phone,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Call',
                                          style: GoogleFonts.workSans(
                                              fontSize: 13),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: height * .02,
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
}
