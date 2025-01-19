import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../services/api_service.dart';
import '../../indexing_page/indexing_page.dart';
import '../model/get_ledger_member_by_id_model.dart';

class CustomTable extends StatefulWidget {
  final UserDetails? userDetails;
  const CustomTable({Key? key, this.userDetails}) : super(key: key);

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  late Future<List<GetLedgerMemberByIdModel>> _data; // Corrected type

  @override
  void initState() {
    super.initState();
    _data = fetchGetLedgerMemberById();
  }

  Future<List<GetLedgerMemberByIdModel>> fetchGetLedgerMemberById() async {
    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      int userId = widget.userDetails?.selectedCompanyData.userId ?? 0;
      int memberId = widget.userDetails?.selectedCompanyData.memberId ?? 0;

      var headers = {
        'Authorization': BaseUrl.authorization,
      };

      var response = await http.get(
        Uri.parse(
            '${BaseUrl.baseUrl}/api/v1/GetLedgerMemberById/$compId/$memberId'),
        headers: headers,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<GetLedgerMemberByIdModel> parsedData =
            List<GetLedgerMemberByIdModel>.from(json
                .decode(response.body)
                .map((x) => GetLedgerMemberByIdModel.fromJson(x)));
        print('Response Data: $parsedData');
        return parsedData;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Reason Phrase: ${response.reasonPhrase}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GetLedgerMemberByIdModel>>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text(
            'Your account ledger has not been created',
            style: TextStyle(color: Colors.white),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data available',
              style: TextStyle(color: Colors.white));
        } else {
          List<GetLedgerMemberByIdModel> data = snapshot.data!;

          // Build DataTable with received data
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white, // Set white border color
                ),
              ),
              child: DataTable(
                headingRowColor: WidgetStateColor.resolveWith(
                  (states) => const Color(0xff15212D),
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Date',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Account Name',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Due',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Paid',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Balance',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                rows: data.map((item) {
                  DateTime date = DateTime.parse(
                      item.processDate!); // Assuming processDate is nullable

                  // Format the date into "dd/mmm/yyyy" format
                  String formattedDate = DateFormat('dd/MMM/yyyy').format(date);

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          formattedDate,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          "${item.accountName ?? ''}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\৳ ${item.crAmount ?? ''}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\৳ ${item.drAmount ?? ''}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      DataCell(
                        Text(
                          '\৳ ${item.amount ?? ''}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }
}
