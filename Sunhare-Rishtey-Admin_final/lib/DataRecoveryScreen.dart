import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:provider/provider.dart';

class DataRecoveryScreen extends StatefulWidget {
  DataRecoveryScreen({Key? key}) : super(key: key);

  @override
  State<DataRecoveryScreen> createState() => _DataRecoveryScreenState();
}

class _DataRecoveryScreenState extends State<DataRecoveryScreen> {
  int totalProfiles = 0;
  int profileRemaining = 0;
  List allStorage = [];
  List users = [];
  String downloadUrl = '';
  UserInformation currentUser = UserInformation();

  @override
  void initState() {
    super.initState();
    getData();
    /* FirebaseStorage.instance.ref().child("CustomerDP").listAll().then((value) {
      data = value.items as Map;
      print("~~~~~~~~~~~~~~~ ${data.length}");
      setState(() {});
    }); */
  }

  int skip = 370;

  void getData() async {
    final ref = Provider.of<AllUser>(context, listen: false);
    users = [...ref.verifiedUsers];
    totalProfiles = users.length;

    for (int i = 0; i < skip; i++) {
      users.removeAt(0);
    }

    profileRemaining = users.length;
    currentUser = users.first;
    users.removeAt(0);

    /* ListResult result =
        await FirebaseStorage.instance.ref().child("CustomerDP").listAll();
    allStorage = result.prefixes;

    print("~~~~~~~~~~ ${allStorage.first}");

    totalProfiles = result.prefixes.length;
 */
    /* result.prefixes.forEach((Reference ref) async {
      try {
        ref.child("CustomerID.jpg").getDownloadURL().then((value) {
          setState(() {
            totalProfiles++;
          });
        });
      } catch (e) {
        print(e);
      }
    }); */
    setState(() {});
  }

  List<String> idList = [
    'Aadhar Card',
    'PAN Card',
    'Driving License',
    'Passport',
  ];

  bool adhar = true;
  bool pan = false;
  bool driving = false;
  bool passport = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    try {
      FirebaseStorage.instance
          .ref()
          .child("CustomerDP")
          .child("${currentUser.id}")
          .child("CustomerID.jpg")
          .getDownloadURL()
          .then((value) {
        downloadUrl = value;
        if (downloadUrl == null) {
          currentUser = users.first;
          profileRemaining--;
          downloadUrl = "";
          users.removeAt(0);
          setState(() {});
          Fluttertoast.showToast(msg: "No Image Found");
          downloadUrl = "";
        }
        setState(() {});
      });
    } catch (e) {
      currentUser = users.first;
      profileRemaining--;
      downloadUrl = "";
      users.removeAt(0);
      setState(() {});
      Fluttertoast.showToast(msg: "No Image Found");
      downloadUrl = "";
      setState(() {});
      print(e);
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('IDs ($profileRemaining/$totalProfiles)'),
          backgroundColor: HexColor('70c4bc'),
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(currentUser.id! + "   " + currentUser.srId!),
              downloadUrl == null
                  ? Container()
                  : Image.network(
                      downloadUrl,
                      fit: BoxFit.contain,
                      width: width,
                      height: width,
                    ),
              Row(
                children: [
                  Checkbox(
                    value: adhar,
                    onChanged: (val) {
                      setState(() {
                        adhar = val!;
                      });
                    },
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          adhar = !adhar;
                        });
                      },
                      child: Text(idList[0])),
                  Checkbox(
                    value: pan,
                    onChanged: (val) {
                      setState(() {
                        pan = val!;
                      });
                    },
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          pan = !pan;
                        });
                      },
                      child: Text(idList[1]))
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: driving,
                    onChanged: (val) {
                      setState(() {
                        driving = val!;
                      });
                    },
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          driving = !driving;
                        });
                      },
                      child: Text(idList[2])),
                  Checkbox(
                    value: passport,
                    onChanged: (val) {
                      setState(() {
                        passport = val!;
                      });
                    },
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          passport = !passport;
                        });
                      },
                      child: Text(idList[3])),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  currentUser = users.first;
                  profileRemaining--;
                  downloadUrl = "";
                  users.removeAt(0);
                  setState(() {});
                },
                child: Text("Skip"),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(12),
                    elevation: 2,
                    textStyle: TextStyle(fontSize: 24)),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  if (downloadUrl == null) {
                    currentUser = users.first;
                    profileRemaining--;
                    downloadUrl = "";
                    users.removeAt(0);
                    setState(() {});
                    return;
                  }

                  Fluttertoast.showToast(
                      msg: "Please wait",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.yellow,
                      textColor: Colors.black,
                      fontSize: 16.0);

                  String verificationBy = "";
                  if (adhar)
                    verificationBy = "Aadhar Card";
                  else if (pan)
                    verificationBy = "PAN Card";
                  else if (driving)
                    verificationBy = "Driving License";
                  else if (passport) verificationBy = "Passport";

                  Map verified = Map();
                  verified[verificationBy] = downloadUrl;

                  Map update = Map();
                  update["imageUrl"] = downloadUrl;
                  update["isVerified"] = true;
                  update["name"] = currentUser.name;
                  update["srId"] = currentUser.srId;
                  update["userId"] = currentUser.id;
                  update["verificationBy"] = verificationBy;
                  update["verified"] = verified;
                  update["verifiedBy"] = verificationBy;

                  FirebaseDatabase.instance
                      .reference()
                      .child("Gov Id")
                      .update({currentUser.id!: update}).then((value) {
                    currentUser = users.first;
                    profileRemaining--;
                    downloadUrl = "";
                    users.removeAt(0);
                    setState(() {});
                  });
                },
                child: Text("Update"),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(12),
                    elevation: 2,
                    textStyle: TextStyle(fontSize: 24)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
