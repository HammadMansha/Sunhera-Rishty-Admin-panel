import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:sunhare_rishtey_new_admin/Screens/subcriptionMemberHistory.dart';
import 'package:sunhare_rishtey_new_admin/config/theme.dart';
import 'package:sunhare_rishtey_new_admin/models/memberShip.dart';

class SubscriptionsScreen extends StatefulWidget {
  @override
  _SubscriptionsScreenState createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<MemberShip> memberShips = [];
  List<MemberShip> tempUsers = [];
  bool isPhone = false;
  bool isId = false;
  bool isName = true;
  bool isLoading = false;
  TextEditingController contact_controller = TextEditingController();
  TextEditingController validity_controller = TextEditingController();
  DateTime dateTime = DateTime.now();
  final _key = GlobalKey<FormState>();


  Future<void> _handleRefresh() async {
    setState(() {
      isLoading = true;
    });
    getActivePlan().then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future getActivePlan() async {
    final data = await FirebaseDatabase.instance
        .reference()
        .child('ActiveMembership')
        .once();
    if (data.snapshot.value != null) {
      memberShips = [];
      final subs = data.snapshot.value as Map;
      subs.forEach((keyId, value) {
        print("key====>>>>>${keyId}");
        List<MemberShipHistory> history = [];
        if (value["history"] != null) {
          var data = value["history"] as Map;
          data.forEach((key, value) {
            history.add(MemberShipHistory(
                price: value["price"] ?? 0.0,
                planName: value['planName'],
                validTill: DateTime.parse(
                    value['validTill'] ?? '2021-07-16 15:33:44.343'),
                startTime: DateTime.parse(
                    value['startTime'] ?? '2021-07-16 15:33:44.343'),
                contacts: value['contacts'],
                packageId: value['packageId']));
          });
        }
        memberShips.add(MemberShip(
            parentId: keyId,
            email: value['email'],
            startTime: DateTime.parse(value['DateOfPerchase'] ?? '2021-07-16 15:33:44.343'),
            nameUser: value['name'],
            id: value['packageId'],
            phone: value['phone'],
            price: value['amount'],
            planName: value['packageName'],
            srId: value['srId'],
            history: history,
            imageUrl: value['imageUrl'] ?? '',
            contacts: value['contacts'],
            validTill: DateTime.parse(value['ValidTill']),
        ));
      });
      tempUsers = [...memberShips];
      tempUsers.sort(
          (MemberShip a, MemberShip b) => b.startTime!.compareTo(a.startTime!));
      setState(() {});
    }
  }

  search(String a) {
    tempUsers = [...memberShips];
    if (isName) {
      memberShips.forEach((element) {
        if (!element.nameUser!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    } else if (isPhone) {
      memberShips.forEach((element) {
        if (!element.phone!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    } else if (isId) {
      memberShips.forEach((element) {
        if (!element.srId!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getActivePlan();
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
            'Subscription',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: isLoading
            ? SpinKitThreeBounce(
                color: Colors.blue,
              )
            : LiquidPullToRefresh(
                color: HexColor('70c4bc'),
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
                                    getActivePlan();
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
                              setState(() {});
                              isPhone = false;
                              isName = true;
                              isId = false;
                              tempUsers = [...memberShips];
                              tempUsers.sort((MemberShip a, MemberShip b) =>
                                  b.startTime!.compareTo(a.startTime!));
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
                              setState(() {});
                              isPhone = true;
                              isName = false;
                              isId = false;
                              tempUsers = [...memberShips];
                              tempUsers.sort((MemberShip a, MemberShip b) =>
                                  b.startTime!.compareTo(a.startTime!));
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
                              setState(() {});
                              isPhone = false;
                              isName = false;
                              isId = true;
                              tempUsers = [...memberShips];
                              tempUsers.sort((MemberShip a, MemberShip b) =>
                                  b.startTime!.compareTo(a.startTime!));
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
                      Divider(thickness: 1.0),
                      Container(
                        width: width,
                        height: height * .75,
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
                                child: InkWell(
                                  onTap: () {
                                    if (tempUsers[index].history!.length > 0) {
                                      print(tempUsers[index]);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SubscriptionMemberHistory(
                                            membershiphistory: tempUsers[index],
                                          ),
                                        ),
                                      );
                                    }
                                  },
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
                                            height: height * .18,
                                            width: width * .28,
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
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tempUsers[index].nameUser!,
                                                overflow: TextOverflow.clip,
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'ID - ${tempUsers[index].srId}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'No. -${tempUsers[index].phone}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'Email - ${tempUsers[index].email}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'Plan - ${tempUsers[index].planName}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Start Date -${tempUsers[index].startTime!.day}/${tempUsers[index].startTime!.month}/${tempUsers[index].startTime!.year}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                'End Date - ${tempUsers[index].validTill!.day}/${tempUsers[index].validTill!.month}/${tempUsers[index].validTill!.year}',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  InkWell(
                                                    child: Container(
                                                      child: Text(
                                                        'Edit',style: TextStyle(color: white),
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color: HexColor('357f78'),
                                                          borderRadius: BorderRadius.circular(8)
                                                      ),
                                                      alignment: Alignment.center,
                                                      height: 35,width: 70,
                                                      margin: EdgeInsets.only(left: 8),
                                                    ),
                                                    onTap: (){
                                                      print("contacts12121212121=========>>>>${tempUsers[index].contacts}");
                                                      print("contacts12121212121=========>>>>${tempUsers[index].validTill!}");
                                                      print("contacts12121212121=========>>>>${tempUsers[index].parentId!}");
                                                      editAlert(validity: "${tempUsers[index].validTill!}",contacts: tempUsers[index].contacts,id: tempUsers[index].parentId!);
                                                    },
                                                  ),
                                                  InkWell(
                                                    child: Container(
                                                      child: Text(
                                                        'Cancel',style: TextStyle(color: white),
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color: HexColor('357f78'),
                                                          borderRadius: BorderRadius.circular(8)
                                                      ),
                                                      alignment: Alignment.center,
                                                      height: 35,width: 70,
                                                      margin: EdgeInsets.only(left: 8),
                                                    ),
                                                    onTap: (){
                                                      cancelAlert(id: tempUsers[index].parentId!);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // Column(
                                          //   mainAxisAlignment: MainAxisAlignment.center,
                                          //   children: [
                                          //     IconButton(icon: Icon(Icons.edit)),
                                          //     Icon(Icons.cancel)
                                          //   ],
                                          // ),
                                        ],
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
      ),
    );
  }

  cancelAlert({String? id}){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure to cancel this user membership?"),
          actions: [
            MaterialButton(
                child: Text("OK",style: TextStyle(color: white)),
              color: HexColor('357f78'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onPressed: () {
                  FirebaseDatabase.instance
                      .reference()
                      .child('ActiveMembership')
                      .child(id!)
                      .remove().then((value){
                    getActivePlan();
                    Navigator.of(context).pop();
                    Fluttertoast.showToast(msg: 'Membership cancel Successfully');
                    setState(() {});
                  });
                },
            ),
            MaterialButton(
              child: Text("Cancel",style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  editAlert({String? validity,num? contacts,String? id}){
    contact_controller.text = contacts.toString();
    print("contacts=========>>>>$contacts");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit membership validity"),
          content: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Contacts",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextFormField(
                  controller: contact_controller,
                  cursorColor: HexColor('357f78'),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 5),
                    hintText: "Enter contacts",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: HexColor('357f78')),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor('357f78')),
                        borderRadius: BorderRadius.circular(5)
                    ),
                  ),
                  validator: (val){
                    if(val!.isEmpty){
                      return 'Enter contacts';
                    }else{
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                Text("Validity",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                DateTimePicker(
                  type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'd MMM, yyyy',
                  initialValue: validity,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialTime: TimeOfDay(hour: 23, minute: 59),
                  icon: Icon(Icons.event),
                  dateLabelText: 'Date',
                  timeLabelText: "Hour",
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'req';
                    } else {
                      dateTime = DateTime.parse(val);
                      return null;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            MaterialButton(
              child: Text("Update",style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                if(_key.currentState!.validate()){
                  print("dateTime selected is===>>>$dateTime");
                  print("dateTime selected is===>>>${contact_controller.text}");
                  FirebaseDatabase.instance
                      .reference()
                      .child('ActiveMembership')
                      .child(id!)
                      .update({
                    "ValidTill": dateTime.toString(),
                    "contacts": int.parse(contact_controller.text),
                  }).then((value) {
                    getActivePlan();
                    Navigator.of(context).pop(true);
                    setState(() {});
                  });
                }
              },
            ),
            MaterialButton(
              child: Text("Cancel",style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
