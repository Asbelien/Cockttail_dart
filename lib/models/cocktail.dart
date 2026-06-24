class Cocktail {
  final String? id;
  final String? apiId;
  final String name;
  final String category;
  final String glass;
  final String instructions;
  final String imageUrl;
  final List<String> ingredients; // nuevo

  Cocktail({
    this.id,
    this.apiId,
    required this.name,
    required this.category,
    required this.glass,
    required this.instructions,
    required this.imageUrl,
    this.ingredients = const [],
  });

  factory Cocktail.fromApiJson(Map<String, dynamic> json) {
    // Instrucciones en español, fallback a inglés
    final instructions = (json['strInstructionsES'] as String?)?.isNotEmpty == true
        ? json['strInstructionsES'] as String
        : json['strInstructions'] ?? 'Sin instrucciones';

    // Extraer ingredientes
    final ingredients = <String>[];
    for (int i = 1; i <= 15; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        final entry = (measure != null && measure.trim().isNotEmpty)
            ? '${measure.trim()} ${ingredient.trim()}'
            : ingredient.trim();
        ingredients.add(entry);
      }
    }

    return Cocktail(
      apiId: json['idDrink'] as String?,
      name: json['strDrink'] ?? 'Sin nombre',
      category: json['strCategory'] ?? 'Sin categoría',
      glass: json['strGlass'] ?? 'Sin vaso',
      instructions: instructions,
      imageUrl: json['strDrinkThumb'] ?? '',
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apiId': apiId,
      'name': name,
      'category': category,
      'glass': glass,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'ingredients': ingredients.join('||'), // separador para SQLite
    };
  }

  factory Cocktail.fromMap(Map<String, dynamic> map) {
    final raw = map['ingredients'] as String?;
    final ingredients = (raw != null && raw.isNotEmpty)
        ? raw.split('||')
        : <String>[];
    return Cocktail(
      id: map['id']?.toString(),
      apiId: map['apiId'] as String?,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      glass: map['glass'] ?? '',
      instructions: map['instructions'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      ingredients: ingredients,
    );
  }

  Cocktail copyWith({
    String? id,
    String? apiId,
    String? name,
    String? category,
    String? glass,
    String? instructions,
    String? imageUrl,
    List<String>? ingredients,
  }) {
    return Cocktail(
      id: id ?? this.id,
      apiId: apiId ?? this.apiId,
      name: name ?? this.name,
      category: category ?? this.category,
      glass: glass ?? this.glass,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}