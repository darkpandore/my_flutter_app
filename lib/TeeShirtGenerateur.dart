import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TeeShirtGenerateur extends StatefulWidget {
  @override
  _TeeShirtGenerateurState createState() => _TeeShirtGenerateurState();
}

class _TeeShirtGenerateurState extends State<TeeShirtGenerateur> {
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _couleurController = TextEditingController();
  final TextEditingController _motifController = TextEditingController();
  final TextEditingController _defautController = TextEditingController();

  String _titre = "";
  String _description = "";
  String _selectedCouleur = "";
  String _selectedTaille = "";

  bool _afficherMotifDansTitre = true;
bool _afficherMotifDansDescription = true;


  String _nettoyerTexte(String texte) {
    // Remplace les caractères spéciaux et les espaces
    return texte
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ô', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r"[^a-z0-9]"), ""); // Garde uniquement les lettres et chiffres
  }

void _genererDescription() {
  setState(() {
    String marque = _nettoyerTexte(_marqueController.text.trim());
    String taille = _nettoyerTexte(_tailleController.text.trim());
String couleurPourTitre = _couleurController.text.split(RegExp(r'[ ,]+')).first.trim();

String couleursPourDescription = _couleurController.text.trim();

  String motif = _afficherMotifDansTitre ? _nettoyerTexte(_motifController.text.trim()) : "";

    String defaut = _defautController.text.trim();

    // Générer le titre avec uniquement la première couleur
    _titre = "Tee-Shirt $motif $marque $couleurPourTitre $taille".trim();

    // Générer la description dynamique
    List<String> descriptionParts = [];

    if (_marqueController.text.trim().isNotEmpty) {
      descriptionParts.add("👕 **Marque** : ${_marqueController.text.trim()}");
    }
    if (_tailleController.text.trim().isNotEmpty) {
      descriptionParts.add("📏 **Taille** : ${_tailleController.text.trim()}");
    }
    if (_couleurController.text.trim().isNotEmpty) {
      descriptionParts.add("🎨 **Couleur** : $couleursPourDescription"); // Toutes les couleurs
    }
if (_afficherMotifDansDescription && _motifController.text.trim().isNotEmpty) {
  descriptionParts.add("🎭 **Motif** : ${_motifController.text.trim()}");
}

    if (defaut.isNotEmpty) {
      descriptionParts.add("⚠️ **Défaut** : $defaut");
    }

    descriptionParts.add("📦 Envoi rapide sous 24h à 48h ouvrables.");

    // Générer les hashtags
    List<String> hashtags = [
      "teeshirt",
      if (marque.isNotEmpty) marque,
      if (couleurPourTitre.isNotEmpty) couleurPourTitre, // Première couleur pour hashtags
      if (taille.isNotEmpty) taille,
      if (motif.isNotEmpty) motif,
      if (marque.isNotEmpty && couleurPourTitre.isNotEmpty) "${marque}${couleurPourTitre}",
      if (marque.isNotEmpty && taille.isNotEmpty) "${marque}${taille}",
      if (couleurPourTitre.isNotEmpty && taille.isNotEmpty) "${couleurPourTitre}${taille}",
      if (motif.isNotEmpty && couleurPourTitre.isNotEmpty) "${motif}${couleurPourTitre}",
      if (motif.isNotEmpty && marque.isNotEmpty) "${motif}${marque}",
      "mode",
      "style",
      "vetement",
      "fashion",
      "tendance"
    ];

    String hashtagsString = hashtags
        .map((tag) => "#$tag") // Ajouter "#" au début de chaque élément
        .take(15)
        .join(" "); // Convertir la liste en une chaîne de texte

    descriptionParts.add("🔖 Hashtags : $hashtagsString");

    // Combiner les parties de la description
    _description = descriptionParts.join("\n");
  });
}


  Widget _couleurSelector() {
    List<String> couleurs = [
      "Noir",
      "Blanc",
      "Rouge",
      "Bleu",
      "Vert",
      "Jaune",
      "Gris",
      "Rose",
      "Violet",
      "Orange",
      "Marron",
      "Beige"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Couleur", style: TextStyle(fontSize: 16)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _couleurController,
                decoration: InputDecoration(
                  hintText: "Saisir une couleur",
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCouleur = couleurs.contains(value.trim()) ? value.trim() : "";
                  });
                },
              ),
            ),
            SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedCouleur.isEmpty ? null : _selectedCouleur,
              hint: Text("Suggestions"),
              onChanged: (String? newValue) {
  setState(() {
    if (newValue != null && couleurs.contains(newValue.trim())) {
      _selectedCouleur = newValue.trim(); // Assigne uniquement si valide
      _couleurController.text = _selectedCouleur; // Met à jour le champ texte
    } else {
      _selectedCouleur = ""; // Réinitialise si invalide
    }
  });
},

              items: couleurs.map<DropdownMenuItem<String>>((String value) {
  return DropdownMenuItem<String>(
    value: value.trim(), // Nettoie les espaces des valeurs
    child: Text(value.trim()),
  );
}).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tailleSelector() {
    List<String> tailles = ["XS", "S", "M", "L", "XL", "XXL", "3XL", "4XL"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Taille", style: TextStyle(fontSize: 16)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tailleController,
                decoration: InputDecoration(hintText: "Saisir une taille"),
              ),
            ),
            SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedTaille.isEmpty ? null : _selectedTaille,
              hint: Text("Suggestions"),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTaille = newValue ?? "";
                  _tailleController.text = _selectedTaille;
                });
              },
              items: tailles.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  void _reinitialiserChamps() {
    setState(() {
      _marqueController.clear();
      _tailleController.clear();
      _couleurController.clear();
      _motifController.clear();
      _defautController.clear();
      _selectedCouleur = "";
      _selectedTaille = "";
      _titre = "";
      _description = "";
    });
  }

  void _copierTexte(String texte) {
    Clipboard.setData(ClipboardData(text: texte));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Texte copié dans le presse-papiers !")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Générateur de Tee-Shirt"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _marqueController,
              decoration: InputDecoration(labelText: "Marque"),
            ),
            _tailleSelector(),
            _couleurSelector(),
            TextField(
              controller: _motifController,
              decoration: InputDecoration(labelText: "Motif"),
            ),
            Column(
  children: [
    Row(
      children: [
        Checkbox(
          value: _afficherMotifDansTitre,
          onChanged: (value) {
            setState(() {
              _afficherMotifDansTitre = value ?? true;
            });
          },
        ),
        Text("Inclure le motif dans le titre"),
      ],
    ),
    Row(
      children: [
        Checkbox(
          value: _afficherMotifDansDescription,
          onChanged: (value) {
            setState(() {
              _afficherMotifDansDescription = value ?? true;
            });
          },
        ),
        Text("Inclure le motif dans la description"),
      ],
    ),
  ],
),

            TextField(
              controller: _defautController,
              decoration: InputDecoration(labelText: "Défaut (optionnel)"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _genererDescription,
              child: Text("Générer"),
            ),
            ElevatedButton(
              onPressed: _reinitialiserChamps,
              child: Text("Réinitialiser"),
            ),
            SizedBox(height: 16),
            if (_titre.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Titre : $_titre",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: () => _copierTexte(_titre),
                    child: Text("Copier le titre"),
                  ),
                ],
              ),
            if (_description.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Description :\n$_description",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _copierTexte(_description),
                    child: Text("Copier la description"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
