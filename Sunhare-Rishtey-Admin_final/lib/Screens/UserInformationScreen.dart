// import 'package:age/age.dart';
import 'package:age_calculator/age_calculator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:sunhare_rishtey_new_admin/Screens/IDViewScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/photoListScreen.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/config/theme.dart';
import 'package:sunhare_rishtey_new_admin/models/memberShip.dart';
import 'package:sunhare_rishtey_new_admin/models/packageMadel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:provider/provider.dart';
import 'contactViewedUsers.dart';

class HomeScreen extends StatefulWidget {
  final List<Package> packageList;
  final UserInformation userInfo;
  final bool isApproved;
  final bool show;
  HomeScreen(this.userInfo, this.isApproved, {this.show = true, required this.packageList});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // String calculateAge() {
  //   AgeDuration age;
  //   age = Age.dateDifference(
  //       fromDate: DateTime(
  //           int.parse(widget.userInfo.dateOfBirth!.split('/').last),
  //           6,
  //           int.parse(widget.userInfo.dateOfBirth!.split('/')[0])),
  //       toDate: DateTime.now(),
  //       includeToDate: false);
  //   return age.years.toString();
  // }
  DateDuration? duration;

  int calculateAge(String s) {
    print("s is==>>$s");
    print("s is==>>${s.split('/').last}");
    DateTime birthday = DateTime(int.parse(s.split('/').last), 0, 0);
    duration = AgeCalculator.age(birthday);
    print("duration is===>>${duration!.years}");
    return duration!.years;
  }

  List<UserInformation> contactViewedUsers = [];
  
  List<UserInformation> verifyUsers = [];
  int totalContactsViewed = 0;

  Future<void> getContacts() async {
    var id = widget.userInfo.id;
    print(id);
    final data = await FirebaseDatabase.instance
        .reference()
        .child('Contacts viewed')
        .child(id!)
        .once();
    final mappedData = data.snapshot.value == null ? {} : data.snapshot.value as Map;
    totalContactsViewed = mappedData.length;

    try {
      mappedData.forEach((key, value) {
        var user = verifyUsers.firstWhere((element) => element.id == key,
          orElse: () => UserInformation()
        );
        if (!contactViewedUsers.contains(user)) {
          setState(() {
            contactViewedUsers.add(user);
            print(contactViewedUsers.length);
          });
        }
      });
    } catch (e) {
      print("Test data ==>");
      print(e.toString());
    }

    print("contactViewedUsers total length ${contactViewedUsers.length}");

    setState(() {});
  }

  Package package = Package();
  bool isPremium = false;
  MemberShip activeMembership = MemberShip();
  List<MemberShipHistory> history = [];
  DateTime dateOfPerchase = DateTime.now();
  bool isLoadMembership = false;

  getMemberShip() {
    // setState(() {
    //   isLoadMembership = true;
    // });
    print("oooo===>>>${widget.userInfo.id!}");
    FirebaseDatabase.instance
        .reference()
        .child('ActiveMembership')
        .child(widget.userInfo.id!)
        .onValue
        .listen((event) {
        print("snapShot====>>>>>${event.snapshot.value}");
        final snapShot = event.snapshot.value == null ? {} : event.snapshot.value as Map;
        print("snapShot data is===>>>${snapShot}");
        dateOfPerchase =  snapShot['DateOfPerchase'] == null || snapShot['DateOfPerchase'].toString().isEmpty ? DateTime.now() :  DateTime.parse(snapShot['DateOfPerchase'].toString());
        package = Package (
            name: snapShot['packageName'] ?? "",
            contacts: snapShot['contacts'] ?? 0,
            validTill: snapShot['ValidTill'] == null || snapShot['ValidTill'].toString().isEmpty ?
            DateTime.now().subtract(const Duration(days: 1)) : DateTime.parse(snapShot['ValidTill'].toString()),
        );
        setState(() {});
        if (snapShot["history"] != null) {
          history.clear();
          var data = snapShot["history"] as Map;
          data.forEach((key, value) {
            history.add(MemberShipHistory(
                price: value["price"] ?? 0,
                planName: value['planName'],
                validTill: DateTime.parse(
                    value['validTill'] ?? '2021-07-16 15:33:44.343'),
                startTime: DateTime.parse(
                    value['startTime'] ?? '2021-07-16 15:33:44.343'),
                contacts: value['contacts'],
                packageId: value['packageId']));
          });
        }
        activeMembership = MemberShip (
            email: snapShot['email'],
            nameUser: snapShot['name'],
            id: snapShot['packageId'],
            phone: snapShot['phone'],
            contacts: snapShot['contacts'],
            planName: snapShot['packageName'],
            srId: snapShot['srId'],
            history: history,
            price: snapShot["amount"] ?? 0,
            imageUrl: snapShot['imageUrl'] ?? '',
            startTime: snapShot['DateOfPerchase'] == null || snapShot['DateOfPerchase'].toString().isEmpty ?
            DateTime(2000,1,1) : DateTime.parse(snapShot['DateOfPerchase']),
            validTill: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").parse(snapShot['ValidTill'])
            // validTill: snapShot['ValidTill'] == null || snapShot['ValidTill'].toString().isEmpty ?
            //  DateTime(2000,1,1) :
            // DateTime.parse(snapShot['ValidTill'])
        );
        int remainingDays = ((activeMembership.validTill)
        !.difference(activeMembership.startTime!).inHours / 24).round();
        isPremium = remainingDays > 0;
        setState(() {});
    });
  }

