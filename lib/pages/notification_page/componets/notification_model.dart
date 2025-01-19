// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
  String? heading;
  String? messagInfo;
  String? memberCode;
  String? attaachment;
  DateTime? inActiveDate;
  int? compId;

  NotificationModel({
    this.heading,
    this.messagInfo,
    this.memberCode,
    this.attaachment,
    this.inActiveDate,
    this.compId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    heading: json["heading"],
    messagInfo: json["messagInfo"],
    memberCode: json["memberCode"],
    attaachment: json["attaachment"],
    inActiveDate: json["inActiveDate"] == null ? null : DateTime.parse(json["inActiveDate"]),
    compId: json["compID"],
  );

  Map<String, dynamic> toJson() => {
    "heading": heading,
    "messagInfo": messagInfo,
    "memberCode": memberCode,
    "attaachment": attaachment,
    "inActiveDate": inActiveDate?.toIso8601String(),
    "compID": compId,
  };
}
