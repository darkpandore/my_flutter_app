import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour accéder au presse-papiers
import 'package:share_plus/share_plus.dart';
import 'Product2.dart';
import 'ProductAddForm.dart';
import 'DatabaseService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ExpressDescriptionGenerator.dart';

class ProductDescriptionPage extends StatefulWidget {
  final Function(Product2) onAddToStock;
  const ProductDescriptionPage({super.key, required this.onAddToStock});

  @override
  _ProductDescriptionPageState createState() => _ProductDescriptionPageState();
}
List<String> hashtagsPlus = []; // Liste des hashtags+ chargés depuis les paramètres
bool includeHashtagsPlus = false; // Booléen pour la case à cocher
  bool isDiscountEnabled = false; // Pour activer ou désactiver la réduction
  double discountPercentage = 0.0; // Pourcentage de réduction pour abonnés
  
class _ProductDescriptionPageState extends State<ProductDescriptionPage> {
  // Liste des marques pour suggestions
final List<String> jeansSizes = [
  'W24 | FR34', 'W25 | FR34', 'W26 | FR36', 'W27 | FR36', 'W28 | FR38',
  'W29 | FR38', 'W30 | FR40', 'W31 | FR40', 'W32 | FR42', 'W33 | FR42',
  'W34 | FR44', 'W35 | FR44', 'W36 | FR46', 'W37 | FR46', 'W38 | FR48',
  'W39 | FR48', 'W40 | FR50', 'W41 | FR50', 'W42 | FR52', 'W43 | FR52',
  'W44 | FR54', 'W45 | FR54', 'W46 | FR56', 'W47 | FR56', 'W48 | FR58',
  'W49 | FR58', 'W50 | FR60', 'W51 | FR60', 'W52 | FR62', 'W53 | FR62',
  'W54 | FR64'
];
// Liste des tailles pour chaussures en FR
final List<String> shoeSizes = List.generate(43, (index) => (10 + index).toString());

  // Liste des tailles standard
  final List<String> adultSizes = ['XXS','XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'];
  final List<String> kidsSizes = List.generate(14, (index) => '${3 + index} ans'); // Tailles enfants : 3 ans à 16 ans
final List<String> colors = [
  'Noir', 'Blanc', 'Bleu', 'Rouge', 'Vert', 'Gris', 'Jaune', 'Rose', 'Orange',
  'Marron', 'Violet', 'Beige', 'Marine', 'Turquoise', 'Kaki', 'Bordeaux',
  'Fuchsia', 'Doré', 'Argenté', 'Cuivre', 'Émeraude', 'Menthe', 'Lavande',
  'Corail', 'Bleu ciel', 'Bleu marine', 'Anthracite', 'Ocre', 'Sable', 'Bleu jeans'
];


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

final List<String> jeansTypes = [
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
  'Chinos',
  'Cargo',
  'Pantalon cargo'
];

  // Liste des types pour suggestions
final List<String> types = [
  'Pull',
  'Jupe',
  'Chemise',
  'Bodie',
  'Tee-shirt',
  'Veste',
  'Pantalon',
  'Joggings',
  'Veste zippée',
  'Veste 1/4 zip',
  'Half zip',
  'Polo',
  'Polaire',
  'Sweat à capuche',
  'Pull col V',
  'Pull torsadé',
  'Pull col rond',
  'Tee-shirt manche longue',
  'Pull col roulé',
  'Manteau',
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
  'Chaussure'
];

List<String> get combinedTypes => [...types, ...jeansTypes];


String cleanForHashtag(String input) {
  final accentsMap = {
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ô': 'o',
    'ö': 'o',
    'î': 'i',
    'ï': 'i',
    'ç': 'c',
    "'": '',
    ' ': '',
    '&': '',
  };

  String result = input.toLowerCase();
  accentsMap.forEach((key, value) {
    result = result.replaceAll(key, value);
  });
  return result.replaceAll(RegExp(r'[^a-z0-9]'), ''); // Supprime tout sauf lettres et chiffres
}

  // Controllers
  final TextEditingController colorController = TextEditingController();
  final TextEditingController defaultController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
final TextEditingController infoController = TextEditingController();

String hashtagPrefix = 'Vinted'; // Par défaut

  
final TextEditingController purchasePriceController = TextEditingController();
  // Dropdown values
  String generatedTitle = '';

  String selectedBrand = '';
  String selectedType = '';
  String selectedSize = 'M'; // Valeur par défaut
  String selectedGender = 'Homme'; // Valeur par défaut
  String selectedCondition = 'Très bon état';

