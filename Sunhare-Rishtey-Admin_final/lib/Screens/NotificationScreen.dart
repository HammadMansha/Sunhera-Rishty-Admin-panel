import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/main.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class NotificationScreen extends StatefulWidget {
  UserInformation? user;
  NotificationScreen({this.user});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String title = '';
  String subject = '';

  @override
  void initState() {
    //  getPackageData();
    super.initState();
  }

  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
        backgroundColor: HexColor('70c4bc'),
      ),
      body: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.user != null
                    ? Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: height * .01,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              height: height * .2,
                              child: GestureDetector(
                                onTap: () {},
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: width * .01,
                                    ),
                                    Container(
                                      height: height * .2,
                                      width: width * .3,
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: InkWell(
                                              onTap: () {},
                                              child: Container(
                                                width: width,
                                                height: height,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        widget.user!.imageUrl!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * .01,
                            ),
                            SizedBox(
                              height: height * .02,
                            ),
                            RichText(
                              text: TextSpan(
                                text:
                                    widget.user!.name!.toUpperCase() ?? 'Loading',
                                style: GoogleFonts.ptSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: theme.colorPrimary,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' (${widget.user!.srId ?? ""})',
                                    style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * .003,
                            ),
                            Container(
                              width: width,
                              alignment: Alignment.center,
                              child: Text(widget.user!.id!),
                            ),
                            SizedBox(
                              height: height * 0.015,
                            )
                          ],
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: height * .02,
                ),
                Container(
                  child: Text(
                    'Title',
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
                        title = val.trim();
                        return null;
                      }
                    },
                    // cursorColor: theme.colorCompanion,
                    decoration: InputDecoration(
                      hintText: "Title",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: height * .02,
                ),
                Container(
                  child: Text(
                    'Subject',
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
                      subject = val!.trim();
                      return null;
                    },
                    // cursorColor: theme.colorCompanion,
                    decoration: InputDecoration(
                      hintText: "Subject",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: height * .02,
                ),
                Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: HexColor('70c4bc'),
                      ),
                      child: Text(
                        "Send",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        if (!_key.currentState!.validate()) {
                          return;
                        }
                        if (widget.user != null) {
                          sendPushNotificationsByID(
                            widget.user!.id!,
                            title: title,
                            subject: subject,
                          ).then((value) => Fluttertoast.showToast(
                              msg: "Notification sent Successfully."));
                        } else {
                          NotificationSender()
                              .sendPushNotifications(
                                  "/topics/discount", title, subject)
                              .then((value) => Fluttertoast.showToast(
                                  msg: value
                                      ? "Notification sent."
                                      : "There was some issue."));
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
