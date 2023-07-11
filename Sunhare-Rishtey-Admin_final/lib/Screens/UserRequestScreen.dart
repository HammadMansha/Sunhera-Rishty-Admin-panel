import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/PartnerPrefsProvider.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'UserInformationScreen.dart';
import 'package:provider/provider.dart';

class UserRequestScreen extends StatefulWidget {
  @override
  _UserRequestScreenState createState() => _UserRequestScreenState();
}

class _UserRequestScreenState extends State<UserRequestScreen> {
  List<UserInformation> pendingReq = [];

  @override
  void didChangeDependencies() {
    final res = Provider.of<AllUser>(context);
    print("notVerified.length ${res.notVerified.length}");
    if (res.notVerified.isEmpty) {
      res.getAllUsers().then((value) {
        pendingReq = res.notVerified;
        setState(() {});
      });
    } else {
      pendingReq = res.notVerified;
    }
    super.didChangeDependencies();
  }

  bool isLoading = false;

  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
    });
    Provider.of<AllUser>(context, listen: false).getAllUsers().then((value) {
      setState(() {
        isLoading = false;
      });
      final res = Provider.of<AllUser>(context, listen: false);
      res.updateList();
    });
  }

  Future<void> onTapMarkAsAccepted(String id) async {
    final database = await FirebaseDatabase.instance.reference().child('Push Notifications').child(id).once();
    final map = database.snapshot.value as Map;
    map.forEach((key, value) {
      NotificationSender().sendPushNotifications(key, "Account approved", "Your account is approved. Start searching your soulmate now",
          target: Constants.ADMIN_NEW_USER_REQUEST);
    });
  }

  Future<void> onTapMarkAsRejected(String id) async {
    final database = await FirebaseDatabase.instance.reference().child('Push Notifications').child(id).once();
    final map = database.snapshot.value as Map;
    map.forEach((key, value) {
      NotificationSender().sendPushNotifications(key, "Account Rejected", "Your account is rejected by Admin. Please contact admin for more details");
    });
  }

  PartnerPrefsProvider? prefsProvider;

  @override
  initState() {
    prefsProvider = Provider.of<PartnerPrefsProvider>(context, listen: false);
    prefsProvider!.getPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('70c4bc'),
          title: Text(
            'Request',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: isLoading
            ? SpinKitThreeBounce(
                color: Colors.blue,
              )
            : LiquidPullToRefresh(
                color: HexColor('70c4bc'),
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  child: Container(
                    height: height * 0.88,
                    width: width,
                    child: ListView.builder(
                      itemCount: pendingReq.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: HexColor('4db6ac'),
                          margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                          elevation: 6,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * .01,
                              ),
                              Card(
                                elevation: 8,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    print("imageUrl===${pendingReq[index].imageUrl!}");
                                    print("id1212121212===${pendingReq[index].id!}");
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (context) => HomeScreen(pendingReq[index], true, packageList: [])));
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        height: height * .18,
                                        width: width * .28,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: pendingReq[index].imageUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .1,
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pendingReq[index].name!,
                                            style: GoogleFonts.openSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "ID -" + pendingReq[index].srId!,
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'No. - ${pendingReq[index].phone}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Joined - ${pendingReq[index].joinedOn!.day}/${pendingReq[index].joinedOn!.month}/${pendingReq[index].joinedOn!.year}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'User Status : ${pendingReq[index].userStatus}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Gender : ${pendingReq[index].gender}',
                                            style: GoogleFonts.openSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * .01,
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        FirebaseDatabase.instance
                                            .reference()
                                            .child('User Information')
                                            .child(pendingReq[index].id!)
                                            .update({'isVerified': true}).then((value) {
                                          setState(() {
                                            final res = Provider.of<AllUser>(context, listen: false);
                                            if (res.notVerified.length == 1) {
                                              res.verifiedUsers.add(pendingReq[index]);
                                              res.updateList();
                                              res.notVerified.clear();
                                              Fluttertoast.showToast(msg: 'Accepted');
                                              return;
                                            }

                                            res.notVerified.removeWhere((element) => element == pendingReq[index]);
                                            // res.verifiedUsers
                                            //     .add(pendingReq[index]);
                                            res.updateList();
                                            Fluttertoast.showToast(msg: 'Accepted');
                                          });
                                        });
                                        prefsProvider!.filterUsers(pendingReq[index]).then((value) {
                                          prefsProvider!.sendNotifications(pendingReq[index].id!);
                                        });
                                        onTapMarkAsAccepted(pendingReq[index].id!);
                                      },
                                      child: Card(
                                        elevation: 10,
                                        color: HexColor('357f78'),
                                        shadowColor: HexColor('70c4bc'),
                                        child: Container(
                                          width: width * .45,
                                          height: height * .06,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Mark as Accepted',
                                            style: GoogleFonts.openSans(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        Fluttertoast.showToast(msg: 'Profile is deleting please wait');
                                        final data =
                                            await FirebaseDatabase.instance.reference().child("User Information").child(pendingReq[index].id!).once();
                                        final mapped = data.snapshot.value as Map;
                                        mapped.putIfAbsent('DeletedTime', () => DateTime.now().toIso8601String());
                                        mapped.putIfAbsent('DeletedBy', () => 'Admin');

                                        await FirebaseDatabase.instance.reference().child('trash').update({'${data.snapshot.key}': mapped});
                                        FirebaseDatabase.instance
                                            .reference()
                                            .child("User Information")
                                            .child(pendingReq[index].id!)
                                            .remove()
                                            .then((value) {
                                          setState(() {
                                            final res = Provider.of<AllUser>(context, listen: false);
                                            Fluttertoast.showToast(msg: 'Profile removed Successfully');
                                            res.notVerified.removeWhere((element) => element == pendingReq[index]);

                                            onTapMarkAsRejected(pendingReq[index].id!);
                                          });
                                        });
                                      },
                                      child: Card(
                                        elevation: 10,
                                        color: HexColor('357f78'),
                                        shadowColor: HexColor('70c4bc'),
                                        child: Container(
                                          width: width * .3,
                                          height: height * .06,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Reject',
                                            style: GoogleFonts.openSans(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //   height: height * .01,
                              // ),
                              // Card(
                              //   elevation: 8,
                              //   margin: EdgeInsets.symmetric(
                              //     horizontal: 12,
                              //     vertical: 5,
                              //   ),
                              //   child: Row(
                              //     children: [
                              //       Container(
                              //         padding: EdgeInsets.symmetric(
                              //           horizontal: 8,
                              //           vertical: 8,
                              //         ),
                              //         height: height * .18,
                              //         width: width * .28,
                              //         child: ClipRRect(
                              //           borderRadius: BorderRadius.circular(8),
                              //           child: CachedNetworkImage(
                              //             'https://miro.medium.com/max/1200/1*mk1-6aYaf_Bes1E3Imhc0A.jpeg',
                              //             fit: BoxFit.cover,
                              //           ),
                              //         ),
                              //       ),
                              //       SizedBox(
                              //         width: width * .1,
                              //       ),
                              //       Column(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: [
                              //           Text(
                              //             'Harsh Mehta',
                              //             style: GoogleFonts.openSans(
                              //               fontSize: 18,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //           ),
                              //           Text(
                              //             'Age : 24',
                              //             style: GoogleFonts.openSans(
                              //               fontSize: 16,
                              //             ),
                              //           ),
                              //           Text(
                              //             'City : Jaipur',
                              //             style: GoogleFonts.openSans(
                              //               fontSize: 16,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              SizedBox(
                                height: height * .01,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
