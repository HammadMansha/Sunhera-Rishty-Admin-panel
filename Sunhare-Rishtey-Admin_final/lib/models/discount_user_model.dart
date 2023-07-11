class DiscountUserWiseModel {
  String? id;
  String? name;
  String? discountPercentage;
  String? expireDate;
  String? startDate;
  String? userName;
  String? imageUrl;
  String? userId;

  DiscountUserWiseModel(
      { this.id,
        this.name,
        this.discountPercentage,
        this.expireDate,
        this.startDate,
        this.userName,
        this.imageUrl,
        this.userId,
      });

  DiscountUserWiseModel.fromJson(Map<Object?, Object?> json) {
    name = json['name'].toString();
    discountPercentage = json['discount_percentage'].toString();
    expireDate = json['expire_date'].toString();
    startDate = json['start_date'].toString();
    userName = json['user_name'].toString();
    imageUrl = json['image_url'].toString();
    userId = json['user_id'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['discount_percentage'] = this.discountPercentage;
    data['expire_date'] = this.expireDate;
    data['start_date'] = this.startDate;
    data['user_name'] = this.userName;
    data['image_url'] = this.imageUrl;
    data['user_id'] = this.userId;
    return data;
  }
}
