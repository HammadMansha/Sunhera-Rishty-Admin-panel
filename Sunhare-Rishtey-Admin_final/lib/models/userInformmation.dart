import 'package:flutter/material.dart';
import 'package:sunhare_rishtey_new_admin/models/parternerInfoModel.dart';
import 'package:sunhare_rishtey_new_admin/models/primiumModel.dart';

class UserInformation {
  String? name;
  String? lastLogin;
  String? noOfChildren;
  String? newIntro;
  int? introEdited;
  String? childrenLivingTogether;
  String? email;
  String? phone;
  String? imageUrl;
  String? id;
  bool? isPhone;
  String? postedBy;
  String? age;
  String? anyDisAbility;
  String? healthInfo;
  bool? showHoroscope;
  String? intro;
  String? religion;
  String? visibility;
  String? motherTongue;
  String? community;
  bool? casteNoBar;
  TimeOfDay? birthTime;
  String? gotra;
  String? fatherStatus;
  String? motherStatus;
  String? nativePlace;
  String? brothers;
  String? sisters;
  String? familyType;
  String? manglik;
  String? dateOfBirth;
  String? employedIn;
  bool? suspended;
  bool? isVerificationRequired;
  bool? isVerificationRequiredGovId;

  // DateTime timeOfBirth;
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
  String? maritalStatus;
  String? fatherGautra;
  String? motherGautra;
  String? gender;
  bool? isVerified;
  String? srId;
  bool? isOnline;
  DateTime? joinedOn;
  String? userStatus;
  DateTime? deletedOn;
  String? deletedBy;
  DateTime? reportedOn;
  String? deletedReason;
  String? referCode;
  bool? allowMarketing;
  bool? isPremium;
  bool? iseditable = true;
  List<String>? blockedByList;

  bool? isSuspended;

  bool? hideContact;
  bool? hideProfile;

  PremiumModel? premiumModel;

  String? marriedBrothers;
  String? bloodGroup;
  String? affluenceLevel;
  String? familyValues;
  String? marriedSisters;
  String? motherName;
  String? fatherName;

  PartnerInfo? partnerInfo;

  String? verifiedBy;

  bool? isGovIdVerified = false;
  bool? isDeleteByAdmin = false;

  // PlanName planDetails;
  UserInformation(
      {this.healthInfo,
        this.newIntro,
        this.introEdited,
      this.lastLogin,
      this.noOfChildren,
      this.childrenLivingTogether,
      this.gender,
      this.birthTime,
      this.premiumModel,
      this.height,
      this.age,
      this.annualIncome,
      this.isPremium,
      this.iseditable,
      this.anyDisAbility,
      this.isSuspended,
      this.brothers,
      this.isGovIdVerified,
      this.casteNoBar,
      this.city,
      this.isVerificationRequired,
      this.isVerificationRequiredGovId,
      this.verifiedBy,
      this.hideContact,
      this.hideProfile,
      this.showHoroscope,
      this.blockedByList,
      this.isOnline,
      this.cityOfBirth,
      this.collegeAttended,
      this.community,
      this.visibility,
      this.country,
      this.dateOfBirth,
      this.diet,
      this.partnerInfo,
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
      this.employedIn,
      this.isPhone,
      this.manglik,
      this.motherStatus,
      this.motherTongue,
      this.name,
      this.nativePlace,
      this.phone,
      this.postedBy,
      this.religion,
      this.residencyStatus,
      this.sisters,
      this.state,
      //    this.timeOfBirth,
      this.workingAs,
      this.workingWith,
      this.zipCode,
      this.maritalStatus,
      this.fatherGautra,
      this.motherGautra,
      this.isVerified,
      this.srId,
      this.suspended,
      this.joinedOn,
      this.userStatus,
      this.deletedOn,
      this.deletedBy,
      this.reportedOn,
      this.deletedReason,
      this.referCode,
      // this.planDetails,
      this.allowMarketing,
      this.affluenceLevel,
      this.familyValues,
      this.motherName,
      this.fatherName,
      this.bloodGroup,
      this.marriedBrothers,
      this.marriedSisters,
      this.isDeleteByAdmin,

      });

  UserInformation.fromMap(Map map)
      : this(
            name: map['name'],
            email: map['email'],
            phone: map['phone'],
            city: map['city']);
}
