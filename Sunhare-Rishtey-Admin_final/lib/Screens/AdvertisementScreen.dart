import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:sunhare_rishtey_new_admin/Screens/addAdvertisementScreen.dart';
import 'package:sunhare_rishtey_new_admin/Screens/editAddScreen.dart';
import 'package:sunhare_rishtey_new_admin/config/theme.dart';
import 'package:sunhare_rishtey_new_admin/models/advertisementModel.dart';

class AdvertisementScreen extends StatefulWidget {
  @override
  _AdvertisementScreenState createState() => _AdvertisementScreenState();
}

class _AdvertisementScreenState extends State<AdvertisementScreen> {
  String name = "";
  String imageUrl = "";
  double months = 0.0;
  double timeDuration = 0.0;

  List<AdvertisementModel> advertisementList = [];
  List<AdvertisementModel> filteredAdvertisementList = [];
  String? formattedToday;

  String searchVal = "";
  showDeleteConfirmation(int index) {
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
                      if (advertisementList.length == 1) {
                        FirebaseDatabase.instance
                            .reference()
                            .child('Advertisement')
                            .child(advertisementList[index].id!)
                            .remove();
                        advertisementList.clear();
                        Navigator.of(context).pop();
                      } else {
                        FirebaseDatabase.instance
                            .reference()
                            .child('Advertisement')
                            .child(advertisementList[index].id!)
                            .remove()
                            .then((value) {
                          Navigator.of(context).pop();
                        });
                      }
                      setState(() {});
                    },
                    child: Text('Yes')),
              ],
              content: Container(
                child: Text('Do you really wants to delete this advertisement?'),
              ),
            ));
  }

  getPackageData() {
    FirebaseDatabase.instance
        .reference()
        .child('Advertisement')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        advertisementList.clear();
        final data = event.snapshot.value as Map;
        if (data != null) {
          data.forEach((key, value) {
            print("Image: ${value['imageURL']}");
            advertisementList.add(AdvertisementModel(
                id: key,
                dateCreated: value['createdOn'] != null
                    ? DateTime.parse(value['createdOn'])
                    : DateTime.now(),
                months: value['months'] != null
                    ? double.parse(value['months'].toString())
                    : 1,
                image: value['imageURL'] ?? "",
                status: value['status'] ?? false,
                adType: value['adType'] ?? "Interstitial",
                title: value['title'] ?? "Empty"));
          });

          advertisementList.sort((AdvertisementModel a, AdvertisementModel b) {
            DateTime aDate =
                a.dateCreated!.add(Duration(days: (30 * a.months!).toInt()));
            DateTime bDate =
                b.dateCreated!.add(Duration(days: (30 * b.months!).toInt()));
            return DateTime.now()
                .difference(aDate)
                .inDays
                .abs()
                .compareTo(DateTime.now().difference(bDate).inDays.abs());
          });
        }
      } else {
        advertisementList = [];
      }
      filteredAdvertisementList.clear();
      filteredAdvertisementList.addAll(advertisementList);
      setState(() {});
    });
  }

  search(str) {
    if (str.isEmpty) {
      setState(() {
        filteredAdvertisementList.clear();
        filteredAdvertisementList.addAll(advertisementList);
      });
    } else {
      setState(() {
        filteredAdvertisementList.clear();
        advertisementList.forEach((element) {
          if (element.title!.toLowerCase().contains(str.trim().toLowerCase())) {
            filteredAdvertisementList.add(element);
          }
        });
      });
    }
  }

  @override
  void initState() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    formattedToday = formatter.format(now);
    print("formatted date is====>>>>>>>${formattedToday}");
    getPackageData();
  }

  @override
  Widget build(BuildContext context) {
    // super.initState();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('70c4bc'),
          title: Text(
            'Advertisement',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddAdvertisement()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
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
                            searchVal = value;
                            search(searchVal);
                            setState(() {});
                          },
                          cursorColor: HexColor('357f78'),
                          decoration: InputDecoration(
                            hintText: "Search Advertisement",
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              onPressed: () {
                                search(searchVal);
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
                  Container(
                    width: width,
                    height: height * .82,
                    child: ListView.builder(
                      itemCount: filteredAdvertisementList.length,
                      itemBuilder: (context, index) {
                        DateTime expDate = filteredAdvertisementList[index]
                            .dateCreated!
                            .add(Duration(
                                days: (30 * filteredAdvertisementList[index].months!).toInt()));
                        final DateFormat formatter = DateFormat('dd/MM/yyyy');
                        final String formattedExp = formatter.format(expDate);
                        print("formatted date is 2====>>>>>>>${formattedExp}");
                        DateTime parsedDate = formatter.parse(formattedExp);
                        print('parsedDate: $parsedDate');
                        DateTime now = DateTime.now();
                        print('now: $now');
                        print('parsedDate is before now: ${parsedDate.isBefore(now)}');
                        // final DateTime now = DateTime.now();
                        // final bool isExpired = expDate.isBefore(now);
                        // print("isExpired====>>>$isExpired");
                        return
                        Card(
                          elevation: 10,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(parsedDate.isBefore(now))
                                Container(
                                  child: Text(
                                    'Expired!',style: TextStyle(color: white),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(left: 8),
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: Container(
                                    height: height * .3,
                                    width: width * .5,
                                    child: CachedNetworkImage(
                                     imageUrl: filteredAdvertisementList[index].image!),
                                  ),
                                ),
                                SizedBox(
                                  height: height * .01,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: Text(
                                                'Title -',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                filteredAdvertisementList[index]
                                                    .title!,
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
                                              width: 140,
                                              child: Text(
                                                'Ad Type -',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                filteredAdvertisementList[index]
                                                    .adType!,
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
                                              width: 140,
                                              child: Text(
                                                'Date Created -',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    ' ${filteredAdvertisementList[index].dateCreated!.day}/${filteredAdvertisementList[index].dateCreated!.month}/${advertisementList[index].dateCreated!.year}',
                                                    style: GoogleFonts.openSans(
                                                      fontSize: 14,
                                                    ),
                                                  ),
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
                                              width: 140,
                                              child: Text(
                                                'Time Period -',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '${filteredAdvertisementList[index].months} months',
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
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 140,
                                              child: Text(
                                                'Expiry Date -',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '${expDate.day}/${expDate.month}/${expDate.year}',
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
                                              width: 140,
                                              child: Text(
                                                'Days Left -',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '${DateTime.now().difference(expDate).inDays.abs()}',
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
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => EditAddScreen(
                                                filteredAdvertisementList[
                                                    index]),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: width * .25,
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
                                        showDeleteConfirmation(index);
                                      },
                                      child: Container(
                                        width: width * .25,
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
                                    InkWell(
                                      onTap: () {
                                        print("aaaa====>>>${!filteredAdvertisementList[index].status!}");
                                        if(parsedDate.isBefore(now)){
                                          // Fluttertoast.showToast(msg: "Your advertise is Expired!!!");
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text("This advertise is expired!!!"),
                                                actions: [
                                                  MaterialButton(
                                                    child: const Text("OK",style: TextStyle(color: white)),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    color: HexColor('357f78'),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }else{
                                          FirebaseDatabase.instance
                                              .reference()
                                              .child('Advertisement')
                                              .child(
                                              filteredAdvertisementList[index].id!)
                                              .update({
                                            "status": !filteredAdvertisementList[index].status!
                                          });
                                        }
                                        // FirebaseDatabase.instance
                                        //     .reference()
                                        //     .child('Advertisement')
                                        //     .child(
                                        //         filteredAdvertisementList[index]
                                        //             .id!)
                                        //     .update({
                                        //   "status":
                                        //       !filteredAdvertisementList[index]
                                        //           .status!
                                        // });
                                      },
                                      child: Container(
                                        width: width * .25,
                                        height: height * .05,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: HexColor('357f78'),
                                        ),
                                        child: Center(
                                          child: Text(
                                            !parsedDate.isBefore(now)
                                                ? filteredAdvertisementList[index].status! ? "Turn On" : "Turn Off"
                                                : "Turn Off",
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
