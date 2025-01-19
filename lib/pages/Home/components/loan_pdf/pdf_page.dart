import 'package:association/pages/Home/components/loan_pdf/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'package:association/pages/Home/model/get_billreceipt_model.dart';
import 'package:association/pages/dashboard.dart';
import 'package:association/pages/indexing_page/indexing_page.dart';
import 'package:association/pages/Home/components/loan_pdf/util.dart'
    as loan_util;

class LPdfPage extends StatefulWidget {
  final UserDetails? userDetails;
  final String serialNumber;
  final String customerName;
  final String phoneNumber;
  final String eventName;
  final String eventDateTime;
  final String numberOfTickets;
  final String ticketRate;
  final String totalAmount;
  final List<GetBillReceiptModel>? billReceipts;

  const LPdfPage({
    Key? key,
    this.userDetails,
    required this.serialNumber,
    required this.customerName,
    required this.phoneNumber,
    required this.eventName,
    required this.eventDateTime,
    required this.numberOfTickets,
    required this.ticketRate,
    required this.totalAmount,
    this.billReceipts,
  }) : super(key: key);

  @override
  State<LPdfPage> createState() => _LPdfPageState();
}

class _LPdfPageState extends State<LPdfPage> {
  PrintingInfo? printingInfo;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final info = await Printing.info();
    setState(() {
      printingInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final action = <PdfPreviewAction>[
      if (!kIsWeb)
        const PdfPreviewAction(icon: Icon(Icons.save), onPressed: saveAsFile),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff162b4a),
        title: Text(
          'Invoice',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Dashboard(userDetails: widget.userDetails)),
              (route) => false,
            );
          },
        ),
        actions: [],
      ),
      body: PdfPreview(
        maxPageWidth: 700,
        actions: action,
        onPrinted: loan_util.showPrintedToast,
        onShared: loan_util.showShearedToast,
        build: (format) => loan_util.generateLoanPdf(
          format,
          widget.userDetails!,
          widget.serialNumber,
          widget.customerName,
          widget.phoneNumber,
          widget.eventName,
          widget.eventDateTime,
          int.parse(widget.numberOfTickets),
          double.parse(widget.ticketRate),
          double.parse(widget.totalAmount),
          widget.billReceipts!,
        ),
      ),
    );
  }
}






// class LPdfPage extends StatefulWidget {
//   final UserDetails? userDetails;
//   final String serialNumber;
//   final String customerName;
//   final String phoneNumber;
//   final String eventName;
//   final String eventDateTime;
//   final String numberOfTickets;
//   final String ticketRate;
//   final String totalAmount;
//   final List<GetBillReceiptModel>? billReceipts;
//
//   const LPdfPage({
//     Key? key,
//     this.userDetails,
//     required this.serialNumber,
//     required this.customerName,
//     required this.phoneNumber,
//     required this.eventName,
//     required this.eventDateTime,
//     required this.numberOfTickets,
//     required this.ticketRate,
//     required this.totalAmount,
//     this.billReceipts,
//   }) : super(key: key);
//
//   @override
//   State<LPdfPage> createState() => _LPdfPageState();
// }
//
// class _LPdfPageState extends State<LPdfPage> {
//   PrintingInfo? printingInfo;
//
//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }
//
//   Future<void> _init() async {
//     final info = await Printing.info();
//     setState(() {
//       printingInfo = info;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final actions = <PdfPreviewAction>[
//       if (!kIsWeb)
//         PdfPreviewAction(
//           icon: Icon(Icons.save),
//           onPressed: (context, build, pageFormat) {
//             loan_util.saveAsFile(context, build, pageFormat);
//           },
//         ),
//     ];
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xff162b4a),
//         title: Text(
//           'Invoice',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () {
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => Dashboard(userDetails: widget.userDetails)),
//                   (route) => false,
//             );
//           },
//         ),
//         actions: [],
//       ),
//       body: PdfPreview(
//         actions: actions,
//         onPageFormatChanged: loan_util.pageFormat,
//         onPrinted: loan_util.showPrintedToast,
//         onShared: loan_util.showShearedToast,
//         initialPageFormat: pw.PdfPageFormat.roll80,
//         pageFormats: {'roll80': pw.PdfPageFormat.roll80},
//         canChangePageFormat: true,
//         canChangeOrientation: true,
//         allowPrinting: true,
//         allowSharing: true,
//         onZoomChanged: (zoomLevel) {},
//         pdfFileName: 'invoice.pdf',
//         build: (format) => loan_util.generateLoanPdf(
//           format,
//           widget.userDetails!,
//           widget.serialNumber,
//           widget.customerName,
//           widget.phoneNumber,
//           widget.eventName,
//           widget.eventDateTime,
//           int.parse(widget.numberOfTickets),
//           double.parse(widget.ticketRate),
//           double.parse(widget.totalAmount),
//           widget.billReceipts!,
//         ),
//       ),
//     );
//   }
// }
