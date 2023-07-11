import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class ContactProvider with ChangeNotifier {
  List<dynamic> contacts = [];
  setContacts(List contacts) {
    this.contacts = contacts;
    notifyListeners();
  }

  addContacts(String id) {
    this.contacts.add(id);
    notifyListeners();
  }

  getContact(context, UserInformation user, UserInformation currentUser,
      bool isPremium,
      {Function? onSuccess}) async {
    if (user.hideContact!) {
      Fluttertoast.showToast(msg: 'Contact is hidden by user');
      return;
    }

    if (!isPremium) {
      Fluttertoast.showToast(msg: "User is not premium");
      return;
    }
    if (contacts.contains(user.id)) {
      if (onSuccess != null) onSuccess();
    } else if (contacts.length < currentUser.premiumModel!.contact!)
      showPopUp(context, user.id!, currentUser.id!, onSuccess!);
    else
      Fluttertoast.showToast(msg: "Contacts overflowed");
  }

  showPopUp(context, String id, String uid, [Function? onSuccess]) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Container(
                child: Text(
                    'Do you really wants to use your one cotanct to see .'),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    FirebaseDatabase.instance
                        .reference()
                        .child('Contacts viewed')
                        .child(uid)
                        .update({'$id': true}).then((value) {
                      contacts.add(id);
                      Navigator.of(context).pop();
                      if (onSuccess != null) onSuccess();
                      Fluttertoast.showToast(msg: 'Contact Unlocked');
                    });
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('No'),
                ),
              ],
            ));
  }

  bool contains(String id) {
    return contacts.contains(id);
  }

  Future getContacts(String uid) async {
    contacts.clear();
    final contactsData = await FirebaseDatabase.instance
        .reference()
        .child('Contacts viewed')
        .child(uid)
        .once();
    if (contactsData.snapshot.value != null) {
      final data = contactsData.snapshot.value as Map;
      data.forEach((key, value) {
        contacts.add(key);
      });
    }
  }
}