  // Checkbox states
  bool fastShipping = false;
  bool authentic = false;
  bool washedAndFolded = false;
  bool showOtherProducts = false;
  bool showHashtags = true;
bool get isJeansOrCargoSelected {
  return jeansTypes.contains(selectedType);
}
Future<void> _loadHashtagsPlus() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    hashtagsPlus = prefs.getStringList('hashtags') ?? []; // Charge la liste des hashtags+
  });
}


  // Generated description
  String generatedDescription = '';
List<DropdownMenuItem<String>> get jeansSizeDropdownItems {
  // Supprime les doublons pour éviter des valeurs identiques
  var uniqueJeansSizes = jeansSizes.toSet().toList();

  return uniqueJeansSizes
      .map((size) => DropdownMenuItem<String>(
            value: size,
            child: Text(size),
          ))
      .toList();
}


@override
void initState() {
  super.initState();
   _loadPreferences(); 
  _loadHashtagPrefix();
  _loadHashtagsPlus();
}
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDiscountEnabled = prefs.getBool('subscriber_discount_enabled') ?? false;
      discountPercentage = prefs.getDouble('subscriber_discount_percentage') ?? 5.0;
    });
  }
Future<void> _loadHashtagPrefix() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    hashtagPrefix = prefs.getString('hashtag_prefix') ?? 'Vinted';
  });
}
void generateTitle() {
  setState(() {
    generatedTitle =
        '${selectedBrand.isNotEmpty ? selectedBrand : "Produit"} - ${selectedType.isNotEmpty ? selectedType : "Type"} - $selectedSize - $selectedGender${colorController.text.isNotEmpty ? " - ${colorController.text}" : ""}';
  });
}



List<String> getSizes() {
  if (selectedType == 'Chaussure') {
    return shoeSizes; // Retourne les tailles pour chaussures
  } else if (selectedGender == 'Enfant') {
    return kidsSizes; // Retourne les tailles pour enfants
  } else if (jeansTypes.contains(selectedType)) { // Vérifie si le type est un jeans/cargo
    return jeansSizes; // Retourne les tailles pour jeans ou cargo
  } else {
    return adultSizes; // Retourne les tailles standards pour adultes
  }
}




Future<void> generateDescription() async {
  // Vérifie que les champs obligatoires sont remplis
if (selectedBrand.trim().isEmpty || selectedType.trim().isEmpty || selectedSize.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Veuillez remplir tous les champs obligatoires (Marque, Type, Taille)."),
    ),
  );
  return; // Arrête la génération si des champs sont vides
}


  String reference = '';
  if (selectedGender == 'Homme' || selectedGender == 'Femme' || selectedGender == 'Mixte') {
    if (numberController.text.isNotEmpty) {
      reference = "${selectedSize}${numberController.text}";
    }
  }

  // Vérifie si la référence existe déjà dans le stock
  if (reference.isNotEmpty) {
    final suggestion = await DatabaseService().checkReference(selectedSize, numberController.text);

    if (suggestion != null) {
      if (suggestion.startsWith("Attention")) {
        // Affiche un avertissement si la référence est déjà utilisée
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Attention"),
              content: Text(
                "$suggestion Voulez-vous tout de même continuer avec cette référence ?",
                style: TextStyle(color: Colors.orange),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // Refuser
                  child: const Text("Non"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true), // Accepter
                  child: const Text("Oui"),
                ),
              ],
            );
          },
        ) ?? false;

        if (!confirmed) {
          return; // Bloque la génération si non confirmé
        }
      } else {
        // Propose une nouvelle référence si elle est déjà utilisée
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Référence déjà utilisée. Essayez : $suggestion",
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
        return; // Bloque la génération
      }
    }
  }

  // Génère les dimensions si elles sont renseignées
  String dimensions = '';
  if ((selectedType == 'Jeans' || selectedType == 'Cargo') &&
      (widthController.text.isNotEmpty || lengthController.text.isNotEmpty)) {
    dimensions = '📏 **Dimensions** :';
    if (widthController.text.isNotEmpty) {
      dimensions += ' Largeur : ${widthController.text} cm';
    }
    if (lengthController.text.isNotEmpty) {
      dimensions += '${widthController.text.isNotEmpty ? ',' : ''} Longueur : ${lengthController.text} cm';
    }
    dimensions += '\n';
  }

  // Génère les défauts si applicable
  String defect = '';
  if (selectedCondition == 'Satisfaisant' || selectedCondition == 'Bon état') {
    defect = '⚠️ **Défaut** : ${defaultController.text}\n';
  }

  // Génère les cases à cocher
  String checkboxesText = '';
  if (fastShipping) checkboxesText += '🚚 Envoi rapide 24h à 48h (ouvrable)\n';
  if (authentic) checkboxesText += '✅ 100% authentique (étiquettes en photo)\n';
  if (washedAndFolded) checkboxesText += '🧼 Lavé et plié avant l’envoi\n';
    if (isDiscountEnabled) {
      checkboxesText += '🎉 ${discountPercentage.toStringAsFixed(1)}% de réduction pour les abonnés\n';
    }

  if (showOtherProducts) {
    String formattedSize = selectedSize;
    if (selectedGender == 'Enfant' && formattedSize.contains('ans')) {
      formattedSize = formattedSize.replaceAll(' ', '');
    }
    checkboxesText +=
        '✨ Cliquez sur le # ci-dessous pour voir d’autres articles à votre taille :\n'
        '#${hashtagPrefix}_${cleanForHashtag(formattedSize)}_${cleanForHashtag(selectedGender)}\n';
  }


