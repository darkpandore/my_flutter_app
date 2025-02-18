import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ExpressSettingsManager.dart';

class ExpressDescriptionGenerator extends StatefulWidget {
  const ExpressDescriptionGenerator({Key? key}) : super(key: key);

  @override
  _ExpressDescriptionGeneratorState createState() => _ExpressDescriptionGeneratorState();
}

class _ExpressDescriptionGeneratorState extends State<ExpressDescriptionGenerator> {
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController infoController = TextEditingController();
  String selectedCondition = "Neuf avec étiquette";

  final ExpressSettingsManager settingsManager = ExpressSettingsManager();

  @override
  void initState() {
    super.initState();
    settingsManager.loadSettings().then((_) {
      setState(() {}); // Rafraîchir après chargement
    });
  }

  String _generateDescription() {
    StringBuffer description = StringBuffer();

    description.writeln("📏 Taille de l'article : ${sizeController.text} | 🎨 Couleur : ${colorController.text}");
    description.writeln("🛍️ État : $selectedCondition");

    if (infoController.text.isNotEmpty) {
      description.writeln("ℹ️ Informations : ${infoController.text}");
    }

    for (var field in settingsManager.defaultCheckboxes) {
      if (field["checked"]) {
        description.writeln(field["label"]);
      }
    }

    return description.toString();
  }

  void _openSettingsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpressSettingsScreen(settingsManager: settingsManager),
      ),
    ).then((_) {
      setState(() {}); // Rafraîchir après retour
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Description copiée dans le presse-papiers !")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Générateur Express"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsScreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: sizeController,
              decoration: const InputDecoration(labelText: "Taille de l'article"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: colorController,
              decoration: const InputDecoration(labelText: "Couleur de l'article"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCondition,
              decoration: const InputDecoration(labelText: "État de l'article"),
              items: ["Neuf avec étiquette", "Neuf sans étiquette", "Très bon état", "Bon état", "Satisfaisant"]
                  .map((condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCondition = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: infoController,
              decoration: const InputDecoration(labelText: "Informations supplémentaires"),
            ),
            const SizedBox(height: 20),
            ...settingsManager.defaultCheckboxes.asMap().entries.map((entry) {
  final field = entry.value; // On ne garde que la valeur
  return CheckboxListTile(
    title: Text(field["label"]),
    value: field["checked"],
    onChanged: (value) {
      setState(() {
        field["checked"] = value!;
      });
    },
  );
}).toList(),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final description = _generateDescription();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Description générée"),
                    content: Text(description),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Fermer"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _copyToClipboard(description);
                          Navigator.pop(context);
                        },
                        child: const Text("Copier"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Générer la description"),
            ),
          ],
        ),
      ),
    );
  }
}
class ExpressSettingsScreen extends StatefulWidget {
  final ExpressSettingsManager settingsManager;

  const ExpressSettingsScreen({Key? key, required this.settingsManager}) : super(key: key);

  @override
  _ExpressSettingsScreenState createState() => _ExpressSettingsScreenState();
}

class _ExpressSettingsScreenState extends State<ExpressSettingsScreen> {
  final TextEditingController newFieldController = TextEditingController();
  final TextEditingController editFieldController = TextEditingController();

  void _editCheckbox(int index) {
    editFieldController.text = widget.settingsManager.defaultCheckboxes[index]["label"];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier le champ"),
          content: TextField(
            controller: editFieldController,
            decoration: const InputDecoration(labelText: "Nouveau nom du champ"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.settingsManager.updateCheckbox(index, editFieldController.text);
                  widget.settingsManager.saveSettings(); // Sauvegarde après modification
                });
                Navigator.pop(context);
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres de champs")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: newFieldController,
              decoration: const InputDecoration(hintText: "Ajouter un nouveau champ"),
            ),
            ElevatedButton(
              onPressed: () {
                if (newFieldController.text.isNotEmpty) {
                  setState(() {
                    widget.settingsManager.addCheckbox(newFieldController.text);
                    widget.settingsManager.saveSettings();
                  });
                  newFieldController.clear();
                }
              },
              child: const Text("Ajouter"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.settingsManager.defaultCheckboxes.length,
                itemBuilder: (context, index) {
                  final field = widget.settingsManager.defaultCheckboxes[index];
                  return ListTile(
                    title: Text(field["label"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editCheckbox(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              widget.settingsManager.removeCheckbox(index);
                              widget.settingsManager.saveSettings();
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
