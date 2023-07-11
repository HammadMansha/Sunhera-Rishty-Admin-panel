import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class ContactViewedUsers extends StatelessWidget {
  final List<UserInformation>? contactUsers;
  const ContactViewedUsers({Key? key, this.contactUsers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Viewed Users"),
        backgroundColor: Color.fromRGBO(255, 21, 87, 1),
      ),
      body: contactUsers == null || contactUsers!.isEmpty ? const Center (
        child: Text("No User Found", style: TextStyle(color: Colors.black),),
      ) :  ListView.builder(
        itemCount: contactUsers!.length,
        itemBuilder: (context, index) {
          return (contactUsers?[index].imageUrl) == null || contactUsers?[index].name == null ? SizedBox() : Card(
            elevation: 10,
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
                            imageUrl: contactUsers![index].imageUrl ?? "",
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
                            contactUsers![index].name!,
                            maxLines: 2,
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "ID -" + contactUsers![index].srId!,
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'No. - ${contactUsers![index].phone}',
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Joined - ${contactUsers![index].joinedOn!.day}/${contactUsers![index].joinedOn!.month}/${contactUsers![index].joinedOn!.year}',
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'User Status : ${contactUsers![index].userStatus}',
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Gender : ${contactUsers![index].gender}',
                            style: GoogleFonts.openSans(
                              fontSize: 13,
                            ),
                          ),
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
        },
      ),
    );
  }
}
