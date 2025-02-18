import 'package:LoopStock/LotManagerApp.dart';
import 'package:LoopStock/SalesManager.dart';
import 'package:flutter/material.dart';
import 'Product_Description_Page.dart';
import 'Product2.dart';
import 'DatabaseService.dart';
import 'StockPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SettingsPage.dart';
import 'package:flutter/gestures.dart'; 
import 'Product_Description_Opti.dart';
import 'SubscriptionPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'PremiumAccountManager.dart';
import 'package:flutter/services.dart';
import 'SavedDescriptionsPage.dart';
import 'SalesManager.dart';
import 'ExpensesManagerApp.dart';
import 'expenses_manager.dart';
import 'ProfitAnalysisPage.dart';
void main() {
  
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp()
  
  
  );
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoopStock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.grey[800]),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String appVersion = "Version Beta 1.2";
  final String developerInfo = "Développé par Brunet.V";
  final PremiumAccountManager premiumAccountManager = PremiumAccountManager();
Map<String, List<Map<String, dynamic>>> sales = {};
Map<String, List<Map<String, dynamic>>> expenses = {};
List<String> closedMonths = [];
List<Map<String, dynamic>> lots = []; // ✅ Déclaration globale

String _deliveryTime = "24h-48h"; // Par défaut

  bool isPremium = false;
  double _monthlyExpenses = 0.0;

@override
void initState() {
  super.initState();
  _loadPremiumStatus(); // Vérifie si l'utilisateur est premium
  _calculateMonthlyExpenses(); // Calcul des dépenses mensuelles à l'initialisation
   _loadDeliveryTime();
   _loadSalesData();
  _loadExpensesData();
    _loadLots();
   
}

Future<void> _loadDeliveryTime() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _deliveryTime = prefs.getString('delivery_time') ?? "24h-48h";
  });
}
Future<void> _loadSalesData() async {
  final prefs = await SharedPreferences.getInstance();
  String? salesData = prefs.getString('sales_data');

  if (salesData != null) {
    sales = Map<String, List<Map<String, dynamic>>>.from(
      json.decode(salesData).map(
        (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
      ),
    );
  }
  setState(() {});
}

Future<void> _loadExpensesData() async {
  final prefs = await SharedPreferences.getInstance();
  String? expensesData = prefs.getString('expenses_data');

  if (expensesData != null) {
    expenses = Map<String, List<Map<String, dynamic>>>.from(
      json.decode(expensesData).map(
        (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
      ),
    );
  }
  setState(() {});
}

void _copyFavMessage() {
  String message =
      "Bonjour,\nJe vous ai fait une offre si vous le souhaitez.Les envois sont effectués sous $_deliveryTime maximum.\nN'hésitez pas à me contacter si vous avez la moindre question.\nBonne journée";
  Clipboard.setData(ClipboardData(text: message));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Message copié :\n$message',
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}


// Méthode pour charger l'état Premium
Future<void> _loadPremiumStatus() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    isPremium = prefs.getBool('isPremium') ?? false; // Chargement du statut Premium
  });
}
double _getTotalExpenses(String month) {
  return (expenses[month] ?? []).fold(0.0, (sum, expense) {
    return sum + ((expense['amount'] as double?) ?? 0.0);
  });
}

  // Affiche une alerte si l'utilisateur n'a pas l'abonnement premium
