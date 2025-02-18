import 'package:flutter/material.dart';
import 'DatabaseService.dart';
import 'Product2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product2 product;
  final Function onUpdate;

  const ProductDetailsPage({Key? key, required this.product, required this.onUpdate}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Product2 product;
Map<String, Map<String, double>> platformFees = {}; // Stocke les frais par plateforme

  @override
  void initState() {
    super.initState();
    product = widget.product;
    _loadPlatformFees(); 
  }
double _calculateNetProfit() {
  if (product.salePrice == null) return 0.0; // Si le prix de vente est null, retourne 0.0
  double salePrice = product.salePrice!;
  double purchasePrice = product.purchasePrice;

  // Appliquer les frais spécifiques à la plateforme
  if (platformFees.containsKey(product.platform)) {
    double percentageFee = platformFees[product.platform]?["percentage"] ?? 0.0;
    double fixedFee = platformFees[product.platform]?["fixedFee"] ?? 0.0;
    double totalFees = (salePrice * (percentageFee / 100)) + fixedFee;
    return salePrice - purchasePrice - totalFees;
  }

  // Si aucun frais spécifique n'est défini, retourne simplement la différence
  return salePrice - purchasePrice;
}



Future<void> _loadPlatformFees() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> platforms = prefs.getStringList('platforms') ?? ["Vinted", "Whatnot", "Brocante"];

  if (mounted) {
    setState(() {
      for (var platform in platforms) {
        double percentageFee = prefs.getDouble('fee_percentage_$platform') ?? 0.0;
        double fixedFee = prefs.getDouble('fee_fixed_$platform') ?? 0.0;
        platformFees[platform] = {
          "percentage": percentageFee,
          "fixedFee": fixedFee,
        };
      }
    });
  }
}

void _markAsSold() {
  showDialog(
    context: context,
    builder: (context) {
      final TextEditingController salePriceController = TextEditingController();
      return AlertDialog(
        title: Text("Prix de vente"),
        content: TextField(
          controller: salePriceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Entrez le prix de vente"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
TextButton(
  onPressed: () {
    final salePrice = double.tryParse(salePriceController.text);
    if (salePrice != null) {
      setState(() {
        product = product.copyWith(
          status: "Vendu",
          salePrice: salePrice,
          estimatedProfit: _calculateNetProfit(), // Applique les frais définis
        );
      });
      DatabaseService().updateProduct(product);
      widget.onUpdate(product);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Prix invalide, veuillez réessayer."),
      ));
    }
  },
  child: const Text("Valider"),
),

        ],
      );
    },
  );
}


void _handlePostSaleAction() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Vente validée ?"),
        content: Text("Confirmez-vous la validation de cette vente ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Ferme la boîte de dialogue
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le dialogue principal
              _handleReasonForInvalidSale(); // Ouvre le dialogue pour la raison
            },
            child: Text("Non"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                product = product.copyWith(
                  status: "Vente validée",
                );
              });
              DatabaseService().updateProduct(product);
              widget.onUpdate(product);
              Navigator.pop(context); // Ferme le dialogue principal
            },
            child: Text("Oui"),
          ),
        ],
      );
    },
  );
}


void _handleReasonForInvalidSale() {
  String selectedReason = "Litige"; // Par défaut, sélectionne Litige
  final TextEditingController reasonController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Raison de l'invalidation"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedReason,
              onChanged: (value) {
                setState(() {
                  selectedReason = value!;
                });
              },
              items: ["Litige", "Annulé", "Autre"].map((String reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              decoration: InputDecoration(labelText: "Raison"),
            ),
            if (selectedReason == "Litige" || selectedReason == "Autre")
              TextField(
                controller: reasonController,
                decoration: InputDecoration(labelText: "Expliquez pourquoi"),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Ferme la boîte de dialogue
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (selectedReason == "Litige") {
                  product = product.copyWith(
                    status: "Litige",
                    info: reasonController.text,
                  );
                } else if (selectedReason == "Autre") {
                  product = product.copyWith(
                    status: "Non vendu",
                    info: reasonController.text,
                  );
                } else if (selectedReason == "Annulé") {
                  product = product.copyWith(
                    status: "Non vendu",
                    info: "",
                  );
                }
              });
              DatabaseService().updateProduct(product);
              widget.onUpdate(product);
              Navigator.pop(context); // Ferme la boîte de dialogue
            },
            child: Text("Valider"),
          ),
        ],
      );
    },
  );
}


