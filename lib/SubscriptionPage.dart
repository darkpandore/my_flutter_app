import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // Pour encoder/décoder les listes en JSON

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final TextEditingController _subscriptionNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  Map<String, TextEditingController> boostControllers = {}; // Contrôleurs pour chaque abonnement boost.

  // Liste des abonnements par défaut
  List<Map<String, dynamic>> subscriptions = [
    {
      "name": "Clemz",
      "prices": [8.99, 14.99, 24.99, 49.99],
      "description": "Réupload produit Vinted",
      "url": "https://www.clemz.app/",
      "active": false,
      "selectedPrice": null,
      "isBoost": false,
    },
    {
      "name": "Vintexapp",
      "prices": [0.00],
      "description": "Réupload produit Vinted gratuitement.",
      "url": "https://www.vintex.app/fr",
      "active": false,
      "selectedPrice": null,
      "isBoost": false,
    },
    {
      "name": "Le Troc Futé",
      "prices": [19.99],
      "description": "Bot Discord et réupload produit Vinted.",
      "url": "https://app.letrocfute.com/login",
      "active": false,
      "selectedPrice": null,
      "isBoost": false,
    },
    {
      "name": "V-Tools",
      "prices": [29.99, 79.99, 149.99],
      "description": "Le meilleur bot Discord avec 0 délai.",
      "url": "https://v-tools.com",
      "active": false,
      "selectedPrice": null,
      "isBoost": false,
    },
    {
      "name": "Boost Dressing Vinted",
      "prices": [],
      "description": "Boostez votre dressing pendant 7 jours.",
      "url": "https://www.vinted.fr",
      "active": false,
      "selectedPrice": null,
      "isBoost": true, // Indicateur pour savoir si c'est le boost
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadSubscriptions(); // Charger les abonnements sauvegardés
    for (var subscription in subscriptions) {
      if (subscription["isBoost"]) {
        boostControllers[subscription["name"]] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in boostControllers.values) {
      controller.dispose(); // Libérer les contrôleurs
    }
    _subscriptionNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Ajouter un abonnement personnalisé
  void _addSubscription() {
    String name = _subscriptionNameController.text.trim();
    double? price = double.tryParse(_priceController.text.trim());

    if (name.isNotEmpty && price != null) {
      setState(() {
        subscriptions.add({
          "name": name,
          "prices": [price],
          "description": "Abonnement personnalisé ajouté par l'utilisateur.",
          "url": "https://exemple.com",
          "active": false,
          "selectedPrice": null,
          "isBoost": false,
        });
        _subscriptionNameController.clear();
        _priceController.clear();
        _saveSubscriptions(); // Sauvegarder après ajout
      });
    }
  }

  // Afficher les détails de l'abonnement avec le lien vers le site
  void _showSubscriptionDetails(Map<String, dynamic> subscription) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Détails de l'abonnement ${subscription['name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subscription["description"]),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse(subscription["url"]);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Impossible d\'ouvrir le lien.')),
                    );
                  }
                },
                child: const Text(
                  "Visiter le site",
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  // Calcul du total des dépenses mensuelles
  double _calculateTotalExpenses() {
    double total = 0.0;
    for (var subscription in subscriptions) {
      if (subscription["active"] && subscription["selectedPrice"] != null) {
        total += subscription["selectedPrice"];
      }
    }
    return total;
  }

  // Sauvegarder les abonnements activés et prix choisis
  Future<void> _saveSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    String subscriptionsJson = jsonEncode(subscriptions);
    await prefs.setString('subscriptions', subscriptionsJson);
  }

  // Charger les abonnements sauvegardés
  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    String? subscriptionsJson = prefs.getString('subscriptions');
    if (subscriptionsJson != null) {
      setState(() {
        subscriptions = List<Map<String, dynamic>>.from(jsonDecode(subscriptionsJson));
        for (var subscription in subscriptions) {
          subscription["active"] = subscription["active"] ?? false;

          // Si c'est un abonnement boost, remplir le TextEditingController
          if (subscription["isBoost"] && subscription["selectedPrice"] != null) {
            boostControllers[subscription["name"]]?.text =
                ((subscription["selectedPrice"] / 30) * 7).toStringAsFixed(2); // Convertir sur 7 jours
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abonnements mensuels"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Ajouter un abonnement",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _subscriptionNameController,
              decoration: const InputDecoration(labelText: "Nom de l'abonnement"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: "Prix en €"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addSubscription,
              child: const Text("Ajouter"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = subscriptions[index];
                  return Card(
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(subscription["name"]),
                          Switch(
                            value: subscription["active"] ?? false,
                            onChanged: (value) {
                              setState(() {
                                subscription["active"] = value;
                                if (!value) {
                                  subscription["selectedPrice"] = null;
                                  boostControllers[subscription["name"]]?.clear();
                                }
                                _saveSubscriptions();
                              });
                            },
                          ),
                        ],
                      ),
                      subtitle: subscription["active"]
                          ? subscription["isBoost"]
                              ? TextField(
                                  controller: boostControllers[subscription["name"]],
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: "Prix du boost sur 7 jours (€)",
                                  ),
                                  onChanged: (value) {
                                    double? boostPrice = double.tryParse(value);
                                    if (boostPrice != null) {
                                      setState(() {
                                        subscription["selectedPrice"] = (boostPrice / 7) * 30;
                                      });
                                      _saveSubscriptions();
                                    }
                                  },
                                )
                              : DropdownButton<double>(
                                  value: subscription["selectedPrice"],
                                  hint: const Text("Choisissez votre tarif"),
                                  items: subscription["prices"]
                                      .map<DropdownMenuItem<double>>(
                                        (price) => DropdownMenuItem<double>(
                                          value: price,
                                          child: Text("€${price.toStringAsFixed(2)}"),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      subscription["selectedPrice"] = value;
                                      _saveSubscriptions();
                                    });
                                  },
                                )
                          : Text("Prix disponibles : ${subscription["prices"].map((e) => "€$e").join(", ")}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.blue),
                        onPressed: () => _showSubscriptionDetails(subscription),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Total des dépenses mensuelles : €${_calculateTotalExpenses().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
