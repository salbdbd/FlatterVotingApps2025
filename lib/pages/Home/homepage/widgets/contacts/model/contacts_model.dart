class Member {
  final int id;
  final String memberCode;
  final String memberName;
  final String mobileNo;
  final int detailsId;
  final String detailsCaption;
  final int brandId;

  Member({
    required this.id,
    required this.memberCode,
    required this.memberName,
    required this.mobileNo,
    required this.detailsId,
    required this.detailsCaption,
    required this.brandId,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      memberCode: json['memberCode'],
      memberName: json['memberName'],
      mobileNo: json['mobileNo'],
      detailsId: json['detailsId'],
      detailsCaption: json['detailsCaption'],
      brandId: json['brandId'],
    );
  }
}
