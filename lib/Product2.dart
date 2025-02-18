class Product2 {
  final int? id;
  final String title;
  final String brand;
  final String type;
  final String color;
  final String reference;
  final String description;
  final double purchasePrice;
  final String size;
    final String platform; // Ajout pour la gestion multi-plateforme
  final double saleFees; // Frais appliqués sur la vente (ex : Whatnot 10,9% + 0.30 €)
  final String material;
  final String? info; // Information actuelle
  final List<String>? litigationHistory; // Historique des litiges
  final String status;
  final double? salePrice;
  final double? estimatedProfit;
  final double? estimatedSalePrice; // Nouveau champ
  final String? annotations; // Nouveau champ
  final List<String>? photos; // Nouveau champ
  final String? mainPhoto; // Nouveau champ pour photo principale

  Product2({
    this.id,
    required this.title,
    required this.brand,
    required this.type,
        required this.platform, // Plateforme
    this.saleFees = 0.0, // Valeur par défaut
    required this.color,
    required this.reference,
    required this.description,
    required this.purchasePrice,
    required this.size,
    required this.material,
    this.info,
    this.litigationHistory,
    required this.status,
    this.salePrice,
    this.estimatedProfit,
    this.estimatedSalePrice,
    this.annotations = "",
    this.photos = const [],
    this.mainPhoto,
  });

  // Conversion en Map pour la base de données
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'title': title.isNotEmpty ? title : "Sans titre", // Ajout d'une valeur par défaut
    'brand': brand,
    'type': type,
     'platform': platform, // Ajout plateforme
      'saleFees': saleFees, // Ajout des frais de vente
    'color': color,
    'reference': reference,
    'description': description,
    'purchasePrice': purchasePrice,
    'size': size,
    'material': material,
    'info': info ?? '',
    'litigationHistory': litigationHistory?.join('|') ?? '',
    'status': status,
    'salePrice': salePrice,
    'estimatedProfit': estimatedProfit,
    'estimatedSalePrice': estimatedSalePrice,
    'annotations': annotations ?? '',
    'photos': photos?.join('|') ?? '',
    'mainPhoto': mainPhoto ?? '',
  };
}


static Product2 fromMap(Map<String, dynamic> map) {
  return Product2(
    id: map['id'],
    title: map['title'] ?? '',
    brand: map['brand'] ?? '',
    type: map['type'] ?? '',
    platform: map['platform'] ?? 'Non spécifié', // Récupération plateforme
      saleFees: map['saleFees'] ?? 0.0, // Frais de vente
    color: map['color'] ?? '',
    reference: map['reference'] ?? '',
    description: map['description'] ?? '',
    purchasePrice: map['purchasePrice'] ?? 0.0,
    size: map['size'] ?? '',
    material: map['material'] ?? '',
    info: map['info'] ?? '',
    litigationHistory: map['litigationHistory'] != null
        ? (map['litigationHistory'] as String).split('|')
        : [],
    status: map['status'] ?? 'Non vendu',
    salePrice: map['salePrice'] ?? 0.0,
    estimatedProfit: map['estimatedProfit'],
    estimatedSalePrice: map['estimatedSalePrice'],
    annotations: map['annotations'] ?? '',
    photos: map['photos'] != null ? (map['photos'] as String).split('|') : [],
    mainPhoto: map['mainPhoto'] ?? '',
  );
}



  // Copie d'un Product2 avec des modifications
  Product2 copyWith({
    int? id,
    String? title,
    String? brand,
    String? type,
    String? color,
    String? reference,
    String? description,
    double? purchasePrice,
    String? size,
    String? material,
    String? info,
    List<String>? litigationHistory,
    String? status,
    double? salePrice,
    double? estimatedProfit,
    double? estimatedSalePrice,
    String? annotations,
    List<String>? photos,
    String? mainPhoto,
      String? platform, // Ajout du champ pour la plateforme
  double? saleFees, // Ajout du champ pour les frais de vente
  }) {
    return Product2(
      id: id ?? this.id,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      color: color ?? this.color,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      size: size ?? this.size,
      material: material ?? this.material,
      info: info ?? this.info,
      litigationHistory: litigationHistory ?? this.litigationHistory,
      status: status ?? this.status,
      salePrice: salePrice ?? this.salePrice,
      estimatedProfit: estimatedProfit ?? this.estimatedProfit,
      estimatedSalePrice: estimatedSalePrice ?? this.estimatedSalePrice,
      annotations: annotations ?? this.annotations,
      photos: photos ?? this.photos,
      mainPhoto: mainPhoto ?? this.mainPhoto,
          platform: platform ?? this.platform, // Utilisation du champ ajouté
    saleFees: saleFees ?? this.saleFees,  // Utilisation du champ ajouté
    );
  }
}
