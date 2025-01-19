import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerViewModel {
  final File pdfFile;
  PdfViewerViewModel({required this.pdfFile});

  //method to save pdf file in the download directory
  Future<void> downloadFile(BuildContext context) async {
    try {
      //Defining the Download directory path
      final Directory downloadsDir = Directory('/storage/emulated/0/Download');

      //Checking if the the download directory is exist or not. if not then create it
      if (!(await downloadsDir.exists())) {
        await downloadsDir.create(recursive: true);
      }

      //defining unique name of the pdf based on date
      String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(
        DateTime.now(),
      );
      final String newFilePath =
          '${downloadsDir.path}/pdf_report_$formattedDate.pdf';
      final File newFile = File(newFilePath);

      await newFile.writeAsBytes(
        await pdfFile.readAsBytes(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved to ${newFile.path}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sharePdf(BuildContext context) async {
    if (await pdfFile.exists()) {
      Share.shareFiles([pdfFile.path], text: 'Check out this PDF!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erorr to share file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
