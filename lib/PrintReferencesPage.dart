import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintReferencesPage extends StatelessWidget {
  final List<String> references;

  PrintReferencesPage({Key? key, required this.references}) : super(key: key);

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // Ajouter une page au PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(102 * PdfPageFormat.mm, 152 * PdfPageFormat.mm),
        build: (pw.Context context) {
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
                ...references.map((ref) => pw.Text(ref, style: pw.TextStyle(fontSize: 14))),
              ],
            ),
          );
        },
      ),
    );

    // Proposer d'imprimer ou d'enregistrer le PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imprimer les Références'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _generatePdf(context),
          icon: const Icon(Icons.print),
          label: const Text('Imprimer les références'),
        ),
      ),
    );
  }
}

class SelectReferencesPage extends StatefulWidget {
  final List<String> references;

  SelectReferencesPage({Key? key, required this.references}) : super(key: key);

  @override
  _SelectReferencesPageState createState() => _SelectReferencesPageState();
}

class _SelectReferencesPageState extends State<SelectReferencesPage> {
  final List<String> selectedReferences = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionnez les Références'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
           onPressed: selectedReferences.isNotEmpty
    ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrintReferencesPage(references: selectedReferences),
          ),
        );
      }
    : () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner au moins une référence.")),
        );
      },

          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.references.length,
        itemBuilder: (context, index) {
          final ref = widget.references[index];
          return CheckboxListTile(
            value: selectedReferences.contains(ref),
            title: Text(ref),
            onChanged: (isSelected) {
              setState(() {
                if (isSelected == true) {
                  selectedReferences.add(ref);
                } else {
                  selectedReferences.remove(ref);
                }
              });
            },
          );
        },
      ),
    );
  }
}