String hashtags = '';
if (showHashtags) {
  hashtags = generateHashtags(); 
}


  // Génère les autres sections
  String materialText = materialController.text.isNotEmpty
      ? '🧵 ** Matière** : ${materialController.text}\n'
      : '';
  String infoText = infoController.text.isNotEmpty
      ? 'ℹ️ **Information** : ${infoController.text}\n'
      : '';
  String referenceText = '';
  if (reference.isNotEmpty) {
    referenceText = '🔖 **Référence produit** : $reference\n';
  }

  // Met à jour la description générée
  setState(() {
    generatedDescription = '''
🏷️ **Marque** : $selectedBrand
👕 **Type** : $selectedType
$materialText
$dimensions
👫 **Pour** : $selectedGender
📐 **Taille** : $selectedSize
${colorController.text.isNotEmpty ? '🎨 **Couleur** : ${colorController.text}\n' : ''}

🛠️ **État** : $selectedCondition
$infoText
$defect
$checkboxesText
💬 *N’hésitez pas à m’envoyer un message si vous avez une question !*

$hashtags

$referenceText
    ''';
  });
}

String capitalize(String input) {
  if (input.isEmpty) return '';
  return '${input[0].toUpperCase()}${input.substring(1).toLowerCase()}';
}


String generateHashtags() {
  // Liste pour stocker les hashtags dynamiquement
  List<String> hashtagsList = [];

  

  // Hashtags spécifiques à la marque
  if (selectedBrand.isNotEmpty) {
    hashtagsList.add('#${cleanForHashtag(selectedBrand)}'); // #marque
    if (selectedType.isNotEmpty) {
      hashtagsList.add('#${cleanForHashtag(selectedBrand)}${cleanForHashtag(selectedType)}'); // #marquetype
    }
    hashtagsList.add('#${cleanForHashtag(selectedBrand)}Original'); // #marqueOriginal
  }

  // Hashtags spécifiques au type de vêtement
  if (selectedType.isNotEmpty) {
    hashtagsList.add('#${cleanForHashtag(selectedType)}'); // #type
    hashtagsList.add('#Mode${capitalize(selectedType)}'); // Exemple : #ModeTeeShirt
    if (materialController.text.isNotEmpty) {
      hashtagsList.add('#${cleanForHashtag(selectedType)}${cleanForHashtag(materialController.text)}'); // #typematiere
    }
  }

  // Hashtags pour la taille
  if (selectedSize.isNotEmpty) {
    hashtagsList.add('#Taille${cleanForHashtag(selectedSize)}'); // #taille
    hashtagsList.add('#Taille${cleanForHashtag(selectedSize)}${capitalize(selectedType)}'); // Exemple : #MFit
  }

  // Hashtags pour le genre
  if (selectedGender.isNotEmpty) {
    hashtagsList.add('#Mode${capitalize(selectedType)}'); // #ModeHomme, #ModeFemme, etc.
  }

  // Hashtags pour la matière
  if (materialController.text.isNotEmpty) {
    hashtagsList.add('#${cleanForHashtag(materialController.text)}'); // #matiere
    hashtagsList.add('#${cleanForHashtag(materialController.text)}Style'); // Exemple : #CotonStyle
  }

  // Hashtags pour la couleur
  if (colorController.text.isNotEmpty) {
    hashtagsList.add('#${cleanForHashtag(colorController.text)}'); // #couleur
    hashtagsList.add('#${cleanForHashtag(colorController.text)}Look'); // Exemple : #NoirLook
  }

  // Ajout de hashtags populaires et génériques
  hashtagsList.addAll([
    '#Vetement',
    '#Fashion',
    '#StyleDuJour',
    '#OOTD', // "Outfit of the day"
    '#Mode', // Général pour attirer plus de recherches
    '#Tendance', // Produits tendances
    '#LookBook',
  ]);

  // Hashtags pour le type de style selon le produit
  if (['Tee-shirt', 'Sweatshirt', 'Jeans', 'Cargo', 'Veste'].contains(selectedType)) {
    hashtagsList.add('#Streetwear');
    hashtagsList.add('#CasualStyle');
  }
  if (['Robe', 'Blazer', 'Tailleur', 'Chemisier'].contains(selectedType)) {
    hashtagsList.add('#Élégance');
    hashtagsList.add('#ClassiqueChic');
  }

  // Ajout des hashtags+ si activé
  if (includeHashtagsPlus && hashtagsPlus.isNotEmpty) {
    hashtagsList.addAll(hashtagsPlus.map((tag) => '#${cleanForHashtag(tag)}'));
  }

  // Suppression des doublons et génération du texte final
  hashtagsList = hashtagsList.toSet().toList(); // Supprime les doublons
  return hashtagsList.join(' ').trim(); // Concatène les hashtags avec un espace
}




  // Réinitialiser tous les champs
  void resetFields() {
    selectedBrand = '';
    selectedType = '';
    colorController.clear();
    defaultController.clear();
    numberController.clear();
    lengthController.clear();
    widthController.clear();
    setState(() {
      selectedGender = 'Homme';
      selectedSize = getSizes().first; // Réinitialisation propre aux tailles valides

      selectedCondition = 'Très bon état';
      fastShipping = false;
      authentic = false;
      washedAndFolded = false;
      showOtherProducts = false;
      generatedDescription = '';
    });
  }

  // Copier la description générée dans le presse-papiers
  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: generatedDescription));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Description copiée dans le presse-papiers !'),
        duration: Duration(seconds: 2),
      ),
    );
  }
