class ChatModel {
  final String? uid;
  final String? message;
  final DateTime? dateTime;
  final String? nameOfCustomer;
  final String? imageURL;
  String? messageID;
  String? likes;
  static String? currentUser;

  ChatModel({
    this.likes,
    this.uid,
    this.message,
    this.dateTime,
    this.nameOfCustomer,
    this.imageURL,
    this.messageID,
  });
}
