import 'package:flutter/material.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  String? selectedGare;
  String? selectedTypeObject;
  Future<List<dynamic>>? _futureLostItems;
  List<String> gares = [];
  List<String> typeObjects = [];

  @override
  void initState() {
    super.initState();
    loadGares();
    loadTypeObject();
  }

  Future<void> loadGares() async {
    try {
      final fetchedGares = await apiService.fetchAllGares();
      setState(() {
        gares = fetchedGares;
      });
    } catch (e) {
      print('Erreur lors de la récupération des gares : $e');
    }
  }

  Future<void> loadTypeObject() async {
    try {
      final fetchedTypeObjects = await apiService.fetchAllTypeObject();
      setState(() {
        typeObjects = fetchedTypeObjects;
      });
    } catch (e) {
      print('Erreur lors de la récupération des types d\'objets : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SNCF Connect'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (gares.isNotEmpty)
              DropdownButton<String>(
                hint: Text('Sélectionnez la gare'),
                value: selectedGare,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGare = newValue;
                  });
                },
                items: gares.map((gare) {
                  return DropdownMenuItem(
                    value: gare,
                    child: Text(gare),
                  );
                }).toList(),
              ),
            if (typeObjects.isNotEmpty)
              DropdownButton<String>(
                hint: Text('Sélectionnez la catégorie'),
                value: selectedTypeObject,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTypeObject = newValue;
                  });
                },
                items: typeObjects.map((typeObject) {
                  return DropdownMenuItem(
                    value: typeObject,
                    child: Text(typeObject),
                  );
                }).toList(),
              ),
            ElevatedButton(
              onPressed: () {
                if (selectedGare != null && selectedTypeObject != null) {
                  print('Gare sélectionnée: $selectedGare');
                  print('Type d\'objet sélectionné: $selectedTypeObject');
                  setState(() {
                    _futureLostItems = apiService.fetchFilteredObjects(
                      gare: selectedGare!,
                      typeObject: selectedTypeObject!,
                    );
                  });
                } else {
                  print('Veuillez sélectionner une gare et un type d\'objet');
                }
              },
              child: Text('Rechercher'),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _futureLostItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun objet trouvé.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return Card(
                          child: ListTile(
                            title: Text(item['gc_obo_nature_c'] ?? 'N/A'),
                            subtitle: Text(
                              'Gare: ${item['gc_obo_gare_origine_r_name'] ?? 'N/A'}\n'
                                  'Date: ${item['date'] ?? 'N/A'}',
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
