import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generatePdfWithReferences(List<String> references) async {
  final pdf = pw.Document();

  // Créez une page au format 4x6 (102mm x 152mm)
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(102 * PdfPageFormat.mm, 152 * PdfPageFormat.mm),
      build: (context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Références sélectionnées',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              ...references.map((ref) => pw.Text(ref, style: pw.TextStyle(fontSize: 14))).toList(),
            ],
          ),
        );
      },
    ),
  );

  // Affichez le PDF ou proposez-le en téléchargement
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
