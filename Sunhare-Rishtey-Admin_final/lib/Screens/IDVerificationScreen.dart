import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Screens/IDScreen.dart';
import 'package:sunhare_rishtey_new_admin/models/govIdModel.dart';

class IDVerificationScreen extends StatefulWidget {
  @override
  _IDVerificationScreenState createState() => _IDVerificationScreenState();
}

class _IDVerificationScreenState extends State<IDVerificationScreen> {
  List<GovIdModel> govList = [];
  getDataForVarification() {
    FirebaseDatabase.instance
        .reference()
        .child('Gov Id')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map;
      if (data.isNotEmpty) {
        govList = [];
        data.forEach((key, value) {
          if (value['isVerified'] != null && !value['isVerified'])
            govList.add(GovIdModel(
                imageUrl: value['imageUrl'],
                isVerified: value['isVerified'],
                name: value['name'],
                srId: value['srId'],
                document: value['varificationBy'],
                userId: value['userId'],
                varifiedBy: value['verifiedBy']));
        });
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    getDataForVarification();
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
            '\Verify ID',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * .01,
              ),
              Container(
                width: width,
                height: height * .875,
                child: ListView.builder(
                  itemCount: govList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => IDScreen(
                              imageUrl: govList[index].imageUrl!,
                              userId: govList[index].userId!,
                              document: govList[index].document!,
                              verificationBy: govList[index].document!,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 10,
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: width * .05,
                                  ),
                                  Container(
                                    width: width * .7,
                                    child: Text(
                                      govList[index].name!,
                                      style: GoogleFonts.openSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * .07,
                                  ),
                                  Icon(
                                    MdiIcons.chevronRight,
                                    size: 27,
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: width * .05,
                                  ),
                                  Text(
                                    'ID - ${govList[index].srId}\n${govList[index].document}',
                                    style: GoogleFonts.openSans(
                                      fontSize: 15,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
