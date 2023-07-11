import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Screens/UserProfileScreen.dart';
import 'package:sunhare_rishtey_new_admin/Utils/pushNotificationSender.dart';
import 'package:sunhare_rishtey_new_admin/main.dart';
import 'package:sunhare_rishtey_new_admin/models/chatModel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';

import 'package:stream_transform/stream_transform.dart';

// ignore: must_be_immutable
class SocialMediaChat extends StatefulWidget {
  String uid;
  UserInformation data;
  UserInformation thisUser;
  SocialMediaChat({required this.uid, required this.data, required this.thisUser});
  @override
  _SocialMediaChatState createState() => _SocialMediaChatState();
}

class _SocialMediaChatState extends State<SocialMediaChat> {
  List<ChatModel> list = [];
  var key;
  ChatModel data = ChatModel();
  TextEditingController messageController = TextEditingController();
  List fcmTokens = [];

  String uid = '';
  bool isFirstMessage = false;
  bool isTyping = false;
  bool isLoading = true;
  bool isOnline = false;

  var onlineListener;
  checkOnline(String id) {
    onlineListener = FirebaseDatabase.instance
        .reference()
        .child('User Information')
        .child(id)
        .child('isOnline')
        .onValue
        .listen((event) {
      setState(() {
        isOnline = event.snapshot.exists ?? false;
        // isOnline = event.snapshot.value ?? false;
      });
    });
  }

  static DateTime lastSeenTime = DateTime.now();
  static DateTime lastReceivedTime = DateTime.now();
  static DateTime lastSentTime = DateTime.now();

  static UserInformation userInfo = UserInformation();
  UserInformation currentUserInfo = UserInformation();
  var theirMetaRef, myMetaRef;
  var theirChatRef, myChatRef;

  StreamController<String> streamController = StreamController();

  var listener1, listener2, listener3, listener4, listener5;

  initState() {
    currentUserInfo = widget.thisUser;
    ChatModel.currentUser = widget.uid;
    userInfo = widget.data;
    init();
    super.initState();
  }

  init() {
    getFCMTokenbyID(userInfo.id!)
        .then((data) => {fcmTokens = data.keys.toList()});
    // fcmTokens = getFCMTokenbyID(userInfo.id);

    print("::: ${widget.thisUser.id}");

    theirMetaRef = FirebaseDatabase.instance
        .reference()
        .child("PersonalChatsPersons")
        .child(widget.uid)
        .child(widget.thisUser.id!);
    myMetaRef = FirebaseDatabase.instance
        .reference()
        .child("PersonalChatsPersons")
        .child(widget.thisUser.id!)
        .child(widget.uid);

    theirChatRef = FirebaseDatabase.instance
        .reference()
        .child("ChatRoomPersonal")
        .child(widget.uid)
        .child(widget.thisUser.id!);

    myChatRef = FirebaseDatabase.instance
        .reference()
        .child("ChatRoomPersonal")
        .child(widget.thisUser.id!)
        .child(widget.uid);

    streamController.stream
        .debounce(Duration(milliseconds: 300))
        .listen((s) => {theirMetaRef.child("isTyping").set(false)});
    getMetaData();
    getMessages();
    checkOnline(widget.uid);
  }

  getMetaData() {
    listener1 = theirMetaRef.child("lastSeen").onValue.listen((event) {
      lastSeenTime =
          DateTime.fromMillisecondsSinceEpoch(event.snapshot.value ?? 0);
      setState(() {});
    });

    listener2 = theirMetaRef.child("lastReceived").onValue.listen((event) {
      lastReceivedTime =
          DateTime.fromMillisecondsSinceEpoch(event.snapshot.value ?? 0);
      setState(() {});
    });
    listener3 = myMetaRef.child("lastSent").onValue.listen((event) {
      lastSentTime =
          DateTime.fromMillisecondsSinceEpoch(event.snapshot.value ?? 0);
      print("~~~~~~ Got senttime");
      setState(() {});
    });
    listener4 = myMetaRef.child("isTyping").onValue.listen((event) {
      isTyping = event.snapshot.value ?? false;
      setState(() {});
    });
  }

  void setLast(String type, {var increment = 500}) {
    myMetaRef
        .child(type)
        .set(DateTime.now().millisecondsSinceEpoch + increment);
  }

  void getMessages() {
    listener5 = myChatRef.onValue.listen((event) {
      if (event.snapshot.value == null) {
        isFirstMessage = true;
        return;
      }
      final chatdata = event.snapshot.value as Map;

      list.clear();
      chatdata.forEach((key, value) {
        list.insert(
            0,
            ChatModel(
                uid: value['uid'],
                message: value['message'],
                dateTime: DateTime.parse(value['timeStamp']),
                imageURL: value['DpURL'],
                messageID: key));
      });
      setLast("lastSeen", increment: 1000);
      setState(() {});
    });
  }

  sendMessage() async {
    // final filter = ProfanityFilter();
    final ref = FirebaseDatabase.instance.reference().child("ChatRoomPersonal");
    final key = ref.push().key;

    /*if (isFirstMessage && false) {
      myMetaRef.update({"imageURL": userInfo.imageUrl, "name": userInfo.name});
      theirMetaRef.update(
          {"imageURL": currentUserInfo.imageUrl, "name": currentUserInfo.name});
    }*/
    String time = DateTime.now().toIso8601String();
    String msg = messageController.text;
    // String msg = filter.censor(messageController.text);
    myChatRef.child(key).update({
      'message': msg,
      "uid": userInfo.id,
      "timeStamp": time,
      'Name': userInfo.name,
      "DpURL": userInfo.imageUrl,
    }).then((value) {
      setLast("lastSent");
      String message = msg.length > 50 ? msg.substring(0, 46) + '....' : msg;
      sendNotificationByTokens(fcmTokens, currentUserInfo.name!, message,
          target: Constants.USER_CHAT_MESSAGE, userId: currentUserInfo.id!);
      sendChatNotificationByTokens(fcmTokens, currentUserInfo.name!, message,
          target: Constants.USER_CHAT_MESSAGE, userId: currentUserInfo.id!);
    });

    theirChatRef.child(key).update({
      'message': msg,
      "uid": userInfo.id,
      "timeStamp": DateTime.now().toIso8601String(),
      'Name': userInfo.name,
      "DpURL": userInfo.imageUrl,
    });

    myMetaRef.child("lastMsg").set("#$msg");
    theirMetaRef.child("lastMsg").set("!$msg");

    messageController.text = '';
  }

  Widget chatMessageList() {
    return list != null
        ? Container(
            child: ListView.builder(
                reverse: true,
                itemCount: list.length,
                itemBuilder: (context, index) => MessageTile(
                      message: list[index].message!,
                      isSendByMe: list[index].uid == userInfo.id,
                      time: list[index].dateTime!,
                    )),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
          backgroundColor: theme.colorBackground,
          appBar: AppBar(
            backgroundColor: theme.colorCompanion,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(userInfo: userInfo)));
                    },
                    child: Text(userInfo != null ? userInfo.name! : "Loading")),
                Text(
                    isTyping
                        ? 'Typing...'
                        : isOnline
                            ? 'Online'
                            : 'Offline',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 12))
              ],
            ),
          ),
          body: Container(
            child: Column(
              children: [
                Expanded(
                  child: chatMessageList(),
                ),
                Container(
                  color: Colors.teal,
                  child: Row(
                    children: [
                      Container(
                        width: width * .8,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: TextField(
                            style: TextStyle(fontSize: 16),
                            controller: messageController,
                            onChanged: (val) {
                              theirMetaRef.child("isTyping").set(true);
                              streamController.add(val);
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              hintText: 'Start Typing....',
                              hintStyle: TextStyle(fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              filled: true,
                              fillColor: theme.colorBackgroundDialog,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width * .03,
                      ),
                      InkWell(
                        onTap: () {
                          if (messageController.text == null ||
                              messageController.text.trim() == "") {
                            Fluttertoast.showToast(
                                msg: "Write some message!",
                                gravity: ToastGravity.BOTTOM);
                            return;
                          }
                          return sendMessage();
                        },
                        child: messageController.text == null ||
                                messageController.text == ""
                            ? Text(
                                'Send',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: theme.colorBackground,
                              ),
                      ),
                      SizedBox(
                        width: width * .05,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  @override
  void dispose() {
    streamController.close();
    listener1?.cancel();
    listener2?.cancel();
    listener3?.cancel();
    listener4?.cancel();
    listener5?.cancel();
    onlineListener?.cancel();
    ChatModel.currentUser = '';
    super.dispose();
  }
}

// ignore: must_be_immutable
class MessageTile extends StatefulWidget {
  final bool isSendByMe;
  final String message;
  final DateTime time;

  MessageTile({
    required this.isSendByMe,
    required this.message,
    required this.time,
  });

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(
          left: widget.isSendByMe ? width * .25 : 15,
          right: widget.isSendByMe ? 15 : width * .2),
      width: width,
      alignment:
          widget.isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isSendByMe ? theme.chatsend : theme.chatrevieve,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: widget.isSendByMe
                      ? Radius.circular(15)
                      : Radius.circular(0),
                  bottomRight: widget.isSendByMe
                      ? Radius.circular(0)
                      : Radius.circular(15)),
            ),
            child: Padding(
                padding:
                    EdgeInsets.only(right: 15, left: 15, bottom: 10, top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: width * 0.56,
                      child: Text(
                        widget.message,
                        textAlign:
                            widget.isSendByMe ? TextAlign.left : TextAlign.left,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    widget.isSendByMe ? getIcon() : Container(),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Icon getIcon() {
    if (widget.time.isBefore(_SocialMediaChatState.lastSeenTime)) {
      return Icon(MdiIcons.checkAll, color: Colors.blueAccent);
    } else if (widget.time.isBefore(_SocialMediaChatState.lastReceivedTime)) {
      // Check if user is online
      return Icon(MdiIcons.checkAll, color: Colors.grey[600]);
    } else if (widget.time.isBefore(_SocialMediaChatState.lastSentTime)) {
      return Icon(MdiIcons.check, color: Colors.grey[600]);
    } else {
      return Icon(MdiIcons.clockOutline, color: Colors.grey[600]);
    }
  }
}
