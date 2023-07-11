import 'dart:developer';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/main.dart';
import 'package:sunhare_rishtey_new_admin/models/discount_group_model.dart';
import 'package:sunhare_rishtey_new_admin/models/packageMadel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:provider/provider.dart';

class DateWiseDiscountScreen extends StatefulWidget {
  @override
  _DateWiseDiscountScreenState createState() => _DateWiseDiscountScreenState();
}

class _DateWiseDiscountScreenState extends State<DateWiseDiscountScreen> {

  DateTime selectedDate = DateTime.now();

  String selectedId = "";
  String name = "";
  double dicountPercentage = 0.0;
  int expireDate = 0;
  int months = 0;
  double userAcOldDays = 0.0;
  String userAcOldDate = "";

  List<UserInformation> users = [];
  List<String> notificationIds = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController discountPerController = TextEditingController();
  TextEditingController userAcOldController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();

  String expDate = "";
  String startDate = "";

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

  List<DiscountGroupModel> packageList = [];
  getPackageData() {
    FirebaseDatabase.instance
        .reference()
        .child('Discount Group')
        .onValue
        .listen((event) {
      packageList = [];
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        if (data != null) {
          data.forEach((key, value) {
            packageList.add (
                DiscountGroupModel (
                  id: key,
                  name: value['name'].toString(),
                  userAcOldDays: value['user_ac_old_days'].toString(),
                  userAcOldDate: value['user_ac_old_date'].toString(),
                  startDate: value['start_date'].toString(),
                  expireDate: value['expire_date'].toString(),
                  discountPercentage: value['discount_percentage'].toString(),
                )
            );

            // packageList.add(Package(
            //   id: key,
            //   contacts: int.parse(value['contacts'].toString()),
            //   discount: double.tryParse(value['discount'].toString()) ?? 0,
            //   discountTillDateTime:
            //   DateTime.tryParse(value['months'].toString()) ?? null,
            //   price: double.parse(value['price'].toString()),
            //   name: value['name'],
            //   timeDuration: double.parse(value['timeDuration'].toString()),
            // ));
          });
          setState(() {});
        }
      }
    });
  }

  final _key = GlobalKey<FormState>();
  double discount = 0.0;
  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea (
      child: Scaffold (
        appBar: AppBar (
          backgroundColor: HexColor('70c4bc'),
          title: Text (
            'Discount Group',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding (
              padding: const EdgeInsets.all(8.0),
              child: IconButton (
                onPressed: () {
                  // addDialog(context);
                  nameController.clear();
                  discountPerController.clear();
                  userAcOldController.clear();
                  expireDateController.clear();
                  addNewDiscountGroup(context, false);
                },
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView (
          child: Column (
            children: [

              SizedBox(height: height * .01),

              Container (
                width: width,
                height: height * .9,
                child: packageList.isEmpty ? const Center (
                  child: Text("No any discount group", style: TextStyle(fontSize: 17)),
                ) : ListView.builder(
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
                            SizedBox(height: height * .001),
                            discountGroup(width, "Name - ", packageList[index].name ?? ""),
                            SizedBox(height: height * .01),
                            discountGroup(width, "Discount % -", "${packageList[index].discountPercentage} %"),
                            SizedBox(height: height * .01),
                            discountGroup(width, "User ac old (Days) -", packageList[index].userAcOldDays ?? ""),
                            SizedBox(height: height * .01),
                            SizedBox(height: height * .01),
                            discountGroup(width, "Discount end on -", packageList[index].expireDate ?? ""),
                            SizedBox(height: height * .01),
                            Row (
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell (
                                  onTap: () {
                                    // addDialog(context, packageList[index]);

                                    selectedId = packageList[index].id ?? "";
                                    name = packageList[index].name ?? "";
                                    dicountPercentage = double.parse(packageList[index].discountPercentage ?? "0.0");
                                    userAcOldDays = double.parse(packageList[index].userAcOldDays ?? "0.0");
                                    userAcOldDate = packageList[index].userAcOldDate ?? "";
                                    expDate = packageList[index].expireDate ?? "";
                                    startDate = packageList[index].startDate ?? "";
                                    DateTime getDate = DateTime.parse(expDate);

                                    nameController.text = packageList[index].name ?? "";
                                    discountPerController.text = packageList[index].discountPercentage ?? "";
                                    userAcOldController.text = packageList[index].userAcOldDays ?? "";
                                    expireDateController.text = DateFormat("dd-MM-yyyy").format(getDate);
                                    addNewDiscountGroup(context, true);
                                  },
                                  child: Container(
                                    width: width * .30,
                                    height: height * .05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: HexColor('357f78'),
                                    ),
                                    child: Center (
                                      child: Text (
                                        "Edit",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell (
                                  onTap: () {
                                    selectedId = packageList[index].id ?? "";
                                    deleteDialog(context, index);
                                  },
                                  child: Container(
                                    width: width * .30,
                                    height: height * .05,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: HexColor('357f78'),
                                    ),
                                    child: Center (
                                      child: Text (
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

  void addNewDiscountGroup(BuildContext context, bool isEdit) async {
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
                  Text(
                    'Name',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: height * .01),
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
                      controller: nameController,
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
                  SizedBox(height: height * .015),

                  Text (
                    'Discount percentage',
                    style: GoogleFonts.openSans (
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: height * .01),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    // height: height * .06,
                    width: width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular (
                        5,
                      ),
                    ),
                    child: TextFormField (
                      controller: discountPerController,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (val) {
                        if (val!.isEmpty)
                          return 'req';
                        else if (double.tryParse(val) == null)
                          return 'must be a number';
                        else {
                          dicountPercentage = double.parse(val.trim());
                          return null;
                        }
                      },
                      // cursorColor: theme.colorCompanion,
                      decoration: InputDecoration (
                        hintText: "Discount percentage",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * .015
                  ),

                  Text (
                    'User AC Old (days)',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: height * .01),
                  Container (
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    //  height: height * .12,
                    width: width,
                    decoration: BoxDecoration (
                      border: Border.all (
                        color: Colors.grey,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextFormField (
                      controller: userAcOldController,
                      validator: (val) {
                        if (val!.isEmpty)
                          return 'req';
                        else if (double.tryParse(val) == null)
                          return 'must be a number';
                        else {
                          userAcOldDays = double.parse(val.trim());
                          var date = new DateTime.now();
                          String newDate = DateTime(date.year, date.month, date.day - userAcOldDays.toInt()).toIso8601String();
                          // debugPrint("newDate ==> ${newDate}");
                          // String getDateFormat = DateFormat("dd-MM-yyyy").format(newDate);
                          userAcOldDate = newDate;
                          return null;
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "User Ac Old",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: height * .015),

                  Text (
                    'Expire date',
                    style: GoogleFonts.openSans(fontSize: 14),
                  ),
                  SizedBox(height: height * .01),
                  Container (
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    //  height: height * .12,
                    width: width,
                    decoration: BoxDecoration (
                      border: Border.all (
                        color: Colors.grey,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextFormField (
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        _selectDate(context);
                      },
                      controller: expireDateController,
                      // validator: (val) {
                      //   if (val!.isEmpty)
                      //     return 'req';
                      //   else if (int.tryParse(val) == null)
                      //     return 'must be a number';
                      //   else {
                      //     expireDate = int.parse(val.trim());
                      //     return null;
                      //   }
                      // },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration (
                        hintText: "Expire date",
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

                String startDate = DateTime.now().toIso8601String();

                DiscountGroupModel discountGroupModel = DiscountGroupModel();
                discountGroupModel.name = name;
                discountGroupModel.discountPercentage = dicountPercentage.toString();
                discountGroupModel.userAcOldDays = userAcOldDays.toString();
                discountGroupModel.userAcOldDate = userAcOldDate;
                discountGroupModel.expireDate = expDate;
                discountGroupModel.startDate = startDate;

                if(isEdit) {
                  debugPrint("selectedId ==> ${selectedId}");
                  FirebaseDatabase.instance.reference().child('Discount Group').child(selectedId)
                      .update(discountGroupModel.toJson()).then((value) {
                    Navigator.of(context).pop(true);
                    setState(() {});
                  });
                } else {
                  FirebaseDatabase.instance.reference().child('Discount Group')
                      .push().update(discountGroupModel.toJson()).then((value) {
                    Navigator.of(context).pop(true);
                    setState(() {});
                  });
                }
              }
            },
          )
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker (
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101)
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        String getDate = selectedDate.toIso8601String();
        expDate = getDate;
        String getDateFormat = DateFormat("dd-MM-yyyy").format(selectedDate);
        expireDateController.text = getDateFormat;
      });
    }
  }

  Widget discountGroup(double width, String title, String details) {
    return Row (
      children: [
        Container(width: 150,
          child: Text(title,
              style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        Container(width: width * .5, child: Text(details, style: GoogleFonts.openSans(fontSize: 13)))
      ],
    );
  }

  void deleteDialog(BuildContext context, int index) async {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    showDialog (
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
                    child: Text(
                      'Delete discount group -',
                      style: GoogleFonts.openSans(fontSize: 20),
                    ),
                  ),
                  SizedBox(height: height * .015),
                  Container (
                    child: Text (
                      'Are you sure went to delete discount group.',
                      style: GoogleFonts.openSans(fontSize: 14),
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
          TextButton (
            child: Text(
              "Delete",
              style: GoogleFonts.lato(
                fontSize: 15,
                color: HexColor('70c4bc'),
              ),
            ),
            onPressed: () {
              if (_key.currentState!.validate()) {
                FirebaseDatabase.instance.reference().child('Discount Group').child(selectedId)
                    .remove().then((value) {
                  // packageList.removeAt(index);
                  getPackageData();
                  Navigator.of(context).pop(true);
                  Future.delayed(const Duration(seconds: 1), ()  {
                    setState(() {});
                  });
                });
              }
            },
          )
        ],
      ),
    );
  }

}