void _resetToUnsold() {
  setState(() {
    product = product.copyWith(
      status: "Non vendu",
      info: "", // Réinitialise l'information actuelle
      litigationHistory: [
        ...(product.litigationHistory ?? []), // Conserve l'historique existant
        if (product.info != null && product.info!.isNotEmpty) product.info!, // Ajoute l'information actuelle au litige
      ],
    );
  });
  DatabaseService().updateProduct(product);
  widget.onUpdate(product);
}


  void _deleteLitigationInfo() {
    setState(() {
      product = product.copyWith(info: "");
    });
    DatabaseService().updateProduct(product);
    widget.onUpdate(product);
  }

void _deleteProduct() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Êtes-vous sûr de vouloir supprimer ce produit ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme la boîte de dialogue sans rien faire
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme la boîte de dialogue
              DatabaseService().deleteProduct(product.id!); // Supprime le produit de la base de données
              widget.onUpdate(null); // Notifie l'écran parent de la suppression
              Navigator.pop(context); // Ferme l'écran des détails
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Produit supprimé avec succès.")),
              );
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
void _editProductDetails() {
  final TextEditingController purchasePriceController = TextEditingController(
    text: product.purchasePrice.toStringAsFixed(2),
  );
  final TextEditingController estimatedSalePriceController = TextEditingController(
    text: product.estimatedSalePrice?.toStringAsFixed(2) ?? '',
  );
  final TextEditingController annotationsController = TextEditingController(
    text: product.annotations ?? '',
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Modifier les détails du produit"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prix d'achat
              TextField(
                controller: purchasePriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Prix d'achat"),
              ),
              const SizedBox(height: 10),

              // Prix de revente estimé
              TextField(
                controller: estimatedSalePriceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Prix de revente estimé"),
              ),
              const SizedBox(height: 10),

              // Annotations
              TextField(
                controller: annotationsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Annotations",
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),

              // Ajout de photos
              ElevatedButton.icon(
                onPressed: () async {
                  // Logique pour sélectionner ou capturer une photo
                  final photoPath = await _pickPhoto();
if (photoPath != null) {
    _addPhotoToProduct(photoPath);
}

                },
                icon: const Icon(Icons.add_a_photo),
                label: const Text("Ajouter une photo"),
              ),
              const SizedBox(height: 10),

              // Afficher les photos existantes
if (product.photos != null && product.photos!.isNotEmpty)
    Wrap(
        spacing: 10,
        runSpacing: 10,
        children: product.photos!
            .map((photo) => GestureDetector(
                  onTap: () {
                      // Action pour voir ou supprimer une photo
                  },
                  child: Image.file(
                      File(photo),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                  ),
                ))
            .toList(),
    ),

            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Annuler
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              final newPurchasePrice = double.tryParse(purchasePriceController.text);
              final newEstimatedSalePrice = double.tryParse(estimatedSalePriceController.text);
              final newAnnotations = annotationsController.text;

              if (newPurchasePrice != null) {
                setState(() {
                  product = product.copyWith(
                    purchasePrice: newPurchasePrice,
                    estimatedSalePrice: newEstimatedSalePrice,
                    annotations: newAnnotations,
                  );
                });

                // Mise à jour dans la base de données
                DatabaseService().updateProduct(product);

                // Notification à l'écran parent
                widget.onUpdate(product);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Détails modifiés avec succès.")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Prix invalide, veuillez réessayer.")),
                );
              }

              Navigator.pop(context); // Ferme la boîte de dialogue
            },
            child: const Text("Valider"),
          ),
        ],
      );
    },
  );
}

Future<String?> _pickPhoto() async {
  final ImagePicker _picker = ImagePicker();
  String? selectedPhotoPath;

  // Afficher une boîte de dialogue pour choisir entre la galerie et l'appareil photo
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Ajouter une photo"),
        content: const Text("Sélectionnez une photo depuis la galerie ou prenez une photo."),
        actions: [
          TextButton(
            onPressed: () async {
              // Choisir une photo depuis la galerie
              final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
              if (photo != null) {
                selectedPhotoPath = await _savePhotoToAppDirectory(photo);
              }
              Navigator.pop(context);
            },
            child: const Text("Galerie"),
          ),
          TextButton(
            onPressed: () async {
              // Prendre une photo avec l'appareil photo
              final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
              if (photo != null) {
                selectedPhotoPath = await _savePhotoToAppDirectory(photo);
              }
              Navigator.pop(context);
            },
            child: const Text("Appareil photo"),
          ),
        ],
      );
    },
  );

  return selectedPhotoPath; // Retourne le chemin de la photo ou null si aucune photo n'a été sélectionnée
}
void _addPhotoToProduct(String photoPath) async {
  await DatabaseService().addPhoto(product.id!, photoPath);

  // Mettez à jour l'état local avec la nouvelle liste de photos
setState(() {
  if (!product.photos!.contains(photoPath)) {
    product = product.copyWith(
      photos: [...?product.photos, photoPath],
    );
  }
});


  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Photo ajoutée : $photoPath")),
  );
}

Future<String> _savePhotoToAppDirectory(XFile photo) async {
  final Directory appDir = await getApplicationDocumentsDirectory();
  final String photoPath = '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${photo.name}';

  // Sauvegarder la photo dans le répertoire de l'application
  final File photoFile = File(photoPath);
  await photoFile.writeAsBytes(await photo.readAsBytes());

  return photoFile.path;
}

void _confirmDeletePhoto(String photo) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Supprimer la photo"),
        content: const Text("Êtes-vous sûr de vouloir supprimer cette photo ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Annuler
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Ferme la boîte de dialogue
              await _deletePhoto(photo); // Supprime la photo
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
Future<void> _deletePhoto(String photo) async {
  // Supprime la photo du stockage local
  final file = File(photo);
  if (await file.exists()) {
    await file.delete();
  }

  // Supprime la photo de la liste et de la base de données
  setState(() {
    product = product.copyWith(
      photos: product.photos!..remove(photo),
    );
  });

  await DatabaseService().updateProduct(product);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Photo supprimée avec succès.")),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Détails du produit"),
      centerTitle: true,
      backgroundColor: Colors.teal,
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des photos
// Section des photos avec option de suppression
// Afficher les photos existantes avec une option pour définir la photo principale
if (product.photos != null && product.photos!.isNotEmpty) ...[
  const Text(
    "Photos du produit",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 10),
  Wrap(
    spacing: 10,
    runSpacing: 10,
    children: product.photos!
        .map((photo) => Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text("Photo"),
                          ),
                          body: Center(
                            child: Image.file(File(photo)),
                          ),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(photo),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Bouton pour définir comme photo principale
                Positioned(
                  top: 5,
                  left: 5,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        product = product.copyWith(mainPhoto: photo);
                      });
                      DatabaseService().updateProduct(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Photo principale définie avec succès.")),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // Bouton pour supprimer une photo
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      _confirmDeletePhoto(photo);
                    },
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ))
        .toList(),
  ),
    const SizedBox(height: 20),
],



            // Informations principales
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${product.brand} - ${product.type}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Prix d'achat : ${product.purchasePrice.toStringAsFixed(2)} €",
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Text(
                      "Référence : ${product.reference}",
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
Text(
              "Plateforme : ${product.platform}",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),

                    const SizedBox(height: 10),

                    // Prix de vente estimé (affiché uniquement si renseigné)
                    if (product.estimatedSalePrice != null) ...[
  Text(
    "Prix de vente estimé : ${product.estimatedSalePrice!.toStringAsFixed(2)} €",
    style: const TextStyle(fontSize: 16, color: Colors.black54),
  ),
  const SizedBox(height: 10),
  Text(
    "Bénéfice potentiel : ${(product.estimatedSalePrice! - product.purchasePrice).toStringAsFixed(2)} €",
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
  ),
],

                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statut et bénéfice
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: product.status == "Vente validée"
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Statut : ${product.status}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: product.status == "Vente validée"
                              ? Colors.green
                              : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (product.status == "Vendu" || product.status == "Vente validée")
Text(
  product.status == "Vente validée"
      ? "Bénéfice net : ${_calculateNetProfit().toStringAsFixed(2)} €"
      : "Bénéfice estimé : ${(product.salePrice ?? 0.0 - product.purchasePrice).toStringAsFixed(2)} €",
  style: const TextStyle(fontSize: 16, color: Colors.black87),
),



                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informations supplémentaires et litiges
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.info != null && product.info!.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Information : ${product.info}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _deleteLitigationInfo,
                          ),
                        ],
                      ),
                    if (product.litigationHistory != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Historique des litiges :",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (product.litigationHistory!.isNotEmpty)
                            ...product.litigationHistory!.map(
                              (litigation) => Text(
                                "- $litigation",
                                style: const TextStyle(fontSize: 14),
                              ),
                            )
                          else
                            const Text(
                              "Aucun litige enregistré.",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (product.status == "Non vendu")
                  ElevatedButton(
                    onPressed: _markAsSold,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Vendu"),
                  ),
                if (product.status == "Vendu")
                  ElevatedButton(
                    onPressed: _handlePostSaleAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Vente validée ?"),
                  ),
                if (product.status == "Litige")
                  ElevatedButton(
                    onPressed: _resetToUnsold,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Reçu ?"),
                  ),
                ElevatedButton(
                  onPressed: _deleteProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Supprimer"),
                ),
                ElevatedButton(
                  onPressed: _editProductDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Modifier"),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


}