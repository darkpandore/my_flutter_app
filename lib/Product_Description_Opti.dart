import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour accéder au presse-papiers
import 'TitleSettingsScreen.dart';
import 'dart:convert';
import 'TranslationService.dart';
import 'Brand.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProductDescriptionOpti extends StatefulWidget {
  const ProductDescriptionOpti({super.key});

  @override
  _ProductDescriptionOptiState createState() => _ProductDescriptionOptiState();
}
List<String> hashtagsPlus = []; // Liste des hashtags+ chargés depuis les paramètres
bool includeHashtagsPlus = false; // Booléen pour la case à cocher
  bool isDiscountEnabled = false; // Pour activer ou désactiver la réduction
  double discountPercentage = 0.0; // Pourcentage de réduction pour abonnés
  final TextEditingController colorController = TextEditingController();
final List<String> selectedColors = []; // Liste des couleurs sélectionnées
  bool includeMaterial = false;  // Pour activer/désactiver le champ "Matière"
  bool includeGender = false;    // Pour activer/désactiver le champ "Sexe"
  bool includeTagNumber = false; // Pour activer/désactiver le champ "Numéro d'étiquette"
bool includeYear  = false;
bool isDescriptionReady = false;

class _ProductDescriptionOptiState extends State<ProductDescriptionOpti> {
final List<String> conditions = [
  'Neuf',
  'Comme neuf',
  'Excellent état',
  'Très bon état',
  'Bon état',
  'Légèrement usé',
  'Usé',
  'Fortement usé',
  'Endommagé',
  'Très endommagé',
];

Map<String, List<String>> defectSuggestions = {
  // Jeans et pantalons
  'Jeans': ['Usure aux genoux', 'Coutures relâchées', 'Fermeture éclair difficile', 'Passants de ceinture abîmés', 'Tâche légère', 'Usure au bas des jambes', 'Légère décoloration'],
  'Jeans slim': ['Usure aux genoux', 'Coutures relâchées', 'Fermeture éclair difficile', 'Tâche légère', 'Légère décoloration sur les cuisses'],
  'Jeans skinny': ['Usure aux genoux', 'Tissu distendu', 'Décoloration sur les cuisses', 'Fermeture abîmée', 'Petit accroc au bas'],
  'Jeans droit': ['Passants de ceinture usés', 'Usure aux genoux', 'Légère tâche', 'Revers légèrement effiloché'],
  'Jeans bootcut': ['Usure au bas des jambes', 'Légère décoloration', 'Coutures relâchées', 'Couture défraîchie'],
  'Jeans flare': ['Bas légèrement effiloché', 'Tissu relâché', 'Usure légère des ourlets'],
  'Jeans boyfriend': ['Effet délavé accentué', 'Revers décousu', 'Coutures fragiles'],
  'Jeans mom': ['Boulochage interne', 'Usure sur les poches', 'Accroc léger', 'Tissu déformé'],
  'Jeans regular': ['Couture relâchée', 'Usure sur le bas', 'Passants fragilisés'],
  'Jeans tapered': ['Décoloration aux plis', 'Accroc sur les poches', 'Couture défraîchie'],
  'Jeans wide leg': ['Revers effilochés', 'Déchirure discrète au bas'],

  'Chinos': ['Tissu froissé', 'Poches déformées', 'Légères taches', 'Couture décousue'],
  'Pantalon': ['Revers décousu', 'Usure légère', 'Passants de ceinture abîmés'],
  'Pantalon cargo': ['Tache sur les poches latérales', 'Velcros usés', 'Coutures des poches affaiblies'],
  'Pantalon ample': ['Tissu déformé', 'Ourlet abîmé', 'Couture fragile'],
  'Pantalon palazzo': ['Effilochage en bas', 'Tissu détendu', 'Revers lâche'],
  'Pantalon de costume': ['Revers décousu', 'Tâche sur la jambe', 'Usure au niveau des plis'],
  'Pantalon à pinces': ['Plis effacés', 'Coutures fragiles', 'Ourlet abîmé'],
  'Pantalon en lin': ['Tissu froissé', 'Fils tirés', 'Usure légère'],

  'Short': ['Usure au bas', 'Accroc sur les coutures', 'Poche déformée'],
  'Short taille haute': ['Décoloration', 'Couture décousue', 'Fermeture abîmée'],
  'Short en jean': ['Bords effilochés', 'Coutures relâchées', 'Usure sur la ceinture'],
  'Short cargo': ['Poche détachée', 'Tâche sur les poches', 'Usure des boutons'],
  'Short cycliste': ['Élastique détendu', 'Tissu distendu', 'Usure aux cuisses'],
  'Short de sport': ['Tissu légèrement déformé', 'Micro-trous', 'Décoloration due à la sueur'],

  'Legging': ['Élastique usé', 'Petit trou discret', 'Usure aux genoux'],
  'Legging de sport': ['Déformation du tissu', 'Tissu transparent', 'Élastique détendu'],
  'Legging taille haute': ['Ceinture distendue', 'Coutures relâchées'],

  'Joggings': ['Poignets élastiques détendus', 'Usure au bas des jambes', 'Taches aux genoux'],
  'Pantalon de survêtement': ['Coutures effilochées', 'Décoloration'],
  'Salopette': ['Boucle rayée', 'Tissu effiloché', 'Fermeture endommagée'],
  'Combinaison pantalon': ['Fermeture éclair coincée', 'Déchirure discrète'],
  'Pantalon doudoune': ['Matelassage aplati', 'Usure sur le rembourrage'],
  'Pantalon de randonnée': ['Griffure sur le tissu', 'Coutures fragiles', 'Tissu imperméable détérioré'],
  'Pantalon de ski': ['Fermeture cassée', 'Doublure abîmée', 'Couture usée'],
  'Pantalon de pluie': ['Déchirure légère', 'Perte d\'imperméabilité'],

  // Hauts
  'Pull': ['Bouloches', 'Légère tâche', 'Trou sur la manche', 'Poignets usés', 'Décoloration'],
  'Chemise': ['Col jauni', 'Poignets usés', 'Bouton manquant', 'Fils tirés'],
  'Bodie': ['Élastique relâché', 'Déformation du tissu', 'Tâche discrète'],
  'Tee-shirt': ['Petite tâche', 'Usure du col', 'Couleur passée', 'Micro-trous'],
  'Veste': ['Fermeture éclair défectueuse', 'Petit accroc', 'Bouton manquant', 'Tâche légère'],
  'Polo': ['Col déformé', 'Usure au bas', 'Boutons absents','Usure du col'],
  'Polaire': ['Tissu pelucheux', 'Fermeture difficile', 'Bouloches aux manches'],
  'Sweat à capuche': ['Cordon manquant', 'Tissu distendu', 'Tâches légères'],
  'Pull col V': ['Usure au col', 'Déchirure discrète'],
  'Pull torsadé': ['Boucles lâches', 'Coutures affaiblies'],
  'Pull col rond': ['Légère déformation', 'Tissu relâché'],
  'Tee-shirt manche longue': ['Usure des manches', 'Coutures effilochées'],
  'Pull col roulé': ['Col distendu', 'Usure au cou'],
  'Sweatshirt': ['Tissu bouloché', 'Usure aux poignets'],
  'Cardigan': ['Bouton manquant', 'Trou sur la manche', 'Déformation'],
  'Gilet': ['Élastique détendu', 'Poignets abîmés'],
  'Blouson': ['Rayures', 'Fermeture défectueuse', 'Doublure usée'],
  'Kimono': ['Fils tirés', 'Tâche légère'],
  'Veste 1/4 zip': ['Zip abîmé', 'Col détendu'],
  'Half zip': ['Usure de la fermeture'],
  'Veste zippée': ['Fermeture coincée'],
  'Chandail': ['Couture détendue'],
  'Top': ['Tâche discrète', 'Fermeture abîmée'],
  'Tunique': ['Décoloration légère'],
  'Crop top': ['Bord effiloché'],
  'Débardeur': ['Élastique usé'],
  'Blouse': ['Tâches légères', 'Col fragile'],
  'Sweat oversize': ['Manches distendues'],
  'Gilet sans manches': ['Zip usé'],

  // Manteaux et vestes
  'Doudoune': ['Plumes sorties', 'Fermeture cassée', 'Tâche sur le rembourrage'],
  'Manteau': ['Usure aux poignets', 'Coutures affaiblies', 'Doublure décousue'],
  'Manteau d\'hiver': ['Capuche abîmée', 'Plumes qui dépassent'],
  'Parka': ['Fermeture abîmée', 'Tissu déchiré'],
  'Blazer': ['Revers abîmé', 'Bouton manquant'],

  // Robes
  'Robe': ['Ourlet défait', 'Tâche légère', 'Couture relâchée'],
  'Robe de soirée': ['Tissu déchiré', 'Tâches', 'Perles manquantes'],

  // Accessoires
  'Écharpe': ['Tissu pelucheux', 'Fils tirés'],
  'Gants': ['Usure aux doigts', 'Perte de matière'],

  // Chaussures
  'Baskets': ['Semelle usée', 'Coutures décousues'],
  'Bottes': ['Cuir rayé', 'Fermeture cassée'],
  'Chaussures de sport': ['Déformation du talon', 'Usure des lacets'],
  'Espadrilles': ['Toile déchirée', 'Semelle abîmée'],

  // Sportswear
  'Maillot de bain': ['Élastique distendu', 'Coutures relâchées'],
  'Maillot de foot': ['Tissu bouloché', 'Numéro effacé'],
};


String customTitleTemplate = "{type} {brand} {info} {color} Taille {size}";

// Liste des tailles pour chaussures en FR
final List<String> shoeSizes = List.generate(43, (index) => (10 + index).toString());

