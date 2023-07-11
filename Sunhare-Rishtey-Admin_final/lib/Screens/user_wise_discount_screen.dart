import 'dart:developer';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/models/discount_group_model.dart';
import 'package:sunhare_rishtey_new_admin/models/discount_user_model.dart';
import 'package:sunhare_rishtey_new_admin/models/packageMadel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:sunhare_rishtey_new_admin/config/theme.dart';
import 'package:sunhare_rishtey_new_admin/provider/groupProvider.dart';

class UserWiseDiscountScreen extends StatefulWidget {
  @override
  _UserWiseDiscountScreenState createState() => _UserWiseDiscountScreenState();
}

class _UserWiseDiscountScreenState extends State<UserWiseDiscountScreen> {

  DateTime selectedDate = DateTime.now();

  String selectedId = "";
  String name = "";
  double dicountPercentage = 0.0;
  int expireDate = 0;
  int months = 0;
  // double userAcOldDays = 0.0;
  // String userAcOldDate = "";

  List<UserInformation> users = [];
  List<String> notificationIds = [];

  List<UserInformation> selectedUserList = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController discountPerController = TextEditingController();
  TextEditingController userAcOldController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();

  String expDate = "";
  String startDate = "";

  String userNameStr = "";
  String userImageUrlStr = "";
  String userIdStr = "";

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

