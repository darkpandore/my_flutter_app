import 'package:flutter/material.dart';
import 'DatabaseService.dart';
import 'Product2.dart';
import 'ProductDetailsPage.dart';
import 'ProductAddForm.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'SettingsPage.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  late Future<List<Product2>> _productList;
  List<Product2> _filteredProducts = [];
  String _searchQuery = "";
  String _selectedStatus = "Tous";
List<String> platforms = [];
  bool _isProAccount = false; // Variable pour stocker l'état "Pro"
double _tvaPercentage = 0.0; // Taux de TVA
Map<String, Map<String, dynamic>> platformFees = {};

@override
void initState() {
  super.initState();
  _loadPreferences();
  _productList = Future.value([]); // Initialisation par défaut
  _refreshProducts();
  _loadPlatforms();
}


Future<void> _loadPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _isProAccount = prefs.getBool('is_vinted_pro') ?? false;
_tvaPercentage = prefs.getDouble('tvaPercentage') ?? 0.0;

  });
}


  

  void _refreshProducts() async {

    
    final products = await DatabaseService().loadProducts();

    // Trier les produits par statut
    products.sort((a, b) => _statusOrder(a.status).compareTo(_statusOrder(b.status)));

    setState(() {
      _productList = Future.value(products);
      _filteredProducts = products;
    });
  }

void _filterProducts(String query) {
  setState(() {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  });
}

void _applyFilters() async {
  final allProducts = await _productList;

  setState(() {
    _filteredProducts = allProducts
        .where((product) =>
            (_selectedStatus == "Tous" || product.status.toLowerCase() == _selectedStatus.toLowerCase()) &&
            (product.reference.toLowerCase().contains(_searchQuery) ||
             product.brand.toLowerCase().contains(_searchQuery) ||
             product.type.toLowerCase().contains(_searchQuery))) // Ajout du filtre sur marque et type
        .toList();
  });
}

  void _filterByStatus(String status) {
    setState(() {
      _selectedStatus = status;
      _applyFilters();
    });
  }

  int _statusOrder(String status) {
    switch (status.toLowerCase()) {
      case "non vendu":
        return 1;
      case "vendu":
        return 2;
      case "litige":
        return 3;
      case "vente validée":
        return 4;
      default:
        return 5;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "vendu":
        return Colors.green;
      case "litige":
        return Colors.orange;
      case "non vendu":
        return Colors.red;
      case "vente validée":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

Future<Map<String, dynamic>> _calculateSummary() async {
  final allProducts = await DatabaseService().loadProducts();

  double totalSpent = 0.0;
  double totalEstimatedProfit = 0.0;
  double totalSales = 0.0;
  double totalPurchaseForSales = 0.0;
  double totalProfit = 0.0;
  int totalSoldItems = 0;

  for (final product in allProducts) {
    totalSpent += product.purchasePrice;

    if ((product.status.toLowerCase() != "vente validée") &&
        product.estimatedSalePrice != null) {
      totalEstimatedProfit += (product.estimatedSalePrice! - product.purchasePrice);
    }

    if (product.status.toLowerCase() == "vente validée" && product.salePrice != null) {
      totalSales += product.salePrice!;
      totalPurchaseForSales += product.purchasePrice;
      totalSoldItems++;
    }
  }

  totalProfit = totalSales - totalPurchaseForSales;

  if (_isProAccount) {
    totalEstimatedProfit -= (totalEstimatedProfit * _tvaPercentage / 100);
    totalSales -= (totalSales * _tvaPercentage / 100);
    totalProfit -= (totalProfit * _tvaPercentage / 100);
  }

  return {
    "totalSpent": totalSpent,
    "totalEstimatedProfit": totalEstimatedProfit,
    "totalSales": totalSales,
    "generalProfit": totalProfit,
    "totalSoldItems": totalSoldItems,
    "totalProducts": allProducts.length,
  };
}




void _generateOfferMessage(BuildContext context, Product2 product) {
  final offerMessage = "Bonjour, je vous fais une offre pour mon article ${product.type} "
      "de la marque ${product.brand}. Si vous souhaitez";
  
  // Copier dans le presse-papiers
  Clipboard.setData(ClipboardData(text: offerMessage));

  // Afficher une notification
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Message généré et copié !"),
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: "Voir",
        onPressed: () {
          // Affiche une boîte de dialogue pour afficher le message
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Message d'offre"),
                content: Text(offerMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Fermer"),
                  ),
                ],
              );
            },
          );
        },
      ),
    ),
  );
}
Future<void> _deleteLastUnsoldProduct() async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Êtes-vous sûr de vouloir supprimer le dernier produit avec le statut 'Non vendu' ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    try {
      await DatabaseService().deleteLastProductByStatus("Non vendu");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le dernier produit 'Non vendu' a été supprimé.")),
      );
      _refreshProducts(); // Recharge les produits après suppression
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression : $error")),
      );
    }
  }
}


double calculateNetProfit(Product2 product) {
  if (product.platform == "Whatnot" && product.salePrice != null) {
    double feePercentage = 0.109; // 10,9 %
    double fixedFee = 0.30; // 0,30 €
    double saleFees = (product.salePrice! * feePercentage) + fixedFee;
    return product.salePrice! - saleFees - product.purchasePrice;
  }
  // Pas de frais sur Vinted
  if (product.salePrice != null) {
    return product.salePrice! - product.purchasePrice;
  }
  return 0.0;
}


