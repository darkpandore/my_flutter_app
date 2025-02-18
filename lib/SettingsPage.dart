import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PremiumAccountManager.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
    
    final TextEditingController _prefixController = TextEditingController();
    final TextEditingController _vatController = TextEditingController();
    final TextEditingController _hashtagController = TextEditingController(); // Controller pour le hashtag
    final TextEditingController _platformController = TextEditingController(); // Controller pour la plateforme
    final TextEditingController _discountController = TextEditingController();
    Map<String, Map<String, dynamic>> platformFees = {}; // Frais par plateforme
    String selectedDeliveryTime = "24h-48h"; // Temps de livraison par défaut
    final List<String> deliveryOptions = ["24h", "24h-48h", "24h-72h", "48h", "48h-72h", "72h"];



  List<String> hashtags = []; // Liste pour stocker les hashtags
  List<String> platforms = ["Vinted", "Whatnot", "Brocante"]; // Plateformes par défaut

  bool isVintedPro = false;
final PremiumAccountManager premiumAccountManager = PremiumAccountManager();

  bool isPremium = false; // Déterminera si l'utilisateur est Premium
// Instance de la classe ProAccountManager
 

  bool subscriberDiscountEnabled = false;
  @override
  void initState() {
    super.initState();
    _loadSettings();
     _loadPremiumStatus();
    
  }
void _checkPremiumUser() async {
  String username = _prefixController.text.trim(); // Récupère le nom de compte entré
  bool isPremiumUser = premiumAccountManager.isPremiumUser(username); // Vérifie si c'est un utilisateur Premium

  // Sauvegarde dans SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isPremium', isPremiumUser); // Sauvegarde le statut Premium

  setState(() {
    isPremium = isPremiumUser; // Mets à jour le statut Premium dans l'interface
  });

  // Retour à la page d'accueil et mise à jour de l'état
  // L'état sera mis à jour automatiquement dans MyHomePage grâce à _loadPremiumStatus()
}




Future<void> _loadPremiumStatus() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    isPremium = prefs.getBool('isPremium') ?? false; // Chargement du statut Premium
  });
}


Future<void> _editPlatformFees(String platform) async {
 TextEditingController percentageController = TextEditingController(
  text: platformFees[platform]?['percentage']?.toString() ?? (platform == "Whatnot" ? "10.2" : "0.0"),
);
TextEditingController fixedFeeController = TextEditingController(
  text: platformFees[platform]?['fixedFee']?.toString() ?? (platform == "Whatnot" ? "0.30" : "0.0"),
);


  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Paramétrer les frais pour $platform"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: percentageController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Frais en % (ex : 10.9)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: fixedFeeController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Frais fixes en € (ex : 0.30)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                platformFees[platform] = {
                  "percentage": double.tryParse(percentageController.text) ?? 0.0,
                  "fixedFee": double.tryParse(fixedFeeController.text) ?? 0.0,
                };
              });
              Navigator.pop(context);
            },
            child: const Text("Valider"),
          ),
        ],
      );
    },
  );
}

Future<void> _loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _prefixController.text = prefs.getString('hashtag_prefix') ?? 'Vinted';
    isVintedPro = prefs.getBool('is_vinted_pro') ?? false;
    _vatController.text = prefs.getDouble('tvaPercentage')?.toString() ?? '';
    hashtags = prefs.getStringList('hashtags') ?? [];
    platforms = prefs.getStringList('platforms') ?? platforms;
    subscriberDiscountEnabled = prefs.getBool('subscriber_discount_enabled') ?? false;
    double discount = prefs.getDouble('subscriber_discount_percentage') ?? 5.0;
    _discountController.text = discount.toString(); // Préremplit le champ avec la valeur
  selectedDeliveryTime = prefs.getString('delivery_time') ?? "24h-48h";
    // Charger les frais pour les plateformes
    for (var platform in platforms) {
      double percentageFee = prefs.getDouble('fee_percentage_$platform') ?? 0.0;
      double fixedFee = prefs.getDouble('fee_fixed_$platform') ?? 0.0;

      if (platform == "Whatnot") {
        percentageFee = percentageFee == 0.0 ? 10.2 : percentageFee;
        fixedFee = fixedFee == 0.0 ? 0.30 : fixedFee;
      }

      platformFees[platform] = {
        "percentage": percentageFee,
        "fixedFee": fixedFee,
      };
    }
  });
}



  
  Widget _buildLabeledTextField({
  required String label,
  required String hint,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ],
  );
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

Future<void> _saveSettings() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('subscriber_discount_enabled', subscriberDiscountEnabled);
await prefs.setString('delivery_time', selectedDeliveryTime);


  if (subscriberDiscountEnabled) {
    await prefs.setDouble(
      'subscriber_discount_percentage',
      double.tryParse(_discountController.text) ?? 5.0,
    );
  } else {
    await prefs.remove('subscriber_discount_percentage'); // Supprime si désactivé
  }

  // Autres paramètres sauvegardés
  await prefs.setString('hashtag_prefix', _prefixController.text);
  await prefs.setBool('is_vinted_pro', isVintedPro);
  await prefs.setStringList('hashtags', hashtags);
  await prefs.setStringList('platforms', platforms);
  if (isVintedPro && _vatController.text.isNotEmpty) {
    await prefs.setDouble('tvaPercentage', double.parse(_vatController.text));
  } else {
    await prefs.remove('tvaPercentage');
  }

  for (var platform in platforms) {
    if (platformFees.containsKey(platform)) {
      await prefs.setDouble(
          'fee_percentage_$platform', platformFees[platform]?["percentage"] ?? 0.0);
      await prefs.setDouble(
          'fee_fixed_$platform', platformFees[platform]?["fixedFee"] ?? 0.0);
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Paramètres sauvegardés avec succès.')),
  );
}

 void _removePlatform(String platform) {
    setState(() {
      platforms.remove(platform);
    });
  }
