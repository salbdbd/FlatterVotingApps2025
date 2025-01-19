// To parse this JSON data, do
//
//     final getWMessageModel = getWMessageModelFromJson(jsonString);

import 'dart:convert';

List<GetWMessageModel> getWMessageModelFromJson(String str) => List<GetWMessageModel>.from(json.decode(str).map((x) => GetWMessageModel.fromJson(x)));

String getWMessageModelToJson(List<GetWMessageModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetWMessageModel {
  final int? id;
  final int? compId;
  final int? memberCode;
  final dynamic messagInfo;
  final String? attaachment;
  final dynamic headLine;
  final int? ticketNumber;
  final int? readed;
  final String? imageBase64;

  GetWMessageModel({
    this.id,
    this.compId,
    this.memberCode,
    this.messagInfo,
    this.attaachment,
    this.headLine,
    this.ticketNumber,
    this.readed,
    this.imageBase64,
  });

  factory GetWMessageModel.fromJson(Map<String, dynamic> json) => GetWMessageModel(
    id: json["id"],
    compId: json["compId"],
    memberCode: json["memberCode"],
    messagInfo: json["messagInfo"],
    attaachment: json["attaachment"],
    headLine: json["headLine"],
    ticketNumber: json["ticketNumber"],
    readed: json["readed"],
    imageBase64: json["imageBase64"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "compId": compId,
    "memberCode": memberCode,
    "messagInfo": messagInfo,
    "attaachment": attaachment,
    "headLine": headLine,
    "ticketNumber": ticketNumber,
    "readed": readed,
    "imageBase64": imageBase64,
  };
}
