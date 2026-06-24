import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cocktail.dart';

class ApiService {
  static const String _baseUrl =
      'https://www.thecocktaildb.com/api/json/v1/1';

  // Trae varios cócteles que empiecen con una letra (para llenar la app al inicio)
  Future<List<Cocktail>> fetchCocktailsByLetter(String letter) async {
    final url = Uri.parse('$_baseUrl/search.php?f=$letter');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final drinks = data['drinks'];

      if (drinks == null) return []; // esa letra no tiene resultados

      return (drinks as List)
          .map((json) => Cocktail.fromApiJson(json))
          .toList();
    } else {
      throw Exception('Error al consultar la API: ${response.statusCode}');
    }
  }

  // Trae cócteles por nombre (búsqueda)
  Future<List<Cocktail>> fetchCocktailsByName(String name) async {
    final url = Uri.parse('$_baseUrl/search.php?s=$name');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final drinks = data['drinks'];

      if (drinks == null) return [];

      return (drinks as List)
          .map((json) => Cocktail.fromApiJson(json))
          .toList();
    } else {
      throw Exception('Error al consultar la API: ${response.statusCode}');
    }
  }
}