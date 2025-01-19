// To parse this JSON data, do
//
//     final getWMemberAccountTransactionModel = getWMemberAccountTransactionModelFromJson(jsonString);

import 'dart:convert';

List<GetWMemberAccountTransactionModel> getWMemberAccountTransactionModelFromJson(String str) => List<GetWMemberAccountTransactionModel>.from(json.decode(str).map((x) => GetWMemberAccountTransactionModel.fromJson(x)));

String getWMemberAccountTransactionModelToJson(List<GetWMemberAccountTransactionModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetWMemberAccountTransactionModel {
  final int? accountId;
  final int? groupId;
  final String? serviceName;
  final String? amount;
  final String? description;
  final String? evenDate;
  final int? billId;
  final int? approved;
  final String? evenPicture;

  GetWMemberAccountTransactionModel({
    this.accountId,
    this.groupId,
    this.serviceName,
    this.amount,
    this.description,
    this.evenDate,
    this.billId,
    this.approved,
    this.evenPicture,
  });

  factory GetWMemberAccountTransactionModel.fromJson(Map<String, dynamic> json) => GetWMemberAccountTransactionModel(
    accountId: json["accountID"],
    groupId: json["groupID"],
    serviceName: json["serviceName"],
    amount: json["amount"],
    description: json["description"],
    evenDate: json["evenDate"],
    billId: json["billID"],
    approved: json["approved"],
    evenPicture: json["evenPicture"],
  );

  Map<String, dynamic> toJson() => {
    "accountID": accountId,
    "groupID": groupId,
    "serviceName": serviceName,
    "amount": amount,
    "description": description,
    "evenDate": evenDate,
    "billID": billId,
    "approved": approved,
    "evenPicture": evenPicture,
  };
}
