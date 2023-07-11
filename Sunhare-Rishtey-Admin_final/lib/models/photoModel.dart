class PhotoUserModel {
  String? uderId;
  String? name;
  List<PhotoModel>? photos;
  PhotoUserModel({this.name, this.photos, this.uderId});
}

class PhotoModel {
  String? userId;
  String? name;
  String? srId;
  String? imageUrl;
  String? photoId;
  bool? isVerified;
  PhotoModel(
      {this.imageUrl,
      this.isVerified,
      this.photoId,
      this.userId,
      this.name,
      this.srId});
}
