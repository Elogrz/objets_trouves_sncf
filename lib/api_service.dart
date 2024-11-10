import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiService {
  final String apiUrl = 'https://data.sncf.com/api/records/1.0/search/?dataset=objets-trouves-restitution';
  static const int nbRows = 50;

  Future<List<dynamic>> fetchLostItems({
    String? gare,
    String? typeObject,
    DateTime? startDate,
    DateTime? endDate,
    int rows = nbRows,
  }) async {
    // Build query parameters
    List<String> queryParams = [
      'rows=$rows',
      if (gare != null) 'q=gc_obo_gare_origine_r_name:"$gare"',
      if (typeObject != null) 'q=gc_obo_type_c:"$typeObject"',
      if (startDate != null) 'q=date>=${DateFormat('yyyy-MM-dd').format(startDate)}',
      if (endDate != null) 'q=date<=${DateFormat('yyyy-MM-dd').format(endDate)}',
    ];

    // Construct the final URI
    final uri = Uri.parse('$apiUrl&${queryParams.join('&')}');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data['records'] is List) {
        return data['records'];
      }
    }
    return [];
  }

  Future<List<String>> fetchAllGares({int rows = nbRows}) async {
    final response = await http.get(Uri.parse('$apiUrl&rows=$rows'));

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

  Future<List<String>> fetchAllTypeObject({int rows = nbRows}) async {
    final response = await http.get(Uri.parse('$apiUrl&rows=$rows'));

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
}