import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Screens/IDVerificationScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/NotificationScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/GroupedUsersScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/PackagesScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/PhotoVerificationScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/SubscriptionScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/TrashScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/UserRequestScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/UsersScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/aboutUsScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/ads_on_off_screen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/dashBord.dart';
import 'package:sunhare_rishtey_new_admin/Screens/group_wise_discount_screen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/delete_list_screen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/discountScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/reprotedAccountScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/user_wise_discount_screen.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import '../Screens/AdvertisementScreen.dart';
import '../auth/loginScreen.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  showLogOutPopUp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () async {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
            child: Text('Yes'),
          ),
        ],
        content: Container(
          child: Text('Do you really wants to LogOut ?'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Stack(
        children: [
          Drawer(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage("assets/shadiLogo.png"),
                          radius: 36,
                        ),
                        SizedBox(
                          width: width * 0.07,
                        ),
                        Column(
                          children: [
                            Container(
                              width: width * 0.42,
                              child: Text(
                                "Sunhare Rishtey",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: HexColor('09c7f7'),
                  ),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "DashBoard", MdiIcons.viewDashboard, 1),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Users", MdiIcons.accountMultiple, 2),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Grouped Users", MdiIcons.accountGroup, 3),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Recent Delete", MdiIcons.delete, 4),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Trash", MdiIcons.delete, 5),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Reported Accounts", MdiIcons.accountAlert, 6),
                  SizedBox(height: height * 0.015),
                  Divider(color: HexColor('09c7f7')),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "User Request", MdiIcons.accountPlus, 7),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Subscription", MdiIcons.crown, 8),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "ID Verification", MdiIcons.identifier, 9),
                  SizedBox(height: height * 0.015),
                  /*  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DataRecoveryScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: width * 0.04,
                        ),
                        Icon(
                          MdiIcons.identifier,
                          color: HexColor('357f78'),
                          size: 30,
                        ),
                        SizedBox(
                          width: width * 0.07,
                        ),
                        Container(
                          child: Text(
                            'ID Recovery',
                            style: GoogleFonts.roboto(
                                fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.015,
                  ), */
                  sideMenuView(width, "Photo Verification", MdiIcons.humanMaleBoy, 10),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Packages", MdiIcons.newspaper, 11),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Discount", MdiIcons.sale, 12),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Discount Group", MdiIcons.sale, 17),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Discount Group User", MdiIcons.sale, 18),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Advertisement", MdiIcons.newspaper, 13),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Ads on/off", MdiIcons.newspaper, 19),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Notification", MdiIcons.bellRing, 14),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "About us", MdiIcons.information, 15),
                  SizedBox(height: height * 0.015),
                  Divider(color: Colors.blue),
                  SizedBox(height: height * 0.015),
                  sideMenuView(width, "Logout", MdiIcons.logoutVariant, 16),
                  SizedBox(height: height * 0.015),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sideMenuView(double width, String title, IconData iconName, int index) {
    return InkWell(
      onTap: () {
        if(index == 1) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => DashbordScreen()));
        } else if(index == 2) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => UsersScreen()));
        } else if(index == 3) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => GroupedUsersScreen()));
        } else if(index == 4) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DeleteListScreen()));
        } else if(index == 5) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => TrashScreen()));
        } else if(index == 6) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReportedAccountScreen()));
        } else if(index == 7) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserRequestScreen()));
        } else if(index == 8) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SubscriptionsScreen()));
        } else if(index == 9) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => IDVerificationScreen()));
        } else if(index == 10) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PhotoVerificationScreen()));
        } else if(index == 11) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PackagesScreen()));
        } else if(index == 12) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DiscountScreen()));
        } else if(index == 13) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdvertisementScreen()));
        } else if(index == 14) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationScreen()));
        } else if(index == 15) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutUsScreen()));
        } else if(index == 16) {
          showLogOutPopUp();
        } else if(index == 17) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DateWiseDiscountScreen()));
        } else if(index == 18) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserWiseDiscountScreen()));
        } else if(index == 19) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdsOnOffScreen()));
        }
      },
      child: Row(
        children: [
          SizedBox(width: width * 0.04),
          Icon(iconName, color: HexColor("357f78"), size: 30),
          SizedBox(width: width * 0.07),
          Container(
            child: Text(title, style: GoogleFonts.roboto(fontSize: 16, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
