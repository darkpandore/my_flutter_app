import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StatisticsPage.dart';

class SalesManagerApp extends StatefulWidget {
  @override
  _SalesManagerAppState createState() => _SalesManagerAppState();
}

class _SalesManagerAppState extends State<SalesManagerApp> {
  static const String salesKey = 'sales_data';
  static const String closedMonthsKey = 'closed_months';
  static const String vatKey = 'tvaPercentage';


Map<String, List<Map<String, dynamic>>> expenses = {};

  Map<String, List<Map<String, dynamic>>> sales = {};
  List<String> closedMonths = [];
  bool isVintedPro = true; // Modifier selon le mode utilisateur
  double vatPercentage = 20.0; // Modifier selon le taux TVA
  bool showClosedMonths = false;
List<Map<String, dynamic>> lots = [];

String? selectedLot; // Par défaut aucun lot sélectionné


  @override
  void initState() {
    super.initState();
  _loadSalesData().then((_) {
    setState(() {}); // ✅ Rafraîchir l'UI après chargement des données
  });
  _loadExpensesData().then((_) {
    setState(() {}); // ✅ Rafraîchir l'UI après chargement des données
  });
    _loadLots();
  }

  Future<void> _loadLots() async {
  final prefs = await SharedPreferences.getInstance();
  String? lotsData = prefs.getString('lots_data');
  if (lotsData != null) {
    lots = List<Map<String, dynamic>>.from(json.decode(lotsData));
  }
  setState(() {});
}

double _getTotalRevenueAllYears() {
  double total = 0.0;
  sales.forEach((month, salesList) {
    total += _getTotalSales(month);
  });
  return total;
}

Future<void> _loadExpensesData() async {
  final prefs = await SharedPreferences.getInstance();
  String? expensesData = prefs.getString('expenses_data');

  if (expensesData != null) {
    expenses = Map<String, List<Map<String, dynamic>>>.from(
      json.decode(expensesData).map(
        (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
      ),
    );
  }
  setState(() {}); // Mettre à jour l'interface après le chargement des dépenses
}
  /// Générer tous les mois de Janvier 2025 à Décembre 2028
  List<String> _generateMonthsList() {
    List<String> months = [];
    List<String> monthNames = [
      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];

    for (int year = 2025; year <= 2028; year++) {
      for (String month in monthNames) {
        months.add("$month $year");
      }
    }
    return months;
  }
Future<void> _loadSalesData() async {
  final prefs = await SharedPreferences.getInstance();

  isVintedPro = prefs.getBool('is_vinted_pro') ?? false;
  vatPercentage = prefs.getDouble(vatKey) ?? 0.0;

  String? salesData = prefs.getString(salesKey);
  closedMonths = prefs.getStringList(closedMonthsKey) ?? [];

  print("🔍 Mois clôturés chargés depuis SharedPreferences (Ventes) : $closedMonths");

  if (salesData != null) {
    sales = Map<String, List<Map<String, dynamic>>>.from(
      json.decode(salesData).map(
        (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
      ),
    );
  }

  print("📊 Vérification des ventes chargées :");
  sales.forEach((month, salesList) {
    double total = _getTotalSales(month);
    print("📆 $month : ${total.toStringAsFixed(2)} €");
  });
  for (String month in _generateMonthsList()) {
    sales.putIfAbsent(month, () => []);
  }
  setState(() {});
  await _saveSales();
}


  /// Ajouter une vente
  Future<void> _addSale(String month, double amount, {String? articleName}) async {
    if (closedMonths.contains(month)) return;

    sales[month]!.add({'amount': amount, 'article': articleName ?? ""});
    await _saveSales();
    setState(() {});
  }

  /// Clôturer un mois
/// 📌 Clôturer un mois
Future<void> _closeMonth(String month) async {
  if (!closedMonths.contains(month)) {
    closedMonths.add(month);
    await _saveClosedMonths();

    print("✅ Mois ajouté à closedMonths et sauvegardé : $closedMonths");

    setState(() {}); // ✅ Met à jour immédiatement l'affichage
  }
}



/// 📌 Réouvrir un mois clôturé
Future<void> _reopenMonth(String month) async {
  if (closedMonths.contains(month)) {
    closedMonths.remove(month);
    await _saveClosedMonths();
    print("❌ Mois rouvert : $month");
    setState(() {});
  }
}

  /// Vérifier si un mois est clôturé
  bool _isMonthClosed(String month) {
    return closedMonths.contains(month);
  }

  /// Calcul du total des ventes d'un mois (TVA appliquée si Pro)
double _getTotalSales(String month) {
  if (!sales.containsKey(month)) return 0.0;

  double total = sales[month]!.fold(0.0, (sum, sale) {
    double amount = (sale['amount'] as double?) ?? 0.0;
    return sum + amount;
  });

  if (isVintedPro && vatPercentage > 0) {
    total -= (total * vatPercentage / 100);
  }

  print("📆 Calcul des ventes pour $month : $total €");
  return total;
}


void _showAddMultipleSalesDialog() {
  List<String> availableMonths = sales.keys
      .where((month) => !_isMonthClosed(month)) // Afficher uniquement les mois ouverts
      .toList();

  if (availableMonths.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Aucun mois disponible pour ajouter une vente.")),
    );
    return;
  }

  String selectedMonth = availableMonths.first; // Mois sélectionné par défaut
  List<TextEditingController> montantsControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(), // ✅ 3 champs de base
  ];
  List<FocusNode> focusNodes = List.generate(3, (index) => FocusNode()); // ✅ Liste des FocusNode

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Ajouter plusieurs ventes"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sélection du mois
                DropdownButton<String>(
                  value: selectedMonth,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setDialogState(() {
                        selectedMonth = newValue;
                      });
                    }
                  },
                  items: availableMonths.map((month) =>
                      DropdownMenuItem(value: month, child: Text(month))
                  ).toList(),
                ),

                const SizedBox(height: 10),

                // Liste des champs montants avec scroll si > 3
                Flexible(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 250, // ✅ Scroll après 3 champs
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: montantsControllers.length > 3
                            ? AlwaysScrollableScrollPhysics()
                            : NeverScrollableScrollPhysics(),
                        itemCount: montantsControllers.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: montantsControllers[index],
                                  focusNode: focusNodes[index], // ✅ Associer le focus node
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Montant (€)",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  if (montantsControllers.length > 1) {
                                    setDialogState(() {
                                      montantsControllers.removeAt(index);
                                      focusNodes.removeAt(index);
                                    });
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ Bouton pour ajouter un autre montant avec focus automatique
                ElevatedButton.icon(
                  onPressed: () {
                    if (montantsControllers.length < 50) {
                      setDialogState(() {
                        montantsControllers.add(TextEditingController());
                        focusNodes.add(FocusNode());
                      });

                      // ✅ Déclencher le focus sur le nouveau champ après affichage
                      Future.delayed(Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(focusNodes.last);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Vous ne pouvez pas ajouter plus de 50 montants.")),
                      );
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text("Ajouter un montant"),
                ),
              ],
            ),

            actions: [
              TextButton(
                child: Text("Annuler"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text("Valider"),
                onPressed: () async {
                  List<double> montants = montantsControllers
                      .map((controller) => double.tryParse(controller.text) ?? 0.0)
                      .where((amount) => amount > 0)
                      .toList();

                  if (montants.isNotEmpty) {
                    for (double montant in montants) {
                      await _addSale(selectedMonth, montant);
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${montants.length} ventes ajoutées dans $selectedMonth")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Veuillez entrer au moins un montant valide.")),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}




Future<bool> _showConfirmationDialog(String title, String message) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("Confirmer"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
    },
  ) ?? false;
}

void _addRevenueToLot(String lotName, String month, double revenue) async {
  bool lotFound = false;

  // ✅ Ajouter le revenu au lot existant
  for (var lot in lots) {
    if (lot['name'] == lotName) {
      lot['revenue'] = (lot['revenue'] ?? 0.0) + revenue;
      lotFound = true;
      break;
    }
  }

  if (!lotFound) return; // Si le lot n'existe pas, on sort

  // ✅ Ajouter le revenu dans le mois sélectionné
  if (!sales.containsKey(month)) {
    sales[month] = [];
  }

  sales[month]!.add({
    'amount': revenue,
    'article': "Revenu pour le lot $lotName",
  });

  // ✅ Sauvegarder les changements
  await _saveLots();
  await _saveSales();

  setState(() {}); // 🔄 Rafraîchir l'affichage
}


Future<void> _saveLots() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('lots_data', json.encode(lots));
}

  /// Sauvegarder les ventes
  Future<void> _saveSales() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(salesKey, json.encode(sales));
  }

  /// Sauvegarder les mois clôturés
  Future<void> _saveClosedMonths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(closedMonthsKey, closedMonths);
  }

