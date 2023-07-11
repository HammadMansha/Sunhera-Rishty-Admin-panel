import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/models/UserModel.dart';
import 'package:sunhare_rishtey_new_admin/Widgets/DrawerWidget.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loading = true;

  List<UserInformation> verifiedUsers = [];
  List<UserInformation> pendingUsers = [];
  getUsers() {
    final ref = Provider.of<AllUser>(context, listen: false);
    ref.getAllUsers().then((value) {
      setState(() {
        loading = false;
        verifiedUsers = ref.verifiedUsers.cast<UserInformation>();
        pendingUsers = ref.notVerified.cast<UserInformation>();
        log(verifiedUsers.toString());
      });
    });
  }

  int currentIndex = 1;
  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("52a199"),
        // title: Text(
        //   "Matrimonial Admin Panel",
        //   style: GoogleFonts.workSans(
        //     color: Colors.white,
        //   ),
        // ),
        // actions: [
        //   Padding(
        //     padding: EdgeInsets.only(right: 15),
        //     child: IconButton(
        //       tooltip: 'Sign Out',
        //       icon: Icon(
        //         MdiIcons.logoutVariant,
        //       ),
        //       onPressed: () {
        //         FirebaseAuth.instance.signOut();
        //         Navigator.pushReplacement(
        //           context,
        //           MaterialPageRoute<void>(
        //             builder: (context) => LoginScreen(),
        //           ),
        //         );
        //       },
        //     ),
        //   ),
        // ],
      ),
      drawer: DrawerWidget(),
    );
  }
}
