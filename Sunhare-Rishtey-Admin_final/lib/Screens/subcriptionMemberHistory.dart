import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:sunhare_rishtey_new_admin/models/memberShip.dart';

class SubscriptionMemberHistory extends StatefulWidget {
  final MemberShip? membershiphistory;
  SubscriptionMemberHistory({Key? key, this.membershiphistory})
      : super(key: key);

  @override
  _SubscriptionMemberHistoryState createState() =>
      _SubscriptionMemberHistoryState(membershiphistory!);
}

class _SubscriptionMemberHistoryState extends State<SubscriptionMemberHistory> {
  final MemberShip membershiphistory;
  var items = ['', 1];
  _SubscriptionMemberHistoryState(this.membershiphistory);

  @override
  void initState() {
    super.initState();
    items = [
      membershiphistory,
      "Subscription History",
      membershiphistory.history!.first
    ];
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HexColor('70c4bc'),
            title: Text(
              'Subscription Member History',
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.w600,
              ),
            )),
        body: Stack(children: [
          SubscriptionHistoryHeader(
              width: width,
              height: height,
              activeMembership: membershiphistory),
          Padding(
            padding: EdgeInsets.fromLTRB(0, height * .15 + 8, 0, 0),
            child: ListView.builder(
                itemCount: membershiphistory.history!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                    child: HistoryItem(
                        membershipHistory: membershiphistory.history![index]),
                  );
                }),
          ),
        ]));
  }
}

class SubscriptionHistoryHeader extends StatelessWidget {
   SubscriptionHistoryHeader(
      {Key? key,
      required this.width,
      required this.height,
      @required this.activeMembership})
      : super(key: key);

   double width = 0.0;
   double height= 0.0;
   MemberShip? activeMembership;

  String setDateInYYYYMMDD(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width * .03,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  height: height * .15,
                  width: width * .23,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: activeMembership!.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: width * .05,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeMembership!.nameUser!,
                      maxLines: 2,
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID : " + activeMembership!.srId!,
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Mobile : ' + activeMembership!.phone!,
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Plan Name : ' + activeMembership!.planName!,
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                      ),
                    ),
                    Text('Price : ' +
                        (activeMembership!.price == 0
                            ? "Given by Admin"
                            : ((activeMembership!.price! / 100.0).ceil())
                                .toString())),
                    Text(
                      'Starting Date : ' +
                          setDateInYYYYMMDD(activeMembership!.startTime!),
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                      ),
                    ),
                    Text(
                        'Valid Till : ' +
                            setDateInYYYYMMDD(activeMembership!.validTill!),
                        style: GoogleFonts.openSans(fontSize: 13)),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: height * .01,
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
   MemberShipHistory? membershipHistory;
   HistoryItem({Key? key, @required this.membershipHistory})
      : super(key: key);

  String setDateInYYYYMMDD(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
              Text('Plan Name : ' + membershipHistory!.planName!),
              Text('Price : ' +
                  (membershipHistory!.price == 0
                      ? "Given by Admin"
                      : ((membershipHistory!.price! / 100.0).ceil()).toString())),
              Text('Starting Date : ' +
                  setDateInYYYYMMDD(membershipHistory!.startTime!)),
              Text('Valid Till : ' +
                  setDateInYYYYMMDD(membershipHistory!.validTill!)),
            ])),
      ),
    );
  }
}
