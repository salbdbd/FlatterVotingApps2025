// To parse this JSON data, do
//
//     final getBillReceiptModel = getBillReceiptModelFromJson(jsonString);

import 'dart:convert';

List<GetBillReceiptModel> getBillReceiptModelFromJson(String str) => List<GetBillReceiptModel>.from(json.decode(str).map((x) => GetBillReceiptModel.fromJson(x)));

String getBillReceiptModelToJson(List<GetBillReceiptModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetBillReceiptModel {
  final int? id;
  final String? reciptNo;
  final int? transactionTypeId;
  final String? transactionId;
  final int? serviceDateId;
  final String? serviceName;
  final dynamic name;
  final int? qty;
  final int? total;
  final int? totalAmount;
  final String? date;
  final int? isEventVisibile;
  final String? eventTime;
  final String? eventDate;
  final String? eventVanue;
  final int? aproved;
  final String? memberName;
  final String? mobileno;
  final String? companyName;
  final String? companyAdrees;
  final String? compPhone;
  final String? compLogo;

  GetBillReceiptModel({
    this.id,
    this.reciptNo,
    this.transactionTypeId,
    this.transactionId,
    this.serviceDateId,
    this.serviceName,
    this.name,
    this.qty,
    this.total,
    this.totalAmount,
    this.date,
    this.isEventVisibile,
    this.eventTime,
    this.eventDate,
    this.eventVanue,
    this.aproved,
    this.memberName,
    this.mobileno,
    this.companyName,
    this.companyAdrees,
    this.compPhone,
    this.compLogo,
  });

  factory GetBillReceiptModel.fromJson(Map<String, dynamic> json) => GetBillReceiptModel(
    id: json["id"],
    reciptNo: json["reciptNo"],
    transactionTypeId: json["transactionTypeId"],
    transactionId: json["transactionId"],
    serviceDateId: json["serviceDateId"],
    serviceName: json["serviceName"],
    name: json["name"],
    qty: json["qty"],
    total: json["total"],
    totalAmount: json["totalAmount"],
    date: json["date"],
    isEventVisibile: json["isEventVisibile"],
    eventTime: json["eventTime"],
    eventDate: json["eventDate"],
    eventVanue: json["eventVanue"],
    aproved: json["aproved"],
    memberName: json["memberName"],
    mobileno: json["mobileno"],
    companyName: json["companyName"],
    companyAdrees: json["companyAdrees"],
    compPhone: json["compPhone"],
    compLogo: json["compLogo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "reciptNo": reciptNo,
    "transactionTypeId": transactionTypeId,
    "transactionId": transactionId,
    "serviceDateId": serviceDateId,
    "serviceName": serviceName,
    "name": name,
    "qty": qty,
    "total": total,
    "totalAmount": totalAmount,
    "date": date,
    "isEventVisibile": isEventVisibile,
    "eventTime": eventTime,
    "eventDate": eventDate,
    "eventVanue": eventVanue,
    "aproved": aproved,
    "memberName": memberName,
    "mobileno": mobileno,
    "companyName": companyName,
    "companyAdrees": companyAdrees,
    "compPhone": compPhone,
    "compLogo": compLogo,
  };
}
