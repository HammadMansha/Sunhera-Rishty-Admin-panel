import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/models/parternerInfoModel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class PartnerPrefsProvider with ChangeNotifier {
  List<PartnerInfo> partnerInfoList = [];
  List matchedUserIds = [];
  List allUserKeys = [];
  Set tokens = Set();
  Map? userValues;
  Map? partnerValues;
  UserInformation? thisUser;
  bool isFetched = false;

  Future<void> getPreferences() async {
    final usersData = await FirebaseDatabase.instance
        .reference()
        .child('User Information')
        .once();
    if (usersData.snapshot.value == null) return null;
    userValues = usersData.snapshot.value as Map;
    matchedUserIds = userValues!.keys.toList();

    final data = await FirebaseDatabase.instance
        .reference()
        .child('Partner Prefrence')
        .once();
    if (data.snapshot.value == null) return null;

    partnerValues = data.snapshot.value as Map;
    // matchedUserIds = values.keys.toList();
    partnerInfoList.clear();
    partnerValues!.forEach((key, value) {
      print("$key ${userValues![key]}");
      partnerInfoList.add(
          PartnerInfo.fromJsonWithMeritalStatus(key, value, userValues![key]));
    });

    isFetched = true;
    print("Preference Notification: Got Users");
  }

  Future<List> filterUsers(UserInformation currentUser) async {
    thisUser = currentUser;
    if (!isFetched) await getPreferences();
    for (PartnerInfo partnerInfo in partnerInfoList) {
      print("Preference Notification: ${partnerInfo.id} matched? " +
          PartnerInfo.matchPreferences(partnerInfo, currentUser).toString() +
          " MaxHeight: ${partnerInfo.maxHeight}, MinHeight: ${partnerInfo.minHeight}");
      if (!PartnerInfo.matchPreferences(partnerInfo, currentUser)) {
        matchedUserIds.remove(partnerInfo.id);
      }
    }

    userValues!.forEach((key, value) {
      if (currentUser.gender == value['gender']) {
        matchedUserIds.remove(key);
      } else if (!partnerValues!.containsKey(key)) {
        if ((currentUser.maritalStatus == "Never Married" &&
                value["maritalStatus"] != "Never Married") ||
            (value["isSuspended"] != null && value["isSuspended"])) {
          matchedUserIds.remove(key);
        }
      }
    });

    partnerInfoList.removeWhere((element) => element.id == currentUser.id);

    print("Preference Notification: Filtered Users");
    return matchedUserIds;
  }

  Future<void> sendNotifications(String id) async {
    print("Preference Notification: Sending notification");
    final data = await FirebaseDatabase.instance
        .reference()
        .child('Push Notifications')
        .once();
    if (data.snapshot.value == null) return null;
    tokens.clear();
    Map values = data.snapshot.value as Map;
    values.forEach((key, value) {
      if (value != null && matchedUserIds.contains(key)) {
        Map currentTokens = value as Map;
        tokens.addAll(currentTokens.keys.toList());
      }
    });
    print("Preference Notification: " + tokens.toString());

    sendNotificationByTokens(tokens.toList(), "New Match Found",
        "${thisUser!.name} is your new match. Connect with him now.",
        target: Constants.USER_NEW_MATCH, userId: id);
  }
}
