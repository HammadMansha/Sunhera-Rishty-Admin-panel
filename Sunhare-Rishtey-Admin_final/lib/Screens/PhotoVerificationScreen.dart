import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/Screens/PhotoScreen.dart';
import 'package:sunhare_rishtey_new_admin/models/photoModel.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';

class PhotoVerificationScreen extends StatefulWidget {
  @override
  _PhotoVerificationScreenState createState() =>
      _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  List<PhotoModel> photos = [];
  Future setUserPhoto() async {
    print("111photos===>>>>>${photos.length}");
    FirebaseDatabase.instance
        .reference()
        .child('Images')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        photos = [];
        final data = event.snapshot.value as Map;
        data.forEach((userId, images) {
          if (images != null) {
            final values = images as Map;
            values.forEach((key, value) {
              photos.add(
                PhotoModel(
                    photoId: key,
                    userId: userId,
                    imageUrl: value['imageURL'],
                    isVerified: value['isVerified'] ?? false),
              );
              print("photos===>>>>>${photos.length}");
            });
          }
        });
        setState(() {});
        setNameAndSrId();
      }
    });
  }

  List<PhotoModel> pho = [];
  bool isLoading = true;

  setNameAndSrId() {
    pho = [];
    final allUserRef = Provider.of<AllUser>(context, listen: false);
    if (allUserRef.verifiedUsers.length == 0) {
      allUserRef.getAllUsers().then((value) {
        final ref = allUserRef.verifiedUsers;
        ref.forEach((user) {
          photos.forEach((photo) {
            if (photo.userId == user.id && !photo.isVerified!) {
              pho.add(PhotoModel(
                  imageUrl: photo.imageUrl,
                  isVerified: photo.isVerified,
                  name: user.name,
                  photoId: photo.photoId,
                  srId: user.srId,
                  userId: user.id));
            }
          });
        });
      });
      return;
    }
    final ref = allUserRef.verifiedUsers;
    ref.forEach((user) {
      photos.forEach((photo) {
        if (photo.userId == user.id && !photo.isVerified!) {
          pho.add(PhotoModel(
              imageUrl: photo.imageUrl,
              isVerified: photo.isVerified,
              name: user.name,
              photoId: photo.photoId,
              srId: user.srId,
              userId: user.id));
        }
      });
    });
    print("pho length===>${pho.length}");
  }

  @override
  void initState() {
    setUserPhoto().then((value) {
      setNameAndSrId();
      setState(() {
        isLoading = false;
      });
    });
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
            'Verify Photos',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Card(
              //   margin: EdgeInsets.symmetric(
              //     horizontal: 20,
              //     vertical: 15,
              //   ),
              //   elevation: 10,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(35),
              //   ),
              //   child: Container(
              //     height: 55,
              //     padding: EdgeInsets.symmetric(
              //       horizontal: 20,
              //       vertical: 8,
              //     ),
              //     alignment: Alignment.centerLeft,
              //     child: TextFormField(
              //       cursorColor: HexColor('357f78'),
              //       decoration: InputDecoration(
              //         hintText: "Search User",
              //         border: InputBorder.none,
              //         suffixIcon: IconButton(
              //           onPressed: () {},
              //           icon: Icon(
              //             Icons.search,
              //             color: Colors.black,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(
                height: height * .01,
              ),
              Container(
                width: width,
                height: height * .875,
                child: ListView.builder(
                  itemCount: pho.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PhotoScreen(
                                  imageUrl: pho[index].imageUrl ?? '',
                                  photoId: pho[index].photoId!,
                                  userId: pho[index].userId!,
                                )));
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                      pho[index].name!,
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
                                  Container(
                                    child: Text(
                                      'SRID-',
                                      style: GoogleFonts.openSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: width * .7,
                                    child: Text(
                                      pho[index].srId!,
                                      style: GoogleFonts.openSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: height * .01,
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
