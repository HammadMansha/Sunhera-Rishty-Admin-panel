import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class IDScreen extends StatefulWidget {
  final String verificationBy;
  final String imageUrl;
  final String userId;
  String document;
  IDScreen({required this.imageUrl, required this.userId, required this.verificationBy, required this.document});
  @override
  _IDScreenState createState() => _IDScreenState();
}

class _IDScreenState extends State<IDScreen> {
  Future<void> onTapAccept(String id) async {
    final database = await FirebaseDatabase.instance
        .reference()
        .child('Push Notifications')
        .child(id)
        .once();
    final map = database.snapshot.value as Map;
    map.forEach((key, value) {
      NotificationSender().sendPushNotifications(
          key, "ID Verified", "Your ID has been successfully verified");
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "ID - ${widget.document}",
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          elevation: 0,
        ),
        bottomNavigationBar: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  FirebaseDatabase.instance
                      .reference()
                      .child('Gov Id')
                      .child(widget.userId)
                      .update({
                    'imageUrl': null,
                    'varificationBy': null,
                    'isVerified': null
                  }).then((value) {
                    setState(() {
                      Navigator.of(context).pop(true);
                    });
                  });

                  var data = await FirebaseDatabase.instance
                      .reference()
                      .child("User Information")
                      .child(widget.userId)
                      .child("isVerificationPending")
                      .once();
                  FirebaseDatabase.instance
                      .reference()
                      .child("User Information")
                      .child(widget.userId)
                      .update({
                    'isVerificationPending': false,
                    'isVerificationRequired':
                        data.snapshot.value != null && data.snapshot.value == true
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  width: width * .4,
                  height: height * .06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.redAccent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Reject',
                    style: GoogleFonts.comfortaa(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  FirebaseDatabase.instance
                      .reference()
                      .child('Gov Id')
                      .child(widget.userId)
                      .child("verifiedBy")
                      .once()
                      .then((value) {
                    String verifiedBy = "";
                    if (value.snapshot.value != null) {
                      verifiedBy = value.snapshot.value.toString() + ", " + widget.verificationBy;
                    }
                    else {
                      verifiedBy = widget.verificationBy;
                    }
                    print("verifiedBy=========>>>$verifiedBy");
                    FirebaseDatabase.instance
                        .reference()
                        .child('Gov Id')
                        .child(widget.userId)
                        .update({'isVerified': true, 'verifiedBy': verifiedBy});

                    FirebaseDatabase.instance
                        .reference()
                        .child('Gov Id')
                        .child(widget.userId)
                        .child("verified")
                        .update({widget.verificationBy: widget.imageUrl});

                    debugPrint("widget.userId ==> ${widget.userId}");
                    debugPrint("widget.userId ==> ${verifiedBy}");
                    FirebaseDatabase.instance
                        .reference()
                        .child('User Information')
                        .child(widget.userId)
                        .update({
                      'verifiedBy': verifiedBy,
                      // "isVerificationRequired": false,
                      "isVerificationPending": false,
                      "isVerificationGovId": true
                    });

                    Provider.of<AllUser>(context, listen: false).removeIDVerification(widget.userId);
                    setState(() {
                      Navigator.of(context).pop(true);
                    });
                    onTapAccept(widget.userId);
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  width: width * .4,
                  height: height * .06,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.greenAccent[400],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Accept',
                    style: GoogleFonts.comfortaa(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: width,
                height: height * .7,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                alignment: Alignment.topCenter,
                child: PhotoViewGallery.builder(
                  itemCount: 1,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider:
                          CachedNetworkImageProvider(widget.imageUrl),
                      // Contained = the smallest possible size to fit one dimension of the screen
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      // Covered = the smallest possible size to fit the whole screen
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  scrollPhysics: BouncingScrollPhysics(),
                  // Set the background color to the "classic white"
                  backgroundDecoration: BoxDecoration(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
