import 'dart:convert';
import 'dart:io';

import 'package:association/pages/Home/model/get_billreceipt_model.dart';
import 'package:association/pages/indexing_page/indexing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart' as printing;

Future<Uint8List> generateLoanPdf(
  final PdfPageFormat format,
  UserDetails userDetails,
  String serialNumber,
  String customerName,
  String phoneNumber,
  String eventName,
  String eventDateTime,
  int numberOfTickets,
  double ticketRate,
  double totalAmount,
  final List<GetBillReceiptModel> billReceipts,
) async {
  final doc = pw.Document(
    title: 'Money Receipt',
  );

  final pageTheme = await _myPageTheme(format, billReceipts);

  Future<Uint8List> loadAssetImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  // final Uint8List ercLogoData = await loadAssetImage('assets/Images/erclogo.png');
  // final pw.ImageProvider ercLogo = pw.MemoryImage(ercLogoData);

  final Uint8List approvedImageData =
      await loadAssetImage('assets/Images/paid.png');
  final pw.ImageProvider approvedImage = pw.MemoryImage(approvedImageData);

  final Uint8List pendingImageData =
      await loadAssetImage('assets/Images/pending.png');
  final pw.ImageProvider pendingImage = pw.MemoryImage(pendingImageData);

  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      header: (final context) => pw.Container(
        margin: pw.EdgeInsets.symmetric(vertical: 10.0),
        child: pw.Center(
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              ...billReceipts.map((receipt) {
                if (receipt.compLogo != null) {
                  final Uint8List imageData = base64Decode(receipt.compLogo!);
                  final pw.MemoryImage imageProvider =
                      pw.MemoryImage(imageData);
                  return pw.Container(
                    padding: pw.EdgeInsets.zero,
                    margin: pw.EdgeInsets.zero,
                    child: pw.Image(
                      imageProvider,
                      width: 100,
                      height: 100,
                      fit: pw.BoxFit.cover,
                    ),
                  );
                } else {
                  return pw.Container();
                }
              }).toList(),
              pw.SizedBox(width: 5),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    userDetails.userData.companyName.toString(),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: pw.TextOverflow.visible,
                    maxLines: 2,
                    softWrap: false,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    userDetails.userData.branchName.toString() ?? '',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    padding: pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 2,
                        color: PdfColors.black,
                      ),
                    ),
                    child: pw.Text(
                      'Money Receipt',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(width: 5),
              ...billReceipts.map(
                (receipt) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 10),
                    pw.Text(
                      "Phone Number: ",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                          height: 5),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(receipt.compPhone ?? '',
                        style: pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 5),
                    pw.Text(receipt.compPhone ?? '',
                        style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      build: (context) => [
        ...billReceipts.map(
          (receipt) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Serial No. ${receipt.reciptNo ?? ""}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Date: ${receipt.date != null ? DateFormat('dd-MMM-yyyy').format(DateTime.parse(receipt.date!)) : ""}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              ...billReceipts.map(
                (receipt) => pw.Text(
                  'Received with Thanks from Mr. ${receipt.memberName ?? ""}',
                ),
              ),
              pw.SizedBox(height: 10),
              ...billReceipts.map((receipt) {
                final totalAmount = receipt.totalAmount != null
                    ? double.parse(receipt.totalAmount.toString())
                    : 0.0;
                return pw.Text(
                  'The Amount of Taka ${receipt.totalAmount?.toStringAsFixed(2) ?? ""} (In words): ${_convertNumberToWords(totalAmount)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                );
              }).toList(),
              pw.SizedBox(height: 15),
              _generateRow('Paid for', receipt.name ?? ""),
              pw.SizedBox(height: 5),
              if (receipt.isEventVisibile == 1) ...[
                _generateRow('Event Date & Time', receipt.eventTime ?? ""),
                pw.SizedBox(height: 5),
                _generateRow('Ticket Description', receipt.serviceName ?? ""),
                pw.SizedBox(height: 5),
                _generateRow(
                    'Number of Ticket(s)', receipt.qty.toString() ?? ""),
                pw.SizedBox(height: 5),
              ],
              _generateRow(
                  'Total Amount', receipt.totalAmount.toString() ?? ""),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Expanded(flex: 1, child: pw.Text("Total Taka")),
                  pw.Text('='),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                      flex: 2,
                      child:
                          pw.Text("${receipt.totalAmount.toString()}   Taka")),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text('#Coupon Number: 1'),
              pw.SizedBox(height: 20),
              if (receipt.aproved == 1)
                pw.Positioned(
                  bottom: 0,
                  left: 0,
                  child: pw.Image(approvedImage, width: 150, height: 150),
                ),
              if (receipt.aproved == 0)
                pw.Positioned(
                  bottom: 0,
                  left: 0,
                  child: pw.Image(pendingImage, width: 150, height: 150),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _generateRow(String label, String value) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
          flex: 1,
          child: pw.Text(label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      pw.Text(':'),
      pw.SizedBox(width: 10),
      pw.Expanded(flex: 2, child: pw.Text(value)),
    ],
  );
}

String _convertNumberToWords(double number) {
  final List<String> ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine'
  ];
  final List<String> tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety'
  ];
  final List<String> teens = [
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen'
  ];
  final List<String> thousands = [
    '',
    'Thousand',
    'Million',
    'Billion',
    'Trillion'
  ];

  String convertLessThanOneThousand(int num) {
    if (num == 0) {
      return '';
    } else if (num < 10) {
      return ones[num];
    } else if (num < 20) {
      return teens[num - 10];
    } else if (num < 100) {
      return '${tens[num ~/ 10]} ${ones[num % 10]}'.trim();
    } else if (num < 1000) {
      return '${ones[num ~/ 100]} Hundred ${convertLessThanOneThousand(num % 100)}';
    } else {
      throw ArgumentError('Number out of range for conversion: $num');
    }
  }

  if (number == 0) {
    return 'Zero';
  }

  try {
    // Convert the double to an int for processing
    int intPart = number.floor();
    int decimalPart = ((number - intPart) * 100).round();

    String words = '';
    int index = 0;

    while (intPart > 0) {
      if (intPart % 1000 != 0) {
        String wordSegment = convertLessThanOneThousand(intPart % 1000);
        if (wordSegment.isNotEmpty) {
          words = '$wordSegment ${thousands[index]} $words'.trim();
        }
      }
      intPart ~/= 1000;
      index++;
    }

    if (decimalPart != 0) {
      words += ' And ${convertLessThanOneThousand(decimalPart)} Poisha';
    }

    // Capitalize the first letter of each word in the final string
    words = words
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');

    return words.trim();
  } catch (e) {
    print('Error converting number to words: $e');
    return 'Conversion error: Unable to convert number to words';
  }
}

Future<pw.PageTheme> _myPageTheme(
    PdfPageFormat format, List<GetBillReceiptModel> billReceipts) async {
  final List<pw.MemoryImage> watermarkImages = [];

  for (final receipt in billReceipts) {
    if (receipt.compLogo != null) {
      final Uint8List imageData = base64Decode(receipt.compLogo!);
      final pw.MemoryImage imageProvider = pw.MemoryImage(imageData);
      watermarkImages.add(imageProvider);
    }
  }

  return pw.PageTheme(
    margin: const pw.EdgeInsets.symmetric(
        horizontal: 2 * PdfPageFormat.cm, vertical: 2 * PdfPageFormat.cm),
    textDirection: pw.TextDirection.ltr,
    orientation: pw.PageOrientation.portrait,
    buildBackground: (final context) => pw.FullPage(
      ignoreMargins: true,
      child: pw.Stack(
        children: [
          for (final image in watermarkImages)
            pw.Positioned.fill(
              child: pw.FittedBox(
                fit: pw.BoxFit.cover,
                child: pw.Opacity(opacity: 0.2, child: pw.Image(image)),
              ),
            ),
        ],
      ),
    ),
  );
}

PdfPageFormat pageFormat(PdfPageFormat format) {
  return PdfPageFormat.roll57;
}

Future<Uint8List> loadAssetImage(String path) async {
  final ByteData data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}

Future<void> saveAsFile(BuildContext context, printing.LayoutCallback build,
    PdfPageFormat pageFormat) async {
  final bytes = await build(pageFormat);
  final appDocDir = await getApplicationDocumentsDirectory();
  final appDocPath = appDocDir.path;
  final file = File('$appDocPath/Money Receipt.pdf');

  await file.writeAsBytes(bytes);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Document saved successfully")),
  );
}

void showPrintedToast(final BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Document Printed successfully")),
  );
}

void showShearedToast(final BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Document Shared successfully")),
  );
}
