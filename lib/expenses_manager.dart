import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExpensesManager {
  static const String expensesKey = 'expenses_data';

  Map<String, List<Map<String, dynamic>>> expenses = {}; // Dépenses classées par mois

  /// 🔹 Charger les dépenses depuis `SharedPreferences`
  Future<void> loadExpensesData() async {
    final prefs = await SharedPreferences.getInstance();
    String? expensesData = prefs.getString(expensesKey);
    if (expensesData != null) {
      expenses = Map<String, List<Map<String, dynamic>>>.from(
        json.decode(expensesData).map(
          (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
        ),
      );
    }
  }

  /// 🔹 Ajouter une dépense à un mois spécifique
  Future<void> addExpense(String month, double amount, String category, {String? description}) async {
    expenses.putIfAbsent(month, () => []);
    expenses[month]!.add({
      'amount': amount,
      'category': category,
      'description': description ?? "",
    });
    await _saveExpenses();
  }

  /// 🔹 Supprimer une dépense
  Future<void> removeExpense(String month, Map<String, dynamic> expense) async {
    expenses[month]?.remove(expense);
    await _saveExpenses();
  }

  /// 🔹 Obtenir le total des dépenses d’un mois
double getTotalExpenses(String month) {
  if (expenses[month] == null) return 0.0; // Vérification si null
  return expenses[month]!.fold(0.0, (sum, expense) => sum + (expense['amount'] as double? ?? 0.0));
}


  /// 🔹 Calculer le **bénéfice** (Ventes - Dépenses)
  double calculateProfit(double totalSales, String month) {
    return totalSales - getTotalExpenses(month);
  }

  /// 🔹 Sauvegarder les dépenses dans `SharedPreferences`
  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(expensesKey, json.encode(expenses));
  }
}
