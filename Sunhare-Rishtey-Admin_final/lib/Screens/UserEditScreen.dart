import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:provider/provider.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';

import '../main.dart';

class EditSection extends StatefulWidget {
  final UserInformation? userInfo;
  final Function? onTapUpdate;
  EditSection({this.userInfo, this.onTapUpdate});
  @override
  _EditSectionState createState() => _EditSectionState();
}

class _EditSectionState extends State<EditSection> {

  String intro = '';
  // final Function onTapUpdate;
  bool _basicInfo = true;
  bool _bio = true;
  bool _religious = true;
  bool _family = true;
  bool _astro = true;
  bool _location = true;
  bool _lifestyle = true;
  bool isLoading = false;

  String livingTogetherStatus = "Yes. Living together";
  String childrenStatus = "1";

  List<String> heightList = [
    "4' 5\" - 134 cm",
    "4' 6\" - 137 cm",
    "4' 7\" - 139 cm",
    "4' 8\" - 142 cm",
    "4' 9\" - 144 cm",
    "4' 10\" - 147 cm",
    "4' 11\" - 149 cm",
    "5' 0\" - 152 cm",
    "5' 1\" - 154 cm",
    "5' 2\" - 157 cm",
    "5' 3\" - 160 cm",
    "5' 4\" - 162 cm",
    "5' 5\" - 165 cm",
    "5' 6\" - 167 cm",
    "5' 7\" - 170 cm",
    "5' 8\" - 172 cm",
    "5' 9\" - 175 cm",
    "5' 10\" - 177 cm",
    "5' 11\" - 180 cm",
    "6' 0\" - 182 cm",
    "6' 1\" - 185 cm",
    "6' 2\" - 187 cm",
    "6' 3\" - 190 cm",
    "6' 4\" - 193 cm",
    "6' 5\" - 195 cm",
    "6' 6\" - 198 cm",
    "6' 7\" - 200 cm",
    "6' 8\" - 203 cm",
    "6' 9\" - 205 cm",
    "6' 10\" - 208 cm",
    "6' 11\" - 210 cm",
    "7' 0\" - 213 cm",
  ];
  List<String> motherTongueList = [
    "Hindi",
    "English",
    "Assamese",
    "Bangla",
    "Bodo",
    "Dogri",
    "Gujarati",
    "Kashmiri",
    "Kannada",
    "Konkani",
    "Maithili",
    "Malayalam",
    "Manipuri",
    "Marathi",
    "Nepali",
    "Oriya",
    "Punjabi",
    "Tamil",
    "Telugu",
    "Santali",
    "Sindhi",
    "Urdu",
  ];

  var selectedDiet;
  List<String> dietList = [
    'Veg',
    'Non-Veg',
    'Occasionally Non-Veg',
    'Eggestarian',
    'Jain',
    'Vegan',
  ];
  var selectedcountry;
  List<String> countryList = [
    'India',
    'Foreign',
  ];

  var selectedprofile;
  List<String> profileList = [
    'Self',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Friend',
  ];
  var selectedreligion;
  List<String> religionList = [
    'Awadhiya',
    'Ayodhyawashi',
    'Brahmin',
    'Bundelkhandi',
    'Bundelkhandi Kshatriya',
    'Dalya',
    'Deshwall',
    'Kanaujiya',
    'Kannokiya',
    'Kanoja',
    'Katalpuri',
    'Khargapuriya',
    'Kshatriya',
    'Kshatriya (Non Maidh)',
    'Mahor',
    'Maidh Kshatriya',
    'Maidh Kshatriya suryavanshi',
    'Maidh Rajput',
    'Malvi',
    'Meerakhpuria',
    'Mevadi',
    'Narvariya',
    'Negapura Maidh Kshatriya',
    'Nekpuriya',
    'Pardesi',
    'Punjabi',
    'Purniya',
    'Rajput',
    'Rastogi',
    'Sekhawati',
    'Shrimali',
    'Vaishnav',
  ];
  var selectedCommunity;
  List<String> communityList = [
    'Brahmin',
    'Jain',
    'Rajput',
  ];

  static const List<String> employedInList = [
    'Private sector',
    "Government/Public sector",
    'Civil service',
    'Defence',
    'Business/Self-employed',
    'Not Working',
  ];

  List<String> maritalStatusList = [
    'Never Married',
    'Divorced',
    'Widowed',
    'Awaiting Divorce',
    'Annulled',
  ];
  List<String> incomeList = [
    '< 1 lakhs',
    '1-3 lakhs',
    '3-5 lakhs',
    '5-7 lakhs',
    '7-9 lakhs',
    '9-10 lakhs',
    '> 10 lakhs',
  ];