  // Liste des tailles standard
  final List<String> adultSizes = ['XXS','XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'];
  final List<String> kidsSizes = List.generate(14, (index) => '${3 + index} ans'); // Tailles enfants : 3 ans à 16 ans
final List<String> sortedColors = [
  'Noir', 'Blanc', 'Bleu', 'Rouge', 'Vert', 'Gris', 'Jaune', 'Rose', 'Orange',
  'Marron', 'Violet', 'Beige', 'Bleu marine', 'Turquoise', 'Vert Kaki', 'Bordeaux',
  'Fuchsia', 'Doré', 'Argenté', 'Cuivre', 'Émeraude', 'Menthe', 'Lavande',
  'Corail', 'Bleu ciel', 'Anthracite', 'Ocre', 'Sable', 'Bleu jeans'
];
bool showAllColors = false; // Contrôle l'affichage des couleurs supplémentaires
final List<String> initialColors = ['Noir', 'Blanc', 'Gris', 'Bleu', 'Rouge', 'Vert']; // 6 couleurs par défaut

IconData getIconForType(String type) {
  type = type.toLowerCase(); // Convertir en minuscule pour simplifier la comparaison

  if (type.contains('jeans') || type.contains('pantalon') || type.contains('legging') || type.contains('short')) {
    return Icons.local_offer; // Icône pour les bas
  }
  if (type.contains('tee-shirt') || type.contains('sweat') || type.contains('top') || type.contains('polo') || type.contains('blouse')) {
    return Icons.checkroom; // Icône pour les hauts
  }
  if (type.contains('robe') || type.contains('combinaison')) {
    return Icons.dry_cleaning; // Icône pour les robes et combinaisons
  }
  if (type.contains('veste') || type.contains('doudoune') || type.contains('manteau') || type.contains('anorak') || type.contains('blazer') || type.contains('gilet')) {
    return Icons.holiday_village; // Icône pour les vestes et manteaux
  }
  if (type.contains('chaussure') || type.contains('baskets') || type.contains('bottes') || type.contains('espadrilles')) {
    return Icons.sports_martial_arts; // Icône pour les chaussures
  }
  if (type.contains('accessoire') || type.contains('bonnet') || type.contains('casquette') || type.contains('chapeau') || type.contains('écharpe') || type.contains('sac')) {
    return Icons.wallet_travel; // Icône pour les accessoires
  }
  if (type.contains('sous-vêtement') || type.contains('body') || type.contains('pyjama') || type.contains('nuisette')) {
    return Icons.nightlife; // Icône pour les sous-vêtements et vêtements de nuit
  }
  if (type.contains('sport') || type.contains('brassière') || type.contains('maillot') || type.contains('survêtement')) {
    return Icons.sports; // Icône pour les vêtements de sport
  }
  
  return Icons.shopping_bag; // Icône par défaut
}

final List<String> jeansTypes = [
  // Jeans
  'Jeans',
  'Jeans slim',
  'Jeans skinny',
  'Jeans droit',
  'Jeans bootcut',
  'Jeans flare',
  'Jeans boyfriend',
  'Jeans mom',
  'Jeans regular',
  'Jeans tapered',
  'Jeans wide leg',

  // Pantalons
  'Chinos',
  'Pantalon',
  'Pantalon cargo',
  'Pantalon ample',
  'Pantalon palazzo',
  'Pantalon de costume',
  'Pantalon à pinces',
  'Pantalon en lin',

  // Shorts
  'Short',
  'Short taille haute',
  'Short en jean',
  'Short cargo',
  'Short cycliste',
  'Short de sport',

  // Leggings
  'Legging',
  'Legging de sport',
  'Legging taille haute',

  // Autres bas
  'Joggings',
  'Pantalon de survêtement',
  'Salopette',
  'Combinaison pantalon',
  'Pantalon doudoune',
  'Pantalon de randonnée',
  'Pantalon de ski',
  'Pantalon de pluie',
];


