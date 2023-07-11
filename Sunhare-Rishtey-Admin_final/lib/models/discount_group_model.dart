class DiscountGroupModel {
  String? id;
  String? name;
  String? discountPercentage;
  String? userAcOldDays;
  String? userAcOldDate;
  String? expireDate;
  String? startDate;

  DiscountGroupModel(
      { this.id,
        this.name,
        this.discountPercentage,
        this.userAcOldDays,
        this.userAcOldDate,
        this.expireDate,
        this.startDate});

  DiscountGroupModel.fromJson(Map<Object?, Object?> json) {
    name = json['name'].toString();
    discountPercentage = json['discount_percentage'].toString();
    userAcOldDays = json['user_ac_old_days'].toString();
    userAcOldDate = json['user_ac_old_date'].toString();
    expireDate = json['expire_date'].toString();
    startDate = json['start_date'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['discount_percentage'] = this.discountPercentage;
    data['user_ac_old_days'] = this.userAcOldDays;
    data['user_ac_old_date'] = this.userAcOldDate;
    data['expire_date'] = this.expireDate;
    data['start_date'] = this.startDate;
    return data;
  }
}
