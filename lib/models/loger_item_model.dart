class PersonalLedgerModel {
  final String? typeName;
  final int transNo;
  final String vdate;
  final String? voucherType;
  final String vno;
  final double amount;
  final int comCod;
  final int brID;
  final String accountName;
  final int subID;
  final int adSubID;
  final String aliasName;
  final double drAmount;
  final double crAmount;
  final String accType;
  final int transType;
  final int transId;

  PersonalLedgerModel({
    this.typeName,
    required this.transNo,
    required this.vdate,
    this.voucherType,
    required this.vno,
    required this.amount,
    required this.comCod,
    required this.brID,
    required this.accountName,
    required this.subID,
    required this.adSubID,
    required this.aliasName,
    required this.drAmount,
    required this.crAmount,
    required this.accType,
    required this.transType,
    required this.transId,
  });

  factory PersonalLedgerModel.fromJson(Map<String, dynamic> json) {
    return PersonalLedgerModel(
      typeName: json['typeName'],
      transNo: json['transNo'] ?? 0,
      vdate: json['vdate'] ?? '',
      voucherType: json['voucherType'],
      vno: json['vno'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      comCod: json['comCod'] ?? 0,
      brID: json['brID'] ?? 0,
      accountName: json['accountName'] ?? '',
      subID: json['subID'] ?? 0,
      adSubID: json['adSubID'] ?? 0,
      aliasName: json['aliasName'] ?? '',
      drAmount: (json['drAmount'] as num?)?.toDouble() ?? 0.0,
      crAmount: (json['crAmount'] as num?)?.toDouble() ?? 0.0,
      accType: json['accType'] ?? '',
      transType: json['transType'] ?? 0,
      transId: json['transId'] ?? 0,
    );
  }
}
