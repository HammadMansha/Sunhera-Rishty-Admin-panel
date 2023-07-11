class ReportModel {
  final String? name;
  final String? srId;
  final String? reportedName;
  final String? reportedSrId;
  final DateTime? reportedOn;
  final String? reportedGender;
  final String? imageUrl;
  final String? reportedMobileNo;
  final String? reason;
  final String? uid;
  ReportModel(
      {this.imageUrl,
      this.name,
      this.reportedGender,
      this.reportedMobileNo,
      this.reportedName,
      this.reportedOn,
      this.reportedSrId,
      this.srId,
      this.reason,
      this.uid});
}
