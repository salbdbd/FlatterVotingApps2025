// To parse this JSON data, do
//
//     final getNewsorEventModel = getNewsorEventModelFromJson(jsonString);

import 'dart:convert';

List<GetNewsorEventModel> getNewsorEventModelFromJson(String str) => List<GetNewsorEventModel>.from(json.decode(str).map((x) => GetNewsorEventModel.fromJson(x)));

String getNewsorEventModelToJson(List<GetNewsorEventModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetNewsorEventModel {
  final int? id;
  final String? newsInfo;
  final String? inActiveDate;
  final int? compId;
  final String? createdDate;
  final int? newOrEvent;
  final String? headLine;
  final String? picture;
  final String? imageBase64;
  final dynamic imageFile;

  GetNewsorEventModel({
    this.id,
    this.newsInfo,
    this.inActiveDate,
    this.compId,
    this.createdDate,
    this.newOrEvent,
    this.headLine,
    this.picture,
    this.imageBase64,
    this.imageFile,
  });

  factory GetNewsorEventModel.fromJson(Map<String, dynamic> json) => GetNewsorEventModel(
    id: json["id"],
    newsInfo: json["newsInfo"],
    inActiveDate: json["inActiveDate"],
    compId: json["compId"],
    createdDate: json["createdDate"],
    newOrEvent: json["newOrEvent"],
    headLine: json["headLine"],
    picture: json["picture"],
    imageBase64: json["imageBase64"],
    imageFile: json["imageFile"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "newsInfo": newsInfo,
    "inActiveDate": inActiveDate,
    "compId": compId,
    "createdDate": createdDate,
    "newOrEvent": newOrEvent,
    "headLine": headLine,
    "picture": picture,
    "imageBase64": imageBase64,
    "imageFile": imageFile,
  };
}
