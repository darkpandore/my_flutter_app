import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpensesManagerApp extends StatefulWidget {
  const ExpensesManagerApp({super.key});

  @override
  _ExpensesManagerAppState createState() => _ExpensesManagerAppState();
}

class _ExpensesManagerAppState extends State<ExpensesManagerApp> {
  static const String expensesKey = 'expenses_data';
  static const String closedMonthsKey = 'closed_expense_months';
  
static const String lotsKey = 'lots_data';

  Map<String, List<Map<String, dynamic>>> expenses = {};
  List<String> closedMonths = [];
  List<String> categories = ["Whatnot", "Vinted", "Achat", "Autres"];
  bool showClosedMonths = false;

List<Map<String, dynamic>> lots = []; // Liste des lots

  @override
  void initState() {
    super.initState();
    _loadExpensesData().then((_) {
    setState(() {});
    _loadLots();
  });
  }
Future<void> _loadLots() async {
  final prefs = await SharedPreferences.getInstance();
  String? lotsData = prefs.getString(lotsKey);
  if (lotsData != null) {
    lots = List<Map<String, dynamic>>.from(json.decode(lotsData));
  }
  setState(() {});
}
Future<void> _saveLots() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(lotsKey, json.encode(lots));
}

  /// 📌 Générer les mois de Janvier 2025 à Décembre 2028
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


Future<void> _loadExpensesData() async {
  final prefs = await SharedPreferences.getInstance();
  String? expensesData = prefs.getString(expensesKey);
  closedMonths = prefs.getStringList(closedMonthsKey) ?? [];

  print("🔍 Mois clôturés chargés depuis SharedPreferences (Dépenses) : $closedMonths");

  if (expensesData != null) {
    expenses = Map<String, List<Map<String, dynamic>>>.from(
      json.decode(expensesData).map(
        (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
      ),
    );
  }

  print("📊 Vérification des dépenses chargées :");
  expenses.forEach((month, expensesList) {
    double total = _getTotalExpenses(month);
    print("📆 $month : ${total.toStringAsFixed(2)} €");
  });
    for (String month in _generateMonthsList()) {
      expenses.putIfAbsent(month, () => []);
    }
  setState(() {});
  await _saveExpenses();
}



  /// 📌 Sauvegarde les dépenses
  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(expensesKey, json.encode(expenses));
  }

  /// 📌 Sauvegarde les mois clôturés
  Future<void> _saveClosedMonths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(closedMonthsKey, closedMonths);
  }

  /// 📌 Ajoute une dépense
  Future<void> _addExpense(String month, double amount, String category, {String? description}) async {
    if (_isMonthClosed(month)) return;
    expenses[month]!.add({'amount': amount, 'category': category, 'description': description ?? ""});
    await _saveExpenses();
    setState(() {});
  }

  /// 📌 Supprime une dépense
  Future<void> _removeExpense(String month, Map<String, dynamic> expense) async {
    expenses[month]!.remove(expense);
    await _saveExpenses();
    setState(() {});
  }

  /// 📌 Calcule le total des dépenses d'un mois
double _getTotalExpenses(String month) {
  if (!expenses.containsKey(month)) return 0.0;

  double total = expenses[month]!.fold(0.0, (sum, expense) {
    double amount = (expense['amount'] as double?) ?? 0.0;
    return sum + amount;
  });

  print("📆 Calcul des dépenses pour $month : $total €");
  return total;
}


