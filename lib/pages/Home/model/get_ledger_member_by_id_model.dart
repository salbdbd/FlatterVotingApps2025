// To parse this JSON data, do
//
//     final getLedgerMemberByIdModel = getLedgerMemberByIdModelFromJson(jsonString);

import 'dart:convert';

List<GetLedgerMemberByIdModel> getLedgerMemberByIdModelFromJson(String str) => List<GetLedgerMemberByIdModel>.from(json.decode(str).map((x) => GetLedgerMemberByIdModel.fromJson(x)));

String getLedgerMemberByIdModelToJson(List<GetLedgerMemberByIdModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLedgerMemberByIdModel {
  final int? accountId;
  final double? amount;
  final String? accountName;
  final String? aliasName;
  final double? drAmount;
  final double? crAmount;
  final String? accType;
  final String? processDate;
  final String? comcod;

  GetLedgerMemberByIdModel({
    this.accountId,
    this.amount,
    this.accountName,
    this.aliasName,
    this.drAmount,
    this.crAmount,
    this.accType,
    this.processDate,
    this.comcod,
  });

  factory GetLedgerMemberByIdModel.fromJson(Map<String, dynamic> json) => GetLedgerMemberByIdModel(
    accountId: json["accountId"],
    amount: json["amount"],
    accountName: json["accountName"],
    aliasName: json["aliasName"],
    drAmount: json["drAmount"],
    crAmount: json["crAmount"],
    accType: json["accType"],
    processDate: json["processDate"],
    comcod: json["comcod"],
  );

  Map<String, dynamic> toJson() => {
    "accountId": accountId,
    "amount": amount,
    "accountName": accountName,
    "aliasName": aliasName,
    "drAmount": drAmount,
    "crAmount": crAmount,
    "accType": accType,
    "processDate": processDate,
    "comcod": comcod,
  };
}
