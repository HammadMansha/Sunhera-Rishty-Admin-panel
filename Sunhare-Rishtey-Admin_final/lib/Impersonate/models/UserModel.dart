import 'package:flutter/material.dart';
import 'package:sunhare_rishtey_new_admin/models/parternerInfoModel.dart';
import 'package:sunhare_rishtey_new_admin/models/primiumModel.dart';

class UserInformation {
  String? name;
  String? email;
  String? phone;
  String? imageUrl;
  String? id;
  bool? isPhone;
  String? postedBy;
  String? age;
  String? anyDisAbility;
  String? healthInfo;
  String? intro;
  String? religion;
  String? motherTongue;
  String? community;
  bool? casteNoBar;
  bool? isOnline;
  String? gotra;
  String? fatherStatus;
  String? motherStatus;
  String? nativePlace;
  String? brothers;
  String? sisters;
  String? familyType;
  String? manglik;
  String? dateOfBirth;
  //  DateTime timeOfBirth;
  String? cityOfBirth;
  String? country;
  String? state;
  String? city;
  String? residencyStatus;
  String? zipCode;
  String? grewUpIn;
  String? highestQualification;
  String? collegeAttended;
  String? workingWith;
  String? workingAs;
  String? annualIncome;
  String? employerName;
  String? diet;
  String? height;
  PartnerInfo? partnerInfo;
  String? maritalStatus;
  String? fatherGautra;
  String? motherGautra;
  String? gender;
  bool? isVerified;
  bool? isPremium;
  String? visibility;
  String? marriedSisters;
  String? marriedBrothers;
  String? srId;
  String? bloodGroup;
  String? fatherName;
  String? motherName;
  String? employedIn;
  String? fatherFamilyFrom;
  String? familyValues;
  String? affluenceLevel;
  TimeOfDay? birthTime;
  bool? showHoroscope;
  String? userStatus;
  String? verifiedBy;
  PremiumModel? premiumModel;
  bool? isSuspended;
  String? fcmToken;
  DateTime? dateOfCreated;
  bool? hideDob;
  bool? hideContact;
  bool? allowMarketing;
  bool? hideProfile;
  bool? isGovIdVerified;
  String? govVerifiedBy;
  final List<String>? blockedByList;

  UserInformation(
      {this.healthInfo,
      this.isPremium,
      this.gender,
      this.height,
      this.age,
      this.annualIncome,
      this.anyDisAbility,
      this.brothers,
      this.casteNoBar,
      this.city,
      this.blockedByList,
      this.cityOfBirth,
      this.collegeAttended,
      this.community,
      this.country,
      this.dateOfBirth,
      this.diet,
      this.email,
      this.employerName,
      this.fatherStatus,
      this.familyType,
      this.gotra,
      this.grewUpIn,
      this.highestQualification,
      this.id,
      this.imageUrl,
      this.intro,
      this.isPhone,
      this.manglik,
      this.employedIn,
      this.motherStatus,
      this.motherTongue,
      this.name,
      this.nativePlace,
      this.partnerInfo,
      this.phone,
      this.postedBy,
      this.isOnline,
      this.religion,
      this.residencyStatus,
      this.sisters,
      this.state,
      this.workingAs,
      this.workingWith,
      this.zipCode,
      this.maritalStatus,
      this.fatherGautra,
      this.motherGautra,
      this.isVerified,
      this.visibility,
      this.marriedSisters,
      this.marriedBrothers,
      this.srId,
      this.bloodGroup,
      this.affluenceLevel,
      this.familyValues,
      this.fatherFamilyFrom,
      this.fatherName,
      this.motherName,
      this.birthTime,
      this.showHoroscope,
      this.userStatus,
      this.premiumModel,
      this.verifiedBy,
      this.isSuspended,
      this.fcmToken,
      this.hideProfile,
      this.allowMarketing,
      this.hideContact,
      this.hideDob,
      this.dateOfCreated,
      this.isGovIdVerified,
      this.govVerifiedBy});

}
