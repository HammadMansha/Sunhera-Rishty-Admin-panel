class MemberShip {
  final String? parentId;
  final String? email;
  final DateTime? validTill;
  final String? id;
  final String? planName;
  final String? phone;
  final String? nameUser;
  final DateTime? startTime;
  final String? imageUrl;
  final String? srId;
  final num? price;
  final int? contacts;
  final List<MemberShipHistory>? history;
  MemberShip(
      {
      this.parentId,
      this.startTime,
      this.price,
      this.email,
      this.id,
      this.nameUser,
      this.phone,
      this.contacts,
      this.planName,
      this.imageUrl,
      this.srId,
      this.validTill,
      this.history});
}

class MemberShipHistory {
  final String? planName;
  final String? packageId;
  final DateTime? validTill;
  final num? price;
  final DateTime? startTime;
  final int? contacts;

  MemberShipHistory(
      {this.contacts,
      this.planName,
      this.packageId,
      this.validTill,
      this.price,
      this.startTime});
}