  List<DiscountUserWiseModel> packageList = [];
  getPackageData() {
    FirebaseDatabase.instance
        .reference()
        .child('Discount User Wise')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        if (data != null) {
          packageList = [];
          data.forEach((key, value) {
            packageList.add (
                DiscountUserWiseModel (
                  id: key,
                  name: value['name'].toString(),
                  // userAcOldDays: value['user_ac_old_days'].toString(),
                  // userAcOldDate: value['user_ac_old_date'].toString(),
                  startDate: value['start_date'].toString(),
                  expireDate: value['expire_date'].toString(),
                  discountPercentage: value['discount_percentage'].toString(),
                  userId: value['user_id'].toString(),
                  userName: value['user_name'].toString(),
                  imageUrl: value['image_url'].toString(),
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

          if (!mounted) return;
          try {
            setState(() {});
          } catch(e) {

          }
        }
      } else {
        packageList = [];
        setState(() { });
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
        extendBody: true,
        appBar: AppBar (
          backgroundColor: HexColor('70c4bc'),
          title: Text (
            'Discount User Wise',
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
                  selectedUserList.clear();
                  addNewDiscountGroup(context, false, -1);
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
                  padding: EdgeInsets.only(bottom: 20),
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
                      margin: const EdgeInsets.symmetric (
                        horizontal: 7,
                        vertical: 10,
                      ),
                      child: Padding (
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Column (
                          children: [

                            packageList[index].imageUrl != null && packageList[index].imageUrl!.isNotEmpty ?
                            CachedNetworkImage(imageUrl: packageList[index].imageUrl ?? "", height: 100, width: 150,) : const SizedBox(),
                            SizedBox(height: height * .01),
                            discountGroup(width, "User Id -", packageList[index].userId ?? ""),
                            SizedBox(height: height * .01),
                            discountGroup(width, "User name -", packageList[index].userName ?? ""),
                            SizedBox(height: height * .001),
                            discountGroup(width, "Name - ", packageList[index].name ?? ""),
                            SizedBox(height: height * .01),
                            discountGroup(width, "Discount % -", "₹ ${packageList[index].discountPercentage}"),
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
                                    // userAcOldDays = double.parse(packageList[index].userAcOldDays ?? "0.0");
                                    // userAcOldDate = packageList[index].userAcOldDate ?? "";
                                    expDate = packageList[index].expireDate ?? "";
                                    startDate = packageList[index].startDate ?? "";
                                    DateTime getDate = DateTime.parse(expDate);

                                    nameController.text = packageList[index].name ?? "";
                                    discountPerController.text = packageList[index].discountPercentage ?? "";
                                    // userAcOldController.text = packageList[index].userAcOldDays ?? "";
                                    expireDateController.text = DateFormat("dd-MM-yyyy").format(getDate);
                                    userNameStr = packageList[index].userName ?? "";
                                    userImageUrlStr = packageList[index].imageUrl ?? "";
                                    userIdStr = packageList[index].userId ?? "";
                                    addNewDiscountGroup(context, true, index);
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
                                    FirebaseDatabase.instance.reference().child('Discount User Wise').child(packageList[index].id ?? "").remove().then((value) {
                                      // setState(() {});
                                    });
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
              SizedBox(height: height * .01),

            ],
          ),
        ),
      ),
    );
  }

  void addNewDiscountGroup(BuildContext context, bool isEdit, int index) async {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    showDialog (
      context: context,
      builder: (ctx) => AlertDialog (
        contentPadding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        content: Form(
          key: _key,
          child: StatefulBuilder(
            builder: (context, setStateAlert) {
              return Container(
                height: height * .37,
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

                      SizedBox(height: height * .02),
                      // Text("User name  (${selectedUserList[index].id})", style: const TextStyle(color: Colors.black))
                      isEdit ?  SizedBox() :
                      InkWell (
                        onTap: () async {
                           var getUserListData = await  Navigator.push(context, MaterialPageRoute(builder: (context) => SelectUserScreen(selectedUserList: selectedUserList)));
                            if(getUserListData != null) {
                              selectedUserList = getUserListData;
                             }
                             setStateAlert(() { });
                            },
                        child: Text("Select User (${selectedUserList.length})", style: TextStyle(color: Colors.black)),
                      ),

                    ],
                  ),
                ),
              );
            }
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              isEdit ? "Update" : "ADD",
              style: GoogleFonts.lato(
                fontSize: 15,
                color: HexColor('70c4bc'),
              ),
            ),
            onPressed: () {
              if (_key.currentState!.validate()) {

                String startDate = DateTime.now().toIso8601String();
                DiscountUserWiseModel discountUserWiseModel = DiscountUserWiseModel();

                if(isEdit) {
                  discountUserWiseModel.name = name;
                  discountUserWiseModel.discountPercentage = dicountPercentage.toString();
                  // discountUserWiseModel.userAcOldDays = userAcOldDays.toString();
                  // discountUserWiseModel.userAcOldDate = userAcOldDate;
                  discountUserWiseModel.expireDate = expDate;
                  discountUserWiseModel.startDate = startDate;
                  discountUserWiseModel.userName = userNameStr;
                  discountUserWiseModel.imageUrl = userImageUrlStr;
                  discountUserWiseModel.userId = userIdStr;

                  debugPrint("element.id ==> ${selectedId}");
                  FirebaseDatabase.instance.reference().child('Discount User Wise').
                  child(selectedId??"").update(discountUserWiseModel.toJson()).then((value) {
                    Navigator.of(context).pop(true);
                    setState(() {});
                  });
                } else {
                  selectedUserList.forEach((element) {

                    discountUserWiseModel.name = name;
                    discountUserWiseModel.discountPercentage = dicountPercentage.toString();
                    // discountUserWiseModel.userAcOldDays = userAcOldDays.toString();
                    // discountUserWiseModel.userAcOldDate = userAcOldDate;
                    discountUserWiseModel.expireDate = expDate;
                    discountUserWiseModel.startDate = startDate;
                    discountUserWiseModel.userName = element.name;
                    discountUserWiseModel.imageUrl = element.imageUrl;
                    discountUserWiseModel.userId = element.srId;

                    FirebaseDatabase.instance.reference().child('Discount User Wise').
                    child(element.id??"").update(discountUserWiseModel.toJson()).then((value) {});
                  });
                  Navigator.of(context).pop();
                  setState(() {});
                }



                // if(isEdit) {
                //   debugPrint("selectedId ==> ${selectedId}");
                //   FirebaseDatabase.instance.reference().child('Discount User Wise').child(selectedId)
                //       .update(discountGroupModel.toJson()).then((value) {
                //     Navigator.of(context).pop(true);
                //     setState(() {});
                //   });
                // } else {
                //   FirebaseDatabase.instance.reference().child('Discount User Wise')
                //       .push().update(discountGroupModel.toJson()).then((value) {
                //     Navigator.of(context).pop(true);
                //     setState(() {});
                //   });
                // }
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

}


class SelectUserScreen extends StatefulWidget {

  final List<UserInformation> selectedUserList;
  const SelectUserScreen({super.key, required this.selectedUserList});

  @override
  _SelectUserScreenState createState() => _SelectUserScreenState();
}

class _SelectUserScreenState extends State<SelectUserScreen> {
  String gender = "All";
  List<String> genderList = [
    'All',
    'Male',
    'Female',
  ];
  List<String> suspendedFilter = ['All', 'Suspended', 'Not Suspended'];

  bool isLoading = false;

  Future<void> _getUserData() async {
    setState(() {
      isLoading = true;
    });
    Provider.of<AllUser>(context, listen: false).getRecentDeleteUsers().then((value) {
      setState(() {
        isLoading = false;
        isRefreshed = true;
      });
      Provider.of<AllUser>(context, listen: false).updateList();
    });
  }

  bool isRefreshed = false;

  List<Package> packageList = [];

  getPackageData() {
    FirebaseDatabase.instance.reference().child('PremiumPackage').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map;
        if (data != null) {
          packageList = [];
          data.forEach((key, value) {
            packageList.add(Package(
                id: key,
                contacts: int.parse(value['contacts'].toString()),
                discount: double.tryParse(value['discount'].toString()) ?? 0,
                discountTillDateTime: DateTime.tryParse(value['months'].toString()) ?? null,
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

  List<UserInformation> pendingReq = [];
  List<UserInformation> allUsers = [];
  List<UserInformation> tempUsers = [];

  List<UserInformation> selectedUserList = [];

  bool run = true;
  bool isPhone = false;
  bool isName = true;
  bool isId = false;
  String suspended = "All";

  TextEditingController contact_controller = TextEditingController();
  TextEditingController validity_controller = TextEditingController();
  DateTime dateTime = DateTime.now();
  final _key = GlobalKey<FormState>();

  String timeAgoCustom(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    // if (diff.inDays > 365)
    //   return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    // if (diff.inDays > 30)
    //   return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    // if (diff.inDays > 7)
    //   return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    return "${(diff.inDays).floor()} ${(diff.inDays).floor() == 1 ? "Days" : "Days"} ago";
    if (diff.inDays > 0) return "${DateFormat.E().add_jm().format(d)}";
    if (diff.inHours > 0) return "Today ${DateFormat('jm').format(d)}";
    if (diff.inMinutes > 0) return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "Never";
  }

  AllUser res = AllUser();

  @override
  Future<void> didChangeDependencies() async {
    res = Provider.of<AllUser>(context);
    res.verifiedUsers.sort((UserInformation a, UserInformation b) => b.joinedOn!.compareTo(a.joinedOn!));
    pendingReq = res.verifiedUsers;
    allUsers = [...pendingReq];
    if (run) {
      tempUsers = [...allUsers];
      run = false;
    }

    super.didChangeDependencies();
  }

  search(String a) {
    tempUsers = [...allUsers];
    if (isName) {
      allUsers.forEach((element) {
        if (!element.name!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    } else if (isPhone) {
      allUsers.forEach((element) {
        if (!element.phone!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    } else if (isId) {
      allUsers.forEach((element) {
        if (!element.srId!.toLowerCase().contains(a.toLowerCase().trim())) {
          tempUsers.remove(element);
        }
      });
    }
  }

  filterGender(String gender) {
    allUsers.forEach((element) {
      if (!(element.gender!.toLowerCase() == gender.toLowerCase())) {
        tempUsers.remove(element);
      }
    });
  }

  suspendeFilter(String suspended) {
    if (suspended == 'Suspended')
      allUsers.forEach((element) {
        if (!(element.suspended!)) {
          tempUsers.remove(element);
        }
      });
    else {
      allUsers.forEach((element) {
        if ((element.suspended!)) {
          tempUsers.remove(element);
        }
      });
    }
  }

  String searchVal = "";
  var groupedUsersRef;
  var allUsersref;
  Map? checkPremiumData;
  bool checkPremiumLoad = false;

  @override
  void initState() {
    _getUserData();
    checkUserPremium();
    groupedUsersRef = Provider.of<GroupdedProvider>(context, listen: false);
    allUsersref = Provider.of<AllUser>(context, listen: false);
    getPackageData();
    if(widget.selectedUserList.isNotEmpty) {
      selectedUserList = widget.selectedUserList;
    }
    super.initState();
  }

  checkUserPremium() async {
    checkPremiumLoad = true;
    final data = await FirebaseDatabase.instance.reference().child('ActiveMembership').once();
    setState(() {
      checkPremiumData = data.snapshot.value as Map;
      checkPremiumLoad = false;
    });
    print("checkPremiumData=========>>>${checkPremiumData}");
  }

  @override
  Widget build(BuildContext context) {
    if (isRefreshed) {
      tempUsers = [...allUsers];
      isRefreshed = false;
    }
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // onWillPop: () async {
    //   Navigator.pop(context, selectedUserList);
    //   return false;
    // },
    return SafeArea (
      child: Scaffold (
        extendBody: true,
        appBar: AppBar (
          backgroundColor: HexColor('70c4bc'),
          //  leading: IconButton (
          //     onPressed: () {
          //       Navigator.pop(context, selectedUserList);
          //     },
          //     icon: const Icon(Icons.arrow_back, color: Colors.white)),
          title: Text (
            'Select User',
            style: GoogleFonts.openSans (
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        bottomNavigationBar: SizedBox (
          height: 55,
          child: Align (
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                List<UserInformation> sendSelectedUserList = [];
                sendSelectedUserList = selectedUserList;
                Navigator.pop(context, sendSelectedUserList);
              },
              child: Container (
                height: 50,
                width: 125,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration (
                  color: HexColor('70c4bc'),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: const Text("Ok", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ),
        body: isLoading
            ? const SpinKitThreeBounce(color: Colors.blue)
            : LiquidPullToRefresh (
          color: HexColor('70c4bc'),
          onRefresh: () {
            return _getUserData();
          },
          child: checkPremiumLoad == true
              ? Center(child: CircularProgressIndicator(color: HexColor('357f78')))
              : SingleChildScrollView (
            child: Column (
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        searchVal = value;
                                        if (value.isEmpty) {
                                          tempUsers = allUsers;
                                        }
                                        search(value.trim());
                                      });
                                    },
                                    cursorColor: HexColor('357f78'),
                                    decoration: InputDecoration (
                                      hintText: "Search User",
                                      border: InputBorder.none,
                                      suffixIcon: IconButton (
                                        onPressed: () {
                                          search(searchVal.trim());
                                        },
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {});
                                    isPhone = false;
                                    isName = true;
                                    isId = false;
                                    tempUsers = [...allUsers];
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
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
                                    tempUsers = [...allUsers];
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * .15,
                                    height: MediaQuery.of(context).size.height * .05,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
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
                                    tempUsers = [...allUsers];
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * .15,
                                    height: MediaQuery.of(context).size.height * .05,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
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
                            SizedBox(height: height * .001),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 10),
                                    // width: width * .38,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        5,
                                      ),
                                    ),
                                    child: DropdownButtonFormField(
                                      value: gender,
                                      validator: (val) {
                                        if (val == null) {
                                          return 'Required';
                                        } else
                                          return null;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      hint: Text('Gender'),
                                      items: genderList.map((e) {
                                        return DropdownMenuItem(value: e, child: Text(e));
                                      }).toList(),
                                      onChanged: (value) {
                                        gender = value!;
                                        tempUsers = [...allUsers];
                                        setState(() {
                                          if (value == 'All')
                                            tempUsers = [...allUsers];
                                          else {
                                            filterGender(gender);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.only(left: 5, right: 10, top: 10, bottom: 10),
                                    // width: width / 2,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        5,
                                      ),
                                    ),
                                    child: DropdownButtonFormField(
                                      value: suspended,
                                      validator: (val) {
                                        if (val == null) {
                                          return 'Required';
                                        } else
                                          return null;
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      hint: Text('Account Type'),
                                      items: suspendedFilter.map((e) {
                                        return DropdownMenuItem(value: e, child: Text(e));
                                      }).toList(),
                                      onChanged: (value) {
                                        suspended = value!;
                                        tempUsers = [...allUsers];
                                        setState(() {
                                          if (value == 'All')
                                            tempUsers = [...allUsers];
                                          else {
                                            suspendeFilter(value);
                                            //  filterGender(gender);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: width * .1),
                            Container(
                              width: width,
                              height: height * .85,
                              child: tempUsers.isEmpty
                                  ? const Center(
                                      child: Text("No recent delete record found", style: TextStyle(fontSize: 17)),
                                    )
                                  : ListView.builder(
                                      itemCount: tempUsers.length,
                                      itemBuilder: (context, index) {
                                        bool isSuspended = tempUsers[index].suspended != null ? tempUsers[index].suspended! : false;
                                        String lastLogin = (tempUsers[index].lastLogin ?? "Never") == "Never"
                                            ? "Never"
                                            : timeAgoCustom(DateTime.parse(tempUsers[index].lastLogin!));
                                        print("lastLogin====>>>>$lastLogin");
                                        print("img url===>>${tempUsers[index].imageUrl!}");
                                        return InkWell(
                                          onTap: () {
                                            bool isDataAvailable = selectedUserList.map((item) => item.id).contains(tempUsers[index].id);
                                            if (isDataAvailable) {
                                              selectedUserList.remove(tempUsers[index]);
                                            } else {
                                              selectedUserList.add(tempUsers[index]);
                                            }
                                            setState(() {});
                                          },
                                          child: Card(
                                            elevation: 10,
                                            color: Colors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(width: width * .03),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8,
                                                    ),
                                                    height: height * .15,
                                                    width: width * .23,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: CachedNetworkImage(imageUrl: tempUsers[index].imageUrl!),
                                                    ),
                                                  ),
                                                  SizedBox(width: width * .05),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          tempUsers[index].name!,
                                                          maxLines: 2,
                                                          style: GoogleFonts.openSans(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: checkPremiumData!.containsKey(tempUsers[index].id) ? Colors.red : black),
                                                        ),
                                                        Text(
                                                          "ID -" + tempUsers[index].srId!,
                                                          style: GoogleFonts.openSans(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        Text(
                                                          'No. - ${tempUsers[index].phone}',
                                                          style: GoogleFonts.openSans(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Joined - ${tempUsers[index].joinedOn!.day}/${tempUsers[index].joinedOn!.month}/${tempUsers[index].joinedOn!.year}',
                                                          style: GoogleFonts.openSans(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        Text(
                                                          'User Status : ${tempUsers[index].userStatus}',
                                                          style: GoogleFonts.openSans(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Gender : ${tempUsers[index].gender}',
                                                          style: GoogleFonts.openSans(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment: Alignment.centerRight,
                                                          child: selectedUserList.map((item) => item.id).contains(tempUsers[index].id)
                                                              ? Container(
                                                                  height: 25,
                                                                  width: 25,
                                                                  alignment: Alignment.center,
                                                                  margin: const EdgeInsets.only(right: 15, bottom: 5),
                                                                  decoration: BoxDecoration(
                                                                      shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1)),
                                                                  child: const Icon(Icons.check, size: 18))
                                                              : SizedBox(),
                                                        ),
                                                        /* Text(
                                                    'Last login : ${lastLogin}',
                                                    style: GoogleFonts.openSans(
                                                      fontSize: 13,
                                                    ),
                                                  ), */
                                                      ],
                                                    ),
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

  editAlert({String? validity, String? contacts, String? id}) {
    contact_controller.text = contacts!;
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
                Text("Contacts", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                TextFormField(
                  controller: contact_controller,
                  cursorColor: HexColor('357f78'),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
                    hintText: "Enter contacts",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: HexColor('357f78')), borderRadius: BorderRadius.circular(5)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: HexColor('357f78')), borderRadius: BorderRadius.circular(5)),
                  ),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Enter contacts';
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(height: 10),
                Text("Validity", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
              child: Text("Update", style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                if (_key.currentState!.validate()) {
                  print("dateTime selected is===>>>$dateTime");
                  print("dateTime selected is===>>>${contact_controller.text}");
                  FirebaseDatabase.instance.reference().child('ActiveMembership').child(id!).update({
                    "ValidTill": dateTime.toString(),
                    "contacts": int.parse(contact_controller.text),
                  }).then((value) {
                    // getActivePlan();
                    Navigator.of(context).pop(true);
                    setState(() {});
                  });
                }
              },
            ),
            MaterialButton(
              child: Text("Cancel", style: TextStyle(color: white)),
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

  cancelAlert({String? id}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure to cancel this user membership?"),
          actions: [
            MaterialButton(
              child: Text("OK", style: TextStyle(color: white)),
              color: HexColor('357f78'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                FirebaseDatabase.instance.reference().child('ActiveMembership').child(id!).remove().then((value) {
                  // getActivePlan();
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(msg: 'Membership cancel Successfully');
                  checkUserPremium();
                  setState(() {});
                });
              },
            ),
            MaterialButton(
              child: Text("Cancel", style: TextStyle(color: white)),
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
}