  // Liste des types pour suggestions
final List<String> types = [
  // Hauts
  'Pull',
  'Pull Halfzip',
  'Pull d\'hiver',
  'Jupe',
  'Chemise',
  'Bodie',
  'Tee-shirt',
  'Veste',
  'Polo',
  'Polaire',
  'Sweat à capuche',
  'Pull col V',
  'Pull torsadé',
  'Pull col rond',
  'Tee-shirt manche longue',
  'Pull col roulé',
  'Sweatshirt',
  'Cardigan',
  'Gilet',
  'Blouson',
  'Kimono',
  'Veste 1/4 zip',
  'Veste halfzip',
  'Half zip',
  'Veste zippée',
  'Chandail',
  'Top',
  'Tunique',
  'Crop top',
  'Débardeur',
  'Blouse',
  'Sweat oversize',
  'Gilet sans manches',

  // Manteaux et vestes
  'Doudoune',
  'Manteau',
  'Manteau d\'hiver',
  'Manteau en laine',
  'Parka',
  'Poncho',
  'Trench-coat',
  'Caban',
  'Blazer',
  'Cape',
  'Anorak',
  'Imperméable',
  'Pèlerine',

  // Bas
  'Jupe',
  'Jupe-culotte',
  'Jupe midi',
  'Jupe plissée',
  'Jupe en cuir',

  // Robes et combinaisons
  'Robe',
  'Robe de soirée',
  'Robe longue',
  'Robe courte',
  'Robe mi-longue',
  'Robe portefeuille',
  'Robe trapèze',
  'Robe empire',
  'Robe patineuse',
  'Robe moulante',
  'Robe bustier',
  'Robe fleurie',
  'Robe en dentelle',
  'Combinaison',
  'Combi-short',
  'Tailleur',

  // Sous-vêtements et vêtements de nuit
  'Soutien-gorge',
  'Culotte',
  'Boxer',
  'Slip',
  'Body',
  'Sous-vêtement',
  'Pyjama',
  'Nuisette',
  'Peignoir',
  'Chaussettes',
  'Collants',
  'Négligé',
  'Combinaison de nuit',
  'Boxer long',
  'Caraco',
  'Bas',

  // Accessoires
  'Echarpe',
  'Bonnet',
  'Chapeau',
  'Casquette',
  'Gants',
  'Ceinture',
  'Foulard',
  'Lunettes de soleil',
  'Sac',
  'Bijoux',
  'Sac à dos',
  'Sac banane',
  'Pochette',
  'Sac en toile',
  'Ceinture en cuir',
  'Bijoux de cheville',
  'Broche',
  'Barrette',

  // Chaussures
  'Chaussures de sport',
  'Baskets',
  'Chaussures en cuir',
  'Bottes',
  'Bottines',
  'Sandales',
  'Espadrilles',
  'Mocassins',
  'Tongs',
  'Derbies',
  'Chaussures à talons',
  'Chaussures plates',
  'Chaussures de randonnée',
  'Chaussures de ville',
  'Espadrilles compensées',
  'Sandales gladiateur',
  'Sabots',
  'Chaussures bateau',
  'Mules',
  'Chaussures de danse',

  // Sportswear
  'Maillot de bain',
  'Maillot de foot',
  'Tee-shirt de sport',
  'Sweat de sport',
  'Brassière de sport',
  'Survêtement complet',
  'Débardeur de sport',

  // Enfants et bébés
  'Pyjama bébé',
  'Grenouillère',
  'Combinaison bébé',
  'Body bébé',
  'Barboteuse',
  'Robe enfant',
  'Pantalon enfant',
  'Gilet enfant',
  'Veste enfant',
  'Doudoune enfant',
  'Salopette bébé',
  'Combinaison pilote',
  'Bottes de neige',
  'Bavoirs',
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

List<Map<String, String>> savedFavorites = [];
final List<String> selectedColors = []; // Liste des couleurs sélectionnées, max 3
  // Controllers
  final TextEditingController colorController = TextEditingController();
  final TextEditingController defaultController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
  final TextEditingController chestWidthController = TextEditingController(); // Aisselle à aisselle
final TextEditingController shoulderWidthController = TextEditingController(); // Épaule à épaule
final TextEditingController sleeveLengthController = TextEditingController(); // Longueur manche
final TextEditingController totalLengthController = TextEditingController(); // Longueur totale
String productReference = ''; // Référence du produit
final TextEditingController infoController = TextEditingController();
final TextEditingController additionalInfoController = TextEditingController();
String additionalInfo = '';
String customMessageText = '';
String hashtagPrefix = 'Vinted'; // Par défaut
final TextEditingController sizeController = TextEditingController();
  
final TextEditingController purchasePriceController = TextEditingController();
bool isYkkZipper = false; // Pour la fermeture éclair YKK
bool showTagNumberField = false; // Indique si le champ doit rester visible
bool includeConsultMessage = false; // Option pour inclure ou non le message

List<Map<String, String>> recentConfigurations = []; 

final TextEditingController brandController = TextEditingController();  // Pour "Marque"
final TextEditingController typeController = TextEditingController();   // Pour "Type"
bool includeInfoInTitle = false; // Détermine si l'info doit apparaître dans le titre
bool isZippedType() {
  if (selectedType.trim().isEmpty) {
    return false; // Si le type est vide, ne pas afficher la Checkbox.
  }
  List<String> keywords = ['zip', 'zippé', 'veste', 'blouson', 'anorak', 'doudoune', 'gilet zippé', 'manteau'];
  return keywords.any((keyword) => selectedType.toLowerCase().contains(keyword));
}
void showSelectionModal(BuildContext context, List<String> options, String title, Function(String) onSelected) {
  TextEditingController searchController = TextEditingController(); // Contrôleur de recherche
  String selectedOption = ''; // Option sélectionnée
  List<String> filteredOptions = List.from(options)..sort(); // Liste triée par ordre alphabétique
  bool isCustomInput = false; // Flag pour savoir si l'utilisateur a complété manuellement


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredOptions = options
                            .where((option) => option.toLowerCase().contains(value.toLowerCase()))
                            .toList()
                          ..sort(); // Trie les options filtrées
                        isCustomInput = false; // Réinitialisation : considère la saisie comme non personnalisée tant qu'on recherche
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredOptions.length,
                    itemBuilder: (context, index) {
                      return RadioListTile<String>(
                        value: filteredOptions[index],
                        groupValue: selectedOption,
                        title: Text(filteredOptions[index]),
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value ?? '';
                            searchController.text = selectedOption; // Remplace uniquement par l'élément choisi
                            isCustomInput = false; // Réinitialisation après sélection
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      String finalValue = searchController.text.trim();

                      // Prendre la saisie personnalisée uniquement si elle ne correspond à rien dans les options
                      if (!options.contains(finalValue)) {
                        isCustomInput = true; // Indique qu'il s'agit d'une saisie manuelle personnalisée
                      }

                      if (finalValue.isNotEmpty) {
                        Navigator.pop(context);
                        onSelected(finalValue); // Passe la valeur personnalisée ou sélectionnée au parent
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez entrer une valeur ou sélectionner un élément.'),
                          ),
                        );
                      }
                    },
                    child: const Text('Valider la sélection'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}



Map<String, List<String>> materialSuggestions = {
  // Hauts
  'Pull': ['Laine', 'Cachemire', 'Acrylique', 'Coton', 'Mérinos', 'Alpaga', 'Mohair'],
  'Chemise': ['Coton', 'Lin', 'Polyester', 'Soie', 'Viscose'],
  'Bodie': ['Coton', 'Élasthanne', 'Polyester', 'Modal'],
  'Tee-shirt': ['Coton', 'Lin', 'Polyester', 'Jersey', 'Modal'],
  'Polo': ['Coton piqué', 'Polyester', 'Coton'],
  'Polaire': ['Polaire', 'Polyester', 'Laine'],
  'Sweat à capuche': ['Coton', 'Polyester', 'Mélange de coton'],
  'Pull col V': ['Laine', 'Cachemire', 'Acrylique', 'Coton'],
  'Pull torsadé': ['Laine', 'Coton', 'Cachemire', 'Mérinos'],
  'Pull col rond': ['Coton', 'Laine', 'Cachemire', 'Acrylique'],
  'Tee-shirt manche longue': ['Coton', 'Polyester', 'Lin'],
  'Pull col roulé': ['Laine', 'Cachemire', 'Mérinos', 'Acrylique'],
  'Sweatshirt': ['Coton', 'Polyester', 'Molleton'],
  'Cardigan': ['Laine', 'Cachemire', 'Acrylique', 'Coton', 'Mérinos'],
  'Gilet': ['Laine', 'Acrylique', 'Coton', 'Cachemire'],
  'Blouson': ['Cuir', 'Jean', 'Polyester', 'Nylon'],
  'Kimono': ['Coton', 'Viscose', 'Soie', 'Lin'],
  'Veste 1/4 zip': ['Polaire', 'Coton', 'Polyester'],
  'Half zip': ['Laine', 'Coton', 'Polyester'],
  'Veste zippée': ['Cuir', 'Polyester', 'Nylon', 'Coton'],
  'Chandail': ['Laine', 'Acrylique', 'Cachemire'],
  'Top': ['Coton', 'Soie', 'Polyester', 'Viscose'],
  'Tunique': ['Coton', 'Lin', 'Viscose', 'Soie'],
  'Crop top': ['Coton', 'Polyester', 'Élasthanne'],
  'Débardeur': ['Coton', 'Modal', 'Polyester'],
  'Blouse': ['Soie', 'Viscose', 'Coton'],
  'Sweat oversize': ['Coton', 'Polyester'],
  'Gilet sans manches': ['Laine', 'Cachemire', 'Polyester'],

  // Manteaux et vestes
  'Doudoune': ['Nylon', 'Polyester', 'Plumes', 'Synthétique'],
  'Manteau': ['Laine', 'Cachemire', 'Polyester', 'Coton'],
  'Manteau d\'hiver': ['Laine', 'Polyester', 'Nylon', 'Gore-Tex'],
  'Manteau en laine': ['Laine', 'Cachemire', 'Mérinos'],
  'Parka': ['Polyester', 'Coton', 'Nylon'],
  'Poncho': ['Laine', 'Acrylique', 'Cachemire'],
  'Trench-coat': ['Coton', 'Polyester', 'Nylon'],
  'Caban': ['Laine', 'Cachemire', 'Polyester'],
  'Blazer': ['Laine', 'Polyester', 'Lin', 'Coton'],
  'Cape': ['Laine', 'Cachemire', 'Mélange'],
  'Anorak': ['Nylon', 'Polyester', 'Gore-Tex'],
  'Imperméable': ['Nylon', 'Polyester', 'Vinyle'],
  'Pèlerine': ['Laine', 'Polyester'],

  // Bas
  'Jupe': ['Coton', 'Jean', 'Polyester', 'Simili cuir'],
  'Jupe-culotte': ['Coton', 'Lin', 'Polyester'],
  'Jupe midi': ['Soie', 'Viscose', 'Polyester'],
  'Jupe plissée': ['Polyester', 'Soie'],
  'Jupe en cuir': ['Cuir', 'Simili cuir'],

  // Robes et combinaisons
  'Robe': ['Coton', 'Lin', 'Polyester', 'Soie'],
  'Robe de soirée': ['Soie', 'Velours', 'Polyester'],
  'Robe longue': ['Coton', 'Lin', 'Polyester', 'Soie'],
  'Robe courte': ['Coton', 'Polyester', 'Viscose'],
  'Robe mi-longue': ['Coton', 'Viscose', 'Soie'],
  'Robe portefeuille': ['Coton', 'Viscose', 'Soie'],
  'Robe trapèze': ['Coton', 'Lin', 'Polyester'],
  'Robe empire': ['Polyester', 'Soie'],
  'Robe patineuse': ['Polyester', 'Coton', 'Élasthanne'],
  'Robe moulante': ['Polyester', 'Coton', 'Élasthanne'],
  'Robe bustier': ['Soie', 'Polyester', 'Coton'],
  'Robe fleurie': ['Coton', 'Viscose', 'Polyester'],
  'Robe en dentelle': ['Dentelle', 'Polyester', 'Coton'],
  'Combinaison': ['Coton', 'Viscose', 'Polyester'],
  'Combi-short': ['Coton', 'Lin', 'Polyester'],
  'Tailleur': ['Laine', 'Polyester', 'Coton'],

  // Sous-vêtements et vêtements de nuit
  'Soutien-gorge': ['Dentelle', 'Coton', 'Élasthanne'],
  'Culotte': ['Coton', 'Modal', 'Élasthanne'],
  'Boxer': ['Coton', 'Modal', 'Polyester'],
  'Slip': ['Coton', 'Modal', 'Polyester'],
  'Body': ['Coton', 'Polyester', 'Élasthanne'],
  'Sous-vêtement': ['Coton', 'Modal', 'Élasthanne'],
  'Pyjama': ['Coton', 'Modal', 'Viscose'],
  'Nuisette': ['Soie', 'Satin', 'Dentelle'],
  'Peignoir': ['Éponge', 'Coton', 'Velours'],
  'Chaussettes': ['Coton', 'Laine', 'Polyamide'],
  'Collants': ['Nylon', 'Polyamide', 'Élasthanne'],
  'Négligé': ['Soie', 'Satin', 'Dentelle'],
  'Combinaison de nuit': ['Coton', 'Modal', 'Viscose'],
  'Boxer long': ['Coton', 'Élasthanne', 'Polyester'],
  'Caraco': ['Soie', 'Satin', 'Polyester'],
  'Bas': ['Nylon', 'Polyamide', 'Élasthanne'],

  // Accessoires
  'Echarpe': ['Laine', 'Cachemire', 'Coton'],
  'Bonnet': ['Laine', 'Acrylique', 'Cachemire'],
  'Chapeau': ['Feutre', 'Laine', 'Paille'],
  'Casquette': ['Coton', 'Polyester', 'Nylon'],
  'Gants': ['Laine', 'Cuir', 'Polyester'],
  'Ceinture': ['Cuir', 'Simili cuir', 'Tissu'],
  'Foulard': ['Soie', 'Viscose', 'Coton'],
  'Lunettes de soleil': ['Plastique', 'Acier', 'Acétate'],
  'Sac': ['Cuir', 'Simili cuir', 'Toile'],
  'Bijoux': ['Argent', 'Or', 'Acier inoxydable'],
  'Sac à dos': ['Toile', 'Nylon', 'Cuir'],
  'Sac banane': ['Nylon', 'Polyester', 'Cuir'],
  'Pochette': ['Cuir', 'Simili cuir', 'Toile'],
  'Sac en toile': ['Coton', 'Toile', 'Chanvre'],
  'Ceinture en cuir': ['Cuir', 'Simili cuir'],
  'Bijoux de cheville': ['Or', 'Argent', 'Acier inoxydable'],
  'Broche': ['Acier', 'Or', 'Argent'],
  'Barrette': ['Plastique', 'Acier', 'Alliage'],

  // Chaussures
  'Chaussures de sport': ['Mesh', 'Cuir', 'Synthétique'],
  'Baskets': ['Cuir', 'Mesh', 'Polyester'],
  'Chaussures en cuir': ['Cuir', 'Nubuck'],
  'Bottes': ['Cuir', 'Suédine', 'Caoutchouc'],
  'Bottines': ['Cuir', 'Suédine', 'Synthétique'],
  'Sandales': ['Cuir', 'Simili cuir', 'Toile'],
  'Espadrilles': ['Coton', 'Chanvre', 'Lin'],
  'Mocassins': ['Cuir', 'Nubuck', 'Velours'],
  'Tongs': ['Caoutchouc', 'Plastique'],
  'Derbies': ['Cuir', 'Nubuck', 'Suédine'],
  'Chaussures à talons': ['Cuir', 'Satin', 'Velours'],
  'Chaussures plates': ['Cuir', 'Polyester', 'Tissu'],
  'Chaussures de randonnée': ['Gore-Tex', 'Cuir', 'Nylon'],
  'Chaussures de ville': ['Cuir', 'Nubuck', 'Synthétique'],
  'Sabots': ['Cuir', 'Plastique', 'Bois'],
  'Chaussures bateau': ['Cuir', 'Toile'],
  'Mules': ['Cuir', 'Synthétique', 'Velours'],

  // Sportswear
  'Maillot de bain': ['Nylon', 'Polyamide', 'Élasthanne'],
  'Maillot de foot': ['Polyester', 'Coton'],
  'Tee-shirt de sport': ['Polyester', 'Élasthanne'],
  'Sweat de sport': ['Coton', 'Polyester'],
  'Brassière de sport': ['Polyester', 'Élasthanne'],
  'Survêtement complet': ['Polyester', 'Nylon'],
  'Débardeur de sport': ['Polyester', 'Coton'],

  // Enfants et bébés
  'Pyjama bébé': ['Coton', 'Velours', 'Éponge'],
  'Grenouillère': ['Coton', 'Velours', 'Bambou'],
  'Combinaison bébé': ['Coton', 'Laine', 'Polaire'],
  'Body bébé': ['Coton', 'Modal', 'Bambou'],
  'Barboteuse': ['Coton', 'Lin'],
  'Robe enfant': ['Coton', 'Viscose'],
  'Pantalon enfant': ['Coton', 'Jean'],
  'Gilet enfant': ['Laine', 'Acrylique'],
  'Veste enfant': ['Polyester', 'Nylon'],
  'Doudoune enfant': ['Polyester', 'Nylon'],
  'Salopette bébé': ['Coton', 'Jean'],
  'Combinaison pilote': ['Polaire', 'Laine'],
  'Bottes de neige': ['Nylon', 'Caoutchouc'],
  'Bavoirs': ['Coton', 'Éponge']
};


void updateMaterialSuggestions() {
  if (materialSuggestions.containsKey(selectedType)) {
    List<String> suggestions = materialSuggestions[selectedType] ?? [];
    showMaterialSuggestions(suggestions);
  }
}

void showMaterialSuggestions(List<String> suggestions) {
  List<String> selectedMaterials = []; // Liste temporaire pour stocker les matières sélectionnées

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder( // Permet de gérer l'état interne de la boîte de dialogue
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Suggestions de matière'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((material) {
                  bool isSelected = selectedMaterials.contains(material);
                  return FilterChip(
                    label: Text(material),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent.withOpacity(0.3),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedMaterials.add(material); // Ajoute la matière si sélectionnée
                        } else {
                          selectedMaterials.remove(material); // Retire la matière si désélectionnée
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer la boîte de dialogue sans rien valider
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    materialController.text = selectedMaterials.join(', '); // Met à jour le champ avec les matières sélectionnées
                  });
                  Navigator.pop(context); // Fermer la boîte de dialogue après validation
                },
                child: const Text('Valider'),
              ),
            ],
          );
        },
      );
    },
  );
}


  // Dropdown values
  String generatedTitle = '';

  String selectedBrand = '';
  String selectedType = '';
  String selectedSize = 'M'; // Valeur par défaut
  String selectedGender = ''; // Valeur par défaut
  String selectedCondition = 'Très bon état';

  // Checkbox states
  bool includeCustomMessage = false;
  bool fastShipping = true;
  bool authentic = false;
  bool annee = false;
  bool washedAndFolded = true;
  bool showOtherProducts = true;
  bool showHashtags = true;