  List<String> familyTypeList = [
    'Joint',
    'Nuclear',
  ];
  List<String> genderTypeList = [
    'Male',
    'Female',
  ];

  List<String> manglikList = [
    'Manglik',
    'Non Manglik',
    'Anshik Manglik',
  ];
  String? maritalStatus;
  String? heightPerson;
  String? disability;
  String? subCommodity;
  String? motherTongue;
  String? goutra;
  String? fatherName;
  String? fatherStatus;
  String? motherName;
  String? motherStatus;
  String? familyCity;
  String? noOfBrothers;
  String? noOfSisters;
  String? familyType;
  String? nativeCity;
  String? cityOfBirth;
  String? manglik;
  String? name;
  String? dateOfBirth;
  String? email;
  String? postedBy;
  String? phone;

  //
  String? state;
  String? city;
  String? zipCode;
  String? highestQualification;
  String? clgAttended;
  String? workWith;
  String? designation;
  String? employedIn;
  String? annualIncome;

  String? motherGotra;
  String? fathergotra;
  String? marriedBrothers;
  String? marriedSisters;
  String? gender;

  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay timeOfBirth = TimeOfDay.now();
  bool showHoroscope = false;

  List<String> fatherStatusList = [
    'Employed',
    'Business',
    'Retired',
    'Not Employed',
    'Passed Away',
  ];
  List<String> motherStatusList = [
    'Home Queen', // 'Homemaker'
    'Employed',
    'Business',
    'Retired',
    'Passed Away',
  ];
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked_s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (BuildContext? context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context!).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        });

    if (picked_s != null && picked_s != selectedTime)
      setState(() {
        selectedTime = picked_s;
        timeOfBirth = picked_s;
      });
  }

  String selectedDay = "01", selectedMonth = "Jan", selectedYear = "2000";
  String selectedHour = "01", selectedMinute = "01", selectedAmPm = "AM";
  List<String> maleYearList = [];

  getMaleList() {
    maleYearList.clear();
    DateTime endYear = DateTime.now().subtract(Duration(days: 7300));
    DateTime startYear = DateTime.now().subtract(Duration(days: 24824));
    for (int x = startYear.year; x < endYear.year; x++) {
      maleYearList.add(x.toString());
      print("maleYearList is===>>>${maleYearList}");
    }
  }

  static const List<String> dayList = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
  ];
  static const List<String> monthList = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const List<String> hourList = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
  ];
  static const List<String> minuteList = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '38',
    '39',
    '40',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '50',
    '51',
    '52',
    '53',
    '54',
    '55',
    '56',
    '57',
    '58',
    '59',
    '60'
  ];
  static const List<String> AmPmList = [
    'AM',
    'PM'
  ];
  @override
  void initState() {
    getMaleList();
    print("DOB is===>>>>${widget.userInfo!.dateOfBirth!}");
    selectedDay = widget.userInfo!.dateOfBirth!.split("/")[0];
    selectedMonth = widget.userInfo!.dateOfBirth!.split("/")[1];
    selectedYear = widget.userInfo!.dateOfBirth!.split("/")[2];
    // selectedHour = widget.userInfo!.birthTime!.split("/")[0];
    // selectedMinute = widget.userInfo!.birthTime!.split("/")[1];
    // selectedAmPm = widget.userInfo!.birthTime!.split("/")[2];
    maritalStatus = widget.userInfo!.maritalStatus!;
    heightPerson = widget.userInfo!.height!;
    disability = widget.userInfo!.anyDisAbility!;
    dateOfBirth = widget.userInfo!.dateOfBirth!;
    email = widget.userInfo!.email!;
    employedIn = widget.userInfo!.employedIn!;
    //////
    intro = widget.userInfo!.intro!;
    selectedreligion = widget.userInfo!.religion!;
    selectedCommunity = widget.userInfo!.community!;
    goutra = widget.userInfo!.gotra == null ? "" :  widget.userInfo!.gotra!;

    /////////
    fatherStatus = widget.userInfo!.fatherStatus!;
    motherTongue = widget.userInfo!.motherTongue!;
    motherStatus = widget.userInfo!.motherStatus!;
    nativeCity = widget.userInfo!.nativePlace!;
    familyCity = widget.userInfo!.residencyStatus!;
    familyType = widget.userInfo!.familyType!;
    postedBy = widget.userInfo!.postedBy!;
    phone = widget.userInfo!.phone!;

    ///////
    cityOfBirth = widget.userInfo!.cityOfBirth!;
    manglik = widget.userInfo!.manglik!;
    gender = widget.userInfo!.gender!;

    ////
    ///
    state = widget.userInfo!.state!;
    city = widget.userInfo!.city!;
    zipCode = widget.userInfo!.zipCode == null ? "" : widget.userInfo!.zipCode!;
    highestQualification = widget.userInfo!.highestQualification!;
    clgAttended = widget.userInfo!.collegeAttended!;
    workWith = widget.userInfo!.workingWith!;
    designation = widget.userInfo!.workingAs!;
    annualIncome = widget.userInfo!.annualIncome!;
    selectedcountry = widget.userInfo!.country;
    motherGotra = widget.userInfo!.motherGautra!;
    fathergotra = widget.userInfo!.fatherGautra!;
    familyCity = widget.userInfo!.residencyStatus!;
    nativeCity = widget.userInfo!.nativePlace!;

    ///
    selectedDiet = widget.userInfo!.diet!;
    name = widget.userInfo!.name!;
    marriedBrothers = widget.userInfo!.marriedBrothers == null ? "" : widget.userInfo!.marriedBrothers!;
    marriedSisters = widget.userInfo!.marriedSisters == null ? "" :widget.userInfo!.marriedSisters!;
    noOfBrothers = widget.userInfo!.brothers!;
    noOfSisters = widget.userInfo!.sisters!;

    timeOfBirth = widget.userInfo!.birthTime == null ? TimeOfDay.now() :widget.userInfo!.birthTime!;
    print("birth time1 is===>>>>${timeOfBirth.hour.toString()}");
    print("birth time2 is===>>>>${timeOfBirth.minute.toString()}");
    print("birth time3 is===>>>>${timeOfBirth.period.toString().split('.').last}");

    livingTogetherStatus = widget.userInfo?.childrenLivingTogether ?? "Yes. Living together";
    childrenStatus = widget.userInfo?.noOfChildren ?? "0";

    var dateFormat = DateFormat("h");
    var utcDate = dateFormat.format(DateTime.parse('2000-12-31 ${timeOfBirth.hour.toString().length.isOdd ? "0${timeOfBirth.hour.toString()}" : timeOfBirth.hour.toString()}:${timeOfBirth.minute.toString().length.isOdd ? "0${timeOfBirth.minute.toString()}" : timeOfBirth.minute.toString()}:00'));
    print("birth time4 is===>>>>${utcDate}");
    selectedHour = utcDate.length.isOdd? "0${utcDate}" : utcDate;
    selectedMinute = timeOfBirth.minute.toString().length.isOdd ? "0${timeOfBirth.minute.toString()}" : timeOfBirth.minute.toString();
    selectedAmPm = timeOfBirth.period.toString().toUpperCase().split('.').last;
    showHoroscope = widget.userInfo!.showHoroscope!;

    // marriedBrothers = widget.userInfo.marriedBrothers;
    // marriedSisters = widget.userInfo.marriedSisters;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        // backgroundColor: theme.colorBackground,
        appBar: AppBar(
          actions: [],
          backgroundColor: theme.colorCompanion,
        ),
        bottomNavigationBar: InkWell(
          onTap: () {
            TimeOfDay tempTimeOfDay;
            String birthDimedateTime;
            if(selectedAmPm == "PM"){
              birthDimedateTime = "TimeOfDay(${(int.parse(selectedHour)+12).toString()}:${selectedMinute})";
              tempTimeOfDay = TimeOfDay(hour:int.parse(selectedHour)+12,minute: int.parse(selectedMinute));
            }else{
              birthDimedateTime = "TimeOfDay(${int.parse(selectedHour).toString()}:${selectedMinute})";
              tempTimeOfDay = TimeOfDay(hour:int.parse(selectedHour),minute: int.parse(selectedMinute));
            }

            final String id = widget.userInfo!.id!;
            setState(() {
              isLoading = true;
            });
            print(postedBy);
            if (noOfBrothers == "" || noOfBrothers == null) noOfBrothers = "0";
            if (noOfSisters == "" || noOfSisters == null) noOfSisters = "0";
            if (marriedBrothers == "" || marriedBrothers == null)
              marriedBrothers = "0";
            if (marriedSisters == "" || marriedSisters == null)
              marriedSisters = "0";
            FirebaseDatabase.instance
                .reference()
                .child('User Information')
                .child(id)
                .update({
              'maritalStatus': maritalStatus,
              'personHeight': heightPerson,
              'disability': disability,
              'intro': intro,
              'email': email,
              'Community': selectedCommunity,
              // 'subCommunity': subCommodity,
              'motherTongue': motherTongue,
              'gautra': goutra,
              'FatherStatus': fatherStatus,
              'MotherStatus': motherStatus,
              'residency': familyCity,
              'nativePlace': nativeCity,
              'brotherCount': noOfBrothers,
              'DateOfBirth': dateOfBirth,
              'sisterCount': noOfSisters,
              'familyType': familyType,
              'ProfileFor': postedBy,
              'cityOfBirth': cityOfBirth,
              'maglik': manglik,
              'state': state,
              'city': city,
              'living': selectedcountry,
              'zipCode': zipCode,
              'qualification': highestQualification,
              'clg': clgAttended,
              'workAt': workWith,
              'designation': designation,
              'annualIncome': annualIncome,
              'diet': selectedDiet,
              'Religion': selectedreligion,
              'fatherGotra': fathergotra,
              'motherGotra': motherGotra,
              'marriedBrothers': marriedBrothers,
              'marriedSisters': marriedSisters,
              'name': name,
              'userName': name,
              'gender': gender,
              'mobileNo': phone,
              // 'timeOfBirth': timeOfBirth.toString(),
              'timeOfBirth': birthDimedateTime,
              'showHoroscope': showHoroscope,
              'childrenLivingTogether': livingTogetherStatus,
              'noOfChildren': childrenStatus
            }).then((value) {
              print('Success');
              setState(() {
                UserInformation user = UserInformation(
                    srId: widget.userInfo!.srId,
                    phone: phone,
                    fatherGautra: fathergotra,
                    motherGautra: motherGotra,
                    id: widget.userInfo!.id,
                    imageUrl: widget.userInfo!.imageUrl,
                    name: name,
                    maritalStatus: maritalStatus,
                    height: heightPerson,
                    anyDisAbility: disability,
                    intro: intro,
                    religion: selectedreligion,
                    community: selectedCommunity,
                    motherTongue: motherTongue,
                    motherStatus: motherStatus,
                    gotra: goutra,
                    fatherStatus: fatherStatus,
                    residencyStatus: familyCity,
                    nativePlace: nativeCity,
                    brothers: noOfBrothers,
                    sisters: noOfSisters,
                    marriedBrothers: marriedBrothers,
                    marriedSisters: marriedSisters,
                    familyType: familyType,
                    postedBy: postedBy,
                    cityOfBirth: cityOfBirth,
                    manglik: manglik,
                    state: state,
                    city: city,
                    country: selectedcountry,
                    zipCode: zipCode,
                    highestQualification: highestQualification,
                    collegeAttended: clgAttended,
                    workingWith: workWith,
                    workingAs: designation,
                    annualIncome: annualIncome,
                    dateOfBirth: widget.userInfo!.dateOfBirth,
                    email: email,
                    gender: gender,
                    isVerified: widget.userInfo!.isVerified,
                    diet: selectedDiet,
                    // birthTime: timeOfBirth,
                    birthTime: tempTimeOfDay,
                    noOfChildren: childrenStatus,
                    childrenLivingTogether: livingTogetherStatus,
                    showHoroscope: showHoroscope
                );
                Provider.of<AllUser>(context, listen: false).updateUser(id, user);
              });

              setState(() {
                isLoading = false;
              });
              Navigator.of(context).pop(true);
              widget.onTapUpdate!();
            }).catchError((error) => print('Failed: $error'));
          },
          child: Container(
            height: height * .071,
            alignment: Alignment.center,
            color: theme.colorCompanion,
            child: isLoading
                ? SpinKitThreeBounce(
                    color: Colors.white,
                    size: 25,
                  )
                : Text(
                    'UPDATE',
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //
                //
                SizedBox(
                  height: height * .02,
                ),
                Card(
                  elevation: 6,
                  child: Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _basicInfo = !_basicInfo;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Basic Info',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorPrimary,
                                  ),
                                ),
                                Icon(
                                  _basicInfo
                                      ? MdiIcons.chevronDown
                                      : MdiIcons.chevronUp,
                                  size: 27,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _basicInfo
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Name',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width * .53,
                                            child: TextFormField(
                                              initialValue: name,
                                              onChanged: (val) {
                                                name = val;
                                              },
                                              cursorColor: theme.colorCompanion,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .01,
                                    ),

                                    Container(
                                      child: Text(
                                        'Gender',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: gender,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: genderTypeList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          gender = value!;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Your marital status',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: height * .015),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: maritalStatus,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: maritalStatusList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          FocusScope.of(context).requestFocus(new FocusNode());
                                          // maritalCurrentStatus = value ?? "";
                                          maritalStatus = value!;
                                        },
                                      ),
                                    ),

                                    maritalStatus != "Never Married"
                                        ? Column (
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: height * .02),
                                        Container(
                                          child: Text(
                                            'Children',
                                            style: GoogleFonts.openSans(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * .015,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 18),
                                          // height: height * .06,
                                          width: width,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorGrey,
                                            ),
                                            color: theme.colorBackground,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: DropdownButtonFormField(
                                            value: livingTogetherStatus,
                                            validator: (val) {
                                              if (val == null) {
                                                return 'Required';
                                              } else
                                                return null;
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            hint: Text('Select'),
                                            items: Constants.livingTogetherList.map((e) {
                                              return DropdownMenuItem(value: e, child: Text(e));
                                            }).toList(),
                                            onChanged: (value) {
                                              FocusScope.of(context).requestFocus(new FocusNode());
                                              livingTogetherStatus = value ?? "";
                                            },
                                          ),
                                        ),


                                        SizedBox(
                                          height: height * .02,
                                        ),
                                        Container(
                                          child: Text(
                                            'No. of Children',
                                            style: GoogleFonts.openSans(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * .015,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 18),
                                          // height: height * .06,
                                          width: width,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorGrey,
                                            ),
                                            color: theme.colorBackground,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: DropdownButtonFormField(
                                            value: childrenStatus,
                                            validator: (val) {
                                              if (val == null) {
                                                return 'Required';
                                              } else
                                                return null;
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            hint: Text('Select'),
                                            items: Constants.childrenList.map((e) {
                                              return DropdownMenuItem(value: e, child: Text(e));
                                            }).toList(),
                                            onChanged: (value) {
                                              FocusScope.of(context).requestFocus(new FocusNode());
                                              childrenStatus = value ?? "";
                                            },
                                          ),
                                        ),
                                      ],
                                    ):SizedBox(),


                                    SizedBox(height: height * .02),
                                    //
                                    Container(
                                      child: Text(
                                        'Date of Birth',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    // Container(
                                    //   padding:
                                    //       EdgeInsets.symmetric(horizontal: 18),
                                    //   // height: height * .06,
                                    //   width: width,
                                    //   decoration: BoxDecoration(
                                    //     border: Border.all(
                                    //       color: theme.colorGrey,
                                    //     ),
                                    //     color: theme.colorBackground,
                                    //     borderRadius: BorderRadius.circular(
                                    //       5,
                                    //     ),
                                    //   ),
                                    //   child: Row(
                                    //     children: [
                                    //       Container(
                                    //         width: width * .53,
                                    //         child: TextFormField(
                                    //           initialValue: dateOfBirth,
                                    //           onChanged: (val) {
                                    //             dateOfBirth = val;
                                    //           },
                                    //           cursorColor: theme.colorCompanion,
                                    //           decoration: InputDecoration(
                                    //             hintText: "ex.dd/mm/yyyy",
                                    //             border: InputBorder.none,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: width * .27,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorGrey,
                                            ),
                                            color: theme.colorBackground,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: DropdownButtonFormField(
                                            value: selectedDay,
                                            validator: (val) {
                                              if (val == null) {
                                                return 'Required*';
                                              } else
                                                return null;
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            hint: Text('Day'),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            items: dayList.map((e) {
                                              return DropdownMenuItem(
                                                  value: e, child: Text(e));
                                            }).toList(),
                                            onChanged: (value) {
                                              FocusScope.of(context).requestFocus(new FocusNode());
                                              selectedDay = value ?? "";
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * .03,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: width * .27,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorGrey,
                                            ),
                                            color: theme.colorBackground,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: DropdownButtonFormField(
                                            value: selectedMonth,
                                            isExpanded: true,
                                            validator: (val) {
                                              if (val == null) {
                                                return 'Required*';
                                              } else
                                                return null;
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            hint: Text('Month'),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                            items: monthList.map((e) {
                                              return DropdownMenuItem(
                                                  value: e, child: Text(e));
                                            }).toList(),
                                            onChanged: (value) {
                                              FocusScope.of(context).requestFocus(new FocusNode());
                                              selectedMonth = value ?? "";
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * .03,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: width * .27,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorGrey,
                                            ),
                                            color: theme.colorBackground,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: DropdownButtonFormField(
                                            value: selectedYear,
                                            validator: (val) {
                                              if (val == null) {
                                                return 'Required*';
                                              } else
                                                return null;
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            hint: Text('Year'),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            items: maleYearList.map((e) {
                                              return DropdownMenuItem(
                                                value: e,
                                                child: Text(
                                                  e.toString(),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              selectedYear = value ?? "";
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                  new FocusNode());
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      child: Text(
                                        'Your height',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: heightPerson,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: heightList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          heightPerson = value!;
                                        },
                                      ),
                                    ),
                                    //
                                    SizedBox(
                                      height: height * .02,
                                    ),

                                    Container(
                                      child: Text(
                                        'Any Disability?',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width * .53,
                                            child: TextFormField(
                                              initialValue: disability,
                                              onChanged: (val) {
                                                disability = val;
                                              },
                                              cursorColor: theme.colorCompanion,
                                              decoration: InputDecoration(
                                                hintText: "If Any",
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),

                                    Container(
                                      child: Text(
                                        'Mobile Number',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width * .53,
                                            child: TextFormField(
                                              initialValue:
                                                  widget.userInfo!.phone,
                                              cursorColor: theme.colorCompanion,
                                              onChanged: (val) {
                                                phone = val;
                                              },
                                              decoration: InputDecoration(
                                                enabled: true,
                                                hintText: "Enter your Number",
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    //

                                    //
                                    Container(
                                      child: Text(
                                        'Email',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width * .53,
                                            child: TextFormField(
                                              initialValue:
                                                  widget.userInfo!.email,
                                              cursorColor: theme.colorCompanion,
                                              onChanged: (val) {
                                                email = val;
                                              },
                                              decoration: InputDecoration(
                                                enabled: true,
                                                hintText: "Enter your Email",
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    )
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                //

                SizedBox(
                  height: height * .015,
                ),
                Card(
                  elevation: 6,
                  child: Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _bio = !_bio;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'More about Myself ',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorPrimary,
                                  ),
                                ),
                                Icon(
                                  _bio
                                      ? MdiIcons.chevronDown
                                      : MdiIcons.chevronUp,
                                  size: 27,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _bio
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'About yourself',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      height: height * .06 * 3,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        initialValue: intro,
                                        onChanged: (val) {
                                          intro = val;
                                        },
                                        cursorColor: theme.colorCompanion,
                                        keyboardType: TextInputType.multiline,
                                        minLines: 1,
                                        maxLines: 6,
                                        decoration: InputDecoration(
                                          hintText: "Start typing here...",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: height * .02,
                ),
                Card(
                  elevation: 6,
                  child: Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _religious = !_religious;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Religious Background',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorPrimary,
                                  ),
                                ),
                                Icon(
                                  _religious
                                      ? MdiIcons.chevronDown
                                      : MdiIcons.chevronUp,
                                  size: 27,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _religious
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Religion',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: selectedreligion,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required*';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: religionList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          selectedreligion = value;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Community',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        initialValue: selectedCommunity,
                                        onChanged: (val) {
                                          selectedCommunity = val;
                                        },
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter Community",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Mother Tongue',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: motherTongue,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: motherTongueList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          motherTongue = value!;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Mother\'s Gothra / Gothram',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        initialValue: motherGotra,
                                        onChanged: (val) {
                                          motherGotra = val;
                                        },
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter Gothra / Gothram",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Father\'s Gothra / Gothram',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        initialValue: fathergotra,
                                        onChanged: (val) {
                                          fathergotra = val;
                                        },
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter Gothra / Gothram",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: height * .02,
                ),
                Card(
                  elevation: 6,
                  child: Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _family = !_family;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Family',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorPrimary,
                                  ),
                                ),
                                Icon(
                                  _family
                                      ? MdiIcons.chevronDown
                                      : MdiIcons.chevronUp,
                                  size: 27,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _family
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Father\'s Status',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: fatherStatus,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required*';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: fatherStatusList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          fatherStatus = value!;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Mother\'s Status',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: motherStatus,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required*';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: motherStatusList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          motherStatus = value!;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Native Place',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        initialValue: nativeCity,
                                        onChanged: (val) {
                                          nativeCity = val;
                                        },
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter Place",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'No. of Siblings',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: width * .6,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                        ),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: Text(
                                                'No. of Brother(s)',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: height * .01,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 18),
                                                      // height: height * .06,
                                                      width: width * .15,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              theme.colorGrey,
                                                        ),
                                                        color: theme
                                                            .colorBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          5,
                                                        ),
                                                      ),
                                                      child: TextFormField(
                                                        initialValue:
                                                            marriedBrothers !=
                                                                    "0"
                                                                ? marriedBrothers
                                                                : "",
                                                        onChanged: (val) {
                                                          marriedBrothers = val;
                                                        },
                                                        cursorColor: theme
                                                            .colorCompanion,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: "0",
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        'Married',
                                                        style: GoogleFonts
                                                            .openSans(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Icon(
                                                  MdiIcons.abTesting,
                                                  // MdiIcons.face,
                                                  color: Colors.lightBlue,
                                                  size: 50,
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 18),
                                                      // height: height * .06,
                                                      width: width * .15,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              theme.colorGrey,
                                                        ),
                                                        color: theme
                                                            .colorBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          5,
                                                        ),
                                                      ),
                                                      child: TextFormField(
                                                        initialValue:
                                                            noOfBrothers != "0"
                                                                ? noOfBrothers
                                                                : "",
                                                        onChanged: (val) {
                                                          noOfBrothers = val;
                                                        },
                                                        cursorColor: theme
                                                            .colorCompanion,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: "0",
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        'Unmarried',
                                                        style: GoogleFonts
                                                            .openSans(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: height * .02,
                                            ),
                                            Center(
                                              child: Text(
                                                'No. of Sister(s)',
                                                style: GoogleFonts.openSans(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: height * .01,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 18),
                                                      // height: height * .06,
                                                      width: width * .15,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              theme.colorGrey,
                                                        ),
                                                        color: theme
                                                            .colorBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          5,
                                                        ),
                                                      ),
                                                      child: TextFormField(
                                                        initialValue:
                                                            marriedSisters !=
                                                                    "0"
                                                                ? marriedSisters
                                                                : "",
                                                        onChanged: (val) {
                                                          marriedSisters = val;
                                                        },
                                                        cursorColor: theme
                                                            .colorCompanion,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: "0",
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        'Married',
                                                        style: GoogleFonts
                                                            .openSans(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Icon(
                                                  MdiIcons.faceWoman,
                                                  color: Colors.pinkAccent,
                                                  size: 50,
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 18),
                                                      // height: height * .06,
                                                      width: width * .15,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              theme.colorGrey,
                                                        ),
                                                        color: theme
                                                            .colorBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          5,
                                                        ),
                                                      ),
                                                      child: TextFormField(
                                                        initialValue:
                                                            noOfSisters != "0"
                                                                ? noOfSisters
                                                                : "",
                                                        onChanged: (val) {
                                                          noOfSisters = val;
                                                        },
                                                        cursorColor: theme
                                                            .colorCompanion,
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: "0",
                                                          border:
                                                              InputBorder.none,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        'Unmarried',
                                                        style: GoogleFonts
                                                            .openSans(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    //
                                    Container(
                                      child: Text(
                                        'Profile for',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .005,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required*';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text(postedBy!),
                                        items: profileList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                          postedBy = value!;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .005,
                                    ),

                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Family Type',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    // Container(
                                    //   padding:
                                    //       EdgeInsets.symmetric(horizontal: 18),
                                    //   // height: height * .06,
                                    //   width: width,
                                    //   decoration: BoxDecoration(
                                    //     border: Border.all(
                                    //       color: theme.colorGrey,
                                    //     ),
                                    //     color: theme.colorBackground,
                                    //     borderRadius: BorderRadius.circular(
                                    //       5,
                                    //     ),
                                    //   ),
                                    //   child: TextFormField(
                                    //     initialValue: familyType,
                                    //     onChanged: (val) {
                                    //       familyType = val;
                                    //     },
                                    //     cursorColor: theme.colorCompanion,
                                    //     decoration: InputDecoration(
                                    //       hintText: "Enter Type",
                                    //       border: InputBorder.none,
                                    //     ),
                                    //   ),
                                    // ),

                                    SizedBox(
                                      height: height * .005,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text(familyType!),
                                        items: familyTypeList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                          familyType = value!;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .005,
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: height * .02,
                ),
                Card(
                  elevation: 6,
                  child: Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _astro = !_astro;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Astro Details',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorPrimary,
                                  ),
                                ),
                                Icon(
                                  _astro
                                      ? MdiIcons.chevronDown
                                      : MdiIcons.chevronUp,
                                  size: 27,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _astro
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'City of Birth',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        initialValue: cityOfBirth,
                                        onChanged: (val) {
                                          cityOfBirth = val;
                                        },
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter City",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      child: Text(
                                        'Time of Birth',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .005,
                                    ),
                                    // Container(
                                    //     padding: EdgeInsets.symmetric(
                                    //         horizontal: 18),
                                    //     height: height * .06,
                                    //     width: width,
                                    //     decoration: BoxDecoration(
                                    //       border: Border.all(
                                    //         color: theme.colorGrey,
                                    //       ),
                                    //       color: theme.colorBackground,
                                    //       borderRadius: BorderRadius.circular(
                                    //         5,
                                    //       ),
                                    //     ),
                                    //     child: InkWell(
                                    //       onTap: () {
                                    //         _selectTime(context);
                                    //       },
                                    //       child: Card(
                                    //           elevation: 0,
                                    //           child: timeOfBirth != null
                                    //               ? Center(
                                    //                   child: Text(
                                    //                       '${timeOfBirth.hour}:${timeOfBirth.minute} ${timeOfBirth.period.toString().split('.').last}'))
                                    //               : Center(
                                    //                   child: Text(
                                    //                       'Not Provided'))),
                                    //     )),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: width * .27,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorGrey,
                                            ),
                                            color: theme.colorBackground,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: DropdownButtonFormField(
                                            value: selectedHour,
                                            validator: (val) {
                                              if (val == null) {
                                                return 'Required*';
                                              } else
                                                return null;
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            hint: Text('Hour'),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            items: hourList.map((e) {
                                              return DropdownMenuItem(
                                                  value: e, child: Text(e));
                                            }).toList(),
                                            onChanged: (value) {
                                              FocusScope.of(context).requestFocus(new FocusNode());
                                              selectedHour = value ?? "";
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * .03,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: width * .27,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorGrey,
                                            ),
                                            color: theme.colorBackground,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: DropdownButtonFormField(
                                            value: selectedMinute,
                                            isExpanded: true,
                                            validator: (val) {
                                              if (val == null) {
                                                return 'Required*';
                                              } else
                                                return null;
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            hint: Text('Minute'),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                            items: minuteList.map((e) {
                                              return DropdownMenuItem(
                                                  value: e, child: Text(e));
                                            }).toList(),
                                            onChanged: (value) {
                                              FocusScope.of(context).requestFocus(new FocusNode());
                                              selectedMinute = value ?? "";
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * .03,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: width * .27,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.colorGrey,
                                            ),
                                            color: theme.colorBackground,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          child: DropdownButtonFormField(
                                            value: selectedAmPm,
                                            validator: (val) {
                                              if (val == null) {
                                                return 'Required*';
                                              } else
                                                return null;
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            hint: Text('AM/PM'),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                            items: AmPmList.map((e) {
                                              return DropdownMenuItem(
                                                value: e,
                                                child: Text(
                                                  e.toString(),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              selectedAmPm = value ?? "";
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                  new FocusNode());
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: height * .005,
                                    ),
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18),
                                        // height: height * .06,
                                        width: width,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: theme.colorGrey,
                                          ),
                                          color: theme.colorBackground,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          title: Text(
                                            'Horoscope privacy settings(show Time of birth and City of Birth)',
                                            style: GoogleFonts.openSans(
                                              fontSize: 14,
                                            ),
                                          ),
                                          value: showHoroscope,
                                          onChanged: (val) {
                                            setState(() {});
                                            showHoroscope = val!;
                                          },
                                        )),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Manglik / Chevvai dosham',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: manglik,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: manglikList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          manglik = value!;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: height * .02,
                ),
                Card(
                  elevation: 6,
                  child: Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _location = !_location;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Location & Education',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorPrimary,
                                  ),
                                ),
                                Icon(
                                  _location
                                      ? MdiIcons.chevronDown
                                      : MdiIcons.chevronUp,
                                  size: 27,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _location
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Country',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        enabled: false,
                                        initialValue: selectedcountry,
                                        onChanged: (val) {
                                          selectedcountry = val;
                                        },
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Country",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    SizedBox(
                                      height: height * .01,
                                    ),
                                    Container(
                                      child: Text(
                                        'You live in',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        enabled: false,
                                        initialValue: state,
                                        onChanged: (val) {
                                          state = val;
                                        },
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter State",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'City',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        onChanged: (val) {
                                          city = val;
                                        },
                                        initialValue: city,
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter City",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Your highest qualification',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        onChanged: (val) {
                                          highestQualification = val;
                                        },
                                        initialValue: highestQualification,
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter your qualification",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'College you attended',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        onChanged: (val) {
                                          clgAttended = val;
                                        },
                                        initialValue: clgAttended,
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText:
                                              "Specify highest degree college",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'You work with',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        onChanged: (val) {
                                          workWith = val;
                                        },
                                        initialValue: workWith,
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter Company Name",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'As',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        onChanged: (val) {
                                          designation = val;
                                        },
                                        initialValue: designation,
                                        cursorColor: theme.colorCompanion,
                                        decoration: InputDecoration(
                                          hintText: "Enter Designation",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Employed In',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: employedIn,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: employedInList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          FocusScope.of(context)
                                              .requestFocus(new FocusNode());
                                          employedIn = value!;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                    Container(
                                      child: Text(
                                        'Your annual income',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: annualIncome,
                                        validator: (val) {
                                          if (val == null) {
                                            return 'Required';
                                          } else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: incomeList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          annualIncome = value!;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: height * .02,
                ),
                Card(
                  elevation: 6,
                  child: Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _lifestyle = !_lifestyle;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lifestyle',
                                  style: GoogleFonts.ptSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorPrimary,
                                  ),
                                ),
                                Icon(
                                  _lifestyle
                                      ? MdiIcons.chevronDown
                                      : MdiIcons.chevronUp,
                                  size: 27,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _lifestyle
                            ? Container()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Your diet',
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .015,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 18),
                                      // height: height * .06,
                                      width: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorGrey,
                                        ),
                                        color: theme.colorBackground,
                                        borderRadius: BorderRadius.circular(
                                          5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField(
                                        value: selectedDiet,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        hint: Text('Select'),
                                        items: dietList.map((e) {
                                          return DropdownMenuItem(
                                              value: e, child: Text(e));
                                        }).toList(),
                                        onChanged: (value) {
                                          selectedDiet = value;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * .02,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: height * .02,
                ),
                SizedBox(
                  height: height * .02,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
