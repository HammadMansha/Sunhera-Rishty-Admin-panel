import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sunhare_rishtey_new_admin/models/packageMadel.dart';

class PackagesScreen extends StatefulWidget {
  @override
  _PackagesScreenState createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  String name = "";
  double price = 0.0;
  int numberOfContacts = 0;
  int months = 0;
  double timeDuration = 0.0;
  File? imageFile;
  File? image;

  void hidePackage(Package package) {
    FirebaseDatabase.instance
        .reference()
        .child('PremiumPackage')
        .child(package.id!)
        .update({'isHide': !package.isHide!})
        .then((value) => {getPackageData()})
        .catchError((error) => print('Failed: $error'));
  }

  List<Package> packageList = [];
  getPackageData() {
    FirebaseDatabase.instance
        .reference()
        .child('PremiumPackage')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        if (data != null) {
          packageList = [];

          data.forEach((key, value) {
            packageList.add(Package(
                id: key,
                contacts: int.parse(value['contacts'].toString()),
                discount: double.tryParse(value['discount'].toString()) ?? 0,
                discountTillDateTime:
                    DateTime.tryParse(value['months'].toString()) ?? null,
                price: double.parse(value['price'].toString()),
                name: value['name'],
                timeDuration: double.parse(value['timeDuration'].toString()),
                isHide: value['isHide']));
          });

          setState(() {});
        }
      }
    });
  }

  @override
  void initState() {
    getPackageData();
    super.initState();
  }

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

  Future _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile!.path,
        aspectRatio: CropAspectRatio(ratioX: 8, ratioY: 5),
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
        // androidUiSettings: AndroidUiSettings(
        //   toolbarTitle: 'Crop',
        //   toolbarColor: Colors.deepOrange,
        //   toolbarWidgetColor: Colors.white,
        //   //  initAspectRatio: CropAspectRatioPreset.original,
        //   lockAspectRatio: true,
        // ),
        // iosUiSettings: IOSUiSettings(
        //   title: 'Crop your image',
        //   aspectRatioLockEnabled: true,
        // ),
    );
    if (croppedFile != null) {
      imageFile = File(croppedFile.path);

      compressFile(File(croppedFile.path)).then((value) {
        image = value;
        uploadPic(image!);
        setState(() {
          // hideAdType = true;
        });
      });
      // image = croppedFile;
      //  state = AppState.cropped;

    }
  }

  Future<File?> compressFile(File file) async {
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
    return result;
  }

  Future<void> uploadPic(File imageFile) async {
    if (image != null) {
      Fluttertoast.showToast(msg: 'Uploading');
      final ref = FirebaseStorage.instance.ref().child("offerBanner" + ".png");
      await ref.putFile(image!);
    }
  }

  final _key = GlobalKey<FormState>();

  void addDialog(BuildContext context) async {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        content: Form(
          key: _key,
          child: Container(
            height: height * .45,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      'Name',
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
                        hintText: "Name",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .015,
                  ),
                  Container(
                    child: Text(
                      'Price',
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
                          price = double.parse(val.trim());
                          return null;
                        }
                      },
                      // cursorColor: theme.colorCompanion,
                      decoration: InputDecoration(
                        hintText: "Price",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .015,
                  ),
                  Container(
                    child: Text(
                      'Number of contacts',
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
                    //  height: height * .12,
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
                      validator: (val) {
                        if (val!.isEmpty)
                          return 'req';
                        else if (int.tryParse(val) == null)
                          return 'must be a number';
                        else {
                          numberOfContacts = int.parse(val.trim());
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "number",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .015,
                  ),
                  Container(
                    child: Text(
                      'Time Duration',
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
                    //  height: height * .12,
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
                      validator: (val) {
                        if (val!.isEmpty)
                          return 'req';
                        else if (double.tryParse(val) == null)
                          return 'must be a number';
                        else {
                          timeDuration = double.parse(val.trim());
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "In months",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              "ADD",
              style: GoogleFonts.lato(
                fontSize: 15,
                color: HexColor('70c4bc'),
              ),
            ),
            onPressed: () {
              if (_key.currentState!.validate()) {
                FirebaseDatabase.instance
                    .reference()
                    .child('PremiumPackage')
                    .push()
                    .update({
                  'contacts': numberOfContacts,
                  'price': price,
                  //'months': months,
                  'timeDuration': timeDuration,
                  'name': name,
                  'isHide': false
                }).then((value) {
                  Navigator.of(context).pop(true);
                  setState(() {});
                });
              }
            },
          )
        ],
      ),
    );
  }

  void editDialog(BuildContext context, Package package) async {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    String name = package.name!;
    double price = package.price!;
    int numberOfContacts = package.contacts!;

    double timeDuration = package.timeDuration!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        content: Form(
          key: _key,
          child: Container(
            height: height * .45,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      'Name',
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
                      initialValue: package.name,
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
                      decoration: InputDecoration(
                        hintText: "Name",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .015,
                  ),
                  Container(
                    child: Text(
                      'Price',
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
                      initialValue: price.toString(),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (val) {
                        if (val!.isEmpty)
                          return 'req';
                        else if (double.tryParse(val) == null)
                          return 'must be a number';
                        else {
                          price = double.parse(val.trim());
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Price",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .015,
                  ),
                  Container(
                    child: Text(
                      'Number of contacts',
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
                    //  height: height * .12,
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
                      initialValue: numberOfContacts.toString(),
                      validator: (val) {
                        if (val!.isEmpty)
                          return 'req';
                        else if (int.tryParse(val) == null)
                          return 'must be a number';
                        else {
                          numberOfContacts = int.parse(val.trim());
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "number",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .015,
                  ),
                  Container(
                    child: Text(
                      'Time Duration',
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
                      initialValue: timeDuration.toString(),
                      validator: (val) {
                        if (val!.isEmpty)
                          return 'req';
                        else if (double.tryParse(val) == null)
                          return 'must be a number';
                        else {
                          timeDuration = double.parse(val.trim());
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "In months",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          // ignore: deprecated_member_use
          MaterialButton(
            child: Text(
              "Update",
              style: GoogleFonts.lato(
                fontSize: 15,
                color: HexColor('70c4bc'),
              ),
            ),
            onPressed: () {
              if (_key.currentState!.validate()) {
                FirebaseDatabase.instance
                    .reference()
                    .child('PremiumPackage')
                    .child(package.id!)
                    .update({
                  'contacts': numberOfContacts,
                  'price': price,
                  //'months': months,
                  'timeDuration': timeDuration,
                  'name': name
                }).then((value) {
                  Navigator.of(context).pop(true);
                  setState(() {});
                });
              }
            },
          )
        ],
      ),
    );
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
            'Packages',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  addDialog(context);
                },
                icon: Icon(
                  Icons.add,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * .01,
              ),
              Container(
                  width: width,
                  height: height * .9,
                  child: Stack(alignment: Alignment.topCenter, children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 52, 0, 0),
                      child: ListView.builder(
                        itemCount: packageList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 10,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: width * .03,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: height * .001,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 120,
                                                child: Text(
                                                  'Name -',
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: width * .5,
                                                child: Text(
                                                  packageList[index].name!,
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: height * .01,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 120,
                                                child: Text(
                                                  'Price -',
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: width * .5,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '₹ ${packageList[index].price}',
                                                      style:
                                                          GoogleFonts.openSans(
                                                        decoration: packageList[
                                                                        index]
                                                                    .discount !=
                                                                0
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    packageList[index]
                                                                .discount !=
                                                            0
                                                        ? Text(
                                                            '₹ ${packageList[index].price! - packageList[index].discount! * packageList[index].price! * .01}',
                                                            style: GoogleFonts
                                                                .openSans(
                                                              fontSize: 14,
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: height * .01,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 120,
                                                child: Text(
                                                  'Time Period -',
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: width * .5,
                                                child: Text(
                                                  '${packageList[index].timeDuration} month subscription',
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: height * .01,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 120,
                                                child: Text(
                                                  'Contacts -',
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: width * .5,
                                                child: Text(
                                                  packageList[index]
                                                      .contacts
                                                      .toString(),
                                                  style: GoogleFonts.openSans(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .01,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          editDialog(
                                              context, packageList[index]);
                                        },
                                        child: Container(
                                          width: width * .22,
                                          height: height * .05,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: HexColor('357f78'),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Edit",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .06,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          hidePackage(packageList[index]);
                                        },
                                        child: Container(
                                          width: width * .22,
                                          height: height * .05,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: HexColor('357f78'),
                                          ),
                                          child: Center(
                                            child: Text(
                                              packageList[index].isHide!
                                                  ? "UnHide"
                                                  : "Hide",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .06,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (packageList.length == 1) {
                                            packageList.clear();
                                            setState(() {});
                                          }
                                          FirebaseDatabase.instance
                                              .reference()
                                              .child('PremiumPackage')
                                              .child(packageList[index].id!)
                                              .remove();
                                          setState(() {});
                                        },
                                        child: Container(
                                          width: width * .22,
                                          height: height * .05,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: HexColor('357f78'),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .04,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Upload Featured Image'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal,
                      ),
                      onPressed: () {
                        picker();
                      },
                    )
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
