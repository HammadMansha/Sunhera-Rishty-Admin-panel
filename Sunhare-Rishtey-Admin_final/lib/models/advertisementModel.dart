class AdvertisementModel {
  final String? id;
  final String? title;
  final String? image;
  final double? months;
  final bool? status;
  final String? daysLeft;
  final DateTime? dateCreated;
  final String? expiryDate;
  final String? adType;
  AdvertisementModel(
      {this.dateCreated,
      this.id,
      this.daysLeft,
      this.expiryDate,
      this.image,
      this.months,
      this.adType,
      this.status,
      this.title});
}
