import 'package:intl/intl.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class PartnerInfo {
  final String? id;
  final String? minAge;
  final String? minHeight;
  final String? maritalStatus;
  final String? religion;
  final String? motherTong;
  final String? country;
  final String? state;
  final String? city;
  final String? qualification;
  final String? workingWith;
  final String? workingAs;
  final String? proffesionArea;
  final String? minIncome;
  final String? diet;
  final String? maxAge;
  final String? maxIncome;
  final String? maxHeight;
  final String? community;
  final bool? qualificationOpenForAll;
  final bool? designationOpenForAll;
  final bool? dietForAll;
  final bool? locationForAll;
  final bool? maritalStatusForAll;
  final bool? religionForAll;
  final bool? motherToungueForAll;
  final bool? manglikForAll;
  final bool? employedInForAll;
  final List? selectedDietList;
  final List? selectedManglikList;
  final List? selectedDesignation;
  final List? selectedQualificationList;
  final List? selectedLocationList;
  final List? selectedMaritalStatusList;
  final List? selectedReligionList;
  final List? selectedMotherToungueList;
  final List? selectedEmployedInList;

  PartnerInfo(
      {this.id,
      this.minAge,
      this.minIncome,
      this.maxIncome,
      this.maxAge,
      this.city,
      this.country,
      this.diet,
      this.minHeight,
      this.maritalStatus,
      this.motherTong,
      this.proffesionArea,
      this.qualification,
      this.religion,
      this.state,
      this.workingAs,
      this.workingWith,
      this.community,
      this.selectedDesignation,
      this.selectedQualificationList,
      this.selectedDietList,
      this.designationOpenForAll,
      this.dietForAll,
      this.qualificationOpenForAll,
      this.manglikForAll,
      this.locationForAll,
      this.selectedLocationList,
      this.maxHeight,
      this.maritalStatusForAll,
      this.motherToungueForAll,
      this.employedInForAll,
      this.religionForAll,
      this.selectedMaritalStatusList,
      this.selectedManglikList,
      this.selectedMotherToungueList,
      this.selectedEmployedInList,
      this.selectedReligionList});

  static PartnerInfo fromJson(key, value) {
    return PartnerInfo(
        id: key,
        maritalStatusForAll: value['maritalStatusForAll'] ?? false,
        selectedMaritalStatusList: value['maritalStatusList'] ?? [],
        motherToungueForAll: value['motherToungeForAll'] ?? true,
        selectedMotherToungueList: value['motherToungueList'] ?? [],
        religionForAll: value['religionForAll'] ?? true,
        manglikForAll: value['manglikForAll'] ?? true,
        employedInForAll: value['employedInForAll'] ?? true,
        selectedEmployedInList: value['emplyedInList'] ?? [],
        selectedReligionList: value['religionList'] ?? [],
        selectedManglikList: value['selectedManglikList'] ?? [],
        city: value['city'] ?? '',
        country: value['country'],
        workingWith: value['workingWith'],
        workingAs: value['designation'],
        diet: value['diet'],
        maritalStatus: value['maritalStatus'],
        maxAge: value['maxAge'],
        minAge: value['minAge'],
        maxIncome: value['maxIncome'],
        minIncome: value['minIncome'],
        motherTong: value['motherTounge'],
        qualification: value['qualification'],
        community: value['community'],
        religion: value['religion'],
        state: value['state'],
        selectedDesignation: value['designationList'] ?? [],
        maxHeight: value['maxHeight'],
        selectedDietList: value['dietList'] ?? [],
        selectedQualificationList: value['qualificationList'] ?? [],
        designationOpenForAll: value['desigForAll'] ?? true,
        dietForAll: value['dietForAll'] ?? true,
        qualificationOpenForAll: value['qualificationForAll'] ?? true,
        locationForAll: value['locationForAll'] ?? true,
        selectedLocationList: value['locationList'] ?? [],
        minHeight: value['minHeight']);
  }

  static PartnerInfo fromJsonWithMeritalStatus(key, value, currentUser) {
    bool maritalStatusForAll;
    List selectedMaritalStatusList = [];
    if (currentUser == null) {
      maritalStatusForAll = true;
      selectedMaritalStatusList = [];
    } else {
      maritalStatusForAll = currentUser['maritalStatus'] != "Never Married";
      if (!maritalStatusForAll) {
        selectedMaritalStatusList = ["Never Married"];
      }
    }

    return PartnerInfo(
        id: key,
        maritalStatusForAll:
            value['maritalStatusForAll'] ?? maritalStatusForAll,
        selectedMaritalStatusList:
            value['maritalStatusList'] ?? selectedMaritalStatusList,
        motherToungueForAll: value['motherToungeForAll'] ?? true,
        selectedMotherToungueList: value['motherToungueList'] ?? [],
        religionForAll: value['religionForAll'] ?? true,
        manglikForAll: value['manglikForAll'] ?? true,
        employedInForAll: value['employedInForAll'] ?? true,
        selectedEmployedInList: value['emplyedInList'] ?? [],
        selectedReligionList: value['religionList'] ?? [],
        selectedManglikList: value['selectedManglikList'] ?? [],
        city: value['city'] ?? '',
        country: value['country'],
        workingWith: value['workingWith'],
        workingAs: value['designation'],
        diet: value['diet'],
        maritalStatus: value['maritalStatus'],
        maxAge: value['maxAge'],
        minAge: value['minAge'],
        maxIncome: value['maxIncome'],
        minIncome: value['minIncome'],
        motherTong: value['motherTounge'],
        qualification: value['qualification'],
        community: value['community'],
        religion: value['religion'],
        state: value['state'],
        selectedDesignation: value['designationList'] ?? [],
        maxHeight: value['maxHeight'],
        selectedDietList: value['dietList'] ?? [],
        selectedQualificationList: value['qualificationList'] ?? [],
        designationOpenForAll: value['desigForAll'] ?? true,
        dietForAll: value['dietForAll'] ?? true,
        qualificationOpenForAll: value['qualificationForAll'] ?? true,
        locationForAll: value['locationForAll'] ?? true,
        selectedLocationList: value['locationList'] ?? [],
        minHeight: value['minHeight']);
  }

  static int countIncome(String annualIncome) {
    String str = annualIncome.replaceFirst("-", "").replaceFirst(" lakhs", "");
    if (str == "Not Working" || str == "" || str.contains("<")) {
      return 0;
    } else if (str.contains(">")) {
      return 100000;
    } else {
      return int.parse(str);
    }
  }

  static int calculateHeight(String height) {
    String str;
    try {
      str = height.split(' - ')[1];
    } catch (e) {
      return 0;
    }
    return int.parse(str.substring(0, str.length - 2));
  }

  static int calculateAge(String dobirth) {
    var now = DateTime.now();
    final DateFormat format = new DateFormat("dd/MMM/yyyy");
    var dob = format.parse(dobirth);
    return (now.difference(dob).inDays ~/ 365);
  }

  static bool checkPref(List selectedList, String info, bool openForAll) {
    return !(openForAll || selectedList.contains(info));
  }

  static bool matchPreferences(
      PartnerInfo partnerInfo, UserInformation currentUser) {
    if (checkPref(partnerInfo.selectedMaritalStatusList!,
        currentUser.maritalStatus!, partnerInfo.maritalStatusForAll!)) {
      print(
          "${partnerInfo.id} not matched mrg status ${currentUser.maritalStatus} ${partnerInfo.selectedMaritalStatusList} ${partnerInfo.maritalStatusForAll}");
      return false;
    }
    if (checkPref(partnerInfo.selectedDietList!, currentUser.diet!,
        partnerInfo.dietForAll!)) {
      print("${partnerInfo.id} not matched ");
      return false;
    }
    if (checkPref(partnerInfo.selectedDesignation!, currentUser.workingAs!,
        partnerInfo.designationOpenForAll!)) {
      print("${partnerInfo.id} not matched ");
      return false;
    }
    if (checkPref(
        partnerInfo.selectedQualificationList!,
        currentUser.highestQualification!,
        partnerInfo.qualificationOpenForAll!)) {
      print("${partnerInfo.id} not matched ");
      return false;
    }
    if (checkPref(partnerInfo.selectedReligionList!, currentUser.religion!,
        partnerInfo.religionForAll!)) {
      print("${partnerInfo.id} not matched ");
      return false;
    }
    if (checkPref(partnerInfo.selectedMotherToungueList!,
        currentUser.motherTongue!, partnerInfo.motherToungueForAll!)) {
      print("${partnerInfo.id} not matched ");
      return false;
    }
    if (checkPref(partnerInfo.selectedLocationList!, currentUser.state!,
        partnerInfo.locationForAll!)) {
      print("${partnerInfo.id} not matched ");
      return false;
    }
    if (checkPref(partnerInfo.selectedEmployedInList!, currentUser.employedIn!,
        partnerInfo.employedInForAll!)) {
      print("${partnerInfo.id} not matched ");
      return false;
    }
    if (currentUser.dateOfBirth != null &&
        ((partnerInfo.minAge != null &&
                partnerInfo.minAge != "" &&
                int.parse(partnerInfo.minAge!) >
                    calculateAge(currentUser.dateOfBirth!)) ||
            (partnerInfo.maxAge != null &&
                partnerInfo.maxAge != "" &&
                int.parse(partnerInfo.maxAge!) <
                    calculateAge(currentUser.dateOfBirth!)))) {
      print("${partnerInfo.id} not matched ");
      return false;
    }
    if (currentUser.annualIncome != null) {
      int income = countIncome(currentUser.annualIncome!);
      if ((partnerInfo.minIncome != null &&
              countIncome(partnerInfo.minIncome!) > income) ||
          (partnerInfo.maxIncome != null &&
              countIncome(partnerInfo.maxIncome!) < income)) {
        print("${partnerInfo.id} not matched ");
        return false;
      }
    }
    if (currentUser.height != null && currentUser.height!.isNotEmpty) {
      String str = currentUser.height!.split(' - ')[1];
      int elementHeight = int.parse(str.substring(0, str.length - 2));
      if ((partnerInfo.maxHeight != null &&
              partnerInfo.maxHeight!.isNotEmpty &&
              elementHeight > calculateHeight(partnerInfo.maxHeight!)) ||
          (partnerInfo.minHeight != null &&
              partnerInfo.minHeight!.isNotEmpty &&
              elementHeight < calculateHeight(partnerInfo.minHeight!))) {
        print("${partnerInfo.id} not matched ");
        return false;
      }
    }
    return true;
  }
}
