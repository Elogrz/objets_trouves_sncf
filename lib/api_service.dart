import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'https://data.sncf.com/api/records/1.0/search/?dataset=objets-trouves-restitution';

  Future<List<dynamic>> fetchLostItems({String? gare, String? typeObject}) async {
    final uri = Uri.parse(apiUrl + (gare != null ? '&q=$gare' : '') + (typeObject != null ? '+$typeObject' : ''));
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['records'] ?? [];
    } else {
      throw Exception('Erreur lors de la récupération des données');
    }
  }

  Future<List<String>> fetchAllGares() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      Set<String> gares = {};
      for (var record in data['records']) {
        if (record['fields']['gc_obo_gare_origine_r_name'] != null) {
          gares.add(record['fields']['gc_obo_gare_origine_r_name']);
        }
      }

      return gares.toList();
    } else {
      throw Exception('Erreur lors de la récupération des gares');
    }
  }

  Future<List<String>> fetchAllTypeObject() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      Set<String> typeObject = {};
      for (var record in data['records']) {
        if (record['fields']['gc_obo_type_c'] != null) {
          typeObject.add(record['fields']['gc_obo_type_c']);
        }
      }

      return typeObject.toList();
    } else {
      throw Exception('Erreur lors de la récupération des types d\'objet');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFilteredObjects({
    String? gare,
    String? typeObject,
  }) async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      List<Map<String, dynamic>> filteredItems = [];
      for (var record in data['records']) {
        var fields = record['fields'];

        if ((gare == null || fields['gc_obo_gare_origine_r_name'] == gare) &&
            (typeObject == null || fields['gc_obo_type_c'] == typeObject)) {
          filteredItems.add(fields);
        }
      }

      return filteredItems;
    } else {
      throw Exception('Erreur lors de la récupération des objets filtrés');
    }
  }

  Future<List<String>> get gares async {
    return await fetchAllGares();
  }

  Future<List<String>> get typeObjects async {
    return await fetchAllTypeObject();
  }
}
