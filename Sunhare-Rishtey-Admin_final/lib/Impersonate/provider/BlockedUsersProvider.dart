import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BlockedUsersProvider with ChangeNotifier {
  List blockedUsers = [];
  var listener;
  getBlockedUsers(String uid) async {
    listener = FirebaseDatabase.instance
        .reference()
        .child('BlockedUsers')
        .child(uid)
        .onValue
        .listen((event) {
      print("snapShot blocked====>>>>>${event.snapshot.value}");
      final snapShot = event.snapshot.value == null ? {} :  event.snapshot.value as Map;
      blockedUsers.clear();
      if (snapShot.isNotEmpty) {
        blockedUsers.addAll(snapShot.keys);
      }
      notifyListeners();
    });
  }

  Future toggle(String id, String uid) async {
    if (blockedUsers.contains(id)) {
      await FirebaseDatabase.instance
          .reference()
          .child('User Information')
          .child(id)
          .child('Blocked By')
          .child(uid)
          .remove();
      await FirebaseDatabase.instance
          .reference()
          .child('BlockedUsers')
          .child(uid)
          .child(id)
          .remove();
      return;
    }
    await FirebaseDatabase.instance
        .reference()
        .child('User Information')
        .child(id)
        .child('Blocked By')
        .update({'$uid': true});
    await FirebaseDatabase.instance
        .reference()
        .child('BlockedUsers')
        .child(uid)
        .update({'$id': true});
  }

  bool isBlocked(String id) {
    return blockedUsers.contains(id);
  }
}
