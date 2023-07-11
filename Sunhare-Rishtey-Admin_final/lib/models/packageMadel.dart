class Package {
  final String? name;
  final String? id;
  final double? timeDuration;
  final double? price;
  final double? discount;
  final DateTime? discountTillDateTime;
  final int? contacts;
  final DateTime? validTill;
  final bool? isHide;
  Package(
      {this.contacts,
      this.discount,
      this.id,
      this.discountTillDateTime,
      this.name,
      this.price,
      this.timeDuration,
      this.validTill,
      this.isHide});
}
