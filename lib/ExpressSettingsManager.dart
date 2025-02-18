import 'package:shared_preferences/shared_preferences.dart'; 

class ExpressSettingsManager {
  List<Map<String, dynamic>> defaultCheckboxes = [
  {"label": "🎉 10% de réduction pour les abonnés", "checked": false},
  {"label": "🚚 Envoi rapide en 24/48h maximum", "checked": false},
  {"label": "❓ N'hésitez pas à m'envoyer un message si vous avez une question !", "checked": false}
];


  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedCheckboxes = defaultCheckboxes.map((item) {
      return "${item['label']}|${item['checked']}";
    }).toList();
    await prefs.setStringList('expressSettings', savedCheckboxes);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedCheckboxes = prefs.getStringList('expressSettings');

    if (savedCheckboxes != null) {
      defaultCheckboxes = savedCheckboxes.map((item) {
        final parts = item.split('|');
        return {
          "label": parts[0],
          "checked": parts[1] == "true",
        };
      }).toList();
    }
  }

  void addCheckbox(String label) {
    defaultCheckboxes.add({"label": label, "checked": false});
  }

  void removeCheckbox(int index) {
    if (index >= 0 && index < defaultCheckboxes.length) {
      defaultCheckboxes.removeAt(index);
    }
  }

  void updateCheckbox(int index, String newLabel) {
    if (index >= 0 && index < defaultCheckboxes.length) {
      defaultCheckboxes[index]["label"] = newLabel;
    }
  }
}