bool isJeansOrCargoSelected() {
  return selectedType.toLowerCase().contains('jeans') ||
         selectedType.toLowerCase().contains('cargo') ||
         selectedType.toLowerCase().contains('pantalon');
}

Future<void> _loadHashtagsPlus() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    hashtagsPlus = prefs.getStringList('hashtags') ?? []; // Charge la liste des hashtags+
  });
}
double calculateCompletionScore() {
  double score = 0.0;

  // Ajoute des points selon la complétion des champs
  if (selectedBrand.isNotEmpty) score += 20;
  if (selectedType.isNotEmpty) score += 20;
  if (selectedSize.isNotEmpty) score += 15;
  if (colorController.text.isNotEmpty) score += 15;
  if (selectedCondition.isNotEmpty) score += 10;
  if ((selectedCondition == 'Légèrement usé' || selectedCondition == 'Bon état' || selectedCondition == 'Usé' || selectedCondition == 'Fortement usé' || selectedCondition == 'Endommagé' || selectedCondition == 'Très endommagé') && defaultController.text.isNotEmpty) {
    score += 10; // Points pour le défaut si applicable
  }
  if (showHashtags) score += 10; // Points si les hashtags sont activés

  return score; // Score final sur 100
}


  // Generated description
  String generatedDescription = '';


