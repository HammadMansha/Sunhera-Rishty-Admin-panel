import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'UserInformationScreen.dart';

class ApprovedUsersScreen extends StatefulWidget {
  final bool? isLoading;
  ApprovedUsersScreen({this.isLoading});
  @override
  _ApprovedUsersScreenState createState() => _ApprovedUsersScreenState();
}

class _ApprovedUsersScreenState extends State<ApprovedUsersScreen> {
  List<UserInformation> approvedUsers = [];
  @override
  void didChangeDependencies() {
    final res = Provider.of<AllUser>(context);
    approvedUsers = res.verifiedUsers.cast<UserInformation>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return widget.isLoading!
        ? SpinKitThreeBounce(
            color: Colors.blue,
          )
        : Container(
            padding: EdgeInsets.all(12),
            child: ListView.builder(
              itemCount: approvedUsers.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(approvedUsers[index], false, packageList: [],),
                      ),
                    );
                  },
                  child: Container(
                    height: height * .1,
                    child: Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: width * .01,
                            ),
                            Container(
                              height: height,
                              width: width * .03,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    6,
                                  ),
                                  border: Border.all()),
                              child: CachedNetworkImage(
                                imageUrl: approvedUsers[index].imageUrl!,
                              ),
                            ),
                            SizedBox(
                              width: width * .015,
                            ),
                            Container(
                              width: width * .45,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Name: " + approvedUsers[index].name!,
                                    style: GoogleFonts.workSans(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * .007,
                                  ),
                                  Text(
                                    "Id: " +
                                        approvedUsers[index].id!.substring(1, 6),
                                    style: GoogleFonts.workSans(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: width * .18,
                            ),
                            Icon(
                              MdiIcons.chevronRight,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
