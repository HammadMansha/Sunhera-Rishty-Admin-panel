import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:sunhare_rishtey_new_admin/provider/getTrashUsers.dart';
import 'UserInformationScreen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TrashScreen extends StatefulWidget {
  @override
  _TrashScreenState createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {

  bool isLoading = true;
  var trashProvider;

  getData() async {
    final trashProvider = Provider.of<TrashUsers>(context, listen: false);

    await trashProvider.getAllUsers();
    setState(() {
      trashUsers = trashProvider.trashUsers.cast<UserInformation>();
      tempUsers = [...trashUsers];
      tempUsers.sort((UserInformation a, UserInformation b) =>
          b.deletedOn!.compareTo(a.deletedOn!));
      isLoading = false;
    });
  }

  String setDateInYYYYMMDD(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String setSubtractDateInYYYYMMDD(DateTime dateTime) {
    DateTime tempDate = dateTime.subtract(Duration(days: 15));
    return DateFormat('yyyy-MM-dd').format(tempDate);
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
  }

  // List<UserInformation> memberShips = [];
  List<UserInformation> tempUsers = [];
  bool isPhone = false;
  bool isId = false;
  bool isName = true;

  List<UserInformation> trashUsers = [];
  search(String a) {
    print("Searching...");
    tempUsers = [...trashUsers];
    if (isName) {
      trashUsers.forEach((element) {
        if (!element.name!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
          setState(() {});
        }
      });
    } else if (isPhone) {
      trashUsers.forEach((element) {
        if (!element.phone!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
          setState(() {});
        }
      });
    } else if (isId) {
      trashUsers.forEach((element) {
        if (!element.srId!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
          setState(() {});
        }
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
      this.tempUsers.clear();
      this.trashUsers.clear();
    });
    Provider.of<TrashUsers>(context, listen: false).getAllUsers().then((value) {
      setState(() {
        isLoading = false;
      });
      getData();
    });
  }

  showPermanentDeleteConfirmation(UserInformation user){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No')),
            TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  print("mapped key is===>>${user.id}");

                  await FirebaseDatabase.instance
                      .reference()
                      .child('trash')
                      .child(user.id!)
                      .remove();

                  await FirebaseDatabase.instance
                      .reference()
                      .child('User Information').child(user.id!).remove();

                  setState(() {
                    Fluttertoast.showToast(msg: 'Profile deleted!');
                    getData();
                  });

                },
                child: Text('Yes')),
          ],
          content: Container(
            child: const Text('Do you really want to permanent delete this user?'),
          ),
        ));
  }

  showRestoreConfirmation(UserInformation user) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No')),
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      print("mapped key is===>>${user.id}");
                      var userRes = Provider.of<AllUser>(context, listen: false);

                      final now = DateTime.now();
                      final after15days = now.add(Duration(days: 1000));

                      var datas = await FirebaseDatabase.instance
                           .reference()
                           .child('User Information').child(user.id!).update({
                        "inTrash" : false, "isDeleteByAdmin": false});
                      // 'AccountDeleteDate': after15days.toIso8601String()

                     //  bool isExist = false;
                     //  var datas = await FirebaseDatabase.instance
                     //      .reference()
                     //      .child('User Information').child(user.id!)
                     //      .once();
                     // Map mappedData = (datas.snapshot.value ?? {}) as Map;
                     // if(mappedData.isNotEmpty){
                     //   print("not empty");
                     //   isExist = true;
                     //   // mappedData.forEach((key, value) {
                     //   //   print("mapped value is===>>${value}");
                     //   //   if(value['phone'] == "7801915788"){
                     //   //     print("::::: phone exists: " + key!);
                     //   //     isExist = true;
                     //   //     return;
                     //   //   }
                     //   // });
                     // }else{
                     //   print("empty");
                     //   isExist = false;
                     // }

                      // bool isExist = false;
                      // userRes.verifiedUsers.forEach((element) {
                      //   if (element.phone == user.phone) {
                      //     print("::::: phone exists: " + element.id!);
                      //     isExist = true;
                      //     return;
                      //   }
                      // });
                      // if (isExist) {
                      //   Fluttertoast.showToast(
                      //       msg: "User Already exist with this number");
                      //   return;
                      // }

                      Fluttertoast.showToast(
                          msg: 'Profile is being restored please wait');

                      final data = await FirebaseDatabase.instance
                          .reference()
                          .child('trash')
                          .child(user.id!)
                          .once();

                      Map fdata = data.snapshot.value as Map;

                      if (fdata.isNotEmpty) {
                        final mapped = data.snapshot.value as Map;
                        await FirebaseDatabase.instance
                            .reference()
                            .child("User Information")
                            .update({'${data.snapshot.key}': mapped});
                        await FirebaseDatabase.instance
                            .reference()
                            .child('trash')
                            .child(user.id!)
                            .remove();

                        setState(() {
                          Fluttertoast.showToast(msg: 'Profile restored!');
                          getData();
                        });

                        userRes.verifiedUsers.add(user);
                        trashProvider.trashUsers.remove(user);
                        tempUsers.remove(user);
                        trashUsers.remove(user);
                      }
                    },
                    child: Text('Yes')),
              ],
              content: Container(
                child: Text('Do you really want to restore this user?'),
              ),
            ));
  }

  @override
  void initState() {
    getData();
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
            'Trash',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [],
        ),
        body: isLoading
            ? SpinKitThreeBounce(
                color: Colors.blue,
              )
            : LiquidPullToRefresh(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextFormField(
                              onChanged: (value) {
                                setState(() {
                                  if (value.isEmpty) {
                                    tempUsers.clear();
                                    getData();
                                  }
                                  search(value.trim());
                                });
                              },
                              cursorColor: HexColor('357f78'),
                              decoration: InputDecoration(
                                hintText: "Search User",
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              isPhone = false;
                              isName = true;
                              isId = false;
                              setState(() {});
                              // tempUsers = [...trashUsers];
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: isName ? Colors.blue : Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              width: MediaQuery.of(context).size.width * .15,
                              height: MediaQuery.of(context).size.height * .05,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Center(child: Text('Name')),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              isPhone = true;
                              isName = false;
                              isId = false;
                              setState(() {});
                              // tempUsers = [...trashUsers];
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .15,
                              height: MediaQuery.of(context).size.height * .05,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: isPhone ? Colors.blue : Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Center(child: Text('Phone')),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              isPhone = false;
                              isName = false;
                              isId = true;
                              setState(() {});
                              // tempUsers = [...trashUsers];
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * .15,
                              height: MediaQuery.of(context).size.height * .05,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: isId ? Colors.blue : Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Center(child: Text('Id')),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 5.0,
                      ),
                      Container(
                        width: width,
                        height: height * .7,
                        child: ListView.builder(
                          itemCount: tempUsers.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 10,
                              color: Colors.white,
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
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                          height: height * .15,
                                          width: width * .23,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  tempUsers[index].imageUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * .03,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tempUsers[index].name!,
                                              overflow: TextOverflow.clip,
                                              style: GoogleFonts.openSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'ID: ${tempUsers[index].srId}',
                                              style: GoogleFonts.openSans(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              'Mobile: ${tempUsers[index].phone}',
                                              style: GoogleFonts.openSans(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              'Email: ${(tempUsers[index].email ?? "").toLowerCase()}',
                                              style: GoogleFonts.openSans(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              'Gender: ${tempUsers[index].gender}',
                                              style: GoogleFonts.openSans(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              'Joined: ' +
                                                  setDateInYYYYMMDD(
                                                      tempUsers[index]
                                                          .joinedOn!),
                                              style: GoogleFonts.openSans(
                                                fontSize: 13,
                                              ),
                                            ),
                                            tempUsers[index].deletedReason == "Deleted By Admin" ? Text(
                                              'Deleted: ' +
                                                  setDateInYYYYMMDD(tempUsers[index].deletedOn!),
                                              // 'Deleted on. - ${tempUsers[index].deletedOn.day}/${tempUsers[index].deletedOn.month}/${tempUsers[index].deletedOn.year}',
                                              style: GoogleFonts.openSans(
                                                fontSize: 13,
                                              ),
                                            ) : Text(
                                              'Deleted: ' +
                                                  setSubtractDateInYYYYMMDD(tempUsers[index].deletedOn!),
                                              // 'Deleted on. - ${tempUsers[index].deletedOn.day}/${tempUsers[index].deletedOn.month}/${tempUsers[index].deletedOn.year}',
                                              style: GoogleFonts.openSans(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              'Deleted By: ${tempUsers[index].deletedBy}',
                                              style: GoogleFonts.openSans(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Container(
                                              width: width * .7,
                                              child: Text(
                                                'Deleted Reason: ${tempUsers[index].deletedReason}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: height * .01,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (contecct) =>
                                                    HomeScreen(
                                                        tempUsers[index], true, packageList: const []),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: width * .13,
                                            height: height * .05,
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: HexColor('357f78'),
                                            ),
                                            child: Icon(
                                              MdiIcons.eye,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * .03,
                                        ),
                                        InkWell(
                                          onTap: () async{
                                            showRestoreConfirmation(tempUsers[index]);
                                            // Navigator.of(context).push(
                                            //   MaterialPageRoute(
                                            //     builder: (contecct) =>
                                            //         HomeScreen(
                                            //             tempUsers[index], true),
                                            //   ),
                                            // );
                                          },
                                          child: Container(
                                            width: width * .13,
                                            height: height * .05,
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              color: HexColor('357f78'),
                                            ),
                                            child: Icon(
                                              MdiIcons.restore,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * .03,
                                        ),
                                        InkWell(
                                          onTap: () async{
                                            showPermanentDeleteConfirmation(tempUsers[index]);
                                          },
                                          child: Container(
                                            width: width * .13,
                                            height: height * .05,
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                              BorderRadius.circular(6),
                                              color: HexColor('357f78'),
                                            ),
                                            child: Icon(
                                              MdiIcons.delete,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
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
      ),
    );
  }
}