Widget _buildPlatformChip(String platform) {
  return GestureDetector(
    onTap: () => _editPlatformFees(platform),
    child: Chip(
      label: Text(platform, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.orange.shade100,
      deleteIcon: const Icon(Icons.close, color: Colors.red),
      onDeleted: () => _removePlatform(platform),
    ),
  );
}

    void _addPlatform() {
    String input = _platformController.text.trim();
    if (input.isNotEmpty && !platforms.contains(input)) {
      setState(() {
        platforms.add(input);
        _platformController.clear(); // Vide le champ après ajout
      });
    }
  }
void _addHashtag() async {
  String input = _hashtagController.text.trim();
  if (input.isNotEmpty) {
    if (!input.startsWith("#")) {
      input = "#$input"; // Ajoute le "#" si ce n’est pas présent
    }
    input = input.replaceAll(RegExp(r"[^\w#]"), ""); // Supprime les caractères spéciaux

    if (!hashtags.contains(input)) {
      setState(() {
        hashtags.add(input);
        _hashtagController.clear();
      });

      // Sauvegarde dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('hashtags', hashtags);
    }
  }
}
 Widget _buildDeliveryTimeSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Temps de livraison"),
        DropdownButtonFormField<String>(
          value: selectedDeliveryTime,
          items: deliveryOptions.map((time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(time),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedDeliveryTime = value!;
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Choisissez un temps de livraison",
          ),
        ),
      ],
    );
  }

void _removeHashtag(String hashtag) {
    setState(() {
      hashtags.remove(hashtag); // Supprime le hashtag de la liste
    });
  }
  Widget _buildHashtagChip(String hashtag) {
    return Chip(
      label: Text(hashtag, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.teal.shade100,
      deleteIcon: const Icon(Icons.close, color: Colors.red),
      onDeleted: () => _removeHashtag(hashtag), // Supprime le hashtag lorsqu'on clique sur la croix
    );
  }
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Paramètres"),
      centerTitle: true,
      backgroundColor: Colors.teal,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre principal
          const Text(
            "Paramètres généraux",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Section 1 : Paramètres de compte Vinted
          _buildSectionTitle("Compte Vinted"),
          _buildLabeledTextField(
            label: "Nom de compte",
            hint: "Entrez votre nom de compte Vinted",
            controller: _prefixController,
          ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPremiumUser, // Vérifier si l'utilisateur est "Premium"
              child: const Text("Vérifier l'abonnement Premium"),
            ),
            const SizedBox(height: 20),
if (isPremium)
              const Text(
                "Vous avez accès aux fonctionnalités Premium.",
                style: TextStyle(fontSize: 18, color: Colors.green),
              )
            else
              const Text(
                "Vous n'avez pas d'abonnement Premium.",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
          // Section 2 : Activer le mode Pro
          _buildSectionTitle("Mode Pro"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Activer le mode Pro",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Switch(
  value: isVintedPro,
  onChanged: (value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_vinted_pro', value);

    setState(() {
      isVintedPro = value;
    });
  },
  activeColor: Colors.teal,
),

            ],
          ),
          if (isVintedPro)
            Column(
              children: [
                const SizedBox(height: 10),
                _buildLabeledTextField(
                  label: "Taux de TVA (%)",
                  hint: "Entrez le taux de TVA applicable",
                  controller: _vatController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
             const SizedBox(height: 16),
            _buildSectionTitle("Réduction pour abonnés"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Activer la réduction pour abonnés",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: subscriberDiscountEnabled,
                  onChanged: (value) {
                    setState(() {
                      subscriberDiscountEnabled = value;
                    });
                  },
                  activeColor: Colors.teal,
                ),
              ],
            ),
            if (subscriberDiscountEnabled)
              Column(
                children: [
                  const SizedBox(height: 10),
                  _buildLabeledTextField(
                    label: "Pourcentage de réduction (%)",
                    hint: "Entrez le pourcentage de réduction (par ex : 5)",
                    controller: _discountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
           const SizedBox(height: 30),

            // Section 3 : Hashtag+
            _buildSectionTitle("Hashtag+"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hashtagController,
                    decoration: const InputDecoration(
                      hintText: "Entrez un hashtag...",
                      prefixText: "#",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _addHashtag(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addHashtag,
                  child: const Text("Ajouter"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: hashtags.map((hashtag) => _buildHashtagChip(hashtag)).toList(),
            ),
 const SizedBox(height: 30),

            // Section 4 : Plateformes de revente
            _buildSectionTitle("Plateformes de revente"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _platformController,
                    decoration: const InputDecoration(
                      hintText: "Entrez une plateforme...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _addPlatform(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addPlatform,
                  child: const Text("Ajouter"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: platforms.map((platform) => _buildPlatformChip(platform)).toList(),
            ),
            const SizedBox(height: 16),
       SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section de temps de livraison
            _buildDeliveryTimeSetting(),
          ],
        ),
      ),
          // Bouton de sauvegarde
                  const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.save, size: 20),
              label: const Text(
                "Sauvegarder les paramètres",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
