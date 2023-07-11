import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/models/photoModel.dart';

class PhotoScreen extends StatefulWidget {
  final String? imageUrl;
  final String? userId;
  final String? photoId;
  final List<PhotoModel>? pho;
  PhotoScreen({this.imageUrl, this.photoId, this.userId, this.pho});
  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> onTapVerifiedPhoto(String id) async {
    final database = await FirebaseDatabase.instance
        .reference()
        .child('Push Notifications')
        .child(id)
        .once();
    final map = database.snapshot.value as Map;
    map.forEach((key, value) {
      NotificationSender().sendPushNotifications(
          key, "Photo Verified", "Your photo has been successfully verified",
          target: Constants.ADMIN_PHOTO_VERIFICATION);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        bottomNavigationBar: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  FirebaseDatabase.instance
                      .reference()
                      .child('Images')
                      .child(widget.userId!)
                      .child(widget.photoId!)
                      .remove()
                      .then((value) {
                    Navigator.of(context).pop(true);
                    setState(() {});
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
                onTap: () {
                  FirebaseDatabase.instance
                      .reference()
                      .child('Images')
                      .child(widget.userId!)
                      .child(widget.photoId!)
                      .update({'isVerified': true}).then((value) {
                    Navigator.of(context).pop(true);
                    onTapVerifiedPhoto(widget.userId!);
                    setState(() {});
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
                height: height * .8,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 10,
                ),
                alignment: Alignment.topCenter,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
