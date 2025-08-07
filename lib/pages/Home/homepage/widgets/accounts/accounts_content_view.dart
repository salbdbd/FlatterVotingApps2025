import 'package:association/pages/Home/home_page.dart';
import 'package:association/pages/Home/homepage/widgets/accounts/summery_item.dart';
import 'package:association/pages/Home/homepage/widgets/controller/ledger_controller.dart';
import 'package:association/pages/Home/homepage/widgets/utilis/constants.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Main content view for the accounts section
class AccountsContentView extends StatelessWidget {
  final LedgerController ledgerController;

  const AccountsContentView({
    Key? key,
    required this.ledgerController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryCard(),
        Expanded(child: _buildLedgerTable()),
      ],
    );
  }

  /// Builds the summary card showing totals and balance
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: _buildCardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: SummaryItem(
              icon: Icons.receipt_long_rounded,
              label: 'Total Records',
              value: '${ledgerController.ledgerList.length}',
              color: AppConstants.primaryPurple,
            ),
          ),
          _buildDivider(),
          const SizedBox(width: 20),
          Expanded(
            child: SummaryItem(
              icon: ledgerController.runningBalance >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              label: 'Current Balance',
              value: '৳${ledgerController.runningBalance.toStringAsFixed(2)}',
              color: ledgerController.runningBalance >= 0
                  ? AppConstants.successGreen
                  : AppConstants.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the ledger table
  Widget _buildLedgerTable() {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: _buildCardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(child: _buildTableBody()),
          ],
        ),
      ),
    );
  }

  /// Builds table header
  Widget _buildTableHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryPurple,
            AppConstants.secondaryPurple,
            Color(0xFF74B9FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: HeaderText('Date')),
          Expanded(flex: 3, child: HeaderText('Note')),
          Expanded(flex: 3, child: HeaderText('Bill')),
          Expanded(flex: 3, child: HeaderText('Paid')),
          Expanded(flex: 3, child: HeaderText('Balance')),
        ],
      ),
    );
  }

  /// Builds table body with ledger entries
  Widget _buildTableBody() {
    LedgerController ledgerController = Get.find<LedgerController>();
    return RefreshIndicator(
      onRefresh: () => ledgerController.refreshLedger(),
      color: AppConstants.primaryPurple,
      backgroundColor: AppConstants.cardBackground,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: ledgerController.ledgerList.length,
        itemBuilder: (context, index) {
          final item = ledgerController.ledgerList[index];
          final cumulativeBalance =
              ledgerController.calculateCumulativeBalance(index);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: _buildRowDecoration(index),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Column
                  Container(
                    width: 80,
                    alignment: Alignment.topLeft,
                    child: Text(
                      _formatDate(item.vdate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Note Column
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        item.accountName.isNotEmpty
                            ? item.accountName
                            : (item.aliasName.isNotEmpty
                                ? item.aliasName
                                : 'N/A'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                  // Bill Column
                  Container(
                    width: 70,
                    alignment: Alignment.topRight,
                    child: AmountText(
                      amount: item.drAmount,
                      positiveColor: AppConstants.errorRed,
                    ),
                  ),
                  // Paid Column
                  Container(
                    width: 70,
                    alignment: Alignment.topRight,
                    child: AmountText(
                      amount: item.crAmount,
                      positiveColor: AppConstants.successGreen,
                    ),
                  ),
                  // Balance Column
                  Container(
                    width: 90,
                    alignment: Alignment.topRight,
                    child: BalanceCard(balance: cumulativeBalance),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Formats date string
  String _formatDate(String vdate) {
    try {
      final dateTime = DateTime.parse(vdate);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return vdate;
    }
  }

  /// Card decoration
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppConstants.cardBackground.withOpacity(0.8),
          AppConstants.cardBackgroundSecondary.withOpacity(0.95),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppConstants.primaryPurple.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Builds divider between summary items
  Widget _buildDivider() {
    return Container(
      width: 1.5,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  /// Row decoration for alternating colors
  BoxDecoration _buildRowDecoration(int index) {
    return BoxDecoration(
      gradient: index % 2 == 0
          ? LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.02),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
          : null,
      border: Border(
        bottom: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
    );
  }
}

class HeaderText extends StatelessWidget {
  final String text;

  const HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class AmountText extends StatelessWidget {
  final double amount;
  final Color positiveColor;

  const AmountText({
    required this.amount,
    required this.positiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '৳${amount.toStringAsFixed(0)}',
      style: TextStyle(
        fontSize: 12,
        color: amount > 0 ? positiveColor : Colors.white54,
        fontWeight: amount > 0 ? FontWeight.w600 : FontWeight.normal,
        letterSpacing: 0.3,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class BalanceCard extends StatelessWidget {
  final double balance;

  const BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final color =
        isPositive ? AppConstants.successGreen : AppConstants.errorRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            isPositive ? '↑' : '↓',
            style: TextStyle(fontSize: 10, color: color),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '৳${balance.toStringAsFixed(0)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
