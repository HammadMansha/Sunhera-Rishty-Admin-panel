// import 'package:age/age.dart';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/UserHomeScreen.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/AllChatScreen.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import '../main.dart';
import 'NotificationScreen.dart';
import 'UserEditScreen.dart';

class EditProfileScreen extends StatefulWidget {
  final UserInformation userInfo;

  EditProfileScreen({required this.userInfo});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  List<String> privacyList = [
    'All Member',
    'Premium Members only',
    'Connected Members',
  ];
  UserInformation userInfo = UserInformation();

  @override
  void initState() {
    //  print(userInfo.partnerInfo.city);
    super.initState();
  }

  List<String> images = [];
  void deleteDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(
          'Are you sure you want to Delete',
        ),
        actions: [
          TextButton(
            child: Text(
              "Cancel",
              style: GoogleFonts.openSans(
                fontSize: 14,
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text(
              "Delete",
              style: theme.text14boldPimary,
            ),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  // AgeDuration? age;

  // String calculateAge() {
  //   // int month=int.parse(userInfo.dateOfBirth.split('/')[1]);
  //   age = Age.dateDifference(
  //       fromDate: DateTime(int.parse(userInfo.dateOfBirth!.split('/').last), 6,
  //           int.parse(userInfo.dateOfBirth!.split('/')[0])),
  //       toDate: DateTime.now(),
  //       includeToDate: false);
  //   return age!.years.toString();
  // }

  String visibility = '';

  @override
  void didChangeDependencies() {
    userInfo = widget.userInfo;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorCompanion,
          title: Text(
            'User Profile',
            style: GoogleFonts.lato(),
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditSection(
                        userInfo: userInfo,
                        onTapUpdate: () {
                          setState(() {});
                        }),
                  ),
                );
              },
              child: Icon(
                Icons.edit,
              ),
            ),
            SizedBox(
              width: width * .05,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * .01,
              ),
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: height * .01,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      height: height * .2,
                      child: GestureDetector(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: width * .01,
                            ),
                            Container(
                              height: height * .2,
                              width: width * .3,
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: userInfo.imageUrl == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: height * .01,
                                        ),
                                        Text(
                                          'Click Here',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'to upload',
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * .01,
                                          width: width * 1,
                                        ),
                                        Icon(
                                          MdiIcons.camera,
                                          size: 35,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          'Photo',
                                          style: GoogleFonts.lato(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        Center(
                                          child: InkWell(
                                            onTap: () {},
                                            child: Container(
                                              width: width,
                                              height: height,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: CachedNetworkImage(
                                                  imageUrl: userInfo.imageUrl!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * .01,
                    ),
                    SizedBox(
                      height: height * .02,
                    ),
                    RichText(
                      text: TextSpan(
                        text: userInfo.name!.toUpperCase() ?? 'Loading',
                        style: GoogleFonts.ptSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: theme.colorPrimary,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' (${userInfo.srId ?? ""})',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * .003,
                    ),
                    Container(
                      width: width,
                      alignment: Alignment.center,
                      child: Text(userInfo.id!),
                    ),
                    SizedBox(
                      height: height * .025,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: HexColor('52a199'),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AllChatScreen(userInfo),
                              ),
                            );
                          },
                          icon: Icon(
                            MdiIcons.chat,
                          ),
                          label: Text(
                            'Chat',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                            ),
                          ),
                        ),
                        SizedBox(width: width * .015),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: HexColor('52a199'),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UserHomeScreen(userInfo),
                              ),
                            );
                          },
                          icon: Icon(
                            MdiIcons.glasses,
                          ),
                          label: Text(
                            'View',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                            ),
                          ),
                        ),
                        SizedBox(width: width * .015),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            primary: HexColor('52a199'),
                          ),
                          onPressed: () {
                            log("user info is=====>>>>>>${userInfo}");
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    NotificationScreen(user: userInfo),
                              ),
                            );
                          },
                          icon: Icon(
                            MdiIcons.bellRing,
                          ),
                          label: Text(
                            'Notification',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.015,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: height * .025,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Basic Info',
                      style: GoogleFonts.ptSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * .01,
              ),
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Age',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            // ': ${calculateAge()}',
                            ': age',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Marital Status',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.maritalStatus == null ? 'Not Filled' : userInfo.maritalStatus}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Height',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.height == null ? 'Not Filled' : userInfo.height}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Any Disability?',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.anyDisAbility == null ? 'none' : userInfo.anyDisAbility}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .02,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * .025,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * .85,
                      child: Text(
                        'More about Myself, Partner and Family Member',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ptSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: theme.colorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * .01,
              ),
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Text(
                    userInfo.intro ?? 'Here Bio will be displayed',
                    style: GoogleFonts.ptSans(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * .025,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Religious Background',
                      style: GoogleFonts.ptSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * .01,
              ),
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Religion',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.religion == null ? 'Not Filled' : userInfo.religion}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Mother Tongue',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.motherTongue == null ? 'Not Filled' : userInfo.motherTongue}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Community',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.community == null ? 'Not Filled' : userInfo.community}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Father\'s Gothra',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.fatherGautra == null ? 'Not Filled' : userInfo.fatherGautra}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Mother\'s Gothra',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.motherGautra == null ? 'Not Filled' : userInfo.motherGautra}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .02,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * .025,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Family',
                      style: GoogleFonts.ptSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * .01,
              ),
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Father\'s Status',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.fatherStatus == null ? 'Not Filled' : userInfo.fatherStatus}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Mother\'s Status',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.motherStatus == null ? 'Not Filled' : userInfo.motherStatus}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Home Town',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Container(
                            width: width * .4,
                            child: Text(
                              ': ${userInfo.nativePlace == null ? 'Not Filled' : userInfo.nativePlace!.split(' ').first}',
                              style: GoogleFonts.ptSans(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Family Values',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.familyType == null ? 'Not Filled' : userInfo.familyType}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .02,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * .025,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Astro Details',
                      style: GoogleFonts.ptSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * .01,
              ),
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Manglik / Chevvai dosham',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.manglik == null ? 'Not Filled' : userInfo.manglik}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Date of Birth',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.dateOfBirth == null ? 'Not Filled' : userInfo.dateOfBirth.toString()}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Time of Birth',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            widget.userInfo.birthTime != null
                                ? ': ${widget.userInfo.birthTime!.hourOfPeriod}:${widget.userInfo.birthTime!.minute} ${widget.userInfo.birthTime!.period.toString().split('.').last}'
                                : ': not given',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'City of Birth',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.city == null ? 'Not Filled' : userInfo.city}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .02,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * .025,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Location Education & Career',
                      style: GoogleFonts.ptSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * .01,
              ),
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Country Living in',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.country == null ? 'Not Filled' : userInfo.country}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'State Living in',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.state == null ? 'Not Filled' : userInfo.state}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'City Living in',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.city == null ? 'Not Filled' : userInfo.city}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      // Row(
                      //   children: [
                      //     Container(
                      //       width: width * .4,
                      //       child: Text(
                      //         'Residency Status',
                      //         style: GoogleFonts.ptSans(
                      //             fontSize: 16, color: Colors.grey),
                      //       ),
                      //     ),
                      //     Text(
                      //       ': ${userInfo.residencyStatus == null ? 'Not Filled' : userInfo.residencyStatus}',
                      //       style: GoogleFonts.ptSans(
                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: height * .01,
                      // ),
                      // Row(
                      //   children: [
                      //     Container(
                      //       width: width * .4,
                      //       child: Text(
                      //         'Zip / Pin Code',
                      //         style: GoogleFonts.ptSans(
                      //             fontSize: 16, color: Colors.grey),
                      //       ),
                      //     ),
                      //     Text(
                      //       ': ${userInfo.zipCode == null ? 'Not Filled' : userInfo.zipCode}',
                      //       style: GoogleFonts.ptSans(
                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   height: height * .01,
                      // ),
                      // Row(
                      //   children: [
                      //     Container(
                      //       width: width * .4,
                      //       child: Text(
                      //         'Grew Up in',
                      //         style: GoogleFonts.ptSans(
                      //             fontSize: 16, color: Colors.grey),
                      //       ),
                      //     ),
                      //     Text(
                      //       ': ${userInfo.grewUpIn == null ? 'Not Filled' : userInfo.grewUpIn}',
                      //       style: GoogleFonts.ptSans(
                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Highest Qualification',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.highestQualification == null ? 'Not Filled' : userInfo.highestQualification}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'College(s) Attended',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Container(
                            width: width * .45,
                            child: Text(
                              ': ${userInfo.collegeAttended == null ? 'Not Filled' : userInfo.collegeAttended}',
                              style: GoogleFonts.ptSans(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Working with',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Container(
                            width: width * .45,
                            child: Text(
                              ': ${userInfo.workingWith == null ? 'Not Filled' : userInfo.workingWith}',
                              style: GoogleFonts.ptSans(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Working as',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.workingAs == null ? 'Not Filled' : userInfo.workingAs}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Employed in',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Container(
                            width: width * .45,
                            child: Text(
                              ': ${userInfo.employedIn == "" ? 'Not Filled' : userInfo.employedIn}',
                              style: GoogleFonts.ptSans(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Annual Income',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.annualIncome == null ? 'Not Filled' : userInfo.annualIncome}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      // Row(
                      //   children: [
                      //     Container(
                      //       width: width * .4,
                      //       child: Text(
                      //         'Employer Name',
                      //         style: GoogleFonts.ptSans(
                      //             fontSize: 16, color: Colors.grey),
                      //       ),
                      //     ),
                      //     Text(
                      //       ': ${userInfo.employerName == null ? 'Not Filled' : userInfo.employerName}',
                      //       style: GoogleFonts.ptSans(
                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: height * .02,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * .025,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lifestyle',
                      style: GoogleFonts.ptSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: theme.colorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * .01,
              ),
              Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * .01,
                      ),
                      SizedBox(
                        height: height * .01,
                      ),
                      Row(
                        children: [
                          Container(
                            width: width * .4,
                            child: Text(
                              'Diet',
                              style: GoogleFonts.ptSans(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ),
                          Text(
                            ': ${userInfo.diet == null ? 'Not Filled' : userInfo.diet}',
                            style: GoogleFonts.ptSans(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: height * .02,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: height * .025,
              ),
              userInfo.referCode != ""
                  ? Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Referral',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * .01,
                          ),
                          Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: height * .01,
                                  ),
                                  SizedBox(
                                    height: height * .01,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: width * .4,
                                        child: Text(
                                          'ReferCode',
                                          style: GoogleFonts.ptSans(
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                      ),
                                      Text(
                                        ": " + userInfo.referCode!,
                                        style: GoogleFonts.ptSans(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .02,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * .025,
                          ),
                        ],
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: height * .06,
              )
            ],
          ),
        ),
      ),
    );
  }
}