void _showAddSaleDialog() {
  List<String> availableLots = lots.map((lot) => lot['name'] as String).toList();
String? selectedLot;

  List<String> availableMonths = sales.keys
      .where((month) => !_isMonthClosed(month)) // Afficher uniquement les mois ouverts
      .toList();

  if (availableMonths.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Aucun mois disponible pour ajouter une vente.")),
    );
    return;
  }

  String selectedMonth = availableMonths.first; // Mois sélectionné par défaut
  TextEditingController amountController = TextEditingController();
  TextEditingController articleController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder( // Utiliser StatefulBuilder pour rafraîchir la sélection du mois
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Ajouter une vente"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
DropdownButton<String>(
  value: selectedLot,
  hint: Text("Sélectionner un lot (optionnel)"),
  onChanged: (newValue) {
    setDialogState(() {
      selectedLot = newValue;
    });
  },
  items: availableLots.map((lot) =>
      DropdownMenuItem(value: lot, child: Text(lot))).toList(),
),

                DropdownButton<String>(
                  value: selectedMonth,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setDialogState(() { // Mettre à jour l'état de la boîte de dialogue
                        selectedMonth = newValue;
                      });
                    }
                  },
                  items: availableMonths.map((month) => 
                    DropdownMenuItem(value: month, child: Text(month))
                  ).toList(),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Montant (€)"),
                ),
                TextField(
                  controller: articleController,
                  decoration: InputDecoration(labelText: "Nom de l'article (optionnel)"),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Annuler"),
                onPressed: () => Navigator.pop(context),
              ),
