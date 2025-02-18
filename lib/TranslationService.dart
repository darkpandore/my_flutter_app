import 'package:translator/translator.dart';

class TranslationService {
  final translator = GoogleTranslator();

  Future<String> translate(String text, String targetLanguage) async {
    try {
      final translation = await translator.translate(text, to: targetLanguage);
      return translation.text;
    } catch (e) {
      return text; // Retourne le texte original en cas d'erreur
    }
  }
}
Future<String> generateHashtagsInGerman({
  required String selectedType,
  required String selectedBrand,
  required String color,
  required String selectedSize,
  required bool includeHashtagsPlus,
  required List<String> hashtagsPlus,
  required String material,
}) async {
  List<String> hashtagsList = [];
  TranslationService translationService = TranslationService();

  // Traduction des champs nécessaires, sauf la marque
  String translatedType = await translationService.translate(selectedType, 'de');
  String translatedColor = await translationService.translate(color, 'de');
  String translatedSize = await translationService.translate(selectedSize, 'de');
  String translatedMaterial = material.isNotEmpty ? await translationService.translate(material, 'de') : '';

  // Hashtags spécifiques à la marque (non traduite)
  if (selectedBrand.isNotEmpty) {
    hashtagsList.add('#${cleanForHashtag(selectedBrand)}'); // #marque
    if (translatedType.isNotEmpty) {
      hashtagsList.add('#${cleanForHashtag(selectedBrand)}${cleanForHashtag(translatedType)}'); // #marquetype
    }
    hashtagsList.add('#${cleanForHashtag(selectedBrand)}Original'); // #marqueOriginal
  }

  // Hashtags spécifiques au type de vêtement
  if (translatedType.isNotEmpty) {
    hashtagsList.add('#${cleanForHashtag(translatedType)}'); // #type
    hashtagsList.add('#Mode${cleanForHashtag(translatedType)}'); // Exemple : #ModePullover
    if (translatedMaterial.isNotEmpty) {
      hashtagsList.add('#${cleanForHashtag(translatedType)}${cleanForHashtag(translatedMaterial)}'); // #typematiere
    }
  }

  // Hashtags pour la taille
  if (translatedSize.isNotEmpty) {
    hashtagsList.add('#Taille${cleanForHashtag(translatedSize).toUpperCase()}'); // Exemple : #TailleL
    hashtagsList.add('#Taille${cleanForHashtag(translatedSize).toUpperCase()}${cleanForHashtag(translatedType)}'); // Exemple : #TailleLPullover
  }

  // Hashtags pour la matière
  if (translatedMaterial.isNotEmpty) {
    hashtagsList.add('#${cleanForHashtag(translatedMaterial)}'); // #matiere
    hashtagsList.add('#${cleanForHashtag(translatedMaterial)}Style'); // Exemple : #BaumwolleStyle
  }

  // Hashtags pour la couleur
  if (translatedColor.isNotEmpty) {
    hashtagsList.add('#${cleanForHashtag(translatedColor)}'); // #couleur
    hashtagsList.add('#${cleanForHashtag(translatedColor)}Look'); // Exemple : #SchwarzLook
  }

  // Ajout de hashtags populaires et génériques
  hashtagsList.addAll([
    '#Kleidung',
    '#Mode',
    '#StilDesTages',
    '#OOTD', // "Outfit des Tages"
    '#Straßenstil', // Streetwear
    '#Trend', // Tendance
    '#LookBook',
    '#Elegant', // Élégance
    '#Alltagsmode', // Mode du quotidien
  ]);

  // Hashtags pour le type de style selon le produit
  if (['Tee-shirt', 'Sweatshirt', 'Jeans', 'Cargo', 'Veste'].contains(selectedType)) {
    hashtagsList.add('#Straßenstil'); // Streetwear
    hashtagsList.add('#LässigerStil'); // CasualStyle
  }
  if (['Robe', 'Blazer', 'Tailleur', 'Chemisier'].contains(selectedType)) {
    hashtagsList.add('#Eleganz'); // Élégance
    hashtagsList.add('#KlassischSchick'); // ClassiqueChic
  }

  // Suppression des doublons et génération du texte final
  hashtagsList = hashtagsList.toSet().toList();

  return hashtagsList.join(' ').trim(); // Concatène les hashtags avec un espace
}



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
    '&': ''
  };

  String result = input.toLowerCase();
  accentsMap.forEach((key, value) {
    result = result.replaceAll(key, value);
  });

  return result.replaceAll(RegExp(r'[^a-z0-9]'), ''); // Supprime les caractères spéciaux
}
