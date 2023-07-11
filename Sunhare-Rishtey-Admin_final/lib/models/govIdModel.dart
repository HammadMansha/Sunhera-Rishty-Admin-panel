class GovIdModel {
  final String? name;
  final String? srId;
  final String? imageUrl;
  final bool? isVerified;
  final String? varifiedBy;
  final String? userId;
  String? document;
  GovIdModel(
      {this.imageUrl,
      this.isVerified,
      this.name,
      this.srId,
      this.document,
      this.varifiedBy,
      this.userId});
}
