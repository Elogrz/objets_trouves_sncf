import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';

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
  List<String> gares = [];
  List<String> types = [];

  @override
  void initState() {
    super.initState();
    selectedGare = widget.selectedGare;
    selectedTypeObject = widget.selectedTypeObject;
    fetchItems();
    loadGares();
    loadTypeObject();
  }

  Future<void> loadGares() async {
    final fetchedGares = await apiService.fetchAllGares();
    setState(() {
      gares = ['Toutes les gares', ...fetchedGares];
    });
  }

  Future<void> loadTypeObject() async {
    final fetchedTypes = await apiService.fetchAllTypeObject();
    setState(() {
      types = ['Toutes les catégories', ...fetchedTypes];
    });
  }

  void fetchItems() {
    _futureLostItems = apiService.fetchLostItems(
      gare: selectedGare,
      typeObject: selectedTypeObject,
    );
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
            DropdownButton<String>(
              hint: Text('Sélectionnez la gare'),
              value: selectedGare ?? 'Toutes les gares',
              isExpanded: true,
              dropdownColor: Color(0xFF8BE7FC),
              style: TextStyle(color: Colors.black),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGare = newValue == 'Toutes les gares' ? null : newValue;
                  fetchItems();
                });
              },
              items: gares.map((gare) {
                return DropdownMenuItem(
                  value: gare,
                  child: Text(gare),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              hint: Text('Sélectionnez la catégorie'),
              value: selectedTypeObject ?? 'Toutes les catégories',
              isExpanded: true,
              dropdownColor: Color(0xFF8BE7FC),
              style: TextStyle(color: Colors.black),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTypeObject = newValue == 'Toutes les catégories' ? null : newValue;
                  fetchItems();
                });
              },
              items: types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
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
                        final gareOrigine = fields['gc_obo_gare_origine_r_name'] ?? 'Inconnue';
                        final typeObjet = fields['gc_obo_type_c'] ?? 'Type non spécifié';
                        final natureObjet = fields['gc_obo_nature_c'] ?? 'Nature non spécifiée';
                        final dateObjet = fields['date'] != null
                            ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(fields['date']))
                            : 'Date inconnue';
                        final statut = fields['gc_obo_date_heure_restitution_c'] != null
                            ? 'Objet récupéré le ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(fields['gc_obo_date_heure_restitution_c']))}'
                            : 'Objet à récupérer';

                        return Card(
                          child: ListTile(
                            title: Text(natureObjet),
                            subtitle: Text(
                              'Gare : $gareOrigine\n'
                                  'Type : $typeObjet\n'
                                  'Date : $dateObjet\n'
                                  'Statut : $statut',
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

