import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class AllUser with ChangeNotifier {

  Map allUserData = {};

  List<UserInformation> notVerified = [];
  List<UserInformation> verifiedUsers = [];

  List<UserInformation> recentDeleteList = [];

  var selectedprofile;
  List<String> profileList = [
    'Self',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Friend',
    'Relative',
  ];

  Future<void> getAllUsers({int? isAbout}) async {

    ///about == 1
    ///delete list data == 2
    var data = await FirebaseDatabase.instance
          .reference()
          .child('User Information')
          .once();

    debugPrint("data ==> ${data}");

    Map mappedData = data.snapshot.value as Map;
    allUserData = mappedData;




    // final mappedData = data.snapshot.value as Map;
    log("mappedData===>>>${mappedData}");
    if (mappedData.isNotEmpty) {
      notVerified = [];
      verifiedUsers = [];
      mappedData.forEach((key, value) {
        final hideProfileMap =
            value['hideProfile'] != null ? value['hideProfile'] as Map : null;
        final hideMobileMap =
            value['hideMobile'] != null ? value['hideMobile'] as Map : null;
        bool hideMobile = false;
        bool hideProfile = false;
        if (hideMobileMap != null)
          hideMobileMap.forEach((key, value) {
            // if (value) hideMobile = true;
            if(key == "expireDate"){
              DateTime tempDate = DateTime.parse(value);
              if(DateTime.now().isBefore(tempDate) == false){
                hideMobile = false;
              }else{
                hideMobile = true;
              }
            }else{
              hideMobile = false;
            }
          });

        if (hideProfileMap != null)
          hideProfileMap.forEach((key, value) {
            // if (value) hideProfile = true;
            if(key == "unHideDate"){
              DateTime tempDate = DateTime.parse(value);
              if(DateTime.now().isBefore(tempDate) == false){
                hideProfile = false;
              }else{
                hideProfile = true;
              }
            }
          });

        List<String> blockedById = [];

        if (mappedData['Blocked By'] != null) {
          mappedData['Blocked By'].forEach((key, value) {
            blockedById.add(key);
          });
        }
        print("isvarified ??????--->>>${value['isVerified']}");

        bool isDeleteByAdmin = value["isDeleteByAdmin"] ?? false;
        String accountDeleteDate = value["AccountDeleteDate"] ?? "";

        if(isDeleteByAdmin == false && accountDeleteDate == "") {
          if (value['isVerified'] != null && value['isVerified'] && value['hasData'] != null) {
            verifiedUsers.add(
              UserInformation(
                userStatus: value['LastActive'] != null
                    ? (DateTime.parse(value['LastActive'].toString())
                    .difference(DateTime.now())
                    .inMinutes
                    .abs() < 5
                    ? 'Active'
                    : 'Inactive')
                    : 'Inactive',
                joinedOn: DateTime.parse(value['DateTime']),
                suspended:
                value['isSuspended'] != null ? value['isSuspended'] : false,
                srId: value['id'],
                iseditable: value['isEditable'],
                name: value['userName'],
                email: value['email'] ?? '',
                id: key,
                isVerified: value['isVerified'],
                // isVerified: mappedData['isVerified'],
                blockedByList: blockedById,
                isSuspended: value['isSuspended'] ?? false,
                phone: value['mobileNo'] ?? '',
                gender: value['gender'] ?? '',
                dateOfBirth: value['DateOfBirth'] ?? '',
                religion: value['Religion'] ?? '',
                annualIncome: value['annualIncome'] ?? '',
                collegeAttended: value['clg'] ?? '',
                workingAs: value['designation'] ?? '',
                country: value['living'] ?? '',
                hideContact: hideMobile,
                hideProfile: hideProfile,
                highestQualification: value['qualification'] ?? '',
                workingWith: value['workAt'] ?? '',
                anyDisAbility: value['disability'] ?? '',
                brothers: value['brotherCount'] ?? '',
                sisters: value['sisterCount'] ?? '',
                visibility: value['visibility'] ?? 'All Member',
                //casteNoBar: value['casteNoBar'] ?? '',
                showHoroscope: mappedData['showHoroscope'] ?? true,
                intro: value['intro'] ?? '',
                manglik: value['maglik'] ?? '',
                city: value['city'] ?? '',
                fatherGautra: value['fatherGotra'] ?? '',
                isVerificationRequired: value['isVerificationRequired'] ?? false,
                isVerificationRequiredGovId: value['isVerificationGovId'] ?? false,
                birthTime: splitData(mappedData['timeOfBirth'] ?? ""),
                motherGautra: value['motherGotra'] ?? '',
                diet: value['diet'] ?? "",
                employedIn: value['employedIn'] ?? '',
                isOnline: value['isOnline'] ?? false,
                // gotra: value['gautra'],
                //  zipCode: value['zipCode'],
                imageUrl: value['imageURL'] ?? '',
                cityOfBirth: value['cityOfBirth'] ?? '',
                employerName: value['employerName'] ?? "",
                state: value['state'] ?? '',
                // timeOfBirth: DateTime.tryParse(
                //   value['timeOfBirth'] != null ? value['timeOfBirth'] : "",
                // ),

                isPremium: value['isPremium'] ?? false,
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
                referCode: value['referCode'] ?? '',
                maritalStatus: value['maritalStatus'] ?? "",
                allowMarketing: value['allowMarketing'] ?? true,
                lastLogin: value['Lastlogin'] ?? "Never",
                noOfChildren: value['noOfChildren'] ?? "",
                childrenLivingTogether: value['childrenLivingTogether'] ?? "",
                newIntro: value['newIntro'] ?? "",
                introEdited: value['introEdited'] ?? 0,
                deletedBy: value['DeletedBy'] ?? 'User',
                deletedReason: value['Reason'] ?? 'Not Available',
                isDeleteByAdmin: false,
                deletedOn: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").parse(value["AccountDeleteDate"] ?? DateTime.now().toIso8601String())

              ),
            );
          } else {
            if (value['hasData'] != null)
              notVerified.add(
                UserInformation(
                  userStatus: value['LastActive'] != null
                      ? DateTime.parse(value['LastActive'].toString())
                      .difference(DateTime.now())
                      .inMinutes
                      .abs() <
                      5
                      ? 'Active'
                      : 'Inactive'
                      : 'Inactive',
                  joinedOn: DateTime.parse(value['DateTime']),
                  isVerified: value['isVerified'] ?? false,
                  suspended: value['isSuspended'] != null
                      ? value['isSuspended']
                      : false,
                  srId: value['id'],
                  name: value['userName'],
                  email: value['email'] ?? '',
                  id: key,
                  hideContact: hideMobile,
                  hideProfile: hideProfile,
                  phone: value['mobileNo'] ?? '',
                  gender: value['gender'] ?? '',
                  isPremium: value['isPremium'] ?? false,
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
                  isVerificationRequired: value['isVerificationRequired'] ?? false,
                  isVerificationRequiredGovId: value['isVerificationGovId'] ?? false,
                  //casteNoBar: value['casteNoBar'] ?? '',
                  intro: value['intro'] ?? '',
                  manglik: value['maglik'] ?? '',
                  city: value['city'] ?? '',
                  visibility: value['visibility'] ?? 'All Member',
                  fatherGautra: value['fatherGotra'] ?? '',
                  motherGautra: value['motherGotra'] ?? '',
                  diet: value['diet'] ?? "",
                  // gotra: value['gautra'],
                  //  zipCode: value['zipCode'],
                  imageUrl: value['imageURL'] ?? '',
                  cityOfBirth: value['cityOfBirth'] ?? '',
                  employerName: value['employerName'] ?? "",
                  state: value['state'] ?? '',
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
                  referCode: value['referCode'] ?? '',
                  maritalStatus: value['maritalStatus'] ?? "",
                  noOfChildren: value['noOfChildren'] ?? "",
                  childrenLivingTogether: value['childrenLivingTogether'] ?? "",
                  verifiedBy: value['verifiedBy'] ?? "",
                  allowMarketing: value['allowMarketing'] ?? true,
                  deletedBy: value['DeletedBy'] ?? 'User',
                  deletedReason: value['Reason'] ?? 'Not Available',
                    isDeleteByAdmin: false,
                    deletedOn: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").parse(value["AccountDeleteDate"] ?? DateTime.now().toIso8601String())
                ),
              );
          }
        }


      });
    }
  }

  // bool isLoaded = false;

  Future<void> getRecentDeleteUsers() async {

    ///about == 1
    ///delete list data == 2

    // var data= await FirebaseDatabase.instance.reference()
    //       .child('User Information').orderByChild("inTrash").equalTo(true)
    //       .once();

    final dateTime = DateTime.now();
    final stringDateTime = dateTime.toIso8601String();
    final parsedDateTime = DateTime.parse(stringDateTime);
    recentDeleteList = [];

    debugPrint("recentDeleteList 123 ==> ${recentDeleteList.length}");

    final data = await FirebaseDatabase.instance.reference().child('User Information').once();
    Map mappedData = (data.snapshot.value ?? {}) as Map;

    // SqzqcL8GwER7OFGgGePDfmmvyaE3
    if (mappedData != null && mappedData.isNotEmpty) {
        mappedData.forEach((key, value) async {
          if (value.containsKey("AccountDeleteDate")) {
            print("key---->>>$key");
            print("aaaaa==>>${value['AccountDeleteDate']}");

            if (parsedDateTime.isBefore(DateTime.parse(value['AccountDeleteDate']))) {
              // final mappedData = data.snapshot.value as Map;
              // log("mappedData===>>>${mappedData}");
              debugPrint("key ==> ${key}");

              final hideProfileMap = value['hideProfile'] != null ? value['hideProfile'] as Map : null;
              final hideMobileMap = value['hideMobile'] != null ? value['hideMobile'] as Map : null;
              bool hideMobile = false;
              bool hideProfile = false;
              if (hideMobileMap != null)
                hideMobileMap.forEach((key, value) {
                  // if (value) hideMobile = true;
                  if (key == "expireDate") {
                    DateTime tempDate = DateTime.parse(value);
                    if (DateTime.now().isBefore(tempDate) == false) {
                      hideMobile = false;
                    } else {
                      hideMobile = true;
                    }
                  } else {
                    hideMobile = false;
                  }
                });

              if (hideProfileMap != null)
                hideProfileMap.forEach((key, value) {
                  // if (value) hideProfile = true;
                  if (key == "unHideDate") {
                    DateTime tempDate = DateTime.parse(value);
                    if (DateTime.now().isBefore(tempDate) == false) {
                      hideProfile = false;
                    } else {
                      hideProfile = true;
                    }
                  }
                });

              List<String> blockedById = [];

              if (mappedData['Blocked By'] != null) {
                mappedData['Blocked By'].forEach((key, value) {
                  blockedById.add(key);
                });
              }

              print("isvarified ??????--->>>${value['isVerified']}");

              recentDeleteList.add(
                UserInformation(
                    deletedBy: value['DeletedBy'] ?? 'User',
                    userStatus: value['LastActive'] != null
                        ? (DateTime.parse(value['LastActive'].toString()).difference(DateTime.now()).inMinutes.abs() < 5
                            ? 'Active'
                            : 'Inactive')
                        : 'Inactive',
                    joinedOn: value['DateTime'] != null
                        ? DateTime.parse(value['DateTime'])
                        : DateTime.now().subtract(Duration(days: 1)),
                    suspended: value['isSuspended'] != null ? value['isSuspended'] : false,
                    srId: value['id'],
                    iseditable: value['isEditable'],
                    name: value['userName'],
                    email: value['email'] ?? '',
                    id: key,
                    isVerified: value['isVerified'],
                    // isVerified: mappedData['isVerified'],
                    blockedByList: blockedById,
                    isSuspended: value['isSuspended'] ?? false,
                    phone: value['mobileNo'] ?? '',
                    gender: value['gender'] ?? '',
                    dateOfBirth: value['DateOfBirth'] ?? '',
                    religion: value['Religion'] ?? '',
                    annualIncome: value['annualIncome'] ?? '',
                    collegeAttended: value['clg'] ?? '',
                    workingAs: value['designation'] ?? '',
                    country: value['living'] ?? '',
                    hideContact: hideMobile,
                    hideProfile: hideProfile,
                    highestQualification: value['qualification'] ?? '',
                    workingWith: value['workAt'] ?? '',
                    anyDisAbility: value['disability'] ?? '',
                    brothers: value['brotherCount'] ?? '',
                    sisters: value['sisterCount'] ?? '',
                    visibility: value['visibility'] ?? 'All Member',
                    //casteNoBar: value['casteNoBar'] ?? '',
                    showHoroscope: mappedData['showHoroscope'] ?? true,
                    intro: value['intro'] ?? '',
                    manglik: value['maglik'] ?? '',
                    city: value['city'] ?? '',
                    fatherGautra: value['fatherGotra'] ?? '',
                    isVerificationRequired: value['isVerificationRequired'] ?? false,
                    isVerificationRequiredGovId: value['isVerificationGovId'] ?? false,
                    birthTime: splitData(mappedData['timeOfBirth'] ?? ""),
                    motherGautra: value['motherGotra'] ?? '',
                    diet: value['diet'] ?? "",
                    employedIn: value['employedIn'] ?? '',
                    isOnline: value['isOnline'] ?? false,
                    // gotra: value['gautra'],
                    //  zipCode: value['zipCode'],
                    imageUrl: value['imageURL'] ?? '',
                    cityOfBirth: value['cityOfBirth'] ?? '',
                    employerName: value['employerName'] ?? "",
                    state: value['state'] ?? '',

                    // timeOfBirth: DateTime.tryParse(
                    //   value['timeOfBirth'] != null ? value['timeOfBirth'] : "",
                    // ),

                    isPremium: value['isPremium'] ?? false,
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
                    referCode: value['referCode'] ?? '',
                    maritalStatus: value['maritalStatus'] ?? "",
                    allowMarketing: value['allowMarketing'] ?? true,
                    lastLogin: value['Lastlogin'] ?? "Never",
                    noOfChildren: value['noOfChildren'] ?? "",
                    childrenLivingTogether: value['childrenLivingTogether'] ?? "",
                    newIntro: value['newIntro'] ?? "",
                    introEdited: value['introEdited'] ?? 0,
                    deletedReason: value['Reason'] ?? 'Not Available',
                    deletedOn: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
                        .parse(value["AccountDeleteDate"] ?? DateTime.now().toIso8601String())),
              );
              // mappedData.forEach((key, value) );
            } else {}
          }
        });
      }

    debugPrint("recentDeleteList ==> ${recentDeleteList.length}");

    /*  Map mappedData = (data.snapshot.value ?? {}) as Map;

    // final mappedData = data.snapshot.value as Map;
    // log("mappedData===>>>${mappedData}");
    recentDeleteList = [];
    if (mappedData != null && mappedData.isNotEmpty) {
      mappedData.forEach((key, value) {
        final hideProfileMap = value['hideProfile'] != null ? value['hideProfile'] as Map : null;
        final hideMobileMap = value['hideMobile'] != null ? value['hideMobile'] as Map : null;
        bool hideMobile = false;
        bool hideProfile = false;
        if (hideMobileMap != null)
          hideMobileMap.forEach((key, value) {
            // if (value) hideMobile = true;
            if(key == "expireDate"){
              DateTime tempDate = DateTime.parse(value);
              if(DateTime.now().isBefore(tempDate) == false){
                hideMobile = false;
              }else{
                hideMobile = true;
              }
            }else{
              hideMobile = false;
            }
          });

        if (hideProfileMap != null)
          hideProfileMap.forEach((key, value) {
            // if (value) hideProfile = true;
            if(key == "unHideDate"){
              DateTime tempDate = DateTime.parse(value);
              if(DateTime.now().isBefore(tempDate) == false){
                hideProfile = false;
              }else{
                hideProfile = true;
              }
            }
          });

        List<String> blockedById = [];

        if (mappedData['Blocked By'] != null) {
          mappedData['Blocked By'].forEach((key, value) {
            blockedById.add(key);
          });
        }
        print("isvarified ??????--->>>${value['isVerified']}");
        recentDeleteList.add(
          UserInformation(
              userStatus: value['LastActive'] != null
                  ? (DateTime.parse(value['LastActive'].toString())
                  .difference(DateTime.now())
                  .inMinutes
                  .abs() <
                  5
                  ? 'Active'
                  : 'Inactive')
                  : 'Inactive',
              joinedOn: DateTime.parse(value['DateTime']),
              suspended:
              value['isSuspended'] != null ? value['isSuspended'] : false,
              srId: value['id'],
              iseditable: value['isEditable'],
              name: value['userName'],
              email: value['email'] ?? '',
              id: key,
              isVerified: value['isVerified'],
              // isVerified: mappedData['isVerified'],
              blockedByList: blockedById,
              isSuspended: value['isSuspended'] ?? false,
              phone: value['mobileNo'] ?? '',
              gender: value['gender'] ?? '',
              dateOfBirth: value['DateOfBirth'] ?? '',
              religion: value['Religion'] ?? '',
              annualIncome: value['annualIncome'] ?? '',
              collegeAttended: value['clg'] ?? '',
              workingAs: value['designation'] ?? '',
              country: value['living'] ?? '',
              hideContact: hideMobile,
              hideProfile: hideProfile,
              highestQualification: value['qualification'] ?? '',
              workingWith: value['workAt'] ?? '',
              anyDisAbility: value['disability'] ?? '',
              brothers: value['brotherCount'] ?? '',
              sisters: value['sisterCount'] ?? '',
              visibility: value['visibility'] ?? 'All Member',
              //casteNoBar: value['casteNoBar'] ?? '',
              showHoroscope: mappedData['showHoroscope'] ?? true,
              intro: value['intro'] ?? '',
              manglik: value['maglik'] ?? '',
              city: value['city'] ?? '',
              fatherGautra: value['fatherGotra'] ?? '',
              isVerificationRequired: value['isVerificationRequired'] ?? false,
              isVerificationRequiredGovId: value['isVerificationRequired'] ?? true,
              birthTime: splitData(mappedData['timeOfBirth'] ?? ""),
              motherGautra: value['motherGotra'] ?? '',
              diet: value['diet'] ?? "",
              employedIn: value['employedIn'] ?? '',
              isOnline: value['isOnline'] ?? false,
              // gotra: value['gautra'],
              //  zipCode: value['zipCode'],
              imageUrl: value['imageURL'] ?? '',
              cityOfBirth: value['cityOfBirth'] ?? '',
              employerName: value['employerName'] ?? "",
              state: value['state'] ?? '',

              // timeOfBirth: DateTime.tryParse(
              //   value['timeOfBirth'] != null ? value['timeOfBirth'] : "",
              // ),

              isPremium: value['isPremium'] ?? false,
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
              referCode: value['referCode'] ?? '',
              maritalStatus: value['maritalStatus'] ?? "",
              allowMarketing: value['allowMarketing'] ?? true,
              lastLogin: value['Lastlogin'] ?? "Never",
              noOfChildren: value['noOfChildren'] ?? "",
              childrenLivingTogether: value['childrenLivingTogether'] ?? "",
              newIntro: value['newIntro'] ?? "",
              introEdited: value['introEdited'] ?? 0
          ),
        );
      });
    }*/
  }

  Future toggleIDVerification(UserInformation user) async {
    this
        .verifiedUsers
        .firstWhere((element) => element.srId == user.srId)
        .isVerificationRequired = !user.isVerificationRequired!;
    await FirebaseDatabase.instance
        .reference()
        .child("User Information")
        .child(user.id!)
        .update({"isVerificationRequired": user.isVerificationRequired});
  }

  Future removeIDVerification(String id) async {
    this
        .verifiedUsers
        .firstWhere((element) => element.id == id)
        .isVerificationRequired = false;
  }

  Future updateList() async {
    this.verifiedUsers = verifiedUsers;
    this.notVerified = notVerified;
    notifyListeners();
  }

  removeSameGender(String gender) {
    notVerified.removeWhere((element) => element.gender == gender);
    notifyListeners();
  }

  updateSuspention(String id) {
    bool? isSuspended = this
                .verifiedUsers
                .firstWhere((element) => element.id == id)
                .suspended !=
            null
        ? this.verifiedUsers.firstWhere((element) => element.id == id).suspended
        : false;
    this.verifiedUsers.firstWhere((element) => element.id == id).suspended =
        !isSuspended!;
    notifyListeners();
  }

  updateUser(String id, UserInformation userInformation) {
    /* int index = this.verifiedUsers.indexWhere((element) => element.id == id);
    this.verifiedUsers[index] = userInformation;
    return;
     */
    this.verifiedUsers.firstWhere((element) => element.id == id).name =
        userInformation.name;
    this.verifiedUsers.firstWhere((element) => element.id == id).name =
        userInformation.name;
    this.verifiedUsers.firstWhere((element) => element.id == id).annualIncome =
        userInformation.annualIncome;
    this.verifiedUsers.firstWhere((element) => element.id == id).anyDisAbility =
        userInformation.anyDisAbility;
    this.verifiedUsers.firstWhere((element) => element.id == id).brothers =
        userInformation.brothers;
    this.verifiedUsers.firstWhere((element) => element.id == id).sisters =
        userInformation.sisters;
    this
        .verifiedUsers
        .firstWhere((element) => element.id == id)
        .marriedBrothers = userInformation.marriedBrothers;
    this
        .verifiedUsers
        .firstWhere((element) => element.id == id)
        .marriedSisters = userInformation.marriedSisters;
    this.verifiedUsers.firstWhere((element) => element.id == id).casteNoBar =
        userInformation.casteNoBar;
    this.verifiedUsers.firstWhere((element) => element.id == id).city =
        userInformation.city;
    this.verifiedUsers.firstWhere((element) => element.id == id).postedBy =
        userInformation.postedBy;
    this.verifiedUsers.firstWhere((element) => element.id == id).cityOfBirth =
        userInformation.cityOfBirth;
    this
        .verifiedUsers
        .firstWhere((element) => element.id == id)
        .collegeAttended = userInformation.collegeAttended;
    this.verifiedUsers.firstWhere((element) => element.id == id).community =
        userInformation.community;
    this.verifiedUsers.firstWhere((element) => element.id == id).country =
        userInformation.country;
    this.verifiedUsers.firstWhere((element) => element.id == id).dateOfBirth =
        userInformation.dateOfBirth;
    this.verifiedUsers.firstWhere((element) => element.id == id).gender =
        userInformation.gender;
    this.verifiedUsers.firstWhere((element) => element.id == id).diet =
        userInformation.diet;
    this.verifiedUsers.firstWhere((element) => element.id == id).email =
        userInformation.email;
    this.verifiedUsers.firstWhere((element) => element.id == id).phone =
        userInformation.phone;
    this.verifiedUsers.firstWhere((element) => element.id == id).employerName =
        userInformation.employerName;
    this.verifiedUsers.firstWhere((element) => element.id == id).familyType =
        userInformation.familyType;
    this.verifiedUsers.firstWhere((element) => element.id == id).fatherGautra =
        userInformation.fatherGautra;
    this.verifiedUsers.firstWhere((element) => element.id == id).religion =
        userInformation.religion;
    this.verifiedUsers.firstWhere((element) => element.id == id).motherTongue =
        userInformation.motherTongue;
    this.verifiedUsers.firstWhere((element) => element.id == id).community =
        userInformation.community;
    this.verifiedUsers.firstWhere((element) => element.id == id).motherGautra =
        userInformation.motherGautra;
    this.verifiedUsers.firstWhere((element) => element.id == id).fatherStatus =
        userInformation.fatherStatus;
    this.verifiedUsers.firstWhere((element) => element.id == id).motherStatus =
        userInformation.motherStatus;
    this.verifiedUsers.firstWhere((element) => element.id == id).nativePlace =
        userInformation.nativePlace;
    this.verifiedUsers.firstWhere((element) => element.id == id).manglik =
        userInformation.manglik;
    this.verifiedUsers.firstWhere((element) => element.id == id).city =
        userInformation.city;
    this.verifiedUsers.firstWhere((element) => element.id == id).country =
        userInformation.country;
    this.verifiedUsers.firstWhere((element) => element.id == id).state =
        userInformation.state;
    this
        .verifiedUsers
        .firstWhere((element) => element.id == id)
        .highestQualification = userInformation.highestQualification;
    this
        .verifiedUsers
        .firstWhere((element) => element.id == id)
        .collegeAttended = userInformation.collegeAttended;
    this.verifiedUsers.firstWhere((element) => element.id == id).workingWith =
        userInformation.workingWith;
    this.verifiedUsers.firstWhere((element) => element.id == id).workingAs =
        userInformation.workingAs;
    this.verifiedUsers.firstWhere((element) => element.id == id).annualIncome =
        userInformation.annualIncome;
    this.verifiedUsers.firstWhere((element) => element.id == id).diet =
        userInformation.diet;
    this.verifiedUsers.firstWhere((element) => element.id == id).maritalStatus =
        userInformation.maritalStatus;
    this.verifiedUsers.firstWhere((element) => element.id == id).birthTime =
        userInformation.birthTime;
    this.verifiedUsers.firstWhere((element) => element.id == id).showHoroscope =
        userInformation.showHoroscope;
    this.verifiedUsers.firstWhere((element) => element.id == id).noOfChildren =
        userInformation.noOfChildren;
    this.verifiedUsers.firstWhere((element) => element.id == id).childrenLivingTogether =
        userInformation.childrenLivingTogether;
    notifyListeners();
  }

  splitData(String time) {
    if (time != null) {
      try {
        List t = time.split('');
        int hr = int.parse(t[10]) * 10 + int.parse(t[11]);
        int minute = int.parse(t[13]) * 10 + int.parse(t[14]);
        //  log(TimeOfDay(hour: hr, minute: minute).toString());

        return TimeOfDay(hour: hr, minute: minute);
      } catch (e) {
        return null;
      }
    } else
      return null;
  }

  Future<bool> toggleHideContact(UserInformation user) async {
    print("user id for hide mobile======>>>>>${user.id}");
    print("hide mobile before======>>>>>${user.hideContact}");

    if (user.hideContact!)
      user.hideContact = false;
    else
      user.hideContact = true;

    print("hide mobile before======>>>>>${user.hideContact}");

    DateTime dt1 = DateTime.now();
    DateTime dt2 = dt1.add(Duration(days: 50000));
    print("dt2 is===>>>>>$dt2");

    DateFormat formatter = DateFormat('yyyy-MM-dd');

    String finalEndDateForHide = formatter.format(dt2);
    String finalEndDateForUnHide = formatter.format(dt1);
    print("finalEndDateForHide is===>>>>>$finalEndDateForHide");
    print("finalEndDateForUnHide is===>>>>>$finalEndDateForUnHide");

    await FirebaseDatabase.instance
        .reference()
        .child('User Information')
        .child(user.id!)
        .child("hideMobile")
        .update({
      'mobile': user.hideContact,
      'expireDate': user.hideContact == true ? finalEndDateForHide.toString() : finalEndDateForUnHide.toString(),
    });
    return user.hideContact!;
  }

  Future<bool> toggleHideProfile(UserInformation user) async {
    if (user.hideProfile!)
      user.hideProfile = false;
    else
      user.hideProfile = true;

    if (user.hideProfile!) {
      await FirebaseDatabase.instance
          .reference()
          .child('User Information')
          .child(user.id!)
          .child("hideProfile")
          .update({
        '1week': user.hideProfile,
      });
    } else {
      await FirebaseDatabase.instance
          .reference()
          .child('User Information')
          .child(user.id!)
          .child("hideProfile")
          .update({
        '1week': user.hideProfile,
        '2week': user.hideProfile,
        'month': user.hideProfile,
      });
    }
    return user.hideProfile!;
  }
}