@override
void initState() {
  super.initState();
  _loadTitleTemplate();
  _loadPreferences();
  resetFields();
  _loadHashtagPrefix();
  _loadHashtagsPlus();
  loadRecentConfigurations();
  _loadFavorites();

  // Listener pour afficher la checkbox authentique et garder le champ visible si activé
  numberController.addListener(() {
    setState(() {
      if (includeTagNumber) {
        showTagNumberField = true; // Garder le champ visible si les paramètres sont activés
      }
    });
  });
}

void resetFields() {
  setState(() {
    selectedBrand = '';
    selectedType = '';
    selectedSize = '';
    selectedGender = '';
    selectedCondition = 'Très bon état';
    colorController.clear();
    selectedColors.clear();
    sizeController.clear();
    defaultController.clear();
    lengthController.clear();
    widthController.clear();
    yearController.clear();
    materialController.clear();
    chestWidthController.clear();
    shoulderWidthController.clear();
    sleeveLengthController.clear();
    totalLengthController.clear();
    additionalInfoController.clear();
    numberController.clear();
    additionalInfo = '';
    isYkkZipper = false;
    fastShipping = true;
    isDiscountEnabled = true;
    includeInfoInTitle = false;
    generatedTitle = '';
    generatedDescription = '';
    showHashtags = true;
  });
}



Future<void> _loadFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> loadedFavorites = prefs.getStringList('favorites') ?? [];
  setState(() {
    savedFavorites = loadedFavorites.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
  });
}
Future<void> _loadTitleTemplate() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    customTitleTemplate = prefs.getString('customTitleTemplate') ??
        "{type} {brand} {info} {color} Taille {size}";
  });
}
Widget buildCompletionIndicator() {
  double score = calculateCompletionScore();
  return Column(
    children: [
      const SizedBox(height: 16),
      const Text(
        'Remplissage :',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: score / 100, // Convertir en fraction (entre 0 et 1)
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(
          score == 100 ? Colors.green : Colors.blueAccent,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        '${score.toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: score == 100 ? Colors.green : Colors.black,
        ),
      ),
    ],
  );
}
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  resetFields(); 
}
void showDefectSuggestions(List<String> suggestions) {
  List<String> selectedDefects = []; // Liste temporaire pour stocker les défauts sélectionnés

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Suggestions de défauts'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((defect) {
                  bool isSelected = selectedDefects.contains(defect);
                  return FilterChip(
                    label: Text(defect),
                    selected: isSelected,
                    selectedColor: Colors.redAccent.withOpacity(0.3),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedDefects.add(defect); // Ajoute le défaut sélectionné
                        } else {
                          selectedDefects.remove(defect); // Retire le défaut si désélectionné
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer la boîte de dialogue sans rien valider
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    defaultController.text = selectedDefects.join(', '); // Met à jour le champ de défauts avec les défauts sélectionnés
                  });
                  Navigator.pop(context); // Fermer la boîte de dialogue après validation
                },
                child: const Text('Valider'),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDiscountEnabled = prefs.getBool('subscriber_discount_enabled') ?? true;
      discountPercentage = prefs.getDouble('subscriber_discount_percentage') ?? 5.0;
    includeMaterial = prefs.getBool('includeMaterial') ?? false;
    includeGender = prefs.getBool('includeGender') ?? false;
    includeTagNumber = prefs.getBool('includeTagNumber') ?? false;
    includeYear = prefs.getBool('includeYear') ?? false;
     includeCustomMessage = prefs.getBool('includeCustomMessage') ?? true;
      customMessageText = prefs.getString('customMessageText') ??
        "💬 N'hésitez pas à consulter le reste de mon Vinted ! Je propose des prix avantageux pour les lots.";

    });
      await _loadTitleTemplate();
  }
Future<void> _loadHashtagPrefix() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    hashtagPrefix = prefs.getString('hashtag_prefix') ?? 'Vinted';
  });
}
void generateTitle() {
  setState(() {
    String template = customTitleTemplate.isNotEmpty ? customTitleTemplate : "{type} {brand} {info} {color} Taille {size}";

    String infoPart = includeInfoInTitle && additionalInfo.isNotEmpty ? additionalInfo : "";
    String materialPart = includeMaterial && materialController.text.isNotEmpty ? materialController.text : "";
    String genderPart = includeGender && selectedGender.isNotEmpty ? selectedGender : "";
    String tagPart = includeTagNumber && numberController.text.isNotEmpty ? numberController.text : "";
    String anPart = includeYear && yearController.text.isNotEmpty ? yearController.text : "";

    generatedTitle = template
        .replaceAll("{type}", selectedType.isNotEmpty ? capitalize(selectedType) : "")
        .replaceAll("{brand}", selectedBrand.isNotEmpty ? capitalize(selectedBrand) : "")
        .replaceAll("{info}", infoPart)
        .replaceAll("{color}", selectedColors.isNotEmpty ? selectedColors.join(', ') : "")
        .replaceAll("{size}", selectedSize.toUpperCase())
        .replaceAll("{material}", materialPart)
        .replaceAll("{gender}", genderPart)
        .replaceAll("{annee}", includeYear && yearController.text.isNotEmpty ? yearController.text.trim() : "")
        .replaceAll("{tag}", tagPart);

    generatedTitle = generatedTitle.replaceAll(RegExp(r'\s{2,}'), ' ').trim(); // Enlève les espaces multiples
      isDescriptionReady = generatedTitle.isNotEmpty && generatedDescription.isNotEmpty;
  });
}

void saveRecentConfiguration() async {
  final prefs = await SharedPreferences.getInstance();
  Map<String, String> currentConfig = {
    'brand': selectedBrand,
    'type': selectedType,
    'size': selectedSize,
    'color': colorController.text,
  };
    if (!recentConfigurations.contains(currentConfig)) {
    recentConfigurations.insert(0, currentConfig); // Ajoute au début de la liste
  }

  // Limite à 5 configurations maximum
  if (recentConfigurations.length > 5) {
    recentConfigurations = recentConfigurations.sublist(0, 5); // Garde les 5 plus récentes
  }

  await prefs.setStringList(
    'recentConfigurations',
    recentConfigurations.map((e) => jsonEncode(e)).toList(),
  );

  setState(() {
    recentConfigurations = recentConfigurations; // Mise à jour de l'interface
  });
}

// Charger l'historique des configurations récentes
void loadRecentConfigurations() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> loadedConfigurations = prefs.getStringList('recentConfigurations') ?? [];
  setState(() {
    recentConfigurations = loadedConfigurations.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
  });
}

void saveFavorite() async {
  final prefs = await SharedPreferences.getInstance();
  Map<String, String> currentConfig = {
    'type': selectedType,
    'brand': selectedBrand,
    'color': colorController.text,
    'info': additionalInfo,
    'size': selectedSize,
    'reference': productReference, // Ajoute la référence ici
  };
  setState(() {
    savedFavorites.add(currentConfig);
  });
  await prefs.setStringList(
    'favorites',
    savedFavorites.map((e) => jsonEncode(e)).toList(), // Sauvegarde persistante
  );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Configuration ajoutée aux favoris !")),
  );
}