void copyTitleToClipboard() {
  Clipboard.setData(ClipboardData(text: generatedTitle));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Titre copié dans le presse-papiers !'),
      duration: Duration(seconds: 2),
    ),
  );
}


@override
Widget build(BuildContext context) {
 if (selectedGender == 'Enfant' && !kidsSizes.contains(selectedSize)) {
    selectedSize = kidsSizes.first; // Défaut à la première taille enfant si la taille actuelle est invalide
  }
if (selectedType == 'Jeans' && !jeansSizes.contains(selectedSize)) {
  selectedSize = jeansSizes.firstWhere((size) => size.isNotEmpty, orElse: () => jeansSizes.first);
} else if (selectedType == 'Chaussure' && !shoeSizes.contains(selectedSize)) {
  selectedSize = shoeSizes.firstWhere((size) => size.isNotEmpty, orElse: () => shoeSizes.first);
} else if (selectedGender == 'Enfant' && !kidsSizes.contains(selectedSize)) {
  selectedSize = kidsSizes.firstWhere((size) => size.isNotEmpty, orElse: () => kidsSizes.first);
}



  return Scaffold(
appBar: AppBar(
  title: Text('Générateur de Description'),
  centerTitle: true,
  actions: [
    IconButton(
      icon: Icon(Icons.tune), // Icône pour accéder à la page d'optimisation
      tooltip: 'Page d\'optimisation',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpressDescriptionGenerator(),
          ),
        );
      },
    ),
  ],
),

    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Marque (avec suggestions)
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return brands.where((brand) => brand
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (String selection) {
              setState(() {
                selectedBrand = selection;
              });
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(labelText: 'Marque*'),
                onEditingComplete: onEditingComplete,
                onChanged: (text) {
                  setState(() {
                    selectedBrand = text; // Prendre la valeur manuelle
                  });
                },
              );
            },
          ),

          SizedBox(height: 10),

