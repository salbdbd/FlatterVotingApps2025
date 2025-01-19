// To parse this JSON data, do
//
//     final getTransactionEntrySubFormModel = getTransactionEntrySubFormModelFromJson(jsonString);

import 'dart:convert';

List<GetTransactionEntrySubFormModel> getTransactionEntrySubFormModelFromJson(String str) => List<GetTransactionEntrySubFormModel>.from(json.decode(str).map((x) => GetTransactionEntrySubFormModel.fromJson(x)));

String getTransactionEntrySubFormModelToJson(List<GetTransactionEntrySubFormModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetTransactionEntrySubFormModel {
  final int? id;
  final int? serviceId;
  final String? subServiceName;
  final double? unitPrice;
  final int? compId;
  final int? moduleId;
  final int? isActive;

  GetTransactionEntrySubFormModel({
    this.id,
    this.serviceId,
    this.subServiceName,
    this.unitPrice,
    this.compId,
    this.moduleId,
    this.isActive,
  });

  factory GetTransactionEntrySubFormModel.fromJson(Map<String, dynamic> json) => GetTransactionEntrySubFormModel(
    id: json["id"],
    serviceId: json["serviceID"],
    subServiceName: json["subServiceName"],
    unitPrice: json["unitPrice"],
    compId: json["compId"],
    moduleId: json["moduleID"],
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "serviceID": serviceId,
    "subServiceName": subServiceName,
    "unitPrice": unitPrice,
    "compId": compId,
    "moduleID": moduleId,
    "isActive": isActive,
  };

  @override
  String toString() {
    return '''
GetTransactionEntrySubFormModel(
  id: $id, 
  serviceId: $serviceId, 
  subServiceName: $subServiceName, 
  unitPrice: $unitPrice, 
  compId: $compId, 
  moduleId: $moduleId, 
  isActive: $isActive
)
    ''';
  }
}
