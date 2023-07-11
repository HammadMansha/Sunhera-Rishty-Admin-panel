import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sunhare_rishtey_new_admin/models/photoModel.dart';

class PhotoListScreen extends StatefulWidget {
  final String? userId;
  PhotoListScreen({this.userId});
  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  List<PhotoModel> pho = [];
  bool isLoading = true;
  getPhotos() {
    FirebaseDatabase.instance
        .reference()
        .child('Images')
        .child(widget.userId!)
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map;
      if (data != null) {
        data.forEach((key, value) {
          if (value['isVerified'] != null)
            pho.add(PhotoModel(
              photoId: key,
              imageUrl: value['imageURL'],
            ));
        });
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    getPhotos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Photos'),
          backgroundColor: HexColor('70c4bc'),
          // backgroundColor: Colors.black87,
        ),
        body: pho.length == 0
            ? Center(
                child: Text(
                  'No Verified photos as of now',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  width: width,
                  height: height * .89,
                  child: ListView.builder(
                    itemCount: pho.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Stack(
                          children: [
                            Container(
                              height: height * .855,
                              child: PhotoView(
                                  imageProvider: CachedNetworkImageProvider(
                                      pho[index].imageUrl!),
                                  minScale:
                                      PhotoViewComputedScale.contained * 0.8,
                                  maxScale: PhotoViewComputedScale.covered * 2),
                            ),
                            Positioned(
                              bottom: 2,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (pho.length == 1) {
                                        FirebaseDatabase.instance
                                            .reference()
                                            .child('Images')
                                            .child(widget.userId!)
                                            .child(pho[index].photoId!)
                                            .remove()
                                            .then((value) {
                                          //  Navigator.of(context).pop(true);
                                          setState(() {
                                            pho.clear();
                                          });
                                        });
                                      } else
                                        FirebaseDatabase.instance
                                            .reference()
                                            .child('Images')
                                            .child(widget.userId!)
                                            .child(pho[index].photoId!)
                                            .remove()
                                            .then((value) {
                                          //  Navigator.of(context).pop(true);
                                          setState(() {});
                                        });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      width: width * .35,
                                      height: height * .05,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.redAccent,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Remove',
                                        style: GoogleFonts.comfortaa(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
