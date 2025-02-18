import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumProvider with ChangeNotifier {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  set isPremium(bool value) {
    _isPremium = value;
    notifyListeners(); // Notifie les auditeurs que l'état a changé
  }

  // Charger l'état de l'abonnement depuis SharedPreferences
  Future<void> loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;
    notifyListeners();
  }

  // Sauvegarder l'état de l'abonnement dans SharedPreferences
  Future<void> savePremiumStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', value);
    _isPremium = value;
    notifyListeners();
  }
}
