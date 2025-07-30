import 'dart:io';
import 'package:association/pages/Home/pdfViewer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final File pdfFile;

  PdfViewerScreen({required this.pdfFile});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  //method to save pdf file in the download directory
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SfPdfViewer.file(
                widget.pdfFile,
                enableDoubleTapZooming: true, // Enable double-tap to zoom
                // You can customize more options here if needed
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.share),
                    label: Text("Share"),
                    onPressed: () async {
                      await PdfViewerViewModel(pdfFile: widget.pdfFile)
                          .sharePdf(context);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.print),
                    label: Text("Print"),
                    onPressed: () async {
                      if (await widget.pdfFile.exists()) {
                        await Printing.layoutPdf(
                          onLayout: (format) async =>
                              widget.pdfFile.readAsBytes(),
                        );
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.download),
                    label: Text("Download"),
                    onPressed: () => PdfViewerViewModel(pdfFile: widget.pdfFile)
                        .downloadFile(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
