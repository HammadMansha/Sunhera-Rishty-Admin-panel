import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class TrashUsers with ChangeNotifier {
  List<UserInformation> trashUsers = [];
  Future<void> getAllUsers() async {
    final data =
        await FirebaseDatabase.instance.reference().child('trash').once();

    final mappedData = data.snapshot.value as Map;
    if (mappedData != null) {
      trashUsers = [];
      mappedData.forEach((key, value) {
        var joinedOn =
            DateTime.parse(value['DateTime'] ?? '2021-07-16 15:33:44.343');

        var deletedOn =
            DateTime.parse(value['DeletedTime'] ?? '2021-07-16 15:33:44.343');
        trashUsers.add(
          UserInformation(
              deletedBy: value['DeletedBy'] ?? 'User',
              deletedOn: deletedOn,
              joinedOn: joinedOn,
              srId: value['id'],
              name: value['userName'] ?? '',
              email: value['email'] ?? '',
              id: key,
              phone: value['mobileNo'] ?? '',
              gender: value['gender'] ?? '',
              dateOfBirth: value['DateOfBirth'] ?? '',
              religion: value['Religion'] ?? '',
              annualIncome: value['annualIncome'] ?? '',
              collegeAttended: value['clg'] ?? '',
              workingAs: value['designation'] ?? '',
              country: value['living'] ?? '',
              highestQualification: value['qualification'] ?? '',
              workingWith: value['workAt'] ?? '',
              anyDisAbility: value['disability'] ?? '',
              brothers: value['brotherCount'] ?? '',
              sisters: value['sisterCount'] ?? '',
              //casteNoBar: value['casteNoBar'] ?? '',
              intro: value['intro'] ?? '',
              manglik: value['maglik'] ?? '',
              city: value['city'] ?? '',
              fatherGautra: value['fatherGotra'] ?? '',
              motherGautra: value['motherGotra'] ?? '',
              diet: value['diet'] ?? "",
              // gotra: value['gautra'],
              //  zipCode: value['zipCode'],
              imageUrl: value['imageURL'] ?? '',
              cityOfBirth: value['cityOfBirth'] ?? '',
              employerName: value['employerName'] ?? "",
              state: value['state'] ?? '',
              // timeOfBirth: DateTime.tryParse(
              //   value['timeOfBirth'] != null ? value['timeOfBirth'] : "",
              // ),
              residencyStatus: value['residency'] ?? '',
              motherStatus: value['MotherStatus'] ?? '',
              postedBy: value['ProfileFor'] ?? '',
              nativePlace: value['nativePlace'] ?? '',
              motherTongue: value['motherTongue'] ?? '',
              community: value['Community'] ?? '',
              fatherStatus: value['FatherStatus'] ?? '',
              grewUpIn: value['grewUpIn'] ?? '',
              familyType: value['familyType'] ?? '',
              height: value['personHeight'] ?? '',
              deletedReason: value['Reason'] ?? 'Not Available',
              maritalStatus: value['maritalStatus'] ?? "",
              noOfChildren: value['noOfChildren'] ?? "",
              childrenLivingTogether: value['childrenLivingTogether'] ?? "",
          ),
        );
      });
    }
  }
}
