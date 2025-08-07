import 'dart:convert';
import 'dart:developer';
import 'package:association/pages/Home/home_page.dart';
import 'package:association/pages/Home/homepage/widgets/utilis/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:association/models/loger_item_model.dart';

/// Controller for managing ledger data and state
class LedgerController extends GetxController {
  final int compId;
  final int memberId;

  LedgerController({required this.compId, required this.memberId});

  // Observable variables
  final _isLoading = true.obs;
  final _ledgerList = <PersonalLedgerModel>[].obs;
  final _runningBalance = 0.0.obs;
  final _errorMessage = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  List<PersonalLedgerModel> get ledgerList => _ledgerList;
  double get runningBalance => _runningBalance.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchLedger();
  }

  /// Fetches ledger data from API
  Future<void> fetchLedger() async {
    try {
      _isLoading(true);
      _errorMessage('');

      final url =
          'http://103.125.253.59:2004/api/v1/get_MemberPersonalLedger/$compId/$memberId';

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      log('API Response: $url - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List jsonData = jsonDecode(response.body);
        _ledgerList.value =
            jsonData.map((e) => PersonalLedgerModel.fromJson(e)).toList();
        _calculateRunningBalance();
      } else {
        throw Exception('Failed to load ledger data: ${response.statusCode}');
      }
    } catch (e) {
      log('Ledger fetch error: $e');
      _errorMessage(e.toString());
      _ledgerList.clear();
      _showErrorSnackbar(e.toString());
    } finally {
      _isLoading(false);
    }
  }

  /// Refreshes ledger data
  Future<void> refreshLedger() async {
    await fetchLedger();
  }

  /// Calculates running balance from ledger entries
  void _calculateRunningBalance() {
    double balance = 0.0;
    for (var item in _ledgerList) {
      balance += item.drAmount - item.crAmount;
    }
    _runningBalance.value = balance;
  }

  /// Shows error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppConstants.errorRed,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Calculates cumulative balance up to a specific index
  double calculateCumulativeBalance(int index) {
    double balance = 0;
    for (int i = 0; i <= index; i++) {
      final item = _ledgerList[i];
      balance += item.drAmount - item.crAmount;
    }
    return balance;
  }

  /// Filters ledger entries by date range
  List<PersonalLedgerModel> filterByDateRange(
      DateTime startDate, DateTime endDate) {
    return _ledgerList.where((item) {
      final itemDate = DateTime.parse(item.vdate);
      return itemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          itemDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Gets total debit amount
  double get totalDebit {
    return _ledgerList.fold(0.0, (sum, item) => sum + item.drAmount);
  }

  /// Gets total credit amount
  double get totalCredit {
    return _ledgerList.fold(0.0, (sum, item) => sum + item.crAmount);
  }
}
