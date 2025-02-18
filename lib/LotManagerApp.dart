import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LotManagerApp extends StatefulWidget {
  const LotManagerApp({super.key});

  @override
  _LotManagerAppState createState() => _LotManagerAppState();
}

class _LotManagerAppState extends State<LotManagerApp> {
  List<Map<String, dynamic>> lots = [];

  @override
  void initState() {
    super.initState();
    _loadLots(); // ✅ Charge les lots au démarrage
  }

  /// ✅ Charger les lots enregistrés dans SharedPreferences
  Future<void> _loadLots() async {
    final prefs = await SharedPreferences.getInstance();
    String? lotsData = prefs.getString('lots_data');

    if (lotsData != null) {
      setState(() {
        lots = List<Map<String, dynamic>>.from(json.decode(lotsData));
      });
      print("📥 Lots chargés : ${json.encode(lots)}"); // Debug pour vérifier
    } else {
      print("⚠️ Aucun lot trouvé dans SharedPreferences !");
    }
  }

  /// ✅ Supprimer un lot avec confirmation
void _deleteLot(Map<String, dynamic> lot, bool deleteWithData) async {
  // ✅ Supprimer le lot de la liste
  setState(() {
    lots.removeWhere((l) => l['name'] == lot['name']);
  });
  await _saveLots();

  // ✅ Si on doit aussi supprimer les revenus et dépenses liés
  if (deleteWithData) {
    _removeLotData(lot['name']);
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Lot supprimé${deleteWithData ? " avec toutes les données associées" : ""}.")),
  );
}
void _removeLotData(String lotName) async {
  final prefs = await SharedPreferences.getInstance();

  // 🔥 Supprimer les revenus liés au lot
  String? salesData = prefs.getString('sales_data');
  if (salesData != null) {
    Map<String, List<Map<String, dynamic>>> sales =
        Map<String, List<Map<String, dynamic>>>.from(json.decode(salesData));

    bool hasChanges = false;

    sales.forEach((month, salesList) {
      int initialLength = salesList.length;
      salesList.removeWhere((sale) => sale['lot'] == lotName);
      if (salesList.length != initialLength) hasChanges = true;
    });

    if (hasChanges) {
      await prefs.setString('sales_data', json.encode(sales));
      print("✅ Revenus du lot '$lotName' supprimés.");
    }
  }

  // 🔥 Supprimer les dépenses liées au lot
  String? expensesData = prefs.getString('expenses_data');
  if (expensesData != null) {
    Map<String, List<Map<String, dynamic>>> expenses =
        Map<String, List<Map<String, dynamic>>>.from(json.decode(expensesData));

    bool hasChanges = false;

    expenses.forEach((month, expenseList) {
      int initialLength = expenseList.length;
      expenseList.removeWhere((expense) => expense['lot'] == lotName);
      if (expenseList.length != initialLength) hasChanges = true;
    });

    if (hasChanges) {
      await prefs.setString('expenses_data', json.encode(expenses));
      print("✅ Dépenses du lot '$lotName' supprimées.");
    }
  }

  print("🔥 Toutes les données associées à '$lotName' ont été supprimées.");
}


void _confirmDeleteLot(Map<String, dynamic> lot) async {
bool? deleteWithData = await showDialog<bool>(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: Text("Supprimer ${lot['name']} ?"),
      content: Text(
        "Voulez-vous également supprimer tous les revenus et dépenses liés à ce lot ?",
      ),
      actions: [
        TextButton(
          child: Text("Annuler"),
          onPressed: () => Navigator.pop(context, null),
        ),
        TextButton(
          child: Text("Supprimer uniquement le lot"),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: Text("Tout supprimer"),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  },
);

// ✅ Si l'utilisateur a annulé, on ne fait rien
if (deleteWithData == null) return;

// ✅ Exécuter la suppression choisie
_deleteLot(lot, deleteWithData);


}

  /// ✅ Sauvegarder la liste des lots dans SharedPreferences
  Future<void> _saveLots() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lots_data', json.encode(lots));
    print("💾 Lots enregistrés : ${json.encode(lots)}"); // Debug
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Suivi des Lots")),
      body: lots.isEmpty
          ? Center(
              child: Text("Aucun lot enregistré.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          : ListView.builder(
              itemCount: lots.length,
              itemBuilder: (context, index) {
                final lot = lots[index];
                
                // ✅ Correction du calcul du prix moyen (sans revenu)
               double pricePerArticle = lot['articleCount'] > 0 ? lot['amountSpent'] / lot['articleCount'] : 0.0;


                // ✅ Correction du calcul du bénéfice net (revenu - dépense)
                double netProfit = lot['revenue'] - lot['amountSpent'];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  child: ListTile(
                    title: Text("${lot['name']} - ${lot['month']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("💰 Dépenses : ${lot['amountSpent']}€"),
                        Text("📦 Articles : ${lot['articleCount']}"),
                        Text("⚖️ Prix moyen : ${pricePerArticle.toStringAsFixed(2)}€"),
                        Text("💵 Revenu total : ${lot['revenue']}€"),
                        Text(
                          "📈 Bénéfice net : ${netProfit}€",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: netProfit >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
  icon: Icon(Icons.delete, color: Colors.red),
  onPressed: () => _confirmDeleteLot(lot),
),

                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: _loadLots, // ✅ Rafraîchir la liste des lots
      ),
    );
  }
}
