import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TitleSettingsScreen extends StatefulWidget {
  @override
  _TitleSettingsScreenState createState() => _TitleSettingsScreenState();
}

class _TitleSettingsScreenState extends State<TitleSettingsScreen> {
  final TextEditingController templateController = TextEditingController();
  bool includeMaterial = false; // Active/désactive le champ Matière
  bool includeGender = false; // Active/désactive le champ Sexe
  bool includeTagNumber = false; // Active/désactive le champ Numéro étiquette
bool includeCustomMessage = false; 
bool includeYear = false; // Active/désactive l'affichage de l'année
final TextEditingController yearController = TextEditingController(); // Contrôleur pour l'année


final TextEditingController customMessageController = TextEditingController();

  final Map<String, String> placeholders = {
    "{type}": "Type de produit",
    "{brand}": "Marque",
    "{color}": "Couleur",
    "{size}": "Taille",
    "{info}": "Information supplémentaire",
    "{material}": "Matière",
    "{gender}": "Sexe",
    "{tag}": "Numéro d'étiquette",
  };

@override
void initState() {
  super.initState();
  _loadCustomTitleTemplate(); // Charger le modèle de titre
  _loadPreferences(); // Charger les préférences des cases à cocher
}
Future<void> _loadPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    includeMaterial = prefs.getBool('includeMaterial') ?? false;
    includeGender = prefs.getBool('includeGender') ?? false;
    includeTagNumber = prefs.getBool('includeTagNumber') ?? false;
     includeYear = prefs.getBool('includeYear') ?? false;
      includeCustomMessage = prefs.getBool('includeCustomMessage') ?? false;
      
      
       customMessageController.text = prefs.getString('customMessageText') ??
          "📦 N'hésitez pas à consulter le reste de mon Vinted ! Je propose des prix avantageux pour les lots.";
  
  });
}
  Future<void> _loadCustomTitleTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      templateController.text = prefs.getString('customTitleTemplate') ??
          "{type} {brand} {info} {color} Taille {size}"; // Modèle par défaut si vide
    });
  }

  void _addPlaceholder(String placeholder) {
    final cursorPosition = templateController.selection.baseOffset;
    String currentText = templateController.text;

    if (cursorPosition >= 0) {
      // Insère le placeholder à la position actuelle du curseur
      final newText = currentText.replaceRange(cursorPosition, cursorPosition, placeholder);
      setState(() {
        templateController.text = newText;
        templateController.selection = TextSelection.collapsed(offset: cursorPosition + placeholder.length);
      });
    } else {
      // Ajoute à la fin si aucun curseur positionné
      setState(() {
        templateController.text = "$currentText $placeholder".trim();
        templateController.selection = TextSelection.collapsed(offset: templateController.text.length);
      });
    }
  }

  Future<void> _saveCustomTitleTemplate(String template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customTitleTemplate', template);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Parametre sauvegardé avec succès !")),
    );
  }

  void savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('includeMaterial', includeMaterial);
    await prefs.setBool('includeGender', includeGender);
    await prefs.setBool('includeTagNumber', includeTagNumber);
    await prefs.setBool('includeYear', includeYear);
     await prefs.setBool('includeCustomMessage', includeCustomMessage);
         await prefs.setString('customMessageText', customMessageController.text.trim());
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aide pour le modèle de titre'),
          content: const Text(
            '''
Un modèle de titre vous permet de personnaliser l'affichage des informations sur vos produits.

Exemples :
- {type} - {brand} - {color} - Taille {size}
- {brand} {type} en {color}, Taille {size}

Les placeholders disponibles :
- {type} : Type de produit (ex. : Tee-shirt)
- {brand} : Marque (ex. : Nike)
- {color} : Couleur (ex. : Rouge)
- {size} : Taille (ex. : M)
- {info} : Informations supplémentaires (ex. : Edition limitée)
- {material} : Matière (ex. : Coton)
- {gender} : Sexe (ex. : Homme, Femme)
- {tag} : Numéro d'étiquette (si disponible)

Astuce : Utilisez ces mots entre accolades {} pour structurer automatiquement votre titre.
            ''',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
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
        title: const Text("Personnalisation du Titre"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog, // Affiche l'aide
            tooltip: 'Comment personnaliser le titre ?',
          ),
IconButton(
  icon: const Icon(Icons.save),
  onPressed: () {
    final newTemplate = templateController.text.trim();
    _saveCustomTitleTemplate(newTemplate); // Sauvegarder le modèle personnalisé
    savePreferences(); // Sauvegarde des préférences
    Navigator.pop(context, true); // Retourne à l'écran précédent avec un booléen pour indiquer un changement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Parametre sauvegardé avec succès !")),
    );
  },
),


        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Modèle du Titre :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: templateController,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Exemple : {type} {brand} en {color}, Taille {size}",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Cliquez sur un élément pour l'insérer :",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Boutons pour ajouter les placeholders
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: placeholders.entries.map((entry) {
                return ElevatedButton(
                  onPressed: () => _addPlaceholder(entry.key),
                  child: Text(entry.key),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.blueAccent,
                    textStyle: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Switch pour "Matière"
            CheckboxListTile(
              value: includeMaterial,
              onChanged: (value) {
                setState(() {
                  includeMaterial = value ?? false;
                });
                savePreferences(); // Sauvegarde lors du changement
              },
              title: const Text('Afficher le champ "Matière"'),
            ),
            CheckboxListTile(
              value: includeGender,
              onChanged: (value) {
                setState(() {
                  includeGender = value ?? false;
                });
                savePreferences(); // Sauvegarde lors du changement
              },
              title: const Text('Afficher le champ "Sexe"'),
            ),
            CheckboxListTile(
              value: includeTagNumber,
              onChanged: (value) {
                setState(() {
                  includeTagNumber = value ?? false;
                });
                savePreferences(); // Sauvegarde lors du changement
              },
              title: const Text('Afficher le champ "Numéro d\'étiquette"'),
            ),
CheckboxListTile(
  value: includeYear,
  onChanged: (value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      includeYear = value ?? false;
    });
    await prefs.setBool('includeYear', includeYear);
  },
  title: const Text('Inclure l\'année dans la description'),
),


            CheckboxListTile(
          title: Text('Activer le message personnalisé'),
          value: includeCustomMessage,
          onChanged: (value) {
            setState(() {
              includeCustomMessage = value ?? false;
            });
            savePreferences(); // Sauvegarde immédiate
          },
        ),
        
                        if (includeCustomMessage)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Message personnalisé :',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: customMessageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Entrez le message personnalisé ici",
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
