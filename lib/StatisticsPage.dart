import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> sales;
  final double Function(String) getTotalSales;
  final double Function(String) getTotalExpenses;
  final List<String> closedMonths;

  const StatisticsPage({
    Key? key,
    required this.sales,
    required this.getTotalSales,
    required this.getTotalExpenses,
    required this.closedMonths,
  }) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedYear = "2025"; // Année par défaut

  /// 🔹 Générer les ventes totales par année
  Map<String, double> _generateYearlySales() {
    Map<String, double> yearlySales = {};
    widget.sales.forEach((month, salesList) {
      String year = month.split(" ").last;
      yearlySales[year] = (yearlySales[year] ?? 0) + widget.getTotalSales(month);
    });
    return yearlySales;
  }

/// 📌 Calcule la moyenne journalière et l'estimation de fin de mois
Map<String, double> _calculateEstimatedSales(String month) {
  String fullMonth = "$month $selectedYear";
  double totalSales = widget.getTotalSales(fullMonth);

  // Vérifier si le mois est clôturé
  if (widget.closedMonths.contains(fullMonth)) {
    print("🚫 Mois clôturé, aucune estimation.");
  }

  DateTime now = DateTime.now();
  print("📆 Date actuelle du téléphone : ${now.toLocal()}");

  // Extraire le mois et l'année depuis "Janvier 2025"
  List<String> parts = fullMonth.split(" ");
  if (parts.length != 2) return {"estimatedProfit": 0.0, "averagePerDay": 0.0};

  String monthName = parts[0];
  int year = int.tryParse(parts[1]) ?? now.year;

  // Liste des mois pour obtenir l'index
  List<String> monthNames = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ];

  int monthIndex = monthNames.indexOf(monthName);
  if (monthIndex == -1) return {"estimatedProfit": 0.0, "averagePerDay": 0.0};

  // Nombre total de jours dans le mois
  int totalDaysInMonth = DateTime(year, monthIndex + 2, 0).day;

  // **CAS 1️⃣ : MOIS PASSÉ (déjà terminé)**
  if (year < now.year || (year == now.year && monthIndex + 1 < now.month)) {
    double averagePerDay = totalSales / totalDaysInMonth;
    print("📊 Mois passé détecté ($month), total : $totalSales €");
    print("📊 Moyenne par jour : ${averagePerDay.toStringAsFixed(2)} €");

    return {
      "estimatedProfit": totalSales, // L'estimation est le total réel
      "averagePerDay": averagePerDay
    };
  }

  // **CAS 2️⃣ : MOIS EN COURS**
  if (now.month == monthIndex + 1 && now.year == year) {
    int daysPassed = now.day;
    if (daysPassed < 1) return {"estimatedProfit": 0.0, "averagePerDay": 0.0};

    double averagePerDay = totalSales / daysPassed;
    double estimatedProfit = averagePerDay * totalDaysInMonth;

    print("📊 Mois en cours détecté ($month), total : $totalSales €");
    print("📊 Jours écoulés : $daysPassed / $totalDaysInMonth");
    print("📊 Moyenne par jour : ${averagePerDay.toStringAsFixed(2)} €");
    print("📊 Estimation fin du mois : ${estimatedProfit.toStringAsFixed(2)} €");

    return {
      "estimatedProfit": estimatedProfit,
      "averagePerDay": averagePerDay
    };
  }

  // **CAS 3️⃣ : MOIS FUTUR (pas encore commencé)**
  print("📊 Mois futur détecté ($month), aucune estimation.");
  return {"estimatedProfit": 0.0, "averagePerDay": 0.0};
}


  @override
  Widget build(BuildContext context) {
    Map<String, double> yearlySales = _generateYearlySales();

    return Scaffold(
      appBar: AppBar(title: const Text("📊 Statistiques des Ventes")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Sélection de l'année
            DropdownButton<String>(
              value: selectedYear,
              onChanged: (newValue) {
                setState(() {
                  selectedYear = newValue!;
                });
              },
              items: yearlySales.keys.map((year) {
                return DropdownMenuItem(value: year, child: Text("📅 Année $year"));
              }).toList(),
            ),

            const SizedBox(height: 10),

            // ✅ Affichage du total annuel
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Total des ventes pour $selectedYear :",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${yearlySales[selectedYear]?.toStringAsFixed(2) ?? "0.00"} €",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Tableau des ventes mensuelles avec estimation et moyenne journalière
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  border: TableBorder.all(color: Colors.grey.shade300),
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
                  columns: const [
                    DataColumn(label: Text("Mois", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Total (€)", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Moyenne Jour (€)", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Estimation (€)", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: List.generate(12, (index) {
                    String month = [
                      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
                      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
                    ][index];

                    Map<String, double> estimates = _calculateEstimatedSales(month);
                    double estimatedProfit = estimates["estimatedProfit"]!;
                    double averagePerDay = estimates["averagePerDay"]!;
                    double totalSales = widget.getTotalSales("$month $selectedYear");

                    return DataRow(
                      cells: [
                        DataCell(Text(month)),
                        DataCell(Text(totalSales.toStringAsFixed(2))),
                        DataCell(Text(averagePerDay.toStringAsFixed(2))),
                        DataCell(Text(estimatedProfit.toStringAsFixed(2))),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
