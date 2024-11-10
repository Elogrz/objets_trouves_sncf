import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';

//TODO ajouter une ligne "toutes les gares" et "toutes les catégories" dans le menu déroulant au lieu de tout afficher quand on séléctionne rien

class ResultsPage extends StatefulWidget {
  final String? selectedGare;
  final String? selectedTypeObject;

  ResultsPage({this.selectedGare, this.selectedTypeObject});

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final ApiService apiService = ApiService();
  String? selectedGare;
  String? selectedTypeObject;
  Future<List<dynamic>>? _futureLostItems;

  @override
  void initState() {
    super.initState();
    selectedGare = widget.selectedGare;
    selectedTypeObject = widget.selectedTypeObject;
    fetchItems();
  }

  void fetchItems() {
    if (selectedGare != null && selectedTypeObject != null) {
      _futureLostItems = apiService.fetchLostItems(
        gare: selectedGare,
        typeObject: selectedTypeObject,
      );
    } else if (selectedGare != null) {
      _futureLostItems = apiService.fetchLostItems(
        gare: selectedGare,
        typeObject: null,
      );
    } else if (selectedTypeObject != null) {
      _futureLostItems = apiService.fetchLostItems(
        gare: null,
        typeObject: selectedTypeObject,
      );
    } else {
      _futureLostItems = apiService.fetchLostItems(
        gare: null,
        typeObject: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/sncf_logo.png', height: 30),
            SizedBox(width: 10),
            Text("Objets trouvés"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<String>>(
              future: apiService.fetchAllGares(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur lors du chargement des gares');
                } else {
                  final gares = snapshot.data!;
                  return DropdownButton<String>(
                    hint: Text('Sélectionnez la gare'),
                    value: selectedGare,
                    isExpanded: true,
                    dropdownColor: Color(0xFF8BE7FC),
                    style: TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGare = newValue;
                        fetchItems();
                      });
                    },
                    items: gares.map((gare) {
                      return DropdownMenuItem(
                        value: gare,
                        child: Text(gare),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            FutureBuilder<List<String>>(
              future: apiService.fetchAllTypeObject(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur lors du chargement des catégories');
                } else {
                  final types = snapshot.data!;
                  return DropdownButton<String>(
                    hint: Text('Sélectionnez la catégorie'),
                    value: selectedTypeObject,
                    isExpanded: true,
                    dropdownColor: Color(0xFF8BE7FC),
                    style: TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTypeObject = newValue;
                        fetchItems();
                      });
                    },
                    items: types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _futureLostItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur lors de la récupération des objets.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun objet trouvé.'));
                  } else {
                    final items = snapshot.data!;
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final fields = item['fields'] ?? {};
                        //TODO ajouter si l'objet a deja ete récupéré ou non
                        final gareOrigine = fields['gc_obo_gare_origine_r_name'] ?? 'Inconnue';
                        final typeObjet = fields['gc_obo_type_c'] ?? 'Type non spécifié';
                        final natureObjet = fields['gc_obo_nature_c'] ?? 'Nature non spécifiée';
                        final dateObjet = fields['date'] != null
                            ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(fields['date']))
                            : 'Date inconnue';

                        return Card(
                          child: ListTile(
                            title: Text(natureObjet),
                            subtitle: Text(
                              'Gare : $gareOrigine\n'
                                  'Type : $typeObjet\n'
                                  'Date : $dateObjet',
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