Autocomplete<String>(
  optionsBuilder: (TextEditingValue textEditingValue) {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<String>.empty();
    }
    return combinedTypes.where((type) =>
        type.toLowerCase().contains(textEditingValue.text.toLowerCase()));
  },
  onSelected: (String selection) {
    setState(() {
      selectedType = selection; // Sélection via suggestion
      // Ajustement de la taille en fonction du type sélectionné
      if (jeansTypes.contains(selectedType)) {
        selectedSize = jeansSizes.first;
      } else if (selectedType == 'Chaussure') {
        selectedSize = shoeSizes.first;
      } else {
        selectedSize = getSizes().first;
      }
    });
  },
  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: const InputDecoration(labelText: 'Type*'),
      onEditingComplete: () {
        
        String manualInput = controller.text.trim(); // Récupération de l'entrée manuelle
        setState(() {
          // Prendre la saisie manuelle même si elle ne figure pas dans la liste
          if (manualInput.isNotEmpty) {
            selectedType = manualInput;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Veuillez entrer un type valide.")),
            );
            return; // Bloque si l'utilisateur n'a pas saisi un type valide
          }

          // Ajustement de la taille selon le type
          if (jeansTypes.contains(selectedType)) {
            selectedSize = jeansSizes.first;
          } else if (selectedType == 'Chaussure') {
            selectedSize = shoeSizes.first;
          } else {
            selectedSize = getSizes().first;
          }
        });
        focusNode.unfocus(); // Retirer le focus après validation
        onEditingComplete(); // Appelle la fonction de validation
      },
        onChanged: (text) {
                  setState(() {
                    selectedType = text; // Prendre la valeur manuelle
                  });
                },
    );
  },
),
                  SizedBox(height: 10),
DropdownButtonFormField(
  value: selectedGender,
  items: ['Homme', 'Femme', 'Mixte', 'Enfant']
      .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
      .toList(),
  onChanged: (value) {
    if (value != null) {
      setState(() {
        selectedGender = value;
       // Vérification avant d'afficher la taille
if (!getSizes().contains(selectedSize)) {
  selectedSize = getSizes().first; // Prend la première taille valide si la taille actuelle n'est pas valide
}

      });
    }
  },
),

SizedBox(height: 10),

// Sinon, affiche les tailles standards ou autres
DropdownButtonFormField<String>(
  value: getSizes().isNotEmpty ? selectedSize : null, // Assure que la taille n'est pas null
  items: getSizes().map((size) => DropdownMenuItem(value: size, child: Text(size))).toList(),
  onChanged: (value) {
    if (value != null) {
      setState(() {
        selectedSize = value;
      });
    }
  },
  decoration: InputDecoration(labelText: 'Taille*'),
),



          SizedBox(height: 10),

          // Dimensions (afficher uniquement si "Jeans" ou "Cargo" est sélectionné)
          if (isJeansOrCargoSelected) 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: widthController,
                  decoration: InputDecoration(labelText: 'Largeur (cm)'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: lengthController,
                  decoration: InputDecoration(labelText: 'Longueur (cm)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          SizedBox(height: 10),


          // Couleur
          Autocomplete<String>(
  optionsBuilder: (TextEditingValue textEditingValue) {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<String>.empty();
    }
    return colors.where((color) => color.toLowerCase().contains(textEditingValue.text.toLowerCase()));
  },
  onSelected: (String selection) {
    setState(() {
      colorController.text = selection;
    });
  },
  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: const InputDecoration(labelText: 'Couleur'),
      onChanged: (value) {
        setState(() {
          colorController.text = value; // Permet aussi la saisie manuelle
        });
      },
    );
  },
),

          SizedBox(height: 10),
// Matière
TextField(
  controller: materialController,
  decoration: InputDecoration(
    labelText: 'Matière',
  ),
),
SizedBox(height: 10),

// Information
TextField(
  controller: infoController,
  decoration: InputDecoration(
    labelText: 'Information',
  ),
),
SizedBox(height: 10),

          // État
          DropdownButtonFormField(
            value: selectedCondition,
            items: ['Satisfaisant', 'Bon état', 'Très bon état', 'Neuf sans étiquette', 'Neuf avec étiquette']
                .map((condition) => DropdownMenuItem(value: condition, child: Text(condition)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCondition = value as String;
              });
            },
            decoration: InputDecoration(labelText: 'État'),
          ),
          SizedBox(height: 10),


          // Défaut (si applicable)
          if (selectedCondition == 'Satisfaisant' || selectedCondition == 'Bon état') ...[
            TextField(
              controller: defaultController,
              decoration: InputDecoration(labelText: 'Défaut'),
            ),
            SizedBox(height: 10),
          ],

          // Référence produit (numéro)
