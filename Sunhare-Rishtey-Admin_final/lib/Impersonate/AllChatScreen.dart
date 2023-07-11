import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/SocialMediaChatRoom.dart';
import 'package:sunhare_rishtey_new_admin/main.dart';
import 'package:sunhare_rishtey_new_admin/models/ChatMetadataModel.dart';
import 'package:sunhare_rishtey_new_admin/models/userInformmation.dart';
import 'package:sunhare_rishtey_new_admin/provider/getAllUserProvider.dart';
import 'package:provider/provider.dart';

var width;
List<ChatMetaDataModel> onlineUsersMeta = [];

class AllChatScreen extends StatefulWidget {
  UserInformation userInfo;
  AllChatScreen(this.userInfo);

  @override
  _AllChatScreenState createState() => _AllChatScreenState();
}

class _AllChatScreenState extends State<AllChatScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  List<String> ids = [];
  List<String> chatUserIDs = [];
  Map<String, ChatMetaDataModel> allUsersMap = {};
  List<ChatMetaDataModel> allUsersMeta = [];

  var listener;
  getPremiumChat() {
    listener = FirebaseDatabase.instance
        .reference()
        .child('PersonalChatsPersons')
        .child(widget.userInfo.id!)
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        print("::::: changed");
        final data = event.snapshot.value as Map;
        chatUserIDs = List<String>.from(data.keys.toList());
        data.forEach((key, value) {
          allUsersMap[key] = ChatMetaDataModel(
              uID: key,
              lastMsg: value['lastMsg'] ?? '',
              isTyping: value['isTyping'] ?? false,
              lastSeen: value['lastSeen'] ?? 0,
              lastSent: value['lastSent'] ?? 0,
              lastReceived: value['lastReceived'] ?? 0);
        });

        final allUsers =
            Provider.of<AllUser>(context, listen: false).verifiedUsers;
        onlineUsersMeta.clear();
        allUsers.forEach((element) {
          if (chatUserIDs.contains(element.id)) {
            allUsersMap[element.id]!.setUser(element);
            if (element.isOnline!) {
              onlineUsersMeta.add(allUsersMap[element.id]!);
            }
          }
        });
        allUsersMeta = allUsersMap.values.toList();
        allUsersMeta.removeWhere((element) => element.user == null);
        onlineUsersMeta.removeWhere((element) => element.user == null);
        sortUsers();
        setState(() {});
      }
    });
  }

  sortUsers() {
    allUsersMeta.sort((a, b) {
      if ((a.lastReceived! > b.lastReceived! && a.lastReceived! > b.lastSent!) ||
          (a.lastSent! > b.lastSent! && a.lastSent! > b.lastReceived!)) {
        return -1;
      } else {
        return 1;
      }
    });
    onlineUsersMeta.sort((a, b) {
      if ((a.lastReceived! > b.lastReceived! && a.lastReceived! > b.lastSent!) ||
          (a.lastSent! > b.lastSent! && a.lastSent! > b.lastReceived!)) {
        return -1;
      } else {
        return 1;
      }
    });
  }

  @override
  void dispose() {
    listener.cancel();
    FirebaseDatabase.instance
        .reference()
        .child('User Information')
        .child(widget.userInfo.id!)
        .update({'isOnline': false});
    super.dispose();
  }

  @override
  void initState() {
    // getAcceptedChanges();
    getPremiumChat();
    tabController = new TabController(length: 2, vsync: this);
    FirebaseDatabase.instance
        .reference()
        .child('User Information')
        .child(widget.userInfo.id!)
        .update({'isOnline': true});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(
            MdiIcons.accountMultiple,
            size: 20,
          ),
          title: Text(
            'Connect with People',
            style: GoogleFonts.karla(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorCompanion,
        ),
        body: allUsersMeta.length == 0
            ? Center(
                child: Text(
                  'No Chats as of now !',
                  style: GoogleFonts.ptSans(
                    // color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              )
            : Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: height * .015,
                    ),
                    width: width,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: TabBar(
                      isScrollable: true,
                      labelPadding: EdgeInsets.only(
                        left: 6,
                        right: 6,
                      ),
                      unselectedLabelColor: Colors.black54,
                      labelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.colorCompanion,
                      ),
                      tabs: [
                        Tab(
                          child: Container(
                            height: height * .05,
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: theme.colorCompanion, width: 1)),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("All Chats"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            height: height * .05,
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: theme.colorCompanion, width: 1)),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("Online Users"),
                            ),
                          ),
                        ),
                      ],
                      controller: tabController,
                    ),
                  ),
                  SizedBox(
                    height: height * .01,
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        getUsers(allUsersMeta, height, width,
                            emptyMsg: 'No Chats as of now !'),
                        getUsers(onlineUsersMeta, height, width,
                            emptyMsg: 'No one is online'),
                      ],
                      controller: tabController,
                    ),
                  ),
                  SizedBox(
                    height: height * .002,
                  ),
                ],
              ),
      ),
    );
  }

  getUsers(List<ChatMetaDataModel> users, double height, double width,
      {String? emptyMsg}) {
    return Container(
      width: width,
      height: height * .8,
      color: theme.colorBackground,
      child: users.length == 0
          ? Center(
              child: Container(
                child: Text(
                  'No Chats as of now !',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                ),
              ),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return UserWidget(users[index], widget.userInfo);
              },
            ),
    );
  }
}

