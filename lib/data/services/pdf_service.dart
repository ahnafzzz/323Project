import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/chat_session.dart';

class PdfService {
  Future<File> generateReport(ChatSession session, String reportText) async {
    final pdf = pw.Document();

    final image = pw.MemoryImage(
      File(session.imagePath).readAsBytesSync(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text("AgriAssist Diagnosis Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text("Date: ${session.createdAt.toLocal().toString()}"),
            pw.Text("Detected Disease: ${session.detectedDisease}"),
            pw.Text("Confidence: ${(session.confidence * 100).toStringAsFixed(1)}%"),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Image(image, height: 200),
            ),
            pw.SizedBox(height: 20),
            pw.Paragraph(text: reportText),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/report_${session.id}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> printPdf(File file) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => file.readAsBytesSync());
  }

  Future<void> sharePdf(File file) async {
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: 'agriassist_report.pdf');
  }
}
