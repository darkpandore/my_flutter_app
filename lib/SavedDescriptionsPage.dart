import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedDescriptionsPage extends StatefulWidget {
  const SavedDescriptionsPage({Key? key}) : super(key: key);

  @override
  _SavedDescriptionsPageState createState() => _SavedDescriptionsPageState();
}

class _SavedDescriptionsPageState extends State<SavedDescriptionsPage> {
  List<Map<String, String>> descriptions = [];
  List<Map<String, String>> filteredDescriptions = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDescriptions();
  }

  /// 📥 Charger les descriptions sauvegardées
  Future<void> _loadDescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedDescriptions = prefs.getStringList('saved_descriptions');

    if (savedDescriptions == null || savedDescriptions.isEmpty) {
      setState(() {
        descriptions = [];
        filteredDescriptions = [];
      });
      return;
    }

    List<Map<String, String>> tempDescriptions = [];

    for (String desc in savedDescriptions) {
      try {
        Map<String, dynamic> data = jsonDecode(desc);
        if (data.containsKey('title') && data.containsKey('description')) {
          tempDescriptions.add({
            'title': data['title'] ?? 'Sans titre',
            'description': data['description'] ?? 'Pas de description',
          });
        }
      } catch (e) {
        debugPrint("❌ Erreur de parsing JSON : $e");
      }
    }

    setState(() {
      descriptions = tempDescriptions;
      filteredDescriptions = List.from(descriptions);
    });
  }

  /// 🔍 Filtrer les descriptions en fonction de la recherche
  void _filterDescriptions(String query) {
    setState(() {
      filteredDescriptions = descriptions
          .where((desc) => desc['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// 📋 Copier un texte dans le presse-papiers
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📋 Copié dans le presse-papiers")),
    );
  }

  /// 🗑️ Supprimer une description sauvegardée
  Future<void> _deleteDescription(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedDescriptions = prefs.getStringList('saved_descriptions') ?? [];

    if (index >= 0 && index < savedDescriptions.length) {
      savedDescriptions.removeAt(index);
      await prefs.setStringList('saved_descriptions', savedDescriptions);
    }

    _loadDescriptions();
  }

  /// 🗑️ Supprimer toutes les descriptions
  Future<void> _clearAllDescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_descriptions');

    setState(() {
      descriptions.clear();
      filteredDescriptions.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Toutes les descriptions ont été supprimées !")),
    );
  }

  /// ✏️ Modifier une description
  void _editDescription(int index) async {
    Map<String, String> description = descriptions[index];

    TextEditingController titleController = TextEditingController(text: description['title']);
    TextEditingController descriptionController = TextEditingController(text: description['description']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier la description"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Titre"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                descriptions[index] = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                };

                final prefs = await SharedPreferences.getInstance();
                await prefs.setStringList(
                  'saved_descriptions',
                  descriptions.map((e) => jsonEncode(e)).toList(),
                );

                _loadDescriptions();
                Navigator.pop(context);
              },
              child: const Text("Modifier"),
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
        title: const Text("📋 Descriptions sauvegardées"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Tout supprimer',
            onPressed: _clearAllDescriptions,
          ),
        ],
      ),
      body: Column(
        children: [
          /// 🔍 Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "🔍 Rechercher...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterDescriptions,
            ),
          ),

          /// 📋 Liste des descriptions sauvegardées
          Expanded(
            child: filteredDescriptions.isEmpty
                ? const Center(child: Text("📭 Aucune description enregistrée."))
                : ListView.builder(
                    itemCount: filteredDescriptions.length,
                    itemBuilder: (context, index) {
                      final description = filteredDescriptions[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        child: ListTile(
                          title: Text(description['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            description['description']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editDescription(index),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(description['title']!),
                                  content: SingleChildScrollView(
                                    child: Text(description['description']!),
                                  ),
                                  actions: [
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      tooltip: 'Copier le titre',
                                      onPressed: () => _copyToClipboard(description['title']!),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.content_copy),
                                      tooltip: 'Copier la description',
                                      onPressed: () => _copyToClipboard(description['description']!),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Supprimer',
                                      onPressed: () {
                                        _deleteDescription(index);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
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