void _showPremiumAccessAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Accès réservé aux utilisateurs Premium"),
        content: const Text("Cette fonctionnalité est uniquement accessible aux utilisateurs Premium. Veuillez souscrire à un abonnement pour y accéder."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      );
    },
  );
}
Future<void> _loadLots() async {
  final prefs = await SharedPreferences.getInstance();
  String? lotsData = prefs.getString('lots_data');

  if (lotsData != null) {
    setState(() {
      lots = List<Map<String, dynamic>>.from(json.decode(lotsData));
    });
  }
}


  // Calcul des dépenses mensuelles
  Future<void> _calculateMonthlyExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    String? subscriptionsJson = prefs.getString('subscriptions');
    if (subscriptionsJson != null) {
      List<Map<String, dynamic>> subscriptions = List<Map<String, dynamic>>.from(jsonDecode(subscriptionsJson));
      double total = 0.0;
      for (var subscription in subscriptions) {
        if (subscription["active"] == true && subscription["selectedPrice"] != null) {
          total += subscription["selectedPrice"];
        }
      }
      setState(() {
        _monthlyExpenses = total;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LoopStock', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
                 IconButton(
            icon: const Icon(Icons.credit_card),
            onPressed: () {
              Navigator.push(
                 context,
                MaterialPageRoute(builder: (context) => SubscriptionPage()),
              );
            },
          ),
                    IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
                _copyFavMessage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                 context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              ).then((_) {
                // Après le retour de SettingsPage, on recharge l'état Premium
                 _loadDeliveryTime();
                _loadPremiumStatus();
              });
            },
          ),

        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 100, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                "Bienvenue dans l'application de gestion des reventes !",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Utilisez les outils disponibles pour gérer vos descriptions et votre stock.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
                          SizedBox(height: 20),
            // Affiche l'état Premium ici
            Text(
              isPremium ? 
              "Vous avez un abonnement Premium !" : 
              "Vous n'avez pas d'abonnement Premium.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPremium ? Colors.green : Colors.red),
            ),
              SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  children: [
                    TextSpan(text: "Un bug ? Une idée d'amélioration ? "),
                    TextSpan(
                      text: "Cliquez ici.",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _sendEmail();
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              _buildMonthlyExpensesCard(),
            ],
          ),
        ),
      ),
    );
  }
double _getTotalSales(String month) {
  // Remplace cette logique par la récupération réelle des ventes
  return 1000.0; // Exemple de total pour un mois
}

  Widget _buildMonthlyExpensesCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Relevé mensuel des dépenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Dépenses mensuelles actuelles :",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Text(
              "€${_monthlyExpenses.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'loopstockpro@gmail.com',
      query: 'subject=Feedback&body=Bonjour, voici mon retour :',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Impossible d'ouvrir l'application email."),
        ),
      );
    }
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "LoopStock",
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  appVersion,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  developerInfo,
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.description,
                  title: "Générateur de Description",
                  destination: ProductDescriptionPage(
                    onAddToStock: (Product2 product) => DatabaseService().saveProduct(product),
                  ),
                ),

_buildDrawerItem(
  context,
  icon: Icons.flash_on,
  title: "Générateur avancée",
  destination: ProductDescriptionOpti(), // La destination est toujours présente
  onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDescriptionOpti()), // Navigue vers la page Premium si l'utilisateur est Premium
      ); 
  },
),

_buildDrawerItem(
  context,
  icon: Icons.save,
  title: "Sauvegarde",
  destination: SavedDescriptionsPage(),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedDescriptionsPage()),
    );
  },
),
_buildDrawerItem(
  context,
  icon: Icons.bar_chart,
  title: "Gestion des lots",
  destination: LotManagerApp(), // ✅ Envoie les lots ici
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LotManagerApp(), // ✅ Passer la liste
      ),
    );
  },
),

_buildDrawerItem(
  context,
  icon: Icons.bar_chart,
  title: "Gestion des ventes",
  destination: SalesManagerApp(), // La destination est toujours présente
  onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SalesManagerApp()), // Navigue vers la page Premium si l'utilisateur est Premium
      ); 
  },
),          
_buildDrawerItem(
  context,
  icon: Icons.bar_chart,
  title: "Gestion des dépenses",
  destination: ExpensesManagerApp(), // La destination est toujours présente
  onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ExpensesManagerApp()), // Navigue vers la page Premium si l'utilisateur est Premium
      ); 
  },
),    
_buildDrawerItem(
  context,
  icon: Icons.bar_chart,
  title: "Rentabilité",
  destination: ProfitAnalysisPage(), // La destination est toujours présente
  onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfitAnalysisPage()), // Navigue vers la page Premium si l'utilisateur est Premium
      ); 
  },
),


  
              ],
            ),
          ),
          Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Merci d'utiliser cette application.\nVotre avis compte !",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

ListTile _buildDrawerItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  Widget? destination, // Paramètre optionnel
  void Function()? onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
    onTap: onTap ??
        () async {
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          }
        },
  );
}


  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("À propos de l'application"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Version : $appVersion",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                developerInfo,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Fermer"),
            ),
          ],
        );
      },
    );
  }
}
