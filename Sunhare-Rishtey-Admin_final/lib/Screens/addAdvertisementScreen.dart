import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/models/advertisementModel.dart';
import '../main.dart';
import 'package:uuid/uuid.dart';

class AddAdvertisement extends StatefulWidget {
  @override
  _AddAdvertisementState createState() => _AddAdvertisementState();
}

class _AddAdvertisementState extends State<AddAdvertisement> {
  String name = "";
  String adType = 'Interstitial';
  String imageUrl = "";
  double months = 0.0;
  double timeDuration = 0.0;
  bool hideAdType = false;

  List<String> adTypeList = [
    'Banner',
    'Interstitial',
    'Native',
  ];

  List<AdvertisementModel> advertisementList = [];

  @override
  void initState() {
    //  getPackageData();
    super.initState();
  }

  bool isLoading = false;

  File? image;
  Future<void> picker() async {
    // ignore: unused_local_variable
    File document;
    var val2;
    // ignore: unused_local_variable
    var _imagesetting = false;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Choose Image"),
        content: Text("Please choose a Image for your profile"),
        actions: <Widget>[
          ElevatedButton.icon(
            icon: Icon(Icons.camera),
            label: Text("Camera"),
            onPressed: () async {
              _pickImageCamera();

              Navigator.of(ctx).pop(true);
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.image),
            label: Text("Gallery"),
            onPressed: () async {
              _pickImageGallery();
              Navigator.of(ctx).pop(true);
            },
          ),
        ],
      ),
    );
    setState(() {
      if (val2 == null) {
        return;
      } else {
        image = val2;
      }
    });
  }

  File? imageFile;

  Future<Null> _pickImageGallery() async {
    final pickedImage = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 60);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        _cropImage();
      });
    }
  }

  Future<Null> _pickImageCamera() async {
    final pickedImage = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 60);
    imageFile = pickedImage != null
        ? File(
            pickedImage.path,
          )
        : null;
    if (imageFile != null) {
      setState(() {
        _cropImage();
      });
    }
  }

  // Future<Null> _cropImage() async {
  //   File croppedFile = (await ImageCropper().cropImage(
  //       sourcePath: imageFile!.path,
  //       aspectRatio: adType == "Banner"
  //           ? CropAspectRatio(ratioX: 1280, ratioY: 268)
  //           : adType == "Native"
  //               ? CropAspectRatio(ratioX: 8, ratioY: 5)
  //               : CropAspectRatio(ratioX: 4, ratioY: 6),
  //       // androidUiSettings: AndroidUiSettings(
  //       //   toolbarTitle: 'Crop',
  //       //   toolbarColor: Colors.deepOrange,
  //       //   toolbarWidgetColor: Colors.white,
  //       //   //  initAspectRatio: CropAspectRatioPreset.original,
  //       //   lockAspectRatio: true,
  //       // ),
  //       // iosUiSettings: IOSUiSettings(
  //       //   title: 'Crop your image',
  //       //   aspectRatioLockEnabled: true,
  //       // ),
  //   )) as File;
  //   if (croppedFile != null) {
  //     imageFile = croppedFile;
  //
  //     compressFile(croppedFile).then((value) {
  //       image = value;
  //       setState(() {
  //         hideAdType = true;
  //       });
  //     });
  //     // image = croppedFile;
  //     //  state = AppState.cropped;
  //
  //   }
  // }

  Future _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
        aspectRatio: adType == "Banner"
            ? CropAspectRatio(ratioX: 1280, ratioY: 268)
            : adType == "Native"
            ? CropAspectRatio(ratioX: 8, ratioY: 5)
            : CropAspectRatio(ratioX: 4, ratioY: 6),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            //  initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop your image',
            aspectRatioLockEnabled: true,
          ),
          WebUiSettings(
            context: context,
          ),
        ]
    );
    if (croppedFile != null) {
      imageFile = File(croppedFile.path);

      compressFile(File(croppedFile.path)).then((value) {
        image = value;
        setState(() {
          hideAdType = true;
        });
      });
      // image = croppedFile;
      //  state = AppState.cropped;

    }
  }

  Future<File> compressFile(File file) async {
    final filePath = file.absolute.path;
    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 20,
    );
    // print(file.lengthSync());
    // print(result.lengthSync());
    return result!;
  }

  Future<void> uploadButton(String adverId) async {
    // ignore: unused_local_variable
    final user = FirebaseAuth.instance.currentUser;
    if (image != null) {
      Fluttertoast.showToast(msg: 'Uploading');
      final ref = FirebaseStorage.instance
          .ref()
          .child("Advertisement")
          .child(DateTime.now().toString())
          .child("Advertisement" + ".jpg");
      await ref.putFile(image!);

      imageUrl = await ref.getDownloadURL();
      try {
        await FirebaseDatabase.instance
            .reference()
            .child("Advertisement")
            .child(adverId)
            .update({'imageURL': imageUrl}).then((value) {
          setState(() {});
        });
      } catch (e) {
        Fluttertoast.showToast(
            msg: e.toString(), backgroundColor: HexColor('fa9033'),
        );
      }
    }
  }

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add'),
        backgroundColor: HexColor('70c4bc'),
      ),
      body: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: height * .02,
                ),
                Container(
                  child: Text(
                    'Title',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  height: height * .01,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  // height: height * .06,
                  width: width,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      5,
                    ),
                  ),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) {
                      if (val!.isEmpty)
                        return 'required';
                      else if (val.length < 3) {
                        return 'Too short';
                      } else {
                        name = val.trim();
                        return null;
                      }
                    },
                    // cursorColor: theme.colorCompanion,
                    decoration: InputDecoration(
                      hintText: "Title",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: height * .02,
                ),
                hideAdType
                    ? Container()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'Type',
                              style: GoogleFonts.openSans(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * .01,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            // height: height * .06,
                            width: width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorGrey,
                              ),
                              color: theme.colorBackground,
                              borderRadius: BorderRadius.circular(
                                5,
                              ),
                            ),
                            child: DropdownButtonFormField(
                              value: adTypeList[1],
                              validator: (val) {
                                if (val == null) {
                                  return 'Required';
                                } else
                                  return null;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              hint: Text('Select'),
                              items: adTypeList.map((e) {
                                return DropdownMenuItem(
                                    value: e, child: Text(e));
                              }).toList(),
                              onChanged: (value) {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                adType = value!;
                              },
                            ),
                          ),
                          SizedBox(
                            height: height * .015,
                          )
                        ],
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                        height: height * .21,
                        width: width * .7,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child:
                            //  widget.userInfo.imageUrl == null
                            // ?
                            image == null
                                ? InkWell(
                                    onTap: () {
                                      setState(() {});
                                      picker();
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: height * .01,
                                        ),
                                        Text(
                                          'Click Here',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'to upload',
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * .01,
                                          width: width * 1,
                                        ),
                                        Icon(
                                          MdiIcons.camera,
                                          size: 35,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    child: Image.file(image!),
                                  )),
                  ),
                ),
                SizedBox(
                  height: height * .015,
                ),
                Container(
                  child: Text(
                    'Months',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  height: height * .01,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  // height: height * .06,
                  width: width,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      5,
                    ),
                  ),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    validator: (val) {
                      if (val!.isEmpty)
                        return 'req';
                      else if (double.tryParse(val) == null)
                        return 'must be a number';
                      else {
                        months = double.parse(val.trim());
                        return null;
                      }
                    },
                    // cursorColor: theme.colorCompanion,
                    decoration: InputDecoration(
                      hintText: "Months",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: height * .015,
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: HexColor('70c4bc'),
                    ),
                    child: Text(
                      "ADD",
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      if (image == null) {
                        Fluttertoast.showToast(msg: 'Please Select image First');
                        return;
                      }
                      if (_key.currentState!.validate()) {
                        print("xxx${months}");
                        print("xxx${DateTime.now().add(Duration(days: 30 * int.parse(months.toStringAsFixed(0)))).toIso8601String()}");
                        String key = Uuid().v4();
                        uploadButton(key).then((value) {
                          FirebaseDatabase.instance
                              .reference()
                              .child('Advertisement')
                              .child(key)
                              .update({
                            'months': months,
                            'imageURL': imageUrl,
                            'createdOn': DateTime.now().toIso8601String(),
                            'status': true,
                            'adType': adType,
                            'title': name,
                            'Expiry': DateTime.now().add(Duration(days: 30 * int.parse(months.toStringAsFixed(0)))).toIso8601String()
                          }).then((value) {
                            Navigator.of(context).pop(true);
                            image = null;
                            setState(() {});
                          });
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
