import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class AdsOnOffScreen extends StatefulWidget {
  const AdsOnOffScreen({Key? key}) : super(key: key);

  @override
  State<AdsOnOffScreen> createState() => _AdsOnOffScreenState();
}

class _AdsOnOffScreenState extends State<AdsOnOffScreen> {

  bool isBannerOn = false;
  bool isInterOn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFirebaseData();
  }


  getFirebaseData() async {
    final getData = await FirebaseDatabase.instance.reference().child("AdsSetting").once();
    Map getMapData = getData.snapshot.value as Map;
    isBannerOn = getMapData['banner'];
    isInterOn = getMapData['interstitial'];
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('70c4bc'),
          title: Text (
            'Ads on/off',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding (
          padding: EdgeInsets.only(left: 15, right: 10),
          child: Column (
            children: [
              Row(
                children: [
                  Expanded(child: Text("Banner Ads", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18))),
                  Switch(value: isBannerOn,
                      activeColor: Color(0xff70c4bc),
                      onChanged: (e) {
                    isBannerOn = e;
                    FirebaseDatabase.instance
                        .reference()
                        .child("AdsSetting")
                        .update({"banner": isBannerOn});
                    setState(() { });
                  })
                ],
              ),

              Row(
                children: [
                  Expanded(child: Text("Interstitial Ads", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18))),
                  Switch(value: isInterOn,
                      activeColor: Color(0xff70c4bc),
                      onChanged: (e) {
                        isInterOn = e;
                        FirebaseDatabase.instance
                            .reference()
                            .child("AdsSetting")
                            .update({"interstitial": isInterOn});
                        setState(() {});
                      })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
