class PremiumModel {
  final DateTime? dateOfPerchase;
  final DateTime? validTill;
  final String? name;
  final String? packageId;
  final String? packageName;
  final bool? isActive;
  final int? contact;

  PremiumModel(
      {this.dateOfPerchase,
      this.name,
      this.packageId,
      this.packageName,
      this.isActive,
      this.contact,
      this.validTill});
}