Future<void> _closeMonth(String month) async {
  if (!closedMonths.contains(month)) {
    closedMonths.add(month);
    await _saveClosedMonths();

    print("✅ Mois ajouté à closedMonths et sauvegardé : $closedMonths");

    setState(() {});
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


  /// 📌 Vérifier si un mois est clôturé
  bool _isMonthClosed(String month) {
    return closedMonths.contains(month);
  }

  /// 📌 Boîte de dialogue pour ajouter une seule dépense
void _showAddExpenseDialog() {
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // ✅ Filtrer pour afficher uniquement les mois non clôturés
  List<String> availableMonths = expenses.keys.where((month) => !closedMonths.contains(month)).toList();

  // ✅ Vérifier qu'il y a des mois disponibles, sinon afficher un message
  if (availableMonths.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Aucun mois disponible pour ajouter une dépense.")),
    );
    return;
  }

  String selectedMonth = availableMonths.first;
  String selectedCategory = categories.first;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Ajouter une Dépense"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Sélectionner un mois (seulement les mois NON clôturés)
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
                      DropdownMenuItem(value: month, child: Text(month))).toList(),
                ),

                // ✅ Champ Montant
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Montant (€)"),
                ),

                // ✅ Sélection de la catégorie
                DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setDialogState(() {
                        selectedCategory = newValue;
                      });
                    }
                  },
                  items: categories.map((category) =>
                      DropdownMenuItem(value: category, child: Text(category))).toList(),
                ),

                // ✅ Champ Description (optionnel)
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description (optionnel)"),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Annuler"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Ajouter"),
                onPressed: () async {
                  double amount = double.tryParse(amountController.text) ?? 0.0;
                  if (amount > 0) {
                    await _addExpense(selectedMonth, amount, selectedCategory, description: descriptionController.text);
                    setState(() {}); 
                    Navigator.pop(context);
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
void _showAddLotDialog() {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController articleCountController = TextEditingController();

  List<String> availableMonths = expenses.keys.where((month) => !closedMonths.contains(month)).toList();

  if (availableMonths.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Aucun mois disponible pour ajouter un lot.")),
    );
    return;
  }

  String selectedMonth = availableMonths.first;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Créer un Lot"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nom du lot")),
            DropdownButton<String>(
              value: selectedMonth,
              onChanged: (newValue) {
                if (newValue != null) {
                  selectedMonth = newValue;
                }
              },
              items: availableMonths.map((month) =>
                DropdownMenuItem(value: month, child: Text(month))).toList(),
            ),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Montant dépensé (€)")),
            TextField(controller: articleCountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Nombre d'articles")),
          ],
        ),
        actions: [
          TextButton(child: const Text("Annuler"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text("Créer"),
            onPressed: () async {
              double amount = double.tryParse(amountController.text) ?? 0.0;
              int articleCount = int.tryParse(articleCountController.text) ?? 1;

              if (nameController.text.isNotEmpty && amount > 0 && articleCount > 0) {
                lots.add({
                  'name': nameController.text,
                  'month': selectedMonth,
                  'amountSpent': amount,
                  'articleCount': articleCount,
                  'revenue': 0.0
                });

                expenses[selectedMonth]!.add({
                  'amount': amount,
                  'category': "Lot (${nameController.text})",
                  'description': "Dépense liée au lot"
                });

                await _saveExpenses();
                await _saveLots();
                if (mounted) {
                  setState(() {});
                }
                Navigator.pop(context);
              }
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Dépenses"),
        actions: [
            IconButton(
    icon: const Icon(Icons.add_shopping_cart),
    onPressed: _showAddLotDialog, // ✅ Ouvre la boîte de dialogue d’ajout de lot
    tooltip: "Créer un Lot",
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
            tooltip: showClosedMonths
                ? "Afficher uniquement les mois clôturés"
                : "Afficher uniquement les mois actifs",
          ),
        ],
      ),
body: ListView.builder(
  itemCount: expenses.length,
  itemBuilder: (context, index) {
    String month = expenses.keys.elementAt(index);
    bool isClosed = _isMonthClosed(month);
    if (showClosedMonths && !isClosed) return SizedBox();
    if (!showClosedMonths && isClosed) return SizedBox();

    double totalExpenses = _getTotalExpenses(month);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          "$month - Dépenses : ${totalExpenses.toStringAsFixed(2)}€",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: Icon(isClosed ? Icons.lock : Icons.lock_open),
          onPressed: () async {
            if (isClosed) {
              await _reopenMonth(month);
            } else {
              await _closeMonth(month);
            }
          },
        ),
        children: expenses[month]!.map((expense) {
          return ListTile(
            title: Text("${expense['amount']}€ - ${expense['category']}"),
            subtitle: expense['description'].isNotEmpty ? Text(expense['description']) : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _removeExpense(month, expense);
              },
            ),
          );
        }).toList(),
      ),
    );
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
