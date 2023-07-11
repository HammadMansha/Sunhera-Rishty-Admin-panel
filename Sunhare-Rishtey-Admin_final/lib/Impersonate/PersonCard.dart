import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/ConnectionProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/contactsProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/favouriteUserProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/SocialMediaChatRoom.dart';
import 'package:sunhare_rishtey_new_admin/Screens/UserInformationScreen.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/main.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class PersonCard extends StatefulWidget {
  final UserInformation user;
  final UserInformation currentUserInfo;
  final bool isFavourite;
  final bool isRequestSent;
  final List<UserInformation> users;
  final int index;

  PersonCard(
      {required this.user,
      required this.currentUserInfo,
      required this.isFavourite,
      required this.isRequestSent,
      required this.users,
      required this.index});

  @override
  _PersonCardState createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  bool isFavourite = false;
  bool isRequestSent = false;
  bool isOnline = false;
  bool isVisible = true;
  bool isRequestAccepted = false;
  bool isPremium = false;
  var onlineListener, requestListener, connectionListener, favListener;
  checkOnline() {
    onlineListener = FirebaseDatabase.instance
        .reference()
        .child('User Information')
        .child(widget.user.id!)
        .child('isOnline')
        .onValue
        .listen((event) {
      setState(() {
        // Map data = event.snapshot.value as Map;
        isOnline = event.snapshot.value != null;
        // isOnline = event.snapshot.value ?? false;
      });
    });
  }

  checkFavourite() {
    favListener = FirebaseDatabase.instance
        .reference()
        .child('FavUsers')
        .child(widget.currentUserInfo.id!)
        .child(widget.user.id!)
        .onValue
        .listen((event) {
      setState(() {
        isFavourite = event.snapshot.value != null;
        // isFavourite = event.snapshot.value ?? false;
      });
    });
  }

  checkRequestStatus() {
    requestListener = FirebaseDatabase.instance
        .reference()
        .child('Connection Requests')
        .child(widget.user.id!)
        .child(widget.currentUserInfo.id!)
        .onValue
        .listen((event) {
      isRequestSent = event.snapshot.value != null;
      isRequestAccepted = event.snapshot.value != null;
      // isRequestAccepted = event.snapshot.value ?? false;

      isVisible = widget.user.visibility == 'All Member' ||
          (widget.user.visibility == 'Premium Members only' && isPremium) ||
          (widget.user.visibility == 'Connected Members' && isRequestAccepted);
    });
  }

  String visibility = '';
  @override
  void initState() {
    isFavourite = widget.isFavourite;
    isRequestSent = widget.isRequestSent;
    visibility = widget.user.visibility ?? 'All Member';
    isPremium = widget.currentUserInfo.premiumModel!.isActive ?? false;

    isVisible = visibility == 'All Member' ||
        (visibility == 'Premium Members only' && isPremium) ||
        (visibility == 'Connected Members' && (Provider.of<ConnectionProvider>(context, listen: false).
        checkConnection(widget.user.id) ?? false));

    checkOnline();
    checkRequestStatus();
    checkFavourite();
    super.initState();
  }

  @override
  void dispose() {
    if (onlineListener != null) {
      onlineListener.cancel();
    }
    if (requestListener != null) {
      requestListener.cancel();
    }
    if (favListener != null) {
      favListener.cancel();
    }
    super.dispose();
  }

  int calculateAge(String dobirth) {
    var now = DateTime.now();
    final DateFormat format = new DateFormat("dd/MMM/yyyy");
    var dob = format.parse(dobirth);
    return (now.difference(dob).inDays ~/ 365);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
              top: height * .01,
              bottom: height * .01,
              left: width * .04,
              right: width * .04),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HomeScreen(
                            widget.user, widget.user.isVerified ?? true, packageList: [])));
                  },
                  child: isVisible
                      ? Container(
                          height: height * .63,
                          width: width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    widget.user.imageUrl!),
                                fit: BoxFit.cover),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                gradient: LinearGradient(
                                    colors: [Colors.black12, Colors.black54],
                                    begin: Alignment.center,
                                    stops: [0.4, 1],
                                    end: Alignment.bottomCenter)),
                            child: Stack(
                              children: [
                                widget.user.isPremium!
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
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Icon(MdiIcons.crown,
                                                    color: Colors.white),
                                                Text('Premium',
                                                    style: GoogleFonts.workSans(
                                                        color: Colors.white)),
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
                                      bottomSheet(context, widget.user,
                                          widget.currentUserInfo);
                                    },
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: Colors.black45,
                                        ),
                                        child: Icon(MdiIcons.dotsHorizontal,
                                            color: Colors.white, size: 23)),
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  top: height * .13,
                                  child: InkWell(
                                    onTap: () {
                                      onFavTap(
                                              context,
                                              isFavourite,
                                              widget.user,
                                              widget.currentUserInfo.id!)
                                          .then((value) {
                                        setState(() {
                                          isFavourite = !isFavourite;
                                        });
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      child: isFavourite
                                          ? Icon(MdiIcons.heart,
                                              color: Colors.red, size: 30)
                                          : Icon(MdiIcons.heartOutline,
                                              color: Colors.white, size: 30),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: width * .01,
                                  top: height * .51,
                                  child: Container(
                                    width: width * 0.2,
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: isOnline
                                        ? Row(
                                            children: [
                                              Icon(MdiIcons.circle,
                                                  size: 10,
                                                  color: Colors.green),
                                              Text('Online',
                                                  style: GoogleFonts.workSans(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          )
                                        : Container() /* Row(
                                            children: [
                                              Icon(MdiIcons.circle,
                                                  size: 10, color: Colors.red),
                                              Text('Offline',
                                                  style: GoogleFonts.workSans(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          ) */
                                    ,
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
                                          // Todo: Check verified
                                          /* verificationPopup(
                                              widget.user.isGovIdVerified,
                                              widget.user.govVerifiedBy), */
                                          SizedBox(width: 10),
                                          Text(
                                              widget.user.name!.toUpperCase() ??
                                                  "",
                                              style: GoogleFonts.ptSans(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      SizedBox(height: height * .005),
                                      Row(
                                        children: [
                                          Text(
                                            widget.user.height ?? '',
                                            style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          SizedBox(width: width * .03),
                                          Text(
                                              "${calculateAge(widget.user.dateOfBirth!)} yrs",
                                              style: GoogleFonts.ptSans(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                          SizedBox(width: width * .03),
                                          Container(
                                            width: width * .24,
                                            child: Text(
                                              widget.user.city ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: height * .005),
                                      Row(
                                        children: [
                                          Text(
                                            widget.user.highestQualification ??
                                                '',
                                            style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                          SizedBox(width: width * .03),
                                          Text(
                                            widget.user.workingAs ?? '',
                                            style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: height * .005),
                                      widget.user.employedIn != null &&
                                              widget.user.employedIn != ""
                                          ? Row(
                                              children: [
                                                Text(
                                                  widget.user.employedIn!,
                                                  style: GoogleFonts.ptSans(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                )
                                              ],
                                            )
                                          : Container(),
                                      SizedBox(height: height * .005),
                                      Row(
                                        children: [
                                          Text(
                                            widget.user.maritalStatus ?? '',
                                            style: GoogleFonts.ptSans(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * .03,
                                          ),
                                          Text(
                                            widget.user.religion ?? '',
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
                                      widget.user.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                    child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 8.0, sigmaY: 8.0),
                                        child: Container()),
                                  ),
                                  Positioned(
                                    top: height * .25,
                                    child: Column(
                                      children: [
                                        Icon(MdiIcons.lock,
                                            color: Colors.white60, size: 50),
                                        SizedBox(height: height * .02),
                                        Text(
                                          'Images will be Visible\nAfter you Connect with Each Other',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                        SizedBox(height: height * .02),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: height * .63,
                                    width: width,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10)),
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.black12,
                                              Colors.black54
                                            ],
                                            begin: Alignment.center,
                                            stops: [0.4, 1],
                                            end: Alignment.bottomCenter),
                                      ),
                                      child: Stack(
                                        children: [
                                          widget.user.isPremium!
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
                                                        color:
                                                            theme.colorPrimary),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(MdiIcons.crown,
                                                              color:
                                                                  Colors.white),
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
                                            top: height * .08,
                                            child: InkWell(
                                              onTap: () {
                                                bottomSheet(
                                                    context,
                                                    widget.user,
                                                    widget.currentUserInfo);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5, vertical: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Colors.black45,
                                                ),
                                                child: Icon(
                                                    MdiIcons.dotsHorizontal,
                                                    color: Colors.white,
                                                    size: 23),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: width * .01,
                                            top: height * .51,
                                            child: Container(
                                              width: width * 0.2,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4),
                                              child: isOnline
                                                  ? Row(
                                                      children: [
                                                        Icon(MdiIcons.circle,
                                                            size: 10,
                                                            color:
                                                                Colors.green),
                                                        Text(
                                                          'Online',
                                                          style: GoogleFonts
                                                              .workSans(
                                                                  color: Colors
                                                                      .green,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        )
                                                      ],
                                                    )
                                                  : Container() /* Row(
                                                      children: [
                                                        Icon(MdiIcons.circle,
                                                            size: 10,
                                                            color: Colors.red),
                                                        Text('Offline',
                                                            style: GoogleFonts
                                                                .workSans(
                                                                    color: Colors
                                                                        .red,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))
                                                      ],
                                                    ) */
                                              ,
                                            ),
                                          ),
                                          Positioned(
                                            right: 13,
                                            top: height * .15,
                                            child: InkWell(
                                              onTap: () {
                                                onFavTap(
                                                        context,
                                                        isFavourite,
                                                        widget.user,
                                                        widget
                                                            .currentUserInfo.id!)
                                                    .then((value) {
                                                  setState(() {
                                                    isFavourite = !isFavourite;
                                                  });
                                                });
                                              },
                                              child: Container(
                                                width: width * 0.15,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                child: isFavourite
                                                    ? Icon(
                                                        MdiIcons.heart,
                                                        color: Colors.red,
                                                        size: 30,
                                                      )
                                                    : Icon(
                                                        MdiIcons.heartOutline,
                                                        color: Colors.white,
                                                        size: 30,
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
                                                    // Todo: verify gov check
                                                    /* verificationPopup(
                                                        widget.user
                                                            .isGovIdVerified,
                                                        widget.user
                                                            .govVerifiedBy), */
                                                    SizedBox(width: 10),
                                                    Text(
                                                      widget.user.name!
                                                              .toUpperCase() ??
                                                          "",
                                                      style: GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: height * .005),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.user.height ?? '',
                                                      style: GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                    SizedBox(
                                                        width: width * .03),
                                                    Text(
                                                      "${calculateAge(widget.user.dateOfBirth!)} yrs",
                                                      style: GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                    SizedBox(
                                                        width: width * .03),
                                                    Text(
                                                      widget.user.city ?? '',
                                                      style: GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: height * .005),
                                                Row(
                                                  children: [
                                                    Text(
                                                      widget.user
                                                              .highestQualification ??
                                                          '',
                                                      style: GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                    SizedBox(
                                                        width: width * .03),
                                                    Text(
                                                      widget.user.workingAs ??
                                                          '',
                                                      style: GoogleFonts.ptSans(
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: height * .005),
                                                Row(
                                                  children: [
                                                    Text(
                                                        widget.user
                                                                .maritalStatus ??
                                                            '',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14)),
                                                    SizedBox(
                                                        width: width * .03),
                                                    Text(
                                                        widget.user.religion ??
                                                            '',
                                                        style:
                                                            GoogleFonts.ptSans(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14)),
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
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      widget.user.imageUrl!),
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
                                          sigmaX: 8.0, sigmaY: 8.0),
                                      child: Container(),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                              onTap: () {
                                                Fluttertoast.showToast(
                                                    msg: "Not Premium");
                                              },
                                              child: Center(
                                                child: Container(
                                                  width: width * .45,
                                                  height: height * .053,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: theme.colorPrimary,
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
                                                      color: theme.colorPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                  Positioned(
                                    right: 25,
                                    top: height * .07,
                                    child: InkWell(
                                      onTap: () {
                                        bottomSheet(context, widget.user,
                                            widget.currentUserInfo);
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
                                    right: 20,
                                    top: height * .13,
                                    child: InkWell(
                                      onTap: () {
                                        onFavTap(
                                                context,
                                                isFavourite,
                                                widget.user,
                                                widget.currentUserInfo.id!)
                                            .then((value) {
                                          setState(() {
                                            isFavourite = !isFavourite;
                                          });
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 5,
                                        ),
                                        child: isFavourite
                                            ? Icon(
                                                MdiIcons.heart,
                                                color: Colors.red,
                                                size: 30,
                                              )
                                            : Icon(
                                                MdiIcons.heartOutline,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: width * .01,
                                    top: height * .51,
                                    child: Container(
                                      width: width * 0.2,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: isOnline
                                          ? Row(
                                              children: [
                                                Icon(
                                                  MdiIcons.circle,
                                                  size: 10,
                                                  color: Colors.green,
                                                ),
                                                Text(
                                                  'Online',
                                                  style: GoogleFonts.workSans(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            )
                                          : Container() /* Row(
                                              children: [
                                                Icon(
                                                  MdiIcons.circle,
                                                  size: 10,
                                                  color: Colors.red,
                                                ),
                                                Text(
                                                  'Offline',
                                                  style: GoogleFonts.workSans(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ) */
                                      ,
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
                                            // Todo: Verify Gov data
                                            /* verificationPopup(
                                                widget.user.isGovIdVerified,
                                                widget.user.govVerifiedBy), */
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              widget.user.name!.toUpperCase() ??
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
                                              widget.user.height ?? '',
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * .03,
                                            ),
                                            Text(
                                              "${calculateAge(widget.user.dateOfBirth!)} yrs",
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * .03,
                                            ),
                                            Text(
                                              widget.user.city ?? '',
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
                                              widget.user
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
                                              widget.user.workingAs ?? '',
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
                                              widget.user.maritalStatus ?? '',
                                              style: GoogleFonts.ptSans(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * .03,
                                            ),
                                            Text(
                                              widget.user.religion ?? '',
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
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: theme.colorPrimary),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          if (!isPremium) {
                            Fluttertoast.showToast(msg: "Not Premium");
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SocialMediaChat(
                                uid: widget.user.id!,
                                data: widget.user,
                                thisUser: widget.currentUserInfo,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: width * .2,
                          child: Column(
                            children: [
                              Icon(
                                MdiIcons.chat,
                                color: Colors.red,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text('Chat')
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Provider.of<ContactProvider>(context, listen: false)
                              .getContact(
                                  context,
                                  widget.user,
                                  widget.currentUserInfo,
                                  isPremium, onSuccess: () {
                            setState(() {});
                            launchWhatsApp(
                                widget.user.phone!, widget.currentUserInfo);
                          });
                        },
                        child: Container(
                          width: width * .2,
                          child: Column(
                            children: [
                              Icon(
                                MdiIcons.whatsapp,
                                color: Colors.red,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text('WhatsApp')
                            ],
                          ),
                        ),
                      ),
                      SizedBox(),
                      InkWell(
                          onTap: () {
                            Provider.of<ContactProvider>(context, listen: false)
                                .getContact(
                                    context,
                                    widget.user,
                                    widget.currentUserInfo,
                                    isPremium, onSuccess: () {
                              setState(() {});
                              launch("tel://${widget.user.phone}");
                            });
                          },
                          child: Container(
                              width: width * .2,
                              child: Column(children: [
                                Icon(MdiIcons.phone, color: Colors.red),
                                SizedBox(height: 4),
                                Text('Phone')
                              ]))),
                      InkWell(
                        onTap: () {
                          if (isRequestSent) {
                            Fluttertoast.showToast(msg: 'Already sent');
                          } else {
                            setState(() {
                              isRequestSent = true;
                            });
                            final String id = widget.currentUserInfo.id!;
                            FirebaseDatabase.instance
                                .reference()
                                .child('Connection Requests')
                                .child(widget.user.id!)
                                .update({id: false}).then((value) {
                              Fluttertoast.showToast(
                                  msg: 'Request sent Successfully');
                            });
                            FirebaseDatabase.instance
                                .reference()
                                .child('userReq')
                                .child(widget.user.id!)
                                .update({id: false});
                            FirebaseDatabase.instance
                                .reference()
                                .child('userReq')
                                .child(id)
                                .update({widget.user.id!: false}).then((value) {
                              sendNotificationsByUserID(
                                  widget.user.id!,
                                  'New Connection Request',
                                  widget.currentUserInfo.name! +
                                      'sent you request',
                                  userId: widget.currentUserInfo.id!,
                                  target: Constants.USER_SENT_REQUEST);
                            });
                          }
                        },
                        child: Container(
                          width: width * .25,
                          child: Column(
                            children: [
                              Transform.rotate(
                                angle: 95,
                                child: Icon(
                                  isRequestSent
                                      ? MdiIcons.navigation
                                      : MdiIcons.navigationOutline,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              isRequestSent
                                  ? Container(
                                      alignment: Alignment.center,
                                      width: width * 25,
                                      child: Text('Sent'),
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      width: width * .25,
                                      child: Text('Send Request'),
                                    )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

bottomSheet(context, UserInformation user, UserInformation currentUserInfo,
    {isBlocked = false}) {
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
        height: 86,
        padding: EdgeInsets.symmetric(horizontal: 23, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 17,
            ),
            GestureDetector(
              onTap: () {
                if (isBlocked) {
                  print(":::: $user.id");
                  FirebaseDatabase.instance
                      .reference()
                      .child('User Information')
                      .child(user.id!)
                      .child('Blocked By')
                      .child(currentUserInfo.id!)
                      .remove();
                  FirebaseDatabase.instance
                      .reference()
                      .child('BlockedUsers')
                      .child(currentUserInfo.id!)
                      .child(user.id!)
                      .remove()
                      .then((value) {
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(msg: 'Successfully UnBlocked');
                  });
                  return;
                }
                print("::: ${user.name}: ${user.id}");
                FirebaseDatabase.instance
                    .reference()
                    .child('User Information')
                    .child(user.id!)
                    .child('Blocked By')
                    .update({'${currentUserInfo.id}': true});
                FirebaseDatabase.instance
                    .reference()
                    .child('BlockedUsers')
                    .child(currentUserInfo.id!)
                    .update({'${user.id}': true}).then((value) {
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: 'Successfully Blocked');
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
                    isBlocked ? 'UnBlock this Profile' : 'Block this Profile',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

PopupMenuButton verificationPopup(bool isGovIdVerified, String govVerifiedBy) {
  return PopupMenuButton(
      padding: EdgeInsets.only(left: 4, right: 10),
      iconSize: 34,
      color: Colors.black,
      offset: Offset(12, isGovIdVerified ? -60 : -44),
      icon: Image.asset(
        isGovIdVerified ? 'assets/govVerifycheck.png' : 'assets/verified.png',
        fit: BoxFit.contain,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            height: 30,
            child: Column(
              children: [
                isGovIdVerified && govVerifiedBy != null
                    ? Row(
                        children: [
                          Icon(
                            Icons.check_rounded,
                            color: Colors.green,
                            size: 22.0,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            govVerifiedBy + " verified",
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Container(),
                Row(
                  children: [
                    Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 22.0,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Mobile Number verified",
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ];
      });
}

Future onFavTap(
    context, bool isFavourite, UserInformation user, String id) async {
  if (!isFavourite) {
    FirebaseDatabase.instance
        .reference()
        .child('FavUsers')
        .child(id)
        .update({'${user.id}': true}).then((value) {
      Provider.of<FavUsers>(context, listen: false).addToFav(user.id!);
    });
  } else {
    FirebaseDatabase.instance
        .reference()
        .child('FavUsers')
        .child(id)
        .child('${user.id}')
        .remove()
        .then((value) {
      Provider.of<FavUsers>(context, listen: false).removeId(user.id!);
    });
  }
}

launchWhatsApp(String phone, UserInformation user) async {
  var userData = "● Profile id: ${user.srId!.toUpperCase()}";
  userData += "\n● Name: ${user.name!.toLowerCase()}";
  userData += "\n● Occupation: ${user.workingAs!.toUpperCase()}";
  userData += "\n● Income: ${user.annualIncome!.toUpperCase()}";
  userData += "\n● Employed In: ${user.employedIn!.toUpperCase()}";
  userData += "\n● Education: ${user.highestQualification!.toUpperCase()}";
  userData += "\n● College: ${user.collegeAttended!.toUpperCase()}";
  userData += "\n● Birth Date: ${user.dateOfBirth!.toUpperCase()}";
  userData += "\n● Height: ${user.height!.toUpperCase()}";
  userData += "\n● Manglik: ${user.manglik!.toUpperCase()}";
  userData += "\n● Marital Status: ${user.maritalStatus!.toUpperCase()}";
  userData += "\n● City of birth: ${user.cityOfBirth!.toUpperCase()}";
  userData += "\n● Current city: ${user.city!.toUpperCase()}";
  userData += "\n● Contact details: \n     DOWNLOAD SUNHARE Rishtey App.";

  final link = WhatsAppUnilink(
    phoneNumber: '$phone',
    text: userData + "\n\n\nHey! I'm inquiring about SUNHARE Rishtey",
  );

  // Convert the WhatsAppUnilink instance to a string.
  // Use either Dart's string interpolation or the toString() method.
  // The "launch" method is part of "url_launcher".
  await launch('$link');
}
