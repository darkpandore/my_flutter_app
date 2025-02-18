import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SelectAndPrintReferencesPage extends StatefulWidget {
  final List<String> allReferences; // Liste de toutes les références disponibles.

  const SelectAndPrintReferencesPage({Key? key, required this.allReferences}) : super(key: key);

  @override
  _SelectAndPrintReferencesPageState createState() => _SelectAndPrintReferencesPageState();
}

class _SelectAndPrintReferencesPageState extends State<SelectAndPrintReferencesPage> {
  final List<String> selectedReferences = []; // Liste des références sélectionnées.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner des références'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: selectedReferences.isNotEmpty
                ? () {
                    // Naviguer vers la page de génération PDF
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrintReferencesPage(references: selectedReferences),
                      ),
                    );
                  }
                : () {
                    // Afficher un message si aucune référence n'est sélectionnée
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Veuillez sélectionner au moins une référence.")),
                    );
                  },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.allReferences.length,
        itemBuilder: (context, index) {
          final reference = widget.allReferences[index];
          return CheckboxListTile(
            title: Text(reference),
            value: selectedReferences.contains(reference),
            onChanged: (isSelected) {
              setState(() {
                if (isSelected == true) {
                  selectedReferences.add(reference);
                } else {
                  selectedReferences.remove(reference);
                }
              });
            },
          );
        },
      ),
    );
  }
}

class PrintReferencesPage extends StatelessWidget {
  final List<String> references;

  const PrintReferencesPage({Key? key, required this.references}) : super(key: key);

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    // Ajouter une page au PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
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
        title: const Text('Imprimer les références'),
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
