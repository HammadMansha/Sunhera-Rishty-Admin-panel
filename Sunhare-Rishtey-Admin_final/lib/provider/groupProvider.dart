import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class GroupdedProvider with ChangeNotifier {
  List users = [];

  Future<void> getUsers() async {
    final data = await FirebaseDatabase.instance
        .reference()
        .child('Grouped Users')
        .once();
    final mappedData = data.snapshot.value as Map;
    if (mappedData != null) {
      users.addAll(mappedData.keys);
      // mappedData.forEach((key, value) {
      // users.add(key);
      // });
    }
  }

  Future<bool> toggle(String id) async {
    if (users.contains(id)) {
      users.remove(id);
      await FirebaseDatabase.instance
          .reference()
          .child('Grouped Users')
          .child(id)
          .remove();
      return false;
    }
    users.add(id);
    await FirebaseDatabase.instance
        .reference()
        .child('Grouped Users')
        .update({id: true});
    return true;
  }
}
