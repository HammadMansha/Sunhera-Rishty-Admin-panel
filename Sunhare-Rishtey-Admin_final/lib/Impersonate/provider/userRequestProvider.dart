import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class UserRequests with ChangeNotifier {
  List<String> pendingUsers = [];
  List<String> acceptedUsers = [];
  List<UserInformation> pendingUserData = [];
  List<UserInformation> acceptedUserData = [];

  Future<void> getAllRequest(String id) async {
    final requests = await FirebaseDatabase.instance
        .reference()
        .child('Connection Requests')
        .child(id)
        .once();
    List sortable = [];
    pendingUsers.clear();
    acceptedUsers.clear();
    print("requests=====>>>>>${requests.snapshot.value}");
    if (requests != null) {
      final data = requests.snapshot.value == null ? {} : requests.snapshot.value as Map<String, dynamic>;
      if (data.isNotEmpty) {
        data.forEach((key, value) {
          if (value is bool) {
            if (value) {
              acceptedUsers.add(key);
            } else {
              pendingUsers.add(key);
            }
          } else {
            Map data = value as Map;
            data['uid'] = key;
            sortable.add(data);
          }

          sortable.sort((a, b) => a['time'].compareTo(b['time']));
          sortable.forEach((data) {
            if (data['accepted']) {
              acceptedUsers.insert(0, data['uid']);
            } else {
              pendingUsers.insert(0, data['uid']);
            }
          });
        });
        notifyListeners();
      }
    }
  }

  setPendingData(List<UserInformation> allUsers) {
    pendingUserData = [];
    pendingUsers.forEach((e) {
      allUsers.forEach((element) {
        if (element.id == e) {
          pendingUserData.add(element);
        }
      });
    });
    // print(reqUser);
  }

  setAcceptedData(List<UserInformation> allUsers) {
    acceptedUserData = [];
    acceptedUsers.forEach((e) {
      allUsers.forEach((element) {
        if (element.id == e) {
          acceptedUserData.add(element);
        }
      });
    });
    //  print(acceptedUser);
  }

  updateAcceptedData(
      List<String> accepted, List<UserInformation> acceptedData) {
    this.acceptedUserData = acceptedData;
    this.acceptedUsers = accepted;
    notifyListeners();
  }

  updatedPendingData(List<String> pending, List<UserInformation> pendingData) {
    this.pendingUserData = pendingData;
    this.pendingUsers = pending;
    notifyListeners();
  }
}