Future<void> _loadPlatforms() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    platforms = prefs.getStringList('platforms') ?? ["Vinted", "Whatnot", "Brocante"];
    for (var platform in platforms) {
      double percentage = prefs.getDouble('fee_percentage_$platform') ?? 0.0;
      double fixedFee = prefs.getDouble('fee_fixed_$platform') ?? 0.0;
      platformFees[platform] = {
        "percentage": percentage,
        "fixedFee": fixedFee,
      };
    }
  });
}



 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Gestion du Stock"),
      centerTitle: true,
      actions: [
         IconButton(
    icon: const Icon(Icons.delete, color: Colors.red),
    onPressed: _deleteLastUnsoldProduct,
    tooltip: "Supprimer les produits 'Non vendu'",
  ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _refreshProducts,
        ),
      ],
    ),
    body: Column(
      children: [
        // Résumé en haut
       FutureBuilder<Map<String, dynamic>>(
  future: _calculateSummary(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (snapshot.hasError) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text("Erreur lors du calcul des données.")),
      );
    }

    final data = snapshot.data ?? {};
    final int totalProducts = _filteredProducts.length; // Nombre total de produits
    final int totalSoldItems = data['totalSoldItems'] ?? 0; // Nombre d'articles vendus

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
  children: [
    Text(
      "Résumé du Stock",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    if (_isProAccount) // Vérifie directement la variable chargée
      GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Information sur la TVA"),
              content: Text(
                  "Les prix affichés dans le résumé incluent la TVA configurée : $_tvaPercentage%."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fermer la boîte de dialogue
                  },
                  child: Text("OK"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fermer la boîte de dialogue
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(),
                      ),
                    );
                  },
                  child: Text("Modifier la TVA"),
                ),
              ],
            ),
          );
        },
        child: Icon(
          Icons.info_outline,
          color: Colors.blue,
          size: 20,
        ),
      ),
  ],
),

            SizedBox(height: 8),
            Text("💸 Prix dépensé : ${data['totalSpent']?.toStringAsFixed(2)} €"),
            Text("📈 Bénéfice estimé : ${data['totalEstimatedProfit']?.toStringAsFixed(2)} €"),
            Text("💵 Total ventes réalisées : ${data['totalSales']?.toStringAsFixed(2)} €"),
            Text("🧾 Bénéfice général : ${data['generalProfit']?.toStringAsFixed(2)} €"),
            Text("📊 Articles vendus : $totalSoldItems / $totalProducts"),
          ],
        ),
      ),
    );
  },
),




        // Barre de recherche
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Rechercher par référence, marque ou type...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: _filterProducts,
          ),
        ),

        // Menu déroulant pour filtrer par statut
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButton<String>(
            value: _selectedStatus,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _filterByStatus(newValue);
              }
            },
                items: ["Tous", "Non vendu", "Vendu", "Litige", "Vente validée", ...platforms]
        .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            isExpanded: true,
            underline: Container(height: 1, color: Colors.grey),
          ),
        ),

        // Liste des produits
        Expanded(
          child: FutureBuilder<List<Product2>>(
            future: _productList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Erreur : ${snapshot.error}"));
              }
              if (_filteredProducts.isEmpty) {
                return Center(child: Text("Aucun produit trouvé."));
              }

              return ListView.builder(
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
  leading: CircleAvatar(
    backgroundColor: Colors.blue.shade100,
    backgroundImage: (product.mainPhoto != null && File(product.mainPhoto!).existsSync())
        ? FileImage(File(product.mainPhoto!))
        : null,
    child: (product.mainPhoto == null || !File(product.mainPhoto!).existsSync())
        ? Text(product.type.isNotEmpty ? product.type[0].toUpperCase() : "?")
        : null,
  ),
title: Text(
  "${product.type} ${product.brand}",  // Affiche la saisie exacte sans modification
  style: TextStyle(fontWeight: FontWeight.bold),
),








subtitle: Text(
  "Réf : ${product.reference}\n"
  "${product.status.toLowerCase() == "vente validée" ? 
    (() {
      double salePrice = product.salePrice ?? 0.0;
      double purchasePrice = product.purchasePrice;
      double benefit = salePrice - purchasePrice;

      // Appliquer les frais pour Whatnot
      if (product.platform == "Whatnot") {
        double fees = (salePrice * 0.109) + 0.30; // 10.9% + 0.30€
        benefit -= fees; // Soustrait les frais du bénéfice
      }

      return "Bénéfice net : ${benefit.toStringAsFixed(2)} €";
    })()
    : (product.status.toLowerCase() == "vendu"
        ? "Prix vendu : ${product.salePrice?.toStringAsFixed(2) ?? "N/A"} €"
        : "Prix d'achat : ${product.purchasePrice.toStringAsFixed(2)} €")}\n"
  "Frais appliqués : ${(product.platform == "Whatnot" ? "10,9% + 0,30 €" : "Aucun")}\n"
  "Statut : ${product.status}",
  style: TextStyle(
    color: _getStatusColor(product.status),
  ),
),


  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(Icons.message, color: Colors.blue),
        onPressed: () => _generateOfferMessage(context, product),
      ),
      Icon(Icons.arrow_forward_ios, color: Colors.blue),
    ],
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(
          product: product,
          onUpdate: (updatedProduct) {
            if (updatedProduct != null) {
              DatabaseService().updateProduct(updatedProduct);
            }
            _refreshProducts();
          },
        ),
      ),
    );
  },
)

                  );
                },
              );
            },
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductAddForm(
              onAddToStock: (product) {
                _refreshProducts();
              },
            ),
          ),
        );
      },
      child: Icon(Icons.add),
    ),
  );
}

}
