import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class IDViewScreen extends StatefulWidget {
  final String userId;
  IDViewScreen({required this.userId});
  @override
  _IDViewScreenState createState() => _IDViewScreenState();
}

class _IDViewScreenState extends State<IDViewScreen> {
  List names = [];
  List images = [];
  getDataForVarification() async {
    log(widget.userId);
    final data = await FirebaseDatabase.instance
        .reference()
        .child('Gov Id')
        .child(widget.userId)
        .child('verified')
        .once();
    if (data.snapshot.value != null) {
      Map verified = data.snapshot.value as Map;
      verified.forEach((key, value) {
        names.add(key);
        images.add(value);
      });
      setState(() {});
    }
  }

  @override
  void initState() {
    getDataForVarification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('IDs'),
          backgroundColor: HexColor('70c4bc'),
        ),
        body: names.length == 0
            ? Center(
                child: Text(
                  'No Id Uploaded',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                itemCount: names.length,
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    children: [
                      Container(
                        width: width,
                        alignment: Alignment.topCenter,
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              names[index],
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                    ],
                  );
                }) /* SingleChildScrollView(
                child: Column(
                children: [
                  Container(
                    width: width,
                    height: height * .5,
                    margin: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    alignment: Alignment.topCenter,
                    child: CachedNetworkImage(
                      imageUrl: govList[0].imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              )) */
        ,
      ),
    );
  }
}
