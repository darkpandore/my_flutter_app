import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Product2.dart'; 

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

 Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'stock.db');

  return await openDatabase(
    path,
    version: 9, // Augmentée pour mainPhoto
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          brand TEXT,
          type TEXT,
          color TEXT,
          reference TEXT,
          description TEXT,
          purchasePrice REAL,
          size TEXT,
          material TEXT,
          info TEXT,
          litigationHistory TEXT,
          annotations TEXT,
          photos TEXT,
          mainPhoto TEXT, -- Nouvelle colonne pour photo principale
          status TEXT DEFAULT 'Non vendu',
          salePrice REAL,
          estimatedProfit REAL,
          estimatedSalePrice REAL
          platform TEXT -- Nouvelle colonne pour la plateforme de vente
          saleFees REAL DEFAULT 0.0, 
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 3) {
        await db.execute("ALTER TABLE products ADD COLUMN info TEXT;");
      }
      if (oldVersion < 4) {
        await db.execute("ALTER TABLE products ADD COLUMN litigationHistory TEXT;");
      }
      if (oldVersion < 5) {
        await db.execute("ALTER TABLE products ADD COLUMN estimatedSalePrice REAL;");
      }
      if (oldVersion < 6) {
        await db.execute("ALTER TABLE products ADD COLUMN annotations TEXT;");
        await db.execute("ALTER TABLE products ADD COLUMN photos TEXT;");
      }
      if (oldVersion < 7) {
        await db.execute("ALTER TABLE products ADD COLUMN mainPhoto TEXT;");
      }
       if (oldVersion < 8) {
        await db.execute("ALTER TABLE products ADD COLUMN platform TEXT;");
      }
       if (oldVersion < 9) {
        await db.execute("ALTER TABLE products ADD COLUMN saleFees REAL DEFAULT 0.0;");
      }
    },
  );
}
Future<void> deleteLastProductByStatus(String status) async {
  final db = await database; // Accéder à l'instance de la base de données
  // Récupère l'ID du dernier produit ayant le statut donné
  final result = await db.query(
    'products', // Nom de la table
    where: 'status = ?', // Condition
    whereArgs: [status],
    orderBy: 'id DESC', // Trier par ID décroissant pour obtenir le plus récent
    limit: 1, // Limite à un seul produit
  );

  if (result.isNotEmpty) {
    final idToDelete = result.first['id']; // Récupérer l'ID du produit
    await db.delete(
      'products',
      where: 'id = ?', // Supprimer par ID
      whereArgs: [idToDelete],
    );
  }
}


Future<String?> checkReference(String size, String ref) async {
  final db = await database;
  final combinedRef = "$size$ref";

  // Vérifier si la référence existe déjà
  final existing = await db.query(
    'products',
    where: 'reference = ?',
    whereArgs: [combinedRef],
  );

  if (existing.isNotEmpty) {
    final product = Product2.fromMap(existing.first);

    // Si le statut est "Vente terminé" ou "Vente validée", avertir l'utilisateur
    if (product.status == "Vente terminé" || product.status == "Vente validée") {
      return "Attention : La référence $combinedRef est utilisée pour un produit avec le statut '${product.status}'. Voulez-vous continuer ?";
    }

    // Sinon, proposer une nouvelle référence
    final similarRefs = await db.query(
      'products',
      columns: ['reference'],
      where: 'reference LIKE ?',
      whereArgs: ["$size%"],
    );

    // Extraire les numéros existants
    final existingNumbers = similarRefs
        .map((row) => int.tryParse((row['reference'] as String).replaceFirst(size, '')))
        .where((num) => num != null)
        .cast<int>()
        .toList()
      ..sort();

    // Trouver une référence libre
    int suggestedNumber = 1;
    for (final num in existingNumbers) {
      if (num == suggestedNumber) {
        suggestedNumber++;
      } else {
        break;
      }
    }

    // Retourner une suggestion de référence alternative
    return "$size${suggestedNumber.toString().padLeft(3, '0')}";
  }

  // Retourne null si la référence n'existe pas
  return null;
}



Future<void> saveProduct(Product2 product) async {
  final db = await database;

  Map<String, dynamic> productMap = product.toMap();
  productMap.removeWhere((key, value) => value == null || value == '');

  print("Données enregistrées : $productMap"); // Ajoutez un log pour vérifier les données sauvegardées.

  await db.insert(
    'products',
    productMap,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}


Future<List<Product2>> loadProducts() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('products');

  if (maps.isEmpty) {
    print("Aucun produit trouvé"); // Vérification des résultats vides.
  }

  return List.generate(maps.length, (i) {
    print("Produit chargé : ${maps[i]}"); // Ajoutez un log pour voir ce qui est chargé.
    return Product2.fromMap(maps[i]);
  });
}

Future<void> addPhoto(int productId, String photoPath) async {
  final db = await database;

  // Charger les photos existantes
  final product = await db.query(
    'products',
    where: 'id = ?',
    whereArgs: [productId],
  );

  if (product.isNotEmpty) {
    // Assurez-vous que 'photos' est une chaîne avant d'utiliser split
    final existingPhotos = product.first['photos'] as String?; 
    final photos = existingPhotos?.split('|') ?? []; // Si null, utilise une liste vide
    photos.add(photoPath);

    await db.update(
      'products',
      {'photos': photos.join('|')},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
}


  Future<void> updateProduct(Product2 product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    print("Produit mis à jour : ${product.title}");
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