void loadFavorites(Map<String, String> favorite) {
  setState(() {
    selectedBrand = favorite['brand'] ?? '';
    selectedType = favorite['type'] ?? '';
    selectedSize = favorite['size'] ?? '';
    additionalInfo = favorite['info'] ?? '';
    productReference = favorite['reference'] ?? ''; // Recharge la référence

    // Met à jour les contrôleurs
    brandController.text = selectedBrand;
    typeController.text = selectedType;
    additionalInfoController.text = additionalInfo;
    sizeController.text = selectedSize;
    colorController.text = favorite['color'] ?? '';

    selectedColors.clear();
    if (favorite['color'] != null && favorite['color']!.isNotEmpty) {
      selectedColors.addAll(favorite['color']!.split(', ').map((e) => e.trim()));
    }
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Favori chargé avec succès !")),
  );
}


void deleteFavorite(int index) async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    savedFavorites.removeAt(index);
  });
  await prefs.setStringList(
    'favorites',
    savedFavorites.map((e) => jsonEncode(e)).toList(),
  );
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Favori supprimé !")),
  );
}
String generateProductReference({
  required String size,
  required String brand,
  required String type,
  int counter = 1,
}) {
  // Réduit les codes de la marque et du type pour simplifier la référence
  String brandCode = brand.isNotEmpty ? brand.substring(0, 2).toUpperCase() : ''; // Prend seulement les 2 premières lettres de la marque
  String typeCode = type.isNotEmpty ? type.substring(0, 3).toUpperCase() : '';   // Prend les 3 premières lettres du type
  String counterCode = counter.toString().padLeft(3, '0'); // Utilise seulement 3 chiffres pour le compteur

  // Assemble une référence plus courte
  return '$size$brandCode$typeCode$counterCode';
}


Future<void> saveDescription() async {
  if (generatedTitle.isEmpty || generatedDescription.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez générer une description avant d'enregistrer.")),
    );
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  List<String> savedData = prefs.getStringList('saved_descriptions') ?? [];

  Map<String, String> descriptionData = {
    'title': generatedTitle,
    'description': generatedDescription,
    'brand': selectedBrand,
    'type': selectedType,
    'size': selectedSize,
    'color': colorController.text,
    'condition': selectedCondition,
    'material': materialController.text.trim(),
    'gender': selectedGender,
    'tagNumber': numberController.text.trim(),
    'year': yearController.text.trim(),
    'width': widthController.text.trim(),
    'length': lengthController.text.trim(),
    'shoulderWidth': shoulderWidthController.text.trim(),
    'chestWidth': chestWidthController.text.trim(),
    'totalLength': totalLengthController.text.trim(),
    'sleeveLength': sleeveLengthController.text.trim(),
    'additionalInfo': additionalInfoController.text.trim(),
  };

  savedData.insert(0, jsonEncode(descriptionData)); // Ajoute au début de la liste

  // Limite à 10 descriptions sauvegardées
  if (savedData.length > 10) {
    savedData = savedData.sublist(0, 10);
  }

  await prefs.setStringList('saved_descriptions', savedData);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Description enregistrée !")),
  );
}

void generateDescription() async{
  // Génère les défauts si applicable
  String defect = '';
if (['Satisfaisant', 'Bon état', 'Légèrement usé', 'Usé', 'Fortement usé', 'Endommagé', 'Très endommagé']
    .contains(selectedCondition) &&
    defaultController.text.isNotEmpty) {
  defect = '⚠️ **Défaut** : ${defaultController.text.trim()}\n';
}



  // Génération des dimensions
  
  String dimensions = '';
  String hashtagsFr = generateHashtags(); // Hashtags en français
String hashtagsWithTranslation = await generateHashtagsInGerman(
  selectedType: selectedType,
  selectedBrand: selectedBrand,
  color: colorController.text,
  selectedSize: selectedSize,
  includeHashtagsPlus: includeHashtagsPlus, // Ajoutez cette ligne
  hashtagsPlus: hashtagsPlus, // Ajoutez cette ligne
  material: materialController.text.trim(), // Ajoutez cette ligne
);



// Vérification dynamique pour détecter jeans/pantalon même si ce n'est pas dans la liste
bool containsJeansOrPantalon = selectedType.toLowerCase().contains('jeans') ||
selectedType.toLowerCase().contains('cargo') ||
                               selectedType.toLowerCase().contains('pantalon');


// Dimensions : Largeur / Longueur pour Jeans/Pantalon
if (containsJeansOrPantalon) {
  if (widthController.text.isNotEmpty || lengthController.text.isNotEmpty) {
    dimensions = '📏 **Dimensions** :';
    if (widthController.text.isNotEmpty) {
      dimensions += ' Largeur : ${widthController.text.trim()} cm';
    }
    if (lengthController.text.isNotEmpty) {
      dimensions += '${widthController.text.isNotEmpty ? ', ' : ''}Longueur : ${lengthController.text.trim()} cm';
    }
    dimensions += '\n';
  }
} 
// Autres types de vêtements : Dimensions classiques
else {
  if (chestWidthController.text.isNotEmpty ||
      shoulderWidthController.text.isNotEmpty ||
      sleeveLengthController.text.isNotEmpty ||
      totalLengthController.text.isNotEmpty) {
    dimensions = '📏 **Dimensions** :';
    if (chestWidthController.text.isNotEmpty) {
      dimensions += ' Aisselle à aisselle : ${chestWidthController.text.trim()} cm';
    }
    if (shoulderWidthController.text.isNotEmpty) {
      dimensions += '${chestWidthController.text.isNotEmpty ? ', ' : ''}Épaule à épaule : ${shoulderWidthController.text.trim()} cm';
    }
    if (sleeveLengthController.text.isNotEmpty) {
      dimensions += '${shoulderWidthController.text.isNotEmpty ? ', ' : ''}Longueur des manches : ${sleeveLengthController.text.trim()} cm';
    }
    if (totalLengthController.text.isNotEmpty) {
      dimensions += '${sleeveLengthController.text.isNotEmpty ? ', ' : ''}Longueur totale : ${totalLengthController.text.trim()} cm';
    }
    dimensions += '\n';
  }
}





  // Matière
  String materialText = '';
  if (includeMaterial && materialController.text.isNotEmpty) {
    materialText = '🧵 **Matière** : ${materialController.text.trim()}\n';
  }
  String customMessage = includeCustomMessage
      ? '$customMessageText\n'
      : '';
  // Sexe
  String genderText = '';
  if (includeGender && selectedGender.isNotEmpty) {
    genderText = '👕 **Sexe** : ${selectedGender.trim()}\n';
  }

  // Numéro d'étiquette
  String tagNumberText = '';
  if (includeTagNumber && numberController.text.isNotEmpty) {
    tagNumberText = '🏷️ **Numéro d\'étiquette** : ${numberController.text.trim()}\n';
  }

String yearText = '';
if (includeYear && yearController.text.isNotEmpty) {
  yearText = '📅 **Année** : ${yearController.text.trim()}\n';
}


  // Options (cases à cocher)
  String checkboxesText = '';
  if (fastShipping) checkboxesText += '🚚 Envoi rapide 24h à 48h (ouvrable)\n';
  if (authentic) checkboxesText += '✅ 100% authentique (étiquettes en photo)\n';
  if (isDiscountEnabled) {
    checkboxesText += '🎉 ${discountPercentage.toStringAsFixed(1)}% de réduction pour les abonnés\n';
  }

  // Informations supplémentaires
  String additionalInfoText = additionalInfo.isNotEmpty ? '✨ **Infos supplémentaires** : $additionalInfo\n' : '';
  
  // Fermeture éclair YKK
  String ykkInfo = isYkkZipper ? '🔒 **Fermeture éclair YKK**\n' : '';

  // Construction finale de la description en supprimant les lignes vides
  setState(() {
    generatedDescription = '''
📏 **Taille de l'article** : ${selectedSize.toUpperCase()}
🎨 **Couleur** : ${colorController.text.trim()}
🛍️ **État** : $selectedCondition

$yearText$defect$dimensions$materialText$genderText$tagNumberText

$ykkInfo$additionalInfoText$checkboxesText
$customMessage
💬 *N’hésitez pas à m’envoyer un message si vous avez une question !*

$hashtagsFr
$hashtagsWithTranslation
'''
        .split('\n')
        .where((line) => line.trim().isNotEmpty) // Enlève les lignes vides
        .join('\n\n'); // Ajoute une ligne vide entre chaque section
          isDescriptionReady = generatedTitle.isNotEmpty && generatedDescription.isNotEmpty;
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
    hashtagsList.add('#Mode${cleanForHashtag(selectedType)}'); // Exemple : #ModeTeeShirt
    if (materialController.text.isNotEmpty) {
      hashtagsList.add('#${cleanForHashtag(selectedType)}${cleanForHashtag(materialController.text)}'); // #typematiere
    }
  }

  // Hashtags pour la taille
if (selectedSize.isNotEmpty) {
  hashtagsList.add('#Taille${cleanForHashtag(selectedSize).toUpperCase()}'); // Exemple : #TailleS
  hashtagsList.add('#Taille${cleanForHashtag(selectedSize).toUpperCase()}${cleanForHashtag(selectedType)}'); // Exemple : #TailleMFIT
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
hashtagsList = hashtagsList.toSet().toList();

  return hashtagsList.join(' ').trim(); // Concatène les hashtags avec un espace
}
String generateCleanHashtags() {
  List<String> hashtagsList = generateHashtags().split(' '); // Sépare les hashtags existants
  List<String> cleanHashtagsList = hashtagsList.map((tag) {
    String cleanTag = cleanForHashtag(tag); // Nettoie le contenu du hashtag
    return cleanTag.isNotEmpty ? '#$cleanTag' : ''; // Réajoute '#' après nettoyage
  }).where((tag) => tag.isNotEmpty).toList(); // Supprime les hashtags vides
  return cleanHashtagsList.join(' '); // Rejoint les hashtags nettoyés avec des espaces
}

Future<void> _saveGeneratedDescription() async {
  if (generatedTitle.isEmpty || generatedDescription.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erreur : Impossible de sauvegarder une description vide !")),
    );
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  List<String> savedDescriptions = prefs.getStringList('saved_descriptions') ?? [];

  // 🔹 Vérifie que la description n'est pas déjà présente (évite les doublons)
  Map<String, String> newDescription = {
    'title': generatedTitle,
    'description': generatedDescription,
  };

  String encodedDescription = jsonEncode(newDescription);

  if (!savedDescriptions.contains(encodedDescription)) {
    savedDescriptions.add(encodedDescription);
  } else {
    debugPrint("⚠️ Description déjà enregistrée, pas besoin de la sauvegarder à nouveau.");
  }

  // 🔹 Enregistre la liste mise à jour
  await prefs.setStringList('saved_descriptions', savedDescriptions);

  debugPrint("✅ Description enregistrée avec succès !");
  debugPrint("📌 Contenu de SharedPreferences après ajout : $savedDescriptions");

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('✅ Description enregistrée !')),
  );
}

  // Copier la description générée dans le presse-papiers
  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: generatedDescription));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Description copiée dans le presse-papiers !'),
        duration: Duration(seconds: 1),
      ),
    );
  }
