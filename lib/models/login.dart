// To parse this JSON data, do
//
//     final login = loginFromJson(jsonString);

import 'dart:convert';

Login loginFromJson(String str) => Login.fromJson(json.decode(str));

String loginToJson(Login data) => json.encode(data.toJson());

class Login {
  String? token;
  dynamic expiration;
  dynamic refreshToken;
  dynamic refreshTokenExpiration;
  int? userId;
  String? userName;
  int? quantity;
  String? password;
  dynamic name;
  dynamic mobileNo;
  int? userTypeId;
  String? userTypeName;
  int? empId;
  bool? isActive;
  int? clientId;
  dynamic isHaveSms;
  String? clientName;
  int? compId;
  String? companyName;
  int? branchId;
  String? branchName;
  dynamic createdDate;
  int? createdBy;
  dynamic creatorName;
  dynamic modifiedDate;
  dynamic modifiedBy;
  dynamic modifierName;
  int? memberId;

  Login({
    this.token,
    this.expiration,
    this.refreshToken,
    this.refreshTokenExpiration,
    this.userId,
    this.userName,
    this.quantity,
    this.password,
    this.name,
    this.mobileNo,
    this.userTypeId,
    this.userTypeName,
    this.empId,
    this.isActive,
    this.clientId,
    this.isHaveSms,
    this.clientName,
    this.compId,
    this.companyName,
    this.branchId,
    this.branchName,
    this.createdDate,
    this.createdBy,
    this.creatorName,
    this.modifiedDate,
    this.modifiedBy,
    this.modifierName,
    this.memberId,
  });

  factory Login.fromJson(Map<String, dynamic> json) => Login(
    token: json["token"],
    expiration: json["expiration"],
    refreshToken: json["refreshToken"],
    refreshTokenExpiration: json["refreshTokenExpiration"],
    userId: json["userId"],
    userName: json["userName"],
    quantity: json["quantity"],
    password: json["password"],
    name: json["name"],
    mobileNo: json["mobileNo"],
    userTypeId: json["userTypeId"],
    userTypeName: json["userTypeName"],
    empId: json["empId"],
    isActive: json["isActive"],
    clientId: json["clientId"],
    isHaveSms: json["isHaveSms"],
    clientName: json["clientName"],
    compId: json["compId"],
    companyName: json["companyName"],
    branchId: json["branchId"],
    branchName: json["branchName"],
    createdDate: json["createdDate"],
    createdBy: json["createdBy"],
    creatorName: json["creatorName"],
    modifiedDate: json["modifiedDate"],
    modifiedBy: json["modifiedBy"],
    modifierName: json["modifierName"],
    memberId: json["memberId"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "expiration": expiration,
    "refreshToken": refreshToken,
    "refreshTokenExpiration": refreshTokenExpiration,
    "userId": userId,
    "userName": userName,
    "quantity": quantity,
    "password": password,
    "name": name,
    "mobileNo": mobileNo,
    "userTypeId": userTypeId,
    "userTypeName": userTypeName,
    "empId": empId,
    "isActive": isActive,
    "clientId": clientId,
    "isHaveSms": isHaveSms,
    "clientName": clientName,
    "compId": compId,
    "companyName": companyName,
    "branchId": branchId,
    "branchName": branchName,
    "createdDate": createdDate,
    "createdBy": createdBy,
    "creatorName": creatorName,
    "modifiedDate": modifiedDate,
    "modifiedBy": modifiedBy,
    "modifierName": modifierName,
    "memberId": memberId,
  };
}
