import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

final postUrl = 'https://fcm.googleapis.com/fcm/send';

final headers = {
  'content-type': 'application/json',
  'Authorization':
      'key=AAAAWkHk10g:APA91bGxdRzp5PJ6o_-Wm_MZsFbkOlqxSuGPpMMKu_20tUI9Z5UgCrdfjCXJ7jz18BoG7aXyh7SLaxvPFNmgyQT94KVrP93z0IYXOs4nNQLb2NpNTUmMiLlpOeIvZCDCLwXhS0wpFijh'
};

class NotificationSender {
  Future<bool> sendPushNotifications(
      String userToken, String title, String body,
      {String target = "-1", String userId = ''}) async {
    final data = {
      "notification": {"body": body, "title": title},
      "priority": "high",
      "data": {
        "target": target,
        "userId": userId,
      },
      "to": "$userToken"
    };

    final response = await http.post(Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    return response.statusCode == 200;
  }
}

Future<void> sendPushNotificationsByID(String id,
    {String title = "", String subject = "", String target = "-1"}) async {
  final database = await FirebaseDatabase.instance
      .reference()
      .child('Push Notifications')
      .child(id)
      .once();
  final map = database.snapshot.value as Map;
  map.forEach((key, value) {
    NotificationSender()
        .sendPushNotifications(key, title, subject, target: target);
  });
}

Future<Map> getFCMTokenbyID(String uid) async {
  final data = await FirebaseDatabase.instance
      .reference()
      .child('Push Notifications')
      .child(uid)
      .once();
  return data.snapshot.value as Map;
}

sendChatNotificationByTokens(List tokens, String title, String body,
    {String target = '-1', String userId = ''}) async {
  final data = {
    "data": {
      "body": body,
      "title": title,
      "target": target,
      "userId": userId,
      "fromChat": true,
    },
    "registration_ids": tokens,
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  return response.statusCode == 200;
}

Future<bool> sendNotificationByTokens(List userToken, String title, String body,
    {String target = '-1', String userId = ''}) async {
  final data = {
    "notification": {"body": body, "title": title},
    "priority": "high",
    "data": {
      "target": target,
      "userId": userId,
    },
    "android_channel_id": 'Notifications',
    "registration_ids": userToken,
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  return response.statusCode == 200;
}

class Constants {
  static const DEFAULT_TARGET = '-1';
  static const ADMIN_NEW_USER_REQUEST = '0';
  static const ADMIN_ID_VERIFICATION = '3';
  static const ADMIN_ACCOUNT_DELETED = '500';
  static const ADMIN_PHOTO_VERIFICATION = '2';
  static const ADMIN_ACCOUNT_REPORTED = '501';
  static const ADMIN_GOT_SUBSCRIPTION = '999';
  static const USER_DISCOUNT = '1';
  static const USER_CHAT_MESSAGE = '435';
  static const USER_SENT_REQUEST = '434';
  static const USER_ACCEPT_REQUEST = '443';
  static const USER_ACCOUNT_DELETED = '-2';
  static const USER_ACCOUNT_SUSPENDED = '-3';
  static const USER_NEW_MATCH = '43';
  static const USER_PREMIUM_MEMBERSHIP = '99';

  static const List<String> livingTogetherList = [
    'Yes. Living together',
    'No',
    'Yes. Not living together'
  ];

  static const List<String> childrenList = [
    '1',
    '2',
    '3',
    'More than 3'
  ];

}

sendNotificationsByUserID(String uid, String title, String body,
    {String target = '-1', String userId = ''}) async {
  final notificationData = await FirebaseDatabase.instance
      .reference()
      .child('Push Notifications')
      .child(uid)
      .once();
  Map tokens = notificationData.snapshot.value as Map;

  final data = {
    "notification": {"body": body, "title": title},
    "priority": "high",
    "data": {
      "target": target,
      "userId": userId,
    },
    "android_channel_id": 'Notifications',
    "registration_ids": tokens.keys.toList(),
  };

  final response = await http.post(Uri.parse(postUrl),
      body: json.encode(data),
      encoding: Encoding.getByName('utf-8'),
      headers: headers);

  return response.statusCode == 200;
}