void copyTitleToClipboard() {
  Clipboard.setData(ClipboardData(text: generatedTitle));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Titre copié dans le presse-papiers !'),
      duration: Duration(seconds: 1),
    ),
  );
}

void _validateAndGenerate() {
  // Vérification des champs requis
  if (selectedType.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez sélectionner un type.')),
    );
    return;
  }
  if (selectedSize.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez entrer une taille.')),
    );
    return;
  }
  if (colorController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez sélectionner ou entrer une couleur.')),
    );
    return;
  }
  if (selectedBrand.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez sélectionner une marque.')),
    );
    return;
  }

  // Sauvegarde automatique des valeurs utilisées
  _saveLastUsedValues();

  // Génère une nouvelle référence produit
  setState(() {
    productReference = generateProductReference(
      size: selectedSize,
      brand: selectedBrand,
      type: selectedType,
      counter: savedFavorites.length + 1, // Utilisez la taille des favoris comme compteur
    );
  });

  // Générez le titre et la description
  generateTitle();
  generateDescription();

  // Affiche un message de confirmation
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Titre, description et référence générés !')),
  );
}


void _saveLastUsedValues() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('lastBrand', selectedBrand);
  await prefs.setString('lastType', selectedType);
  await prefs.setString('lastColor', colorController.text);
  await prefs.setString('lastAdditionalInfo', additionalInfo);

}


@override
Widget build(BuildContext context) {
  return Scaffold(
appBar: PreferredSize(
  preferredSize: const Size.fromHeight(80), // Augmente la hauteur de l'AppBar
  child: AppBar(
    title: const Text(''),
actions: [
  IconButton(
  icon: const Icon(Icons.refresh), // Icône de réinitialisation
  tooltip: 'Réinitialiser les champs',
  onPressed: () {
    setState(() {
      resetFields();
    });
     setState(() {});
  },
),
    IconButton(
      icon: const Icon(Icons.copy),
      tooltip: 'Copier le titre',
      onPressed: copyTitleToClipboard,
    ),
    IconButton(
      icon: const Icon(Icons.content_copy),
      tooltip: 'Copier la description',
      onPressed: copyToClipboard,
    ),
    IconButton(
      icon: const Icon(Icons.favorite),
      tooltip: 'Ajouter aux favoris',
      onPressed: saveFavorite,
    ),
    IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Paramètres',
      onPressed: () async {
        bool? settingsChanged = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TitleSettingsScreen()),
        );
        if (settingsChanged == true) {
          await _loadPreferences();
          _loadTitleTemplate();
          setState(() {});
        }
      },
    ),
  ],
  ),
),

    
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // Section Marque
          if (recentConfigurations.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Configurations récentes",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentConfigurations.length,
        itemBuilder: (context, index) {
          final config = recentConfigurations[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text('${config['type']} - ${config['brand']} (${config['size']})'),
              subtitle: Text('Couleur : ${config['color']}'),
              trailing: const Icon(Icons.history),
              onTap: () {
                // Charger la configuration dans le formulaire
                setState(() {
                  selectedBrand = config['brand'] ?? '';
                  selectedType = config['type'] ?? '';
                  selectedSize = config['size'] ?? '';
                  colorController.text = config['color'] ?? '';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Configuration chargée !")),
                );
              },
            ),
          );
        },
      ),
    ],
  ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Marque',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        Card(
  elevation: 2,
  child: ListTile(
    title: Text(selectedBrand.isNotEmpty ? selectedBrand : 'Sélectionnez une marque'),
    trailing: const Icon(Icons.arrow_drop_down),
onTap: () {
  showSelectionModal(context, Brand.brands, 'Sélectionner une marque', (selection) {
    setState(() {
      selectedBrand = selection;
    });
  });
},



  ),
),


          const SizedBox(height: 16),

          // Section Type
          const Text(
            'Type de produit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
Card(
  elevation: 2,
  child: ListTile(
    title: Text(selectedType.isNotEmpty ? selectedType : 'Sélectionnez un type'),
    trailing: const Icon(Icons.arrow_drop_down),
onTap: () {
  showSelectionModal(context, combinedTypes, 'Sélectionner un type', (selection) {
    setState(() {
      selectedType = selection;
    });
  });
},



  ),
),
          const SizedBox(height: 16),
if (isZippedType())
  CheckboxListTile(
    value: isYkkZipper,
    onChanged: (value) {
      setState(() {
        isYkkZipper = value ?? false;
      });
    },
    title: const Text('Fermeture éclair YKK'),
    subtitle: const Text('Indiquez si l\'article utilise une fermeture YKK.'),
  ),
   
   const SizedBox(height: 16),
// Section Matière
if (includeMaterial)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Matière',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: materialController,
        decoration: InputDecoration(
          labelText: 'Entrez la matière (ex. : Coton, Laine...)',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.texture),
          suffixIcon: IconButton(
            icon: const Icon(Icons.lightbulb),
            tooltip: 'Suggestions de matière',
            onPressed: () {
              if (materialSuggestions.containsKey(selectedType)) {
                updateMaterialSuggestions(); // Affiche les suggestions
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Aucune suggestion pour ce type.")),
                );
              }
            },
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  ),

// Section Sexe
if (includeGender)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Sexe',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      DropdownButtonFormField<String>(
        value: selectedGender.isNotEmpty ? selectedGender : null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Sélectionnez le sexe',
          prefixIcon: Icon(Icons.person),
        ),
        items: ['Homme', 'Femme','Enfant Fille', 'Enfant Garçon', 'Peut convenir à un homme ou une femme'].map((gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedGender = value ?? '';
          });
        },
      ),
      const SizedBox(height: 16),
    ],
  ),
  const Text(
        'Année du produit',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
        TextField(
  controller: yearController,
  decoration: const InputDecoration(
    labelText: 'Entrez l\'année',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.calendar_today),
  ),
  keyboardType: TextInputType.number,
),
          const SizedBox(height: 16),
// Section Numéro d'étiquette
// Section Numéro d'étiquette
if (includeTagNumber || showTagNumberField)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Numéro d\'étiquette',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      TextField(
        controller: numberController,
        decoration: const InputDecoration(
          labelText: 'Entrez le numéro d\'étiquette',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.label),
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              authentic = false; // Réinitialise la checkbox si le champ devient vide
            });
          }
        },
      ),

      const SizedBox(height: 16),
      if (numberController.text.isNotEmpty)
        CheckboxListTile(
          value: authentic,
          onChanged: (value) {
            setState(() {
              authentic = value ?? false;
            });
          },
          title: const Text('100% authentique (étiquettes en photo)'),
        ),
    ],
  ),

          const SizedBox(height: 16),

          // Section des dimensions
if (isJeansOrCargoSelected())

  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Dimensions',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: widthController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Largeur (cm)',
          border: OutlineInputBorder(),
          suffixText: 'cm',
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: lengthController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Longueur (cm)',
          border: OutlineInputBorder(),
          suffixText: 'cm',
        ),
      ),
      const SizedBox(height: 16),
    ],
  )
else
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Dimensions',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: shoulderWidthController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Épaule à épaule (cm)',
          border: OutlineInputBorder(),
          suffixText: 'cm',
        ),
      ),
      const SizedBox(height: 16),
            const SizedBox(height: 8),
      TextField(
        controller: chestWidthController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Aisselle à aisselle (cm)',
          border: OutlineInputBorder(),
          suffixText: 'cm',
        ),
      ),

      const SizedBox(height: 16),
            TextField(
        controller: totalLengthController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Longueur totale (cm)',
          border: OutlineInputBorder(),
          suffixText: 'cm',
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: sleeveLengthController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Longueur des manches (cm)',
          border: OutlineInputBorder(),
          suffixText: 'cm',
        ),
      ),
 
      const SizedBox(height: 16),
    ],
  ),
const SizedBox(height: 16),
Text(
  'État de l\'article',
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
Card(
  elevation: 2,
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: DropdownButtonFormField<String>(
      value: selectedCondition,
      items: conditions.map((condition) {
        return DropdownMenuItem<String>(
          value: condition,
          child: Text(condition),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedCondition = value ?? 'Très bon état';
        });
      },
      decoration: const InputDecoration(
        labelText: 'Sélectionnez l\'état',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.check_circle),
      ),
    ),
  ),
),
 const SizedBox(height: 16),
       if (selectedCondition == 'Légèrement usé' || selectedCondition == 'Bon état' || selectedCondition == 'Usé' || selectedCondition == 'Fortement usé' || selectedCondition == 'Endommagé' || selectedCondition == 'Très endommagé')
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Défaut de l’article',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: defaultController,
        decoration: InputDecoration(
          labelText: 'Décrivez le défaut',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.warning),
          suffixIcon: IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              if (defectSuggestions.containsKey(selectedType)) {
                showDefectSuggestions(defectSuggestions[selectedType]!); // Affiche les suggestions
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Aucune suggestion de défaut pour ce type.")),
                );
              }
            },
          ),
        ),
      ),
    ],
  ),


const SizedBox(height: 8),
TextField(
  controller: additionalInfoController,
  decoration: const InputDecoration(
    labelText: 'Exemple : Édition limitée, Neuf en boîte, Référence, etc.',
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.info),
  ),
  onChanged: (value) {
    setState(() {
      additionalInfo = value.trim(); // Met à jour la valeur pour le titre
    });
  },
),
const SizedBox(height: 16),
CheckboxListTile(
  value: includeInfoInTitle,
  onChanged: (value) {
    setState(() {
      includeInfoInTitle = value ?? false;
    });
  },
  title: const Text('Afficher l\'information sur le produit dans le titre ?'),
),

const SizedBox(height: 16),


          // Section Taille
          const Text(
            'Taille',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: sizeController,
            decoration: const InputDecoration(
              labelText: 'Entrez la taille',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.straighten),
            ),
            onChanged: (value) {
              setState(() {
                selectedSize = value.trim();
              });
            },
          ),
          const SizedBox(height: 16),
TextField(
  controller: colorController,
  decoration: InputDecoration(
    labelText: 'Sélectionnez ou saisissez une couleur',
    border: OutlineInputBorder(),
    prefixIcon: const Icon(Icons.color_lens),
  ),
  onChanged: (value) {
    // On permet la saisie manuelle sans intervenir sur selectedColors ici.
  },
  onSubmitted: (value) {
    setState(() {
      if (value.isNotEmpty && !selectedColors.contains(value.trim()) && selectedColors.length < 3) {
        selectedColors.add(value.trim()); // Ajoute la couleur saisie manuellement
        colorController.clear(); // Vide le champ après saisie
      }
    });
  },
),
 const SizedBox(height: 16),
// Section pour afficher les couleurs sélectionnables
Wrap(
  spacing: 8,
  children: (showAllColors ? sortedColors : initialColors).map((color) {
    return ChoiceChip(
      label: Text(color),
      selected: selectedColors.contains(color),
      selectedColor: Colors.blueAccent,
      onSelected: (selected) {
        setState(() {
          // Si la couleur est sélectionnée et qu'on n'a pas atteint la limite de 3 couleurs
          if (selected) {
            if (selectedColors.length < 3) {
              selectedColors.add(color); // Ajoute la couleur sélectionnée
            }
          } else {
            // Si la couleur est désélectionnée, on la supprime de la liste
            selectedColors.remove(color);
          }
          // Met à jour le champ de texte avec les couleurs sélectionnées
          // On conserve les couleurs saisies manuellement et ajoutées
          colorController.text = selectedColors.join(', ');
        });
      },
    );
  }).toList(),
),

// Afficher le bouton "Voir plus" seulement s'il y a plus de 6 couleurs
if (sortedColors.length > 6)
  TextButton(
    onPressed: () {
      setState(() {
        showAllColors = !showAllColors; // Bascule l'affichage des couleurs
      });
    },
    child: Text(showAllColors ? 'Voir moins' : 'Voir plus'),
  ),

          const SizedBox(height: 16),

          // Options supplémentaires
          const Text(
            'Options supplémentaires',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          CheckboxListTile(
            value: fastShipping,
            onChanged: (value) {
              setState(() {
                fastShipping = value ?? false;
              });
            },
            title: const Text('Envoi rapide 24h à 48h (ouvrable)'),
          ),
          CheckboxListTile(
            value: isDiscountEnabled,
            onChanged: (value) {
              setState(() {
                isDiscountEnabled = value ?? false;
              });
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Réduction pour abonnés'),
                if (isDiscountEnabled)
                  Text(
                    '${discountPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.blue),
                  ),
              ],
            ),
          ),
          CheckboxListTile(
            value: showHashtags,
            onChanged: (value) {
              setState(() {
                showHashtags = value ?? false;
              });
            },
            title: const Text('Afficher les hashtags'),
          ),

          const SizedBox(height: 16),
  CheckboxListTile(
    value: includeHashtagsPlus,
    onChanged: (value) {
      setState(() {
        includeHashtagsPlus = value!;
      });
    },
    title: const Text('Inclure Hashtags+'),
  ),

    
          const SizedBox(height: 16),

          // Bouton de génération
          Center(
            child: ElevatedButton.icon(
              onPressed: _validateAndGenerate,
              icon: const Icon(Icons.build),
              label: const Text('Générer le titre et la description'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Titre généré
          if (generatedTitle.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Titre généré :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(generatedTitle),
                const SizedBox(height: 20),
              ],
            ),

          // Description générée
          if (generatedDescription.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description générée :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(generatedDescription),
                const SizedBox(height: 10),
if (productReference.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Référence produit :',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(productReference),
      const SizedBox(height: 16),
    ],
  ),


     const SizedBox(height: 10),
     if (isDescriptionReady)
  Center(
    child: ElevatedButton.icon(
      onPressed: _saveGeneratedDescription,
      icon: const Icon(Icons.save),
      label: const Text('Enregistrer la description'),
    ),
  ),
                ElevatedButton(
                  onPressed: copyTitleToClipboard,
                  child: const Text('Copier le titre'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: copyToClipboard,
                  child: const Text('Copier la description'),
                ),
              ],
            ),
            if (savedFavorites.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Favoris enregistrés",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
ListView.builder(
  shrinkWrap: true, // Important pour éviter les erreurs de layout
  itemCount: savedFavorites.length,
  itemBuilder: (context, index) {
    final favorite = savedFavorites[index];
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          getIconForType(favorite['type'] ?? ''), // Ajout de l'icône spécifique
          color: Colors.blueAccent, // Optionnel : couleur pour uniformiser les icônes
          size: 32, // Taille de l'icône
        ),
        title: Text(
          '${favorite['type']} - ${favorite['brand']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Couleur : ${favorite['color'] ?? "Aucune"}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => deleteFavorite(index),
        ),
        onTap: () {
          loadFavorites(favorite);
        },
      ),
    );
  },
)

    ],
  ),

        ],
        
      ),
      
    ),
  );
}

 
}