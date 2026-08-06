import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class ReportPreviewScreen extends StatelessWidget {
  final File pdfFile;
  const ReportPreviewScreen({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Printing.sharePdf(bytes: pdfFile.readAsBytesSync(), filename: 'agriassist_report.pdf'),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfFile.readAsBytesSync(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }
}