TextButton(
  child: Text("Valider"),
  onPressed: () async {
    double amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount > 0) {
      if (selectedLot != null) {
        _addRevenueToLot(selectedLot!, selectedMonth, amount); // ✅ On envoie aussi le mois
      } else {
        await _addSale(selectedMonth, amount);
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Revenu ajouté.")),
      );
    }
  },
),



            ],
          );
        },
      );
    },
  );
}

double _getTotalExpenses(String month) {
  return (expenses[month] ?? []).fold(0.0, (sum, expense) {
    return sum + ((expense['amount'] as double?) ?? 0.0);
  });
}


Future<bool> _showConfirmationDialog2(String title, String message) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("Confirmer"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
    },
  ) ?? false;
}
void _showYearSelectionDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Sélectionner une année"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["2025", "2026", "2027", "2028"].map((year) {
            return ListTile(
              title: Text("Ventes de l'année $year"),
              onTap: () {
                Navigator.pop(context); // Fermer le dialogue
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YearlySalesPage(
                      year: year,
                      sales: sales,
                      getTotalSales: _getTotalSales,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      );
    },
  );
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Gestion des Ventes"),
      actions: [
        IconButton(
  icon: Icon(Icons.bar_chart), // 📊 Icône de statistiques
  onPressed: () {
  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => StatisticsPage(
      sales: sales,
      getTotalSales: _getTotalSales,
      getTotalExpenses: _getTotalExpenses, // Ajoute cette fonction !
      closedMonths: closedMonths, // Passe la liste des mois clôturés !
    ),
  ),
);

  },
),

        IconButton(
          icon: Icon(
            showClosedMonths ? Icons.visibility_off : Icons.visibility, 
            color: showClosedMonths ? Colors.black : Colors.black,
          ),
          onPressed: () {
            setState(() {
              showClosedMonths = !showClosedMonths;
            });
          },
          tooltip: showClosedMonths ? "Afficher uniquement les mois clôturés" : "Afficher uniquement les mois actifs",
        ),
        IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: _showAddMultipleSalesDialog,
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: _showAddSaleDialog,
        ),
      ],
    ),

    body: Column(
      children: [
        // ✅ Carte affichant le total global des ventes
        Card(
          margin: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: ListTile(
            title: Text(
              "Total des revenus : ${_getTotalRevenueAllYears().toStringAsFixed(2)}€",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showYearSelectionDialog(); // ✅ Ouvre la sélection des années
            },
          ),
        ),

        // ✅ Liste des mois et ventes
        Expanded(
          child: ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              String month = sales.keys.elementAt(index);
              bool isClosed = _isMonthClosed(month);

              if (showClosedMonths && !isClosed) return SizedBox();
              if (!showClosedMonths && isClosed) return SizedBox();

              double totalSales = _getTotalSales(month);

              return GestureDetector(
                onLongPress: () async {
                  bool confirm = await _showConfirmationDialog(
                    isClosed ? "Réactiver" : "Clôturer",
                    "Voulez-vous vraiment ${isClosed ? "réactiver" : "clôturer"} le mois $month ?",
                  );

                  if (confirm) {
                    if (isClosed) {
                      await _reopenMonth(month);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Le mois $month a été réactivé.")),
                      );
                    } else {
                      await _closeMonth(month);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Le mois $month a été clôturé.")),
                      );
                    }
                    setState(() {});
                  }
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      "$month - Total : ${totalSales.toStringAsFixed(2)}€",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    children: sales[month]!.map((sale) {
                      return ListTile(
                        title: Text("${sale['amount']}€"),
                        subtitle: sale['article'].isNotEmpty ? Text(sale['article']) : null,
                        onLongPress: () async {
                          bool confirm = await _showConfirmationDialog2(
                            "Supprimer la vente",
                            "Voulez-vous vraiment supprimer cette vente de ${sale['amount']}€ ?",
                          );

                          if (confirm) {
                            setState(() {
                              sales[month]!.remove(sale); // Supprime la vente
                            });
                            await _saveSales(); // Sauvegarde la modification

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Vente de ${sale['amount']}€ supprimée.")),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

}
class YearlySalesPage extends StatelessWidget {
  final String year;
  final Map<String, List<Map<String, dynamic>>> sales;
  final Function(String) getTotalSales;

  YearlySalesPage({
    required this.year,
    required this.sales,
    required this.getTotalSales,
  });

  /// 📌 Fonction pour calculer le total des ventes de l'année sélectionnée
  double _getTotalForYear() {
    double total = 0.0;
    sales.keys
        .where((month) => month.contains(year))
        .forEach((month) {
          total += getTotalSales(month);
        });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    // Liste des noms des mois dans l'ordre
    List<String> monthNames = [
      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];

    // Filtrer et trier les mois de l'année sélectionnée
    List<String> monthsInYear = sales.keys
        .where((month) => month.contains(year))
        .toList()
      ..sort((a, b) {
        int monthA = monthNames.indexWhere((name) => a.startsWith(name));
        int monthB = monthNames.indexWhere((name) => b.startsWith(name));
        return monthA.compareTo(monthB);
      });

    // 📊 Calculer le total des ventes pour l'année sélectionnée
    double totalYearlySales = _getTotalForYear();

    return Scaffold(
      appBar: AppBar(
        title: Text("Détail des ventes - $year"),
      ),
      body: Column(
        children: [
          // ✅ Carte affichant le total annuel en haut
          Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: ListTile(
              title: Text(
                "Total des ventes - $year : ${totalYearlySales.toStringAsFixed(2)}€",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ✅ Liste des mois avec leurs ventes
          Expanded(
            child: ListView.builder(
              itemCount: monthsInYear.length,
              itemBuilder: (context, index) {
                String month = monthsInYear[index];
                double totalSales = getTotalSales(month);

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      "$month - Total : ${totalSales.toStringAsFixed(2)}€",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    children: sales[month]!.isNotEmpty
                        ? sales[month]!.map((sale) {
                            return ListTile(
                              title: Text("${sale['amount']}€"),
                              subtitle: sale['article'].isNotEmpty ? Text(sale['article']) : null,
                            );
                          }).toList()
                        : [
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "Aucune vente enregistrée.",
                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                              ),
                            ),
                          ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