TextFormField(
  controller: numberController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(labelText: "Numéro (pour référence produit)"),
  onChanged: (value) async {
    final suggestion = await DatabaseService().checkReference(selectedSize, value);
    if (suggestion != null) {
      if (suggestion.startsWith("La référence")) {
        // Avertissement pour une référence déjà utilisée avec statut "Vente terminée"
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$suggestion Voulez-vous tout de même continuer ?",
              style: TextStyle(color: Colors.orange),
            ),
          ),
        );
      } else {
        // Suggérer une nouvelle référence si elle est utilisée dans un autre statut
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Référence déjà utilisée. Essayez : $suggestion",
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
        setState(() {
          // Ne modifie pas la saisie de l'utilisateur
          numberController.text = value; 
        });
      }
    }
  },
),


          SizedBox(height: 10),
          TextField(
            controller: purchasePriceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Prix d\'achat',
              hintText: 'Entrez le prix d\'achat du produit',
            ),
          ),    
          SizedBox(height: 10),

          // Cases à cocher
          CheckboxListTile(
            value: fastShipping,
            onChanged: (value) {
              setState(() {
                fastShipping = value!;
              });
            },
            title: Text('Envoi rapide 24h à 48h (ouvrable)'),
          ),
          CheckboxListTile(
            value: authentic,
            onChanged: (value) {
              setState(() {
                authentic = value!;
              });
            },
            title: Text('100% authentique (étiquettes en photo)'),
          ),
          CheckboxListTile(
            value: washedAndFolded,
            onChanged: (value) {
              setState(() {
                washedAndFolded = value!;
              });
            },
            title: Text('Lavé et plié avant l’envoi'),
          ),
CheckboxListTile(
  value: isDiscountEnabled,
  onChanged: (value) {
    setState(() {
      isDiscountEnabled = value!;
    });
  },
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('Réduction pour abonnés'),
      if (isDiscountEnabled)
        Text(
          '${discountPercentage.toStringAsFixed(1)}%',
          style: TextStyle(color: Colors.blue),
        ),
    ],
  ),
),


          CheckboxListTile(
            value: showOtherProducts,
            onChanged: (value) {
              setState(() {
                showOtherProducts = value!;
              });
            },
            title: Text('Afficher mes autres produits correspondants'),
          ),
if (hashtagsPlus.isNotEmpty)
  CheckboxListTile(
    value: includeHashtagsPlus,
    onChanged: (value) {
      setState(() {
        includeHashtagsPlus = value!;
      });
    },
    title: const Text('Inclure Hashtags+'),
  ),


          CheckboxListTile(
  value: showHashtags,
  onChanged: (value) {
    setState(() {
      showHashtags = value!;
    });
  },
  title: Text('Afficher les hashtags'),
),
if (showHashtags)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aperçu des hashtags :',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            generateHashtags(), // Fonction qui génère les hashtags
            style: TextStyle(color: Colors.black87),
          ),
        ),
      ],
    ),
  ),

          SizedBox(height: 20),

          // Bouton pour générer la description
          ElevatedButton(
            onPressed: () {
              generateTitle();
              generateDescription();
            },
            child: Text('Générer le titre et la description'),
          ),
          SizedBox(height: 20),
          if (generatedTitle.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Titre généré :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(generatedTitle),
                SizedBox(height: 20),
              ],
            ),

          SizedBox(height: 20),

          // Description générée
          if (generatedDescription.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description générée :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(generatedDescription),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: copyTitleToClipboard,
                  child: Text('Copier le titre'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: copyToClipboard,
                  child: Text('Copier la description'),
                ),
                SizedBox(height: 20),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductAddForm(
          onAddToStock: widget.onAddToStock,
          initialData: Product2(
            title: generatedTitle,
            brand: selectedBrand, // Assure que la marque est bien transmise
            type: selectedType, // Assure que le type est bien transmis
            color: colorController.text,
            reference: numberController.text.isNotEmpty ? numberController.text : '000', // Récupère uniquement le numéro de référence sans taille
            description: generatedDescription,
            purchasePrice: double.tryParse(purchasePriceController.text) ?? 0.0,
            size: selectedSize,
            material: materialController.text,
            info: infoController.text,
            status: "Non vendu",
            platform: "Vinted",
          ),
          
        ),
      ),
    );
  },
  child: Text('Importer au stock'),
),


                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: resetFields,
                  child: Text('Réinitialiser'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Share.share(generatedDescription, subject: 'Description produit');
                  },
                  child: Text('Partager'),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

 
}