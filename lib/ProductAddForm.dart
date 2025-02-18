import 'package:flutter/material.dart';
import 'DatabaseService.dart';
import 'Product2.dart';
import 'FormConfigManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductAddForm extends StatefulWidget {
  final Function(Product2) onAddToStock;
  final Product2? initialData;

  const ProductAddForm({Key? key, required this.onAddToStock, this.initialData}) : super(key: key);

  @override
  _ProductAddFormState createState() => _ProductAddFormState();
}

class _ProductAddFormState extends State<ProductAddForm> {
  final _formKey = GlobalKey<FormState>();
    late FormConfigManager configManager;
  final TextEditingController brandController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController estimatedSalePriceController = TextEditingController();
  List<String> platforms = []; // Liste dynamique des plateformes
  String selectedPlatform = ""; // Plateforme sélectionnée

  bool _isAdding = false;

final List<String> brands = [
  // Mode et luxe
  'Tommy Hilfiger', 'Ralph Lauren', 'Lacoste', 'Columbia', 'The North Face', 'Patagonia', 'CP Company', 'Stone Island',
  'Burberry', 'Prada', 'Gucci', 'Versace', 'Balenciaga', 'Moncler', 'Canada Goose', 'Balmain', 'Off-White',
  'Louis Vuitton', 'Yves Saint Laurent', 'Givenchy', 'Alexander McQueen', 'Maison Margiela', 'Celine', 'Chanel',
  'Chloe', 'Fendi', 'Dior', 'Hermès', 'Valentino', 'Miu Miu', 'Salvatore Ferragamo', 'Bulgari', 'Cartier', 'Rolex',
  'Jean Patou', 'Lanvin', 'Thierry Mugler', 'Amiri', 'Brunello Cucinelli', 'Thom Browne', 'Ermenegildo Zegna',

  // Streetwear et casual
  'Nike', 'Adidas', 'Puma', 'Reebok', 'New Balance', 'Asics', 'Vans', 'Converse', 'Fila', 'Supreme', 'Bape',
  'Stüssy', 'Carhartt WIP', 'Dickies', 'Champion', 'Kappa', 'Umbro', 'Levi\'s', 'Wrangler', 'Lee', 'Dockers',
  'Abercrombie & Fitch', 'Hollister', 'GAP', 'Old Navy', 'American Eagle', 'Bershka', 'Pull & Bear', 'Zara',
  'H&M', 'Uniqlo', 'Massimo Dutti', 'Pimkie', 'C&A', 'Primark', 'Urban Outfitters', 'All Saints', 'Aigle',
  'Only', 'Scotch & Soda', 'Tom Tailor', 'Esprit', 'Pepe Jeans', 'Celio', 'Springfield', 'Jules', 'Mango',
  'Stradivarius', 'Reserved', 'Kiabi', 'Maison Kitsuné', 'Wrangler', 'Armani Exchange',

  // Sportswear et équipements
  'Under Armour', 'Mizuno', 'Salomon', 'Helly Hansen', 'Palladium', 'Timberland', 'Skechers', 'New Era', 'Oakley',
  'Burton', 'Mammut', 'Quiksilver', 'Billabong', 'Roxy', 'O\'Neill', 'Hoka', 'Decathlon', 'Lotto', 'Colmar',
  'Ellesse', 'Diadora', 'K-Swiss', 'The Hundreds', 'Rip Curl', 'DC Shoes', 'Element', 'Volcom',

  // Luxe alternatif et créateurs
  'Kenzo', 'Etro', 'Dsquared2', 'Loewe', 'Paul Smith', 'Ted Baker', 'Vivienne Westwood', 'Stella McCartney',
  'The Kooples', 'Sandro', 'Sézane', 'Reiss', 'Acne Studios', 'Jacquemus', 'Comme des Garçons', 'Rick Owens',
  'Zadig & Voltaire', 'Balibaris', 'A.P.C.', 'Isabel Marant', 'Saint James', 'Maison Martin Margiela', 'Eytys',

  // Chaussures et accessoires
  'Birkenstock', 'Dr. Martens', 'Clarks', 'UGG', 'Paraboot', 'Giuseppe Zanotti', 'Tod\'s', 'Bally', 'Louboutin',
  'Jimmy Choo', 'Manolo Blahnik', 'Valentino Garavani', 'Kickers', 'Camper', 'Veja', 'Tory Burch', 'L.L.Bean',
  'Timberland', 'Nike ACG', 'Merrell', 'Sebago', 'Mephisto', 'Santoni', 'Common Projects',

  // Montres et bijoux
  'Tissot', 'Omega', 'Tag Heuer', 'Longines', 'Patek Philippe', 'Chopard', 'Seiko', 'Casio', 'Swatch', 'Fossil',
  'Michael Kors', 'Emporio Armani', 'Daniel Wellington', 'Guess', 'Hamilton', 'Bell & Ross', 'Hublot', 'Panerai',
  'Breitling', 'Audemars Piguet', 'Franck Muller',

  // Fast fashion et prêt-à-porter
  'Boohoo', 'Shein', 'PrettyLittleThing', 'ASOS', 'Forever 21', 'Missguided', 'Nasty Gal', 'New Look',
  'Fashion Nova', 'In The Style', 'Primadonna', 'Bershka', 'Tally Weijl', 'Topshop', 'Dorothy Perkins', 'Sfera',

  // Vintage et rétro
  'Lee Cooper', 'Pierre Cardin', 'Jean Paul Gaultier', 'Issey Miyake', 'Yohji Yamamoto', 'Castelbajac',
  'Franklin & Marshall', 'Lacoste Live', 'Cacharel', 'Schott NYC', 'A.P.C.', 'Gosha Rubchinskiy','Quechua',

  // Accessoires
  'Ray-Ban', 'Persol', 'Victoria\'s Secret', 'Longchamp', 'Eastpak', 'Samsonite', 'Fjällräven', 'Herschel',
  'Michael Kors', 'Rimowa', 'Delsey', 'Antler', 'Bellroy', 'Sandqvist', 'Timbuk2', 'Osprey',

  // Maroquinerie
  'Coach', 'Marc Jacobs', 'Kate Spade', 'Furla', 'Tumi', 'Mulberry', 'Proenza Schouler', 'Berluti', 'Moynat',

  // Spécial luxe
  'Bottega Veneta', 'Loro Piana', 'Zegna', 'Brioni', 'Kiton', 'Canali', 'Corneliani', 'Lanvin', 'Schiaparelli',

  // Marque d'enfants
  'Petit Bateau', 'Catimini', 'Jacadi', 'Okaïdi', 'Tartine et Chocolat', 'Sergent Major', 'Bonpoint', 'Cyrillus',
  'Vertbaudet', 'DPAM (Du Pareil au Même)', 'Noukies', 'Tartine et Chocolat',

  // Haut de gamme scandinave
  'Ganni', 'Filippa K', 'Arket', 'COS', 'Weekday', 'Monki', 'Jack & Jones', 'Avirex', 'True Religion', 'Tiger of Sweden',
  'Selected', 'Norwegian Rain', 'Our Legacy', 'Eton', 'J.Lindeberg', 'Rains',

  // Autres incontournables
  'Diesel', 'Superdry', 'Gant', 'Fred Perry', 'Barbour', 'Strellson', 'Napapijri', 'Officine Générale', 'Rivaldi',
  'Nascar', 'Hugo Boss', 'Ben Sherman', 'Hackett', 'Spagnolo', 'Sergio Tacchini', 'Massimo Osti', 'Fay'
];


  final List<String> types = [
      'Jeans',
  'Jeans slim',
  'Jeans skinny',
  'Jeans droit',
  'Jeans bootcut',
  'Jeans flare',
  'Jeans boyfriend',
  'Jeans mom',
  'Jeans regular',
  'Short',
  'Jeans tapered',
  'Jeans wide leg',
  'Cargo',
  'Pantalon cargo',
'Pull',
  'Jupe',
  'Chemise',
  'Tee-shirt',
  'Veste',
  'Veste zippée',
  'Veste 1/4 zip',
  'Half zip',
  'Polo',
  'Polaire',
  'Sweat à capuche',
  'Pull col V',
  'Pull col rond',
  'Tee-shirt manche longue',
  'Pull col roulé',
  'Manteau',
    'Pantalon',
  'Joggings',
  'Robe',
  'Salopette',
  'Gilet',
  'Cardigan',
  'Blouson',
  'Parka',
  'Bermuda',
  'Kimono',
  'Tunique',
  'Tailleur',
  'Chemisier',
  'Sweatshirt',
  'Legging',
  'Jupe-culotte',
  'Sous-vêtement',
  'Pyjama',
  'Manteau d\'hiver',
  'Manteau en laine',
  'Poncho',
  'Chandail',
    'Chaussure',
  'Pantalon'
  ];

@override
void initState() {
  super.initState();
  configManager = FormConfigManager();
  configManager.loadDefaults(); // Appel de la méthode publique pour charger les configurations.
  _loadPlatforms();
   _initializeConfig();
  if (widget.initialData != null) {
    _loadInitialData(widget.initialData!);
  }
}
Future<void> _initializeConfig() async {
  configManager = FormConfigManager();
  await configManager.loadDefaults(); // Attente du chargement complet
  await _loadPlatforms(); // Attente du chargement des plateformes
  if (widget.initialData != null) {
    _loadInitialData(widget.initialData!);
  }
  setState(() {}); // Rafraîchir l'interface après chargement des données
}
  Future<void> _loadPlatforms() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      platforms = prefs.getStringList('platforms') ?? ["Vinted", "Whatnot", "Brocante"];
      selectedPlatform = platforms.first; // Par défaut, sélectionner la première plateforme
    });
  }
  void _loadInitialData(Product2 initialData) {
    brandController.text = initialData.brand;
    typeController.text = initialData.type;
    sizeController.text = initialData.size;
    priceController.text = initialData.purchasePrice.toStringAsFixed(2);
    referenceController.text = initialData.reference;
    estimatedSalePriceController.text =
        initialData.estimatedSalePrice?.toStringAsFixed(2) ?? '';
  }

  String _generateProductReference(String baseReference) {
    return baseReference.padLeft(3, '0');
  }
  Widget _buildPlatformDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedPlatform.isNotEmpty ? selectedPlatform : null,
      decoration: const InputDecoration(labelText: 'Plateforme de vente*'),
      items: platforms.map((platform) {
        return DropdownMenuItem<String>(
          value: platform,
          child: Text(platform),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedPlatform = newValue!;
        });
      },
      validator: (value) => value == null ? "Sélectionnez une plateforme" : null,
    );
  }

Future<void> _addProduct() async {
  if (!_formKey.currentState!.validate() || _isAdding) return;

  setState(() {
    _isAdding = true;
  });

  try {
    final String baseReference =
        referenceController.text.isNotEmpty ? referenceController.text : '000';
    final reference = "${sizeController.text}${_generateProductReference(baseReference)}";

    final suggestion = await DatabaseService().checkReference(sizeController.text, baseReference);

    if (suggestion != null) {
      final confirmed = await _showReferenceConflictDialog(suggestion);
      if (!confirmed) {
        _suggestAlternativeReference(suggestion, baseReference);
        return;
      }
    }



final product = Product2(
  title: "${brandController.text.trim()} ${typeController.text.trim()}", // Utilisation directe de la saisie
  brand: brandController.text.trim(),
  type: typeController.text.trim(),
  color: "",
  reference: reference,
  description: "",
  purchasePrice: double.tryParse(priceController.text) ?? 0.0,
  size: sizeController.text.trim(),
  material: "",
  info: "",
  status: "Non vendu",
  estimatedSalePrice: double.tryParse(estimatedSalePriceController.text),
  platform: selectedPlatform,
);

print("Produit ajouté : ${product.toMap()}"); // Log pour vérifier les champs ajoutés



    await DatabaseService().saveProduct(product);
    widget.onAddToStock(product);

    _resetForm();
    Navigator.pop(context);
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur lors de l'ajout : $error")),
    );
  } finally {
    setState(() {
      _isAdding = false;
    });
  }
}


  Future<bool> _showReferenceConflictDialog(String suggestion) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Attention"),
              content: Text(
                suggestion,
                style: const TextStyle(color: Colors.orange),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Non"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Oui"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _suggestAlternativeReference(String suggestion, String baseReference) {
    referenceController.text = suggestion.replaceFirst(sizeController.text, '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nouvelle référence suggérée : $suggestion")),
    );
    setState(() {
      _isAdding = false;
    });
  }

  void _resetForm() {
    brandController.clear();
    typeController.clear();
    sizeController.clear();
    priceController.clear();
    referenceController.clear();
    estimatedSalePriceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un produit")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildSuggestionField("Marque*", brandController, brands),
_buildSuggestionField("Type*", typeController, types),
              const SizedBox(height: 10),
              _buildTextField("Taille*", sizeController),
              const SizedBox(height: 10),
              _buildTextField("Référence*", referenceController),
              const SizedBox(height: 10),
              _buildTextField("Prix d'achat*", priceController, isNumeric: true),
              const SizedBox(height: 10),
              _buildTextField("Prix de revente estimé", estimatedSalePriceController, isNumeric: true),
                  const SizedBox(height: 10),
    _buildPlatformDropdown(),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _isAdding ? null : _addProduct,
                child: _isAdding
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Ajouter au stock"),
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildSuggestionField(String label, TextEditingController controller, List<String> suggestions) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        onChanged: (text) {
          setState(() {}); // Met à jour les suggestions
        },
        validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
      ),
      if (controller.text.isNotEmpty) // Affiche les suggestions uniquement si le champ n'est pas vide
        Container(
          constraints: BoxConstraints(maxHeight: 100),
          child: ListView(
            shrinkWrap: true,
            children: suggestions
                .where((suggestion) =>
                    suggestion.toLowerCase().contains(controller.text.toLowerCase()))
                .map((suggestion) => ListTile(
                      title: Text(suggestion),
                      onTap: () {
                        controller.text = suggestion;
                        setState(() {}); // Ferme la liste de suggestions après sélection
                      },
                    ))
                .toList(),
          ),
        ),
    ],
  );
}



  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? "Champ obligatoire" : null,
    );
  }
}
class FieldEditScreen extends StatefulWidget {
  final FormConfigManager configManager;

  const FieldEditScreen({Key? key, required this.configManager}) : super(key: key);

  @override
  _FieldEditScreenState createState() => _FieldEditScreenState();
}

class _FieldEditScreenState extends State<FieldEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier les champs")),
      body: ListView(
        children: widget.configManager.fields.map((field) {
          return ListTile(
            title: Text(field.label),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: field.isVisible,
                  onChanged: (value) {
                    setState(() {
                      field.isVisible = value;
                      widget.configManager.updateField(field);
                    });
                  },
                ),
                Checkbox(
                  value: field.isMandatory,
                  onChanged: field.label.contains("*")
                      ? null // Ne pas permettre de rendre obligatoire les champs fixes
                      : (value) {
                          setState(() {
                            field.isMandatory = value!;
                            widget.configManager.updateField(field);
                          });
                        },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
