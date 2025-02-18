import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfitAnalysisPage extends StatefulWidget {
  const ProfitAnalysisPage({Key? key}) : super(key: key);

  @override
  _ProfitAnalysisPageState createState() => _ProfitAnalysisPageState();
}

class _ProfitAnalysisPageState extends State<ProfitAnalysisPage> {
  List<String> closedMonths = [];
  Map<String, double> salesData = {};
  Map<String, double> expensesData = {};
  double tvaPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadClosedMonths();
    _loadSalesData();
    _loadExpensesData();
    _loadTVA(); 
  }
Future<void> _loadTVA() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    tvaPercentage = prefs.getDouble('tvaPercentage') ?? 0.0;
  });
  print("📊 Taux de TVA chargé : ${tvaPercentage.toStringAsFixed(2)}%");
}

  /// 📌 Charge les mois clôturés
  Future<void> _loadClosedMonths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      closedMonths = prefs.getStringList('closed_months') ?? [];
    });
    print("✅ Mois clôturés chargés : $closedMonths");
  }

  /// 📌 Charge et additionne les ventes stockées
  Future<void> _loadSalesData() async {
    final prefs = await SharedPreferences.getInstance();
    String? salesJson = prefs.getString('sales_data');

    if (salesJson != null) {
      Map<String, dynamic> decodedSales = json.decode(salesJson);
      setState(() {
        salesData = decodedSales.map((month, salesList) {
          if (salesList is List) {
            double totalSales = salesList.fold(0.0, (sum, sale) {
              return sum + ((sale['amount'] as num?) ?? 0.0);
            });
            return MapEntry(month, totalSales);
          }
          return MapEntry(month, 0.0);
        });
      });
    }
    print("💰 Ventes chargées : $salesData");
  }

  /// 📌 Charge et additionne les dépenses stockées
  Future<void> _loadExpensesData() async {
    final prefs = await SharedPreferences.getInstance();
    String? expensesJson = prefs.getString('expenses_data');

    if (expensesJson != null) {
      Map<String, dynamic> decodedExpenses = json.decode(expensesJson);
      setState(() {
        expensesData = decodedExpenses.map((month, expensesList) {
          if (expensesList is List) {
            double totalExpenses = expensesList.fold(0.0, (sum, expense) {
              return sum + ((expense['amount'] as num?) ?? 0.0);
            });
            return MapEntry(month, totalExpenses);
          }
          return MapEntry(month, 0.0);
        });
      });
    }
    print("💸 Dépenses chargées : $expensesData");
  }

  /// 📌 Trie les mois dans l'ordre chronologique
  List<String> _sortMonthsChronologically(List<String> months) {
    List<String> monthNames = [
      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];

    months.sort((a, b) {
      List<String> partsA = a.split(" ");
      List<String> partsB = b.split(" ");
      int yearA = int.parse(partsA[1]);
      int yearB = int.parse(partsB[1]);
      int monthA = monthNames.indexOf(partsA[0]);
      int monthB = monthNames.indexOf(partsB[0]);

      if (yearA == yearB) {
        return monthA.compareTo(monthB);
      }
      return yearA.compareTo(yearB);
    });

    return months;
  }

  /// 📌 Résumé global des bénéfices
Widget _buildGlobalSummary(List<String> sortedClosedMonths) {
    double totalRevenue = 0.0;
    double totalExpenses = 0.0;

    for (String month in salesData.keys) {
      double sales = salesData[month] ?? 0.0;
      double expenses = expensesData[month] ?? 0.0;
      totalRevenue += sales;
      totalExpenses += expenses;
    }

double netProfit = totalRevenue - totalExpenses;
double tax = (netProfit * tvaPercentage) / 100;
double netProfitAfterTax = netProfit - tax;

    double profitabilityRatio = totalExpenses == 0 ? 0.0 : totalRevenue / totalExpenses;

    print("📊 Résumé Global : Ventes: ${totalRevenue.toStringAsFixed(2)} €, Dépenses: ${totalExpenses.toStringAsFixed(2)} €, Bénéfice Net: ${netProfit.toStringAsFixed(2)} €, Rentabilité: x${profitabilityRatio.toStringAsFixed(2)}");

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Résumé Global", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildStatRow("💰 Total des ventes", "${totalRevenue.toStringAsFixed(2)} €", Colors.blue),
            _buildStatRow("💸 Total des dépenses", "${totalExpenses.toStringAsFixed(2)} €", Colors.red),
             _buildStatRow("🧾 TAXE (${tvaPercentage.toStringAsFixed(2)}%)", "${tax.toStringAsFixed(2)} €", Colors.orange), 
           _buildStatRow("📈 Bénéfice Net (après taxe)", "${netProfitAfterTax.toStringAsFixed(2)} €", netProfitAfterTax >= 0 ? Colors.green : Colors.orange),
            _buildStatRow("📊 Rentabilité", totalExpenses == 0 ? "N/A" : "x${profitabilityRatio.toStringAsFixed(2)}", Colors.purple),

          ],
        ),
      ),
    );
}


  /// 📌 Affichage des détails d'un mois donné
  Widget _buildMonthlyCard(String month) {
    double totalSales = salesData[month] ?? 0.0;
    double totalExpenses = expensesData[month] ?? 0.0;
double netProfit = totalSales - totalExpenses;
double tax = (netProfit * tvaPercentage) / 100;
double netProfitAfterTax = netProfit - tax;

    double profitabilityRatio = totalExpenses == 0 ? 0.0 : totalSales / totalExpenses;



    // 🚨 Vérification de la rentabilité minimum (Bénéfice doit être ≥ 3x les dépenses)
   bool isLowProfit = profitabilityRatio < 3;

    String warningMessage = isLowProfit
        ? "⚠️ Attention : Rentabilité faible !\nLe bénéfice net (${netProfit.toStringAsFixed(2)} €) est inférieur à 3 fois les dépenses (${totalExpenses.toStringAsFixed(2)} €)."
        : "";

    if (!salesData.containsKey(month) && !expensesData.containsKey(month)) {
  return SizedBox();
}


    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              "$month",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (isLowProfit) ...[
              SizedBox(width: 8),
              Icon(Icons.warning, color: Colors.orange),
            ],
          ],
        ),
        children: [
          _buildStatRow("💰 Ventes", "${totalSales.toStringAsFixed(2)} €", Colors.blue),
          _buildStatRow("💸 Dépenses", "${totalExpenses.toStringAsFixed(2)} €", Colors.red),
          _buildStatRow("🧾 TAXE (${tvaPercentage.toStringAsFixed(2)}%)", "${tax.toStringAsFixed(2)} €", Colors.orange), // ✅ Ajout de la TVA
         _buildStatRow("📈 Bénéfice Net (après taxe)", "${netProfitAfterTax.toStringAsFixed(2)} €", netProfitAfterTax >= 0 ? Colors.green : Colors.orange),

          _buildStatRow("📊 Rentabilité", totalExpenses == 0 ? "N/A" : "x${profitabilityRatio.toStringAsFixed(2)}", Colors.purple),


          
          if (isLowProfit)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                warningMessage,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildStatRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> sortedClosedMonths = _sortMonthsChronologically(
  (salesData.keys.toList() + expensesData.keys.toList()).toSet().toList()
);


    return Scaffold(
      appBar: AppBar(title: const Text("📊 Analyse de Rentabilité")),
      body: Column(
        children: [
          _buildGlobalSummary(sortedClosedMonths),
          Expanded(child: ListView(children: sortedClosedMonths.map(_buildMonthlyCard).toList())),
        ],
      ),
    );
  }
}
