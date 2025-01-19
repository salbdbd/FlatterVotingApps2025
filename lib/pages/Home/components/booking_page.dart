import 'dart:convert';
import 'dart:io';
import 'package:association/pages/Home/components/loan_pdf/pdf_page.dart';
import 'package:association/pages/Home/model/get_billreceipt_model.dart';
import 'package:association/pages/Home/model/get_w_memberAccountTransaction_model.dart';
import 'package:http/http.dart' as http;
import 'package:association/pages/Home/components/transection_image_picker.dart';
import 'package:association/pages/indexing_page/indexing_page.dart';
import 'package:association/pages/notification_page/componets/get_transactionentrysubform_model.dart';
import 'package:association/pages/profile_page/components/custom_text_field_for_profile.dart';
import 'package:association/services/api_service.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  final UserDetails? userDetails;
  final int eventId;
  final String eventDate;
  final String eventName;
  final String eventDetails;
  final String eventPrice;
  final int groupID;
  final int accountID;

  const BookingPage({
    Key? key,
    this.userDetails,
    required this.eventDate,
    required this.eventName,
    required this.eventDetails,
    required this.eventPrice,
    required this.groupID,
    required this.accountID,
    required this.eventId,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  TextEditingController dateController = TextEditingController();
  TextEditingController occasionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController transactionIdController = TextEditingController();
  TextEditingController pictureController = TextEditingController();

  String selectedPaymentMethod = '';
  File? selectedImageTransaction;

  List<ValueItem> _selectedOptions = [];
  Map<String, int> optionCounts = {};
  Map<String, bool> optionSelected = {};

  List<GetTransactionEntrySubFormModel> EventPeople = [];
  List<TransactionDetailsModel> transctionDetails = [];
  bool _isLoading = false;
  double _containerHeight = 0.0;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: widget.eventDate);
    occasionController = TextEditingController(text: widget.eventName);
    amountController = TextEditingController(text: widget.eventPrice);
    fetchGetTransactionEntrySubForm();
  }



  Future<void> fetchGetTransactionEntrySubForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;


      String url = '${BaseUrl.baseUrl}/api/v1/Get_TransactionEntrySubForm/$compId/${widget.accountID}';
      print("urt Get_TransactionEntrySubForm = $url");

      http.Response response = await http.get(Uri.parse(url), headers: {
        'accept': '*/*',
        'Authorization': '${BaseUrl.authorization}'
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        setState(() {
          EventPeople = jsonResponse
              .map((data) => GetTransactionEntrySubFormModel.fromJson(data))
              .toList();

          for (var person in EventPeople) {
            optionCounts[person.subServiceName!] = 0;
            optionSelected[person.subServiceName!] = false;
          }
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  List<Map<String, dynamic>> transactionDetailsToJson(List<TransactionDetailsModel> details) {
    return details.map((detail) => detail.toJson()).toList();
  }


  Future<void> saveManualTransaction({
    required String transactionName,
    required String date,
    required List<ValueItem> selectedOptions,
    required String occasion,
    required String amount,
    required String transactionId,
    String? imageBase64,
  }) async {

    final url = Uri.parse('${BaseUrl.baseUrl}/api/v1/SaveTransactionEntryForm');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': '${BaseUrl.authorization}',
    };

    int totalQuantity = selectedOptions.fold(0, (sum, item) => sum + item.quantity);


    //sample
    //    {"id": 0, "memberId": 0, "amount": 0, "transactionTypeId": 0, "transactionId": "string",
    //    "transactionName": "string", "serviceDateId": 0, "approvedBy": 0, "createdBy": 0, "date": "string",
  //   "qty": 0, "total": 0, "totalAmount": 0, "note": "string", "compId": 0, "status": 0, "name": "string",
  //   "serviceName": "string", "billProcessId": 0, "fileAttach": "string",
    //
    //   "transctionDetails": [{"id": 0, "transactionId": 0, "compId": 0,"subServiceId": 0,
  //   "amount": 0, "qty": 0,"subServiceName": "string"}]
  // }

    final requestBody = jsonEncode({
      "id": 0,
      "memberId": widget.userDetails!.selectedCompanyData.memberId ?? 0,
      "amount": double.parse(amount),
      "transactionTypeId": 1,
      "transactionId": transactionId,
      "transactionName": transactionName,
      "serviceDateId": widget.eventId,
      "approvedBy": 0,
      "createdBy": 0,
      "date": date,
      "qty": totalQuantity,
      "total": double.parse(amount),
      "totalAmount": double.parse(amount),
      "note": "",
      "compId": widget.userDetails!.selectedCompanyData.compId ?? 0,
      "status": 0,
      "name": occasion ?? '',
      "serviceName": selectedOptions.map((option) => option.label).join(', '),
      "billProcessId": 0,
      "fileAttach": imageBase64 ?? "",
      "transctionDetails":transactionDetailsToJson(transctionDetails)
    });

    print('Request Body: $requestBody');

    try {
      _isLoading = true;

      final response = await http.post(
        url,
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('Transaction saved successfully.');

        await Future.delayed(Duration(seconds: 2));
        await fetchGetWMemberAccountTransaction(widget.eventId);

        _isLoading = false;
      }
      else {
        print('Failed to save transaction. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        _isLoading = false;
      }
    } catch (e) {
      print('Error occurred: $e');
      _isLoading = false;
    }
  }

  List<GetWMemberAccountTransactionModel> EventsDetails = [];

  Future<void> fetchGetWMemberAccountTransaction(int eventId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      int userId = widget.userDetails?.selectedCompanyData.userId ?? 0;
      int memberId = widget.userDetails?.selectedCompanyData.memberId ?? 0;//widget.userDetails?.userData.memberId ?? 0;
      print("memberId = ${memberId}");
      String url = '${BaseUrl.baseUrl}/api/v1/W_MemberAccountTransaction/$compId/$memberId';

      print('Request URL: $url'); // Print the URL

      http.Response response = await http.get(Uri.parse(url), headers: {
        'accept': '*/*',
        'Authorization': '${BaseUrl.authorization}'
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        print('Response Data: $jsonResponse'); // Print the response data

        setState(() {
          EventsDetails = jsonResponse
              .map((data) => GetWMemberAccountTransactionModel.fromJson(data))
              .toList();
        });


        if (EventsDetails.isNotEmpty) {
          // Assuming your model has fields like eventId and billId
          List<GetWMemberAccountTransactionModel> filteredEvents = EventsDetails
              .where((event) => event.accountId == eventId) // Adjust this to match your model
              .toList();

          if (filteredEvents.isNotEmpty) {
            int billID = filteredEvents.first.billId ?? 0; // Get the billId

            await fetchGetBillReceipt(billID);
          } else {
            print('No data found for eventId: $eventId');
          }
        }

      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<List<GetBillReceiptModel>> fetchGetBillReceipt(int billID) async {

    try {

      String url = '${BaseUrl.baseUrl}/api/v1/GetBillReceipt/${widget.userDetails!.selectedCompanyData.compId}/$billID';
      print("urt Get_TransactionEntrySubForm = $url");

      http.Response response = await http.get(Uri.parse(url), headers: {
        'accept': '*/*',
        'Authorization': '${BaseUrl.authorization}'
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<GetBillReceiptModel> billReceipts = jsonResponse.map((data) => GetBillReceiptModel.fromJson(data)).toList();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LPdfPage(
              userDetails: widget.userDetails,
              serialNumber: 'TKTS021739',
              customerName: 'ENGR. KHAN ATAUR RAHMAN SANTU',
              phoneNumber: '1234567890',
              eventName: 'RABINDRA-NAZRUL JAYANTI 2024',
              eventDateTime: '03-June-2024 @ 7.00',
              numberOfTickets: "1",
              ticketRate: "100.0",
              totalAmount: "100.0",
              billReceipts: billReceipts,
            ),
          ),
        );

        return billReceipts;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          "Booking Transaction",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff15212D),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              CustomTextFieldsforProfile(
                controller: dateController,
                hintText: 'Date',
                labelText: 'Date',
                disableOrEnable: false,
                borderColor: 0xffffffff,
                filled: false,
                prefixIcon: Icons.date_range_sharp,
              ),
              const SizedBox(height: 10),
              if (widget.groupID == 1)
                GestureDetector(
                  onTap: _showMultiSelectBottomSheet,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 2, color: Colors.white)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          children: _selectedOptions.map((option) {
                            return Chip(
                              label: Text(option.label),
                            );
                          }).toList(),
                        ),
                        const Icon(Icons.arrow_drop_down_outlined, color: Colors.white,)
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              CustomTextFieldsforProfile(
                controller: occasionController,
                hintText: 'Occasion',
                labelText: 'Occasion',
                disableOrEnable: false,
                borderColor: 0xffffffff,
                filled: false,
                prefixIcon: Icons.event_seat_sharp,
              ),
              CustomTextFieldsforProfile(
                controller: amountController,
                hintText: 'Amount',
                labelText: 'Amount',
                disableOrEnable: true,
                borderColor: 0xffffffff,
                filled: false,
                prefixIcon: Icons.monetization_on_outlined,
              ),
              const SizedBox(height: 20,),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 3,
                        child: CommonCustomBtn(
                          onPressed: () {
                            setState(() {
                              selectedPaymentMethod = 'Bkash';
                            });
                          },
                          imageWidth: 80,
                          imageHeight: 50,
                          image: 'assets/Images/BKash.png',
                          text: "Bkash",
                          selected: selectedPaymentMethod == 'Bkash',
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: CommonCustomBtn(
                          onPressed: () {
                            setState(() {
                              selectedPaymentMethod = 'Nagad';
                            });
                          },
                          image: 'assets/Images/nagad.png',
                          text: "Nagad",
                          selected: selectedPaymentMethod == 'Nagad',
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: CommonCustomBtn(
                          onPressed: () {
                            setState(() {
                              selectedPaymentMethod = 'Bank';
                            });
                          },
                          image: 'assets/Images/bank.png',
                          text: "Bank",
                          selected: selectedPaymentMethod == 'Bank',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 3,
                        child: CommonCustomBtn(
                          onPressed: () {
                            setState(() {
                              selectedPaymentMethod = 'Manual';
                            });
                          },
                          imageWidth: 40,
                          imageHeight: 40,
                          imagePadding: 8,
                          image: 'assets/Images/menual_transaction.png',
                          text: "Manual Pay",
                          selected: selectedPaymentMethod == 'Manual',
                        ),
                      ),
                      const Flexible(
                        flex: 3,
                        child: SizedBox(width: 100,),
                      ),
                      const Flexible(
                        flex: 3,
                        child: SizedBox(width: 100,),
                      ),
                    ],
                  ),
                ],
              ),

              if (selectedPaymentMethod == 'Manual') ...[
                CustomTextFieldsforProfile(
                  controller: transactionIdController,
                  hintText: 'TransactionId',
                  labelText: 'TransactionId',
                  disableOrEnable: true,
                  borderColor: 0xffffffff,
                  filled: false,
                  prefixIcon: Icons.money_sharp,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: []
                ),
                CustomImagePicker(
                  heading: 'Transaction Id ScreenShot',
                  selectedImage: selectedImageTransaction,
                  onImagePicked: (File? image) {
                    setState(() {
                      selectedImageTransaction = image;
                    });
                  },
                ),

                SizedBox(height: 20,),

                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String imageBase64 = '';
                      if (selectedImageTransaction != null) {
                        final bytes = await selectedImageTransaction!.readAsBytes();
                        imageBase64 = base64Encode(bytes);
                      }

                      await saveManualTransaction(
                        transactionName: "Manual Transaction",
                        date: dateController.text,
                        selectedOptions: _selectedOptions,
                        occasion: occasionController.text,
                        amount: amountController.text,
                        transactionId: transactionIdController.text,
                        imageBase64: imageBase64,
                      );

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => LPdfPage(
                      //       userDetails: widget.userDetails,
                      //     serialNumber: 'TKTS021739',
                      //     customerName: 'ENGR. KHAN ATAUR RAHMAN SANTU',
                      //     phoneNumber: '1234567890',
                      //     eventName: 'RABINDRA-NAZRUL JAYANTI 2024',
                      //     eventDateTime: '03-June-2024 @ 7.00',
                      //     numberOfTickets: "1",
                      //     ticketRate: "100.0",
                      //     totalAmount: "100.0",
                      //
                      //     ),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color
                    ),
                    child: const Text(
                      'Manual Transaction Save',
                      style: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                )

              ],

            ],
          ),
        ),
      ),
    );
  }


  void _showMultiSelectBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView(
                    shrinkWrap: true,
                    children: EventPeople.map((person) {
                      String label = person.subServiceName!;
                      int id = person.id!;
                      double unitPrice = person.unitPrice ?? 0; // Assuming unitPrice is a double
                      return ListTile(
                        leading: Checkbox(
                          value: optionSelected[label],
                          onChanged: (bool? value) {
                            setModalState(() {
                              optionSelected[label] = value!;
                              if (value) {
                                if (id == 3) {
                                  optionCounts[label] = 1; // Set default value to 1 if id is 3 or 4
                                } else {
                                  optionCounts[label] = (optionCounts[label] ?? 0) + 1; // Increment if not 3 or 4
                                }
                              } else {
                                optionCounts[label] = 0;
                              }
                            });
                          },
                        ),
                        title: Text('$label ($unitPrice TK)'),
                        trailing: optionSelected[label]! // Show buttons only if option is selected
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: id == 3 ? null : () { // Disable if id is 3 or 4
                                setModalState(() {
                                  if (optionCounts[label]! > 1) { // Prevent decrementing below 1
                                    optionCounts[label] = optionCounts[label]! - 1;
                                  }
                                });
                              },
                            ),
                            Text(optionCounts[label].toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: id == 3 ? null : () { // Disable if id is 3 or 4
                                setModalState(() {
                                  optionCounts[label] = optionCounts[label]! + 1;
                                });
                              },
                            ),
                          ],
                        )
                            : null, // Hide buttons if option is not selected
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {

                        //initializing selected options
                        _selectedOptions = EventPeople.where((person) {
                          return optionCounts[person.subServiceName!]! > 0;
                        }).map((person) {
                          return ValueItem(
                            label: '${person.subServiceName} ${optionCounts[person.subServiceName!]} (${(person.unitPrice! * optionCounts[person.subServiceName!]!).toStringAsFixed(2)} TK)',
                            value: person.subServiceName!,
                            quantity: optionCounts[person.subServiceName!]!,
                          );
                        }).toList();

                        //initializing list of transaction
                        transctionDetails = EventPeople.where((person){
                          return  optionCounts[person.subServiceName!]! > 0;
                        }).map((transaction){
                          return TransactionDetailsModel(
                            id: transaction.id,
                            transactionId: transactionIdController.text.toString(),
                            compId: widget.userDetails!.selectedCompanyData.compId,
                            subServiceId: transaction.serviceId,
                            amount: transaction.unitPrice,
                            qty: optionCounts[transaction.subServiceName!]!,
                            subServiceName: transaction.subServiceName,

                          );
                        }).toList();

                        print("\n\nTransaction Details : $transctionDetails\n\n");



                        print("Pressed");
                        print("Selected options : $_selectedOptions");
                        _updateTotalAmount();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateTotalAmount() {
    double totalAmount = _selectedOptions.fold(0.0, (sum, option) {
      var parts = option.label.split(' (');
      double price = double.parse(parts.last.replaceAll('TK)', ''));
      return sum + price;
    });
    amountController.text = totalAmount.toStringAsFixed(2);
  }

  void _calculateContainerHeight() {
    double totalHeight = _selectedOptions.length * 10.0; // Assuming each chip is 40.0 in height
    setState(() {
      _containerHeight = totalHeight;
    });
  }
}

class ValueItem {
  final String label;
  final String value;
  final int quantity;

  ValueItem({required this.label, required this.value, required this.quantity});
  @override
  String toString() {
    return 'ValueItem(label: $label,\n value: $value,\n quantity: $quantity)';
  }
}


class TransactionDetailsModel {
  final int? id;
  final String? transactionId;
  final int? compId;
  final int? subServiceId;
  final double? amount;
  final int? qty;
  final String? subServiceName;

  TransactionDetailsModel({
    required this.id,
    required this.transactionId,
    required this.compId,
    required this.subServiceId,
    required this.amount,
    required this.qty,
    required this.subServiceName,

});

  Map<String, dynamic> toJson() {
    return {
      "id": id ?? 0,
      "transactionId": transactionId ?? "0",
      "compId": compId ?? 0,
      "subServiceId": subServiceId ?? 0,
      "amount": amount ?? 0.0,
      "qty": qty ?? 0,
      "subServiceName": subServiceName ?? "",
    };
  }

  @override
  String toString() {
    return '''
Transaction Details(
  id: $id, 
  transactionId: $transactionId, 
  subServiceName: $subServiceName, 
  compId: $compId, 
  subServiceId: $subServiceId, 
  amount: $amount, 
  qty: $qty
  subServiceName: $subServiceName
)
    ''';
  }

}





class CommonCustomBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final String image;
  final String text;
  final bool selected;
  final double imagePadding;
  final double imageWidth;
  final double imageHeight;

  CommonCustomBtn({
    Key? key,
    required this.onPressed,
    required this.image,
    required this.text,
    this.selected = false,
    this.imagePadding = 0,
    this.imageWidth = 50,
    this.imageHeight = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(imagePadding),
                  child: Image.asset(
                    image,
                    width: imageWidth,
                    height: imageHeight,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (selected)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.check_circle, color: Colors.green, size: 24),
            ),
        ],
      ),
    );
  }
}

