import 'dart:convert'; // Pour la gestion du JSON
import 'package:shared_preferences/shared_preferences.dart';

class FormFieldConfig {
  String label;
  bool isMandatory;
  bool isVisible;

  FormFieldConfig({
    required this.label,
    this.isMandatory = false,
    this.isVisible = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'isMandatory': isMandatory,
      'isVisible': isVisible,
    };
  }

  static FormFieldConfig fromMap(Map<String, dynamic> map) {
    return FormFieldConfig(
      label: map['label'],
      isMandatory: map['isMandatory'] ?? false,
      isVisible: map['isVisible'] ?? true,
    );
  }
}

class FormConfigManager {
  static const String _typesKey = "types";
  static const String _brandsKey = "brands";
  static const String _fieldsKey = "fields";

  List<String> _types = [];
  List<String> _brands = [];
  List<FormFieldConfig> _fields = [];

  // Méthode publique pour initialiser les données
  Future<void> loadDefaults() async {
    await _initializeDefaults();
  }

  Future<void> _initializeDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    // Chargement des types
    _types = prefs.getStringList(_typesKey) ?? [
      'Jeans', 'Pull', 'Tee-shirt', 'Manteau', 'Chaussure'
    ];

    // Chargement des marques
    _brands = prefs.getStringList(_brandsKey) ?? [
      'Nike', 'Adidas', 'Tommy Hilfiger', 'Lacoste', 'Ralph Lauren'
    ];

    // Chargement des champs depuis JSON
    List<String>? fieldsData = prefs.getStringList(_fieldsKey);
    if (fieldsData != null) {
      _fields = fieldsData
          .map((e) => FormFieldConfig.fromMap(jsonDecode(e)))
          .toList();
    } else {
      // Champs par défaut
      _fields = [
        FormFieldConfig(label: "Marque*", isMandatory: true),
        FormFieldConfig(label: "Type*", isMandatory: true),
        FormFieldConfig(label: "Prix d'achat*", isMandatory: true),
        FormFieldConfig(label: "Référence"),
        FormFieldConfig(label: "Prix de revente estimé"),
      ];
    }
  }

  List<String> get types => _types;
  List<String> get brands => _brands;
  List<FormFieldConfig> get fields => _fields;

  Future<void> addType(String type) async {
    _types.add(type);
    await _saveToPreferences(_typesKey, _types);
  }

  Future<void> addBrand(String brand) async {
    _brands.add(brand);
    await _saveToPreferences(_brandsKey, _brands);
  }

  Future<void> updateField(FormFieldConfig field) async {
    final index = _fields.indexWhere((f) => f.label == field.label);
    if (index != -1) {
      _fields[index] = field;
    } else {
      _fields.add(field);
    }
    await _saveFields();
  }

  Future<void> _saveFields() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> fieldsData = _fields.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_fieldsKey, fieldsData);
  }

  Future<void> _saveToPreferences(String key, List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, values);
  }
}
