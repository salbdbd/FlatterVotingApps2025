// To parse this JSON data, do
//
//     final getUserCompanyModel = getUserCompanyModelFromJson(jsonString);

import 'dart:convert';

List<GetUserCompanyModel> getUserCompanyModelFromJson(String str) => List<GetUserCompanyModel>.from(json.decode(str).map((x) => GetUserCompanyModel.fromJson(x)));

String getUserCompanyModelToJson(List<GetUserCompanyModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetUserCompanyModel {
  final int? userId;
  final int? memberId;
  final String? name;
  final int? compId;
  final String? logo;

  GetUserCompanyModel({
    this.userId,
    this.memberId,
    this.name,
    this.compId,
    this.logo,
  });

  factory GetUserCompanyModel.fromJson(Map<String, dynamic> json) => GetUserCompanyModel(
    userId: json["userId"],
    memberId: json["memberId"],
    name: json["name"],
    compId: json["compId"],
    logo: json["logo"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "memberId": memberId,
    "name": name,
    "compId": compId,
    "logo": logo,
  };
}
