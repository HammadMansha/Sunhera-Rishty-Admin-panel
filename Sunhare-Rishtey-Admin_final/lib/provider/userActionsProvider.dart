import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class UserActions with ChangeNotifier {
  Future toggleSuspention(UserInformation user) async {
    bool? isSuspended;
    isSuspended = user.suspended != null ? user.suspended : false;
    if (!isSuspended!) {
      FirebaseDatabase.instance
          .reference()
          .child('User Information')
          .child(user.id!)
          .update({'isSuspended': true});
      sendPushNotificationsByID(user.id!,
          title: "Account suspended",
          subject: "Your account has been suspended by Admin",
          target: Constants.USER_ACCOUNT_SUSPENDED);
    } else {
      FirebaseDatabase.instance
          .reference()
          .child('User Information')
          .child(user.id!)
          .update({'isSuspended': false});
    }
  }
}