Stream checkOnline(String id) {
  return FirebaseDatabase.instance
      .reference()
      .child('User Information')
      .child(id)
      .child('isOnline')
      .onValue;
}

class UserWidget extends StatefulWidget {
  ChatMetaDataModel user;
  UserInformation userInfo;
  UserWidget(this.user, this.userInfo);

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  bool isOnline = false;
  var onlineListener;

  @override
  void dispose() {
    super.dispose();
    if (onlineListener != null) onlineListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    onlineListener = checkOnline(widget.user.uID!).listen((event) {
      setState(() {
        isOnline = event.snapshot.value ?? false;
        if (isOnline) {
          if (!onlineUsersMeta.contains(widget.user)) {
            onlineUsersMeta.add(widget.user);
            onlineUsersMeta.sort((a, b) {
              if ((a.lastReceived! > b.lastReceived! &&
                      a.lastReceived! > b.lastSent!) ||
                  (a.lastSent! > b.lastSent! && a.lastSent! > b.lastReceived!)) {
                return -1;
              } else {
                return 1;
              }
            });
          }
        } else {
          onlineUsersMeta.remove(widget.user);
        }
      });
    });
    return InkWell(
      onTap: () {
        print("::::::::::::: " + widget.user.user!.name!);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SocialMediaChat(
              uid: widget.user.uID!,
              data: widget.user.user!,
              thisUser: widget.userInfo,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 12,
            top: 10,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  widget.user.user!.imageUrl != null ? CircleAvatar(
                    radius: 25,
                    backgroundImage: CachedNetworkImageProvider(widget.user.user!.imageUrl!)
                  ) : CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(
                            'assets/profile.png',
                          ),
                  ),
                  SizedBox(
                    width: width * .05,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: width * .7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.user.user!.name ?? "",
                              style: GoogleFonts.openSans(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            isOnline ?? false
                                ? Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 10,
                                  )
                                : Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 10,
                                  )
                          ],
                        ),
                      ),
                      widget.user.isTyping!
                          ? Text("Typing...",
                              style: TextStyle(color: Colors.pinkAccent))
                          : Container(
                              width: width * .66,
                              child: Text(
                                  (widget.user.lastMsg!.startsWith('#')
                                          ? 'You: '
                                          : '') +
                                      ((widget.user.lastMsg != "")
                                          ? widget.user.lastMsg!.substring(1)
                                          : ""),
                                  style: widget.user.lastSeen! <
                                          widget.user.lastReceived!
                                      ? TextStyle(fontWeight: FontWeight.bold)
                                      : TextStyle(color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            )
                    ],
                  ),
                ],
              ),
              Divider(
                thickness: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
