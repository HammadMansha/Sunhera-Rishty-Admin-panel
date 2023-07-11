import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getTrashUsers.dart';
import 'UserInformationScreen.dart';

class TrashUsersScreen extends StatefulWidget {
  @override
  _TrashUsersScreenState createState() => _TrashUsersScreenState();
}

class _TrashUsersScreenState extends State<TrashUsersScreen> {
  List<UserInformation> trashUsers = [];
  @override
  void initState() {
    trashUsers = [];
    final res = Provider.of<TrashUsers>(context, listen: false);
    res.getAllUsers().then((value) {
      trashUsers = res.trashUsers.cast<UserInformation>();
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: trashUsers.length,
        itemBuilder: (context, index) {
          // print(widget.acceeptedUsers[index].id);
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    trashUsers[index],
                    true,
                    show: false, packageList: [],
                  ),
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
                          imageUrl: trashUsers[index].imageUrl??"",
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
                              "Name: ${trashUsers[index].name??""}",
                              style: GoogleFonts.workSans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: height * .007,
                            ),
                            Text(
                              "Id: " + trashUsers[index].id!.substring(1, 6),
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
