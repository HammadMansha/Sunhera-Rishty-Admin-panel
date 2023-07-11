import 'dart:developer';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/models/packageMadel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:provider/provider.dart';

class DiscountScreen extends StatefulWidget {
  @override
  _DiscountScreenState createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  List<UserInformation> users = [];
  List<String> notificationIds = [];

  @override
  initState() {
    super.initState();
    getPackageData();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    final res = Provider.of<AllUser>(context);
    users = res.verifiedUsers;
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
            ));
          });

          setState(() {});
        }
      }
    });
  }

  final _key = GlobalKey<FormState>();
  double discount = 0.0;
  DateTime dateTime = DateTime.now();

  void addDialog(BuildContext context, Package package) async {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    dateTime = (package.discountTillDateTime != null
        ? package.discountTillDateTime
        : DateTime.now())!;
    discount = (package.discount != null ? package.discount : 0)!;
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
            height: height * .25,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      'Date upto -',
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
                      child: DateTimePicker(
                        type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'd MMM, yyyy',
                        initialValue: dateTime.toString(),
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
                      )),
                  SizedBox(
                    height: height * .015,
                  ),
                  Container(
                    child: Text(
                      'Discount',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .01,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
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
                      initialValue: discount.toString(),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (val) {
                        if (val!.isEmpty)
                          return 'req';
                        else if (double.tryParse(val) == null)
                          return 'must be a number';
                        else {
                          discount = double.parse(val.trim());
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Discount",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .015,
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
                log(dateTime.toIso8601String());
                FirebaseDatabase.instance
                    .reference()
                    .child('PremiumPackage')
                    .child(package.id!)
                    .update({
                  'discount': discount,
                  'months': dateTime.toIso8601String()
                }).then((value) {
                  Navigator.of(context).pop(true);
                  // sendNotification("New Discount",
                  // "$discount% discount available on ${package.name} package.");
                  NotificationSender().sendPushNotifications(
                      "/topics/discount",
                      "New Discount",
                      "$discount% discount available on ${package.name} package.",
                      target: Constants.USER_DISCOUNT);
                  setState(() {});
                });
              }
            },
          )
        ],
      ),
    );
  }

  void deleteDialog(BuildContext context, Package package) async {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    dateTime = (package.discountTillDateTime != null
        ? package.discountTillDateTime
        : DateTime.now())!;
    discount = (package.discount != null ? package.discount : 0)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        content: Form (
          key: _key,
          child: Container (
            // height: height / 10,
            child: SingleChildScrollView (
              child: Column (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container (
                    child: Text (
                      'Delete discount -',
                      style: GoogleFonts.openSans(fontSize: 20),
                    ),
                  ),
                  SizedBox(height: height * .015),
                  Container (
                    child: Text (
                      'Are you sure went to delete discount.',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton (
            child: Text (
              "Cancel",
              style: GoogleFonts.lato (
                fontSize: 15,
                color: Colors.red,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: Text(
              "Delete",
              style: GoogleFonts.lato(
                fontSize: 15,
                color: HexColor('70c4bc'),
              ),
            ),
            onPressed: () {
              if (_key.currentState!.validate()) {
                log(dateTime.toIso8601String());
                FirebaseDatabase.instance
                    .reference()
                    .child('PremiumPackage')
                    .child(package.id ?? "")
                    .remove().then((value) {
                  Navigator.of(context).pop(true);
                  // sendNotification("New Discount",
                  // "$discount% discount available on ${package.name} package.");
                  /*  NotificationSender().sendPushNotifications(
                      "/topics/discount",
                      "New Discount",
                      "$discount% discount available on ${package.name} package.",
                      target: Constants.USER_DISCOUNT);*/
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('70c4bc'),
          title: Text(
            'Discount',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
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
                            vertical: 8, horizontal: 12),
                        child: Column(
                          children: [
                            SizedBox(
                              height: height * .001,
                            ),
                            Row(
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
                                  child: Text(
                                    '₹ ${packageList[index].price}',
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
                              children: [
                                Container(
                                  width: 140,
                                  child: Text(
                                    'Discount end on -',
                                    style: GoogleFonts.openSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: width * .5,
                                  child: Text(
                                    ' ${packageList[index].discountTillDateTime != null ?packageList[index].discountTillDateTime : 'not defined'}',
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
                              children: [
                                Container(
                                  width: 140,
                                  child: Text(
                                    'Discount',
                                    style: GoogleFonts.openSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: width * .5,
                                  child: Text(
                                    '${packageList[index].discount} %',
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    addDialog(context, packageList[index]);
                                  },
                                  child: Container(
                                    width: width * .30,
                                    height: height * .05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
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
                                InkWell(
                                  onTap: () {
                                    // addDialog(context, packageList[index]);
                                    deleteDialog(context, packageList[index]);
                                  },
                                  child: Container(
                                    width: width * .30,
                                    height: height * .05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
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
                                )
                              ],
                            ),
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
    );
  }
}