  assignMembership() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                height: height * .4,
                width: width * .5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('PackageList',
                          style: GoogleFonts.workSans(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: height * .03,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * .3,
                      width: MediaQuery.of(context).size.width * .5,
                      child: ListView.builder(
                          itemCount: widget.packageList.length,
                          itemBuilder: (context, index) => InkWell(
                              onTap: () async{
                                bool isIdAvailableInActiveMembership = false;
                                final data = await FirebaseDatabase.instance.reference()
                                    .child('ActiveMembership')
                                    .once();
                                setState(() {
                                  Map checkPremiumData = data.snapshot.value as Map;
                                  isIdAvailableInActiveMembership = checkPremiumData.containsKey(widget.userInfo.id);
                                  print("check====${checkPremiumData.containsKey(widget.userInfo.id)}");
                                });
                                // if(isIdAvailableInActiveMembership){

                                  int days = (widget.packageList[index].timeDuration! * 30).toInt();
                                  int remainingDays = package != null
                                      ? ((package.validTill ?? DateTime.now())
                                                  .difference(dateOfPerchase ??
                                                      DateTime.now())
                                                  .inHours / 24).round() : 0;
                                  days = days + remainingDays;
                                  print("::: ${widget.userInfo.id}");
                                  print("::: remainingDays $remainingDays");
                                  addHistory(remainingDays, isIdAvailableInActiveMembership).then((value) => {
                                        FirebaseDatabase.instance
                                            .reference()
                                            .child('ActiveMembership')
                                            .child(widget.userInfo.id!)
                                            .update({
                                          'srId': widget.userInfo.srId,
                                          'contacts':
                                              widget.packageList[index].contacts! +
                                                  value,
                                          'name': widget.userInfo.name,
                                          'phone': widget.userInfo.phone,
                                          'email': widget.userInfo.email,
                                          'packageId':
                                              widget.packageList[index].id,
                                          'DateOfPerchase':
                                              DateTime.now().toIso8601String(),
                                          'status': 'Current',
                                          'ValidTill': DateTime.now()
                                              .add(Duration(days: days))
                                              .toIso8601String(),
                                          'packageName':
                                              widget.packageList[index].name,
                                          'amount': 0,
                                          'imageUrl':
                                              widget.userInfo.imageUrl ?? '',
                                        }).then((value) {
                                          Navigator.of(context).pop(true);
                                          Fluttertoast.showToast(
                                              msg: 'Assign Successfully');
                                          sendPushNotificationsByID(
                                            widget.userInfo.id!,
                                            title: "Congratulations!",
                                            target: Constants.USER_PREMIUM_MEMBERSHIP,
                                            subject: "You can now access premium features of SUNHARE Rishtey",
                                          );
                                        })
                                      });
                                // }
                                // else{
                                //
                                // }

                              },
                              child: Container(
                                  height: height * .08,
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Text((index + 1).toString() + " ) "),
                                      SizedBox(
                                        width: width * .01,
                                      ),
                                      Text(widget.packageList[index].name!),
                                    ],
                                  )))),
                    ),
                  ],
                ),
              ),
            ));
  }

  bool memberShipButton = true;

  @override
  void initState() {
    if (widget.packageList != null) {
      memberShipButton = true;
    } else {
      memberShipButton = false;
    }
    print("###################### ${widget.userInfo.id}");
    verifyUsers = Provider.of<AllUser>(context, listen: false).verifiedUsers;
    getContacts();
    getMemberShip();
    getData();
    super.initState();
  }

  Future<num> addHistory(int remainingDays, bool isIdAvailableInActiveMembership) async {
    print("widget.userInfo.id!===>>${widget.userInfo.id!}");

    Map fdata = {};
    if(isIdAvailableInActiveMembership){
      final data = await FirebaseDatabase.instance
          .reference()
          .child('ActiveMembership')
          .child(widget.userInfo.id!)
          .once();
      fdata = data.snapshot.value as Map;
      print("fdata is====>>>>${fdata}");
    }

    if (fdata.isNotEmpty) {

      await FirebaseDatabase.instance
          .reference()
          .child('ActiveMembership')
          .child(widget.userInfo.id!)
          .child('history')
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .update({
        'planName': fdata['packageName'],
        'contacts': fdata['contacts'],
        'validTill': fdata['ValidTill'],
        'price': fdata['amount'],
        'startTime': fdata['DateOfPerchase'],
        'packageId': fdata['packageId'],
      });
    } else {
      return 0;
    }
    num returnVal = 0;
    if (remainingDays <= 0) {
      returnVal += contactViewedUsers.length;
    } else {
      returnVal += fdata['contacts'] ?? 0;
    }
    // Return contacts to add with new plan
    return returnVal;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // final _controller = PageController(
    //   initialPage: 1,
    // );

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async{
          Navigator.pop(context,true);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: HexColor('52a199'),
            title: Text (
              "User Info",
              style: GoogleFonts.workSans(
                color: Colors.white,
              ),
            ),
            elevation: 4,
            leading: InkWell(child: Icon(Icons.arrow_back_outlined,color: white),onTap: (){
              Navigator.pop(context,true);
            }),
          ),
          body: Stack(
            children: [
              // itemCount: widget.filteredUsers.length,
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: height * .02,
                    ),
                    Container(
                      width: width,
                    ), // Just for width

                    Container(
                      height: height * .7,
                      width: width * .8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            widget.userInfo.imageUrl!,
                            //'https://picsum.photos/seed/picsum/200/300',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Colors.black12, Colors.black54],
                            begin: Alignment.center,
                            stops: [0.4, 1],
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 10,
                              left: 20,
                              bottom: 10,
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        //  widget.userInfo.name
                                        widget.userInfo.name!.toUpperCase(),
                                        style: GoogleFonts.ptSans(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .03,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .005,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.userInfo.height ?? '',
                                        style: GoogleFonts.ptSans(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .03,
                                      ),
                                      Text(
                                        widget.userInfo.workingAs ?? 'Not given',
                                        style: GoogleFonts.ptSans(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .005,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.userInfo.motherTongue ??
                                            'language',
                                        style: GoogleFonts.ptSans(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .03,
                                      ),
                                      Container(
                                        child: Text(
                                          (widget.userInfo.country ?? 'Country') +
                                              ', ' +
                                              (widget.userInfo.state ?? 'State'),
                                          //   (widget.userInfo.city ?? 'City'),
                                          style: GoogleFonts.ptSans(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height * .015,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //
                    //
                    //
                    //

                    SizedBox(
                      height: height * .02,
                    ),
                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        width: width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Text(
                              'About ${widget.userInfo.name != null ? widget.userInfo.name!.toUpperCase() : ''}',
                              style: GoogleFonts.ptSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: height * .02,
                            ),
                            Text(
                              widget.userInfo.intro != null
                                  ? widget.userInfo.intro!
                                  : '',
                              style: GoogleFonts.ptSans(),
                            ),
                            SizedBox(
                              height: height * .01,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: height * .02,
                    ),
                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        width: width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Text(
                              'Basic Details',
                              style: GoogleFonts.ptSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: height * .01,
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: .8,
                                      color: HexColor('00b8d4'),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Created by ${widget.userInfo.postedBy == 'Son' || widget.userInfo.postedBy == 'Daughter' ? 'Parent' : widget.userInfo.postedBy}',
                                    style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: width * .015,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: .8,
                                      color: HexColor('00b8d4'),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Profile ID - ${widget.userInfo.srId}',
                                    style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontSize: 13,
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: .8,
                                      color: HexColor('00b8d4'),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Height - ${widget.userInfo.height ?? ''}',
                                    style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: width * .02,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: .8,
                                      color: HexColor('00b8d4'),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Age - ${calculateAge(widget.userInfo.dateOfBirth!)}',
                                    // 'Age - ',
                                    style: GoogleFonts.roboto(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height * .02,
                            ),
                            Text(
                              'Profile ID',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '${widget.userInfo.id!.substring(1, 6)}',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            Text(
                              'Gender',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '${widget.userInfo.gender}',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Religion & Mother Tongue',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              "${widget.userInfo.religion ?? 'not given'} & " +
                                  '${widget.userInfo.motherTongue ?? ''}',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Marital Status',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.maritalStatus ?? "not provided",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            if((widget.userInfo.noOfChildren ?? "") != "" && (widget.userInfo.childrenLivingTogether ?? "") != "")
                            Column (
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NoOfChildren',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  widget.userInfo.noOfChildren!,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                                SizedBox(
                                  height: height * .005,
                                ),
                                Text(
                                  'Children Living Together',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  widget.userInfo.childrenLivingTogether!,
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                                SizedBox(
                                  height: height * .005,
                                ),
                              ],
                            ),
                            Text(
                              'Lives in',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.city ?? 'not given',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Hometown',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.nativePlace ?? 'not given',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Community',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.community ?? 'not given',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Diet Prefrence',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.diet ?? "not given",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: height * .02,
                    ),
                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        width: width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Text(
                              'Contact Details',
                              style: GoogleFonts.ptSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: height * .02,
                            ),
                            Text(
                              'Contact No.',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            SelectableText(
                              widget.userInfo.phone ?? 'not given',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Email ID',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            SelectableText (
                              (widget.userInfo.email ?? "").toLowerCase(),
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: height * .02,
                    ),
                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        width: width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Text(
                              'Career & Education',
                              style: GoogleFonts.ptSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: height * .02,
                            ),
                            Text(
                              'Profession',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.workingAs ?? "not available",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Company Name',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.workingWith ?? "",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Employed In',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.employedIn == "" ||
                                      widget.userInfo.employedIn == null
                                  ? "not available"
                                  : widget.userInfo.employedIn!,
                              style: GoogleFonts.lato(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Annual Income',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.annualIncome ?? "",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Highest Qualification',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.highestQualification ?? "",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'College Name',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.collegeAttended ?? '',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: height * .02,
                    ),
                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        width: width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Text(
                              'Family Details',
                              style: GoogleFonts.ptSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: height * .02,
                            ),
                            Text(
                              'Father\'s Status',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.fatherStatus ?? 'not given',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Mother\'s Status',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.motherStatus ?? 'not given',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Father\'s Gotra',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.fatherGautra!,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Mother\'s Gotra',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.motherGautra ?? 'not given',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'No. of Brother(s)',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.brothers!,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'No. of Sister(s)',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.sisters!,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Family Type',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.familyType!,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Native Place',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.nativePlace!,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: height * .02,
                    ),
                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        width: width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Text(
                              'Astro Details',
                              style: GoogleFonts.ptSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: height * .02,
                            ),
                            Text(
                              'Born in',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.cityOfBirth ?? "",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Manglik',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.manglik ?? '',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Birth Date',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.dateOfBirth != null
                                  ? '${widget.userInfo.dateOfBirth}'
                                  : 'not given',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Time of Birth',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.birthTime != null
                                  ? "${widget.userInfo.birthTime!.hour.toString()} : ${widget.userInfo.birthTime!.minute.toString()}"
                                  : 'not given',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: height * .02,
                    ),

                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        width: width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Membership Details',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                memberShipButton
                                    ? ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          primary: HexColor('52a199'),
                                        ),
                                        onPressed: () {
                                          assignMembership();
                                        },
                                        icon: Icon(
                                          Icons.person,
                                        ),
                                        label: Text(
                                          'Give Membership',
                                          style: GoogleFonts.workSans(
                                            fontSize: 10,
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                            SizedBox(
                              height: height * .02
                            ),
                            Text(
                              'Active Plan',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            package.name == null || package.name == "" ? const SizedBox() :
                            Text (
                              package.name != null || package.name != ""  ? package.name! : 'None',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Divider(thickness: 1),
                            SizedBox(height: height * .005),
                            Text (
                              'Valid till',
                              style: GoogleFonts.ptSans(fontSize: 13, color: Colors.black54),
                            ),
                            Text (
                              package.name == null || package.name == "" ? 'Not Defined'
                                  : package.validTill.toString().split(' ').first,
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              'Refer code',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              widget.userInfo.referCode ?? 'Not Defined',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * .02),
                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        width: width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Text(
                              'Photos',
                              style: GoogleFonts.ptSans(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: height * .02,
                            ),
                            Text(
                              '',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (countext) => PhotoListScreen(
                                      userId: widget.userInfo.id,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Photos',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    width: width * .03,
                                  ),
                                  Icon(Icons.arrow_forward_ios)
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                            Text(
                              '',
                              style: GoogleFonts.ptSans(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => IDViewScreen(
                                      userId: widget.userInfo.id!,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'ID Photo',
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    width: width * .03,
                                  ),
                                  Icon(Icons.arrow_forward_ios)
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            SizedBox(
                              height: height * .005,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * .02),
                    // contactViewedUsers.length == 0
                    //     ? SizedBox()
                    //     :
                    Card(
                            elevation: 6,
                            margin: EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              width: width * 0.9,
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: height * .01,
                                      ),
                                      Text(
                                        'Contact Viewed',
                                        style: GoogleFonts.ptSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        totalContactsViewed.toString() + "/" +
                                            (package != null
                                            ? package.contacts.toString() ?? "0" : "0")
                                          /*  (!isPremium ? (package != null
                                                    ? package.contacts.toString() ?? "0" : "0")
                                                : totalContactsViewed.toString())*/,
                                        style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(height: height * .005),
                                    ],
                                  ),
                                  Expanded(child: SizedBox()),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(16.0),
                                      primary: HexColor('52a199'),
                                      textStyle: const TextStyle(fontSize: 16),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ContactViewedUsers(
                                                    contactUsers:
                                                        contactViewedUsers)),
                                      );
                                    },
                                    child: const Text('See all'),
                                  )
                                ],
                              ),
                            ),
                          ),
                    SizedBox(height: height * .02),
                    activeMembership.planName == null || activeMembership.planName == ""
                        ? SizedBox()
                        : Card(
                            elevation: 6,
                            margin: EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              width: width * 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: height * .01,
                                  ),
                                  Text(
                                    'Membership',
                                    style: GoogleFonts.ptSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * .005,
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Plan Name : ' +
                                              activeMembership.planName!),
                                          Text('Start Time : ' +
                                              setDateInYYYYMMDD(activeMembership.startTime ?? DateTime.now())),
                                          Text('Valid Till : ' +
                                              setDateInYYYYMMDD(
                                                activeMembership.validTill ??
                                                      DateTime.now().subtract(Duration(days: 1))
                                              )),
                                        ],
                                      ),
                                      Expanded(child: SizedBox()),
                                      // Text((activeMembership.price! ~/ 100).toString() + " ₹"),
                                      Text((activeMembership.price!).toString() + " ₹"),
                                    ],
                                  ),
                                  ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: activeMembership.history!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Column(
                                          children: [
                                            Divider(thickness: 1),
                                            Row(
                                              children: [
                                                Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Plan name :' +
                                                          activeMembership
                                                              .history![index]
                                                              .planName!),
                                                      Text('StartTime :' +
                                                          setDateInYYYYMMDD(
                                                              activeMembership
                                                                  .history![index]
                                                                  .startTime!)),
                                                      Text('ValidTill :' +
                                                          setDateInYYYYMMDD(
                                                              activeMembership
                                                                  .history![index]
                                                                  .validTill!)),
                                                    ]),
                                                Expanded(child: SizedBox()),

                                                Text(activeMembership

                                                            .history![index]
                                                            .price ==
                                                        0
                                                    ? "Given by Admin"
                                                    : (activeMembership
                                                                    .history![
                                                                        index]
                                                                    .price!)
                                                            .toString() +
                                                        " ₹"),
                                              ],
                                            ),
                                          ],
                                        );
                                      })
                                ],
                              ),
                            ),
                          ),
                    SizedBox(height: height * .02),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool gotData = false;

  getData() async {
    final data = await FirebaseDatabase.instance
        .reference()
        .child('trash')
        .orderByChild('mobileNo')
        .equalTo('+917828464204')
        .once();
    if (data.snapshot.value != null) {
      gotData = true;
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }
}

String setDateInYYYYMMDD(DateTime dateTime) {
  return DateFormat('dd MMMM yyyy').format(dateTime);
}

String setSubtractDateInYYYYMMDD(DateTime dateTime) {
  DateTime tempDate = dateTime.subtract(Duration(days: 15));
  return DateFormat('dd MMMM yyyy').format(tempDate);
}