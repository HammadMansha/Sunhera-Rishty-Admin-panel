import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

class ChatMetaDataModel {
  String? uID;
  String? lastMsg;
  int? lastReceived;
  int? lastSeen;
  int? lastSent;
  bool? isTyping;
  bool? isOnline;
  UserInformation? user;

  ChatMetaDataModel({
    this.uID,
    this.lastReceived,
    this.lastSeen,
    this.lastSent,
    this.isTyping,
    this.lastMsg,
    this.isOnline,
    this.user,
  });

  setUser(UserInformation userInfo) {
    this.user = userInfo;
  }
}
