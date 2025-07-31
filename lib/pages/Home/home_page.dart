import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:association/pages/Home/components/event_card.dart';
import 'package:association/pages/Home/components/loan_pdf/pdf_page.dart';
import 'package:association/pages/Home/model/get_billreceipt_model.dart';
import 'package:association/pages/Home/model/get_w_memberAccountTransaction_model.dart';
import 'package:association/pages/Home/pdf_viewer_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../services/api_service.dart';
import '../indexing_page/indexing_page.dart';
import 'components/CountDownAnimation.dart';
import 'components/booking_page.dart';
import 'model/get_newsor_event_model.dart';

class HomePage extends StatefulWidget {
  final UserDetails? userDetails;

  const HomePage({
    Key? key,
    this.userDetails,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('NumberAnimation Widget Initialized');
    String userName = widget.userDetails?.selectedCompanyData.name ?? '';
    nameController.text = userName;

    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page!.toInt();
        });
      }
    });
    loadDataSerially();
  }

  Future<void> loadDataSerially() async {
    await fetchGetNewsorEvent();
    await fetchGetWMemberAccountTransaction();
    isLoading = List<bool>.filled(EventsDetails.length, false);
  }

  List<GetNewsorEventModel> newsOrEvents = [];

  Future<void> fetchGetNewsorEvent() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      int userId = widget.userDetails?.selectedCompanyData.userId ?? 0;
      int memberId = widget.userDetails?.selectedCompanyData.memberId ??
          0; //widget.userDetails?.userData.memberId ?? 0;
      String url = '${BaseUrl.baseUrl}/api/v1/GetNewsorEvent/$compId/2';

      http.Response response = await http.get(Uri.parse(url), headers: {
        'accept': '*/*',
        'Authorization': '${BaseUrl.authorization}'
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        newsOrEvents = jsonResponse
            .map((data) => GetNewsorEventModel.fromJson(data))
            .toList();
        if (mounted) {
          setState(() {});
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<GetWMemberAccountTransactionModel> EventsDetails = [];

  Future<void> fetchGetWMemberAccountTransaction() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      int compId = widget.userDetails?.selectedCompanyData.compId ?? 0;
      int userId = widget.userDetails?.selectedCompanyData.userId ?? 0;
      int memberId = widget.userDetails?.selectedCompanyData.memberId ??
          0; //widget.userDetails?.userData.memberId ?? 0;
      print("memberId = ${memberId}");
      print("Company id = ${compId}");
      String url =
          '${BaseUrl.baseUrl}/api/v1/W_MemberAccountTransaction/$compId/$memberId';

      print('Request URL: $url'); // Print the URL

      http.Response response = await http.get(Uri.parse(url), headers: {
        'accept': '*/*',
        'Authorization': '${BaseUrl.authorization}'
      });

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        print('Response Data: $jsonResponse'); // Print the response data

        if (mounted) {
          setState(() {
            EventsDetails = jsonResponse
                .map((data) => GetWMemberAccountTransactionModel.fromJson(data))
                .toList();
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<bool> isLoading = [];

  Future<void> printProduct(
    BuildContext context,
    int serviceId,
    String transactionId,
    int index,
  ) async {
    // print(transactionId);
    if (mounted) {
      setState(() {
        isLoading[index] = true;
      });
    }

    print("Is loading list : $isLoading");

    var parameter = {
      // "CompId": '79',
      // "ExportType": "pdf",
      // "MemberId": '18472',
      // "ReportId": '6594',
      // "TransId": "123445",
      // "servceId": '18555',

      'ReportId': '6594',
      'ExportType': 'pdf',
      // 'servceId':18555,
      'servceId': serviceId.toString() ?? '',
      'MemberId': widget.userDetails!.selectedCompanyData.memberId.toString(),
      // 18472,

      'TransId': transactionId.toString() ?? '',
      // '123445',

      'CompId': widget.userDetails!.selectedCompanyData.compId.toString() ?? '',
      // 79
    };
    //  print(loginModel!.compId!.toString());

    print("Parameter : ${parameter}");
    var responsType = 'blob';
    //var uri =  Uri.parse('http://103.125.253.59:6003/api/erp/commercialRpt/').replace(queryParameters: parameter);

    final uri = Uri.http(
        //  'apireport.ercdhaka-ieb.org'
        '103.125.253.59:2003',
        '/api/erp/commercialRpt/',
        parameter);
    print("Before get request");
    try {
      print("URI: $uri");
      http.Response response = await http.get(uri, headers: {
        'Accept': 'application/pdf',
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 30));
      print("After get request");
      print(
          "Response's status code: ${response.statusCode}, response type : ${response.body}");

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        print("\n\n\nSuccess and byte's leanth : ${bytes.length}");
        final tempDir = await getApplicationCacheDirectory();
        final file = File('${tempDir.path}/report.pdf');
        await file.writeAsBytes(bytes, flush: true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(pdfFile: file),
          ),
        );
      } else {
        print("Failed");
        //  print(
        //  "Failed to fetch data: ${response.statusCode} ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Exception : $error");
    } finally {
      if (mounted) {
        setState(() {
          isLoading[index] = false;
        });
      }
    }
  }

  Uint8List? _pdfData;
  Future<List<GetBillReceiptModel>> fetchGetBillReceipt(int billId) async {
    try {
      print("Company ID : ${widget.userDetails!.selectedCompanyData.compId}");
      print("Bill ID : ${billId}");
      final response = await http.get(
        Uri.parse(
            '${BaseUrl.baseUrl}/api/v1/GetBillReceipt/${widget.userDetails!.selectedCompanyData.compId}/$billId'),
        headers: {
          'accept': '*/*',
          'Authorization': '${BaseUrl.authorization}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        print("Json data : ${jsonResponse}");
        List<GetBillReceiptModel> billReceipts = jsonResponse
            .map((data) => GetBillReceiptModel.fromJson(data))
            .toList();

        print("List leangth : ${billReceipts.length}");
        //  navigateToPdfPage(billReceipts);

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

  void navigateToPdfPage(List<GetBillReceiptModel> billReceipts) {
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
  }

  List<List<dynamic>> eventslist = [
    [
      [
        "assets/Images/erclogo.png",
        "assets/Images/erclogo.png",
      ],
      "10/jan/2024",
      "Concert",
      "jems, artcel, coke stodio",
      "1000"
    ],
    [
      [
        "assets/Images/erclogo.png",
        "assets/Images/erclogo.png",
      ],
      "10/jan/2024",
      "Annual picnic",
      "jems, artcel, coke stodio",
      "1000"
    ],
  ];

  @override
  Widget build(BuildContext context) {
    double containerHeight = 400.0;
    //double totalHeight = containerHeight * 10;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xff15212D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double maxWidth = constraints.maxWidth;

                            TextPainter textPainter = TextPainter(
                              text: TextSpan(
                                text: newsOrEvents.isNotEmpty
                                    ? newsOrEvents[_currentPage].headLine ?? ''
                                    : '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            )..layout(maxWidth: maxWidth);

                            double textHeight = textPainter.height;
                            double containerHeight = textHeight + 20;

                            return Container(
                              height: containerHeight,
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Text(
                                  newsOrEvents.isNotEmpty
                                      ? newsOrEvents[_currentPage].headLine ??
                                          ''
                                      : '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 220,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xff15212D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 20.0, top: 10),
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height: 200.0,
                                  enlargeCenterPage: true,
                                  autoPlay: true,
                                  aspectRatio: 16 / 9,
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enableInfiniteScroll: true,
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 800),
                                  viewportFraction: 0.8,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentPage = index.toInt();
                                    });
                                  },
                                ),
                                items: newsOrEvents.map((newsOrEvent) {
                                  Uint8List bytes = base64Decode(
                                      newsOrEvent.imageBase64 ?? '');
                                  return Image.memory(
                                    bytes,
                                    fit: BoxFit.cover,
                                  );
                                }).toList(),
                              ),
                            ),
                            if (newsOrEvents.isNotEmpty)
                              Positioned(
                                bottom: 5,
                                left: 0,
                                right: 0,
                                child: DotsIndicator(
                                  dotsCount: newsOrEvents.length,
                                  decorator: const DotsDecorator(
                                    activeColor: Colors.white,
                                    size: Size.square(8.0),
                                    activeSize: Size(16.0, 8.0),
                                    spacing:
                                        EdgeInsets.symmetric(horizontal: 3.0),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: NumberAnimation(userDetails: widget.userDetails),
                      ),
                      // Container(
                      //   child: CustomTable(userDetails: widget.userDetails),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Occasion & Payment List",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4.0),
                              height: 2,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverFixedExtentList(
                  itemExtent: containerHeight,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final transaction = EventsDetails[index];

                      Uint8List? eventPicture = transaction.evenPicture != null
                          ? base64Decode(transaction.evenPicture!)
                          : null;

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xff15212D).withOpacity(0.5),
                          ),
                          child: CustomEventCard(
                            onPressed: () async {
                              print("Pressed");
                              if (transaction.approved == -1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookingPage(
                                      userDetails: widget.userDetails,
                                      eventId: transaction.accountId ?? 0,
                                      eventDate: transaction.evenDate ?? '',
                                      eventName: transaction.serviceName ?? '',
                                      eventDetails:
                                          transaction.description ?? '',
                                      eventPrice: transaction.amount ?? '',
                                      groupID: transaction.groupId ?? 0,
                                      accountID: transaction.accountId ?? 0,
                                    ),
                                  ),
                                );
                              } else if (transaction.approved == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('This event is pending approval.'),
                                  ),
                                );
                              } else if (transaction.approved == 2) {
                                List<GetBillReceiptModel> billReceipts =
                                    await fetchGetBillReceipt(
                                        transaction.billId ?? 0);
                                print(
                                    'transaction id : ${billReceipts[0].transactionId}');
                                await printProduct(
                                    context,
                                    transaction.accountId ?? 0,
                                    billReceipts[0].transactionId.toString(),
                                    index);

                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Text('This event is approved and print Receipt.'),
                                //   ),
                                // );
                              }
                            },
                            index: index,
                            isLoading: isLoading,
                            elevatedText:
                                _getElevatedText(transaction.approved),
                            bytesImage: eventPicture,
                            dotsCount: transaction.evenPicture != null ? 1 : 0,
                            items: transaction.evenPicture != null
                                ? [transaction.evenPicture!]
                                : [],
                            eventDate: transaction.evenDate ?? '',
                            eventName: transaction.serviceName ?? '',
                            eventDetails: transaction.description ?? '',
                            eventPrice: transaction.amount ?? '',
                          ),
                        ),
                      );
                    },
                    childCount: EventsDetails.length,
                  ),
                )
              ],
            ),
    );
  }

  String _getElevatedText(int? approved) {
    switch (approved) {
      case -1:
        return 'Book Now';
      case 0:
        return 'Pending';
      case 2:
        return 'Print';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
