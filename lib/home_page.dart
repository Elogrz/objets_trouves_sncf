import 'package:flutter/material.dart';
import 'api_service.dart';
import 'results_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
//TODO ajouter une ligne "toutes les gares" et "toutes les catégories" dans le menu déroulant au lieu de tout afficher quand on séléctionne rien et rendre le bouton rechercher inaccessible si rien n'est séléctionné

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  String? selectedGare;
  String? selectedTypeObject;
  List<String> gares = [];
  List<String> typeObjects = [];

  @override
  void initState() {
    super.initState();
    loadGares();
    loadTypeObject();
  }

  Future<void> loadGares() async {
    final fetchedGares = await apiService.fetchAllGares();
    setState(() {
      gares = fetchedGares;
    });
  }

  Future<void> loadTypeObject() async {
    final fetchedTypeObjects = await apiService.fetchAllTypeObject();
    setState(() {
      typeObjects = fetchedTypeObjects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF161A25),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/sncf_logo_dark.png"),
            SizedBox(height: 16),
            Text(
              'Bonjour',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              'Retrouvez vos objets perdus en fonction de votre gare et de la catégorie de votre objet.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              hint: Text('Sélectionnez la gare', style: TextStyle(color: Colors.white)),
              value: selectedGare,
              isExpanded: true,
              dropdownColor: Color(0xFF8BE7FC),
              style: TextStyle(color: Colors.white),
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
            SizedBox(height: 8),
            DropdownButton<String>(
              hint: Text('Sélectionnez la catégorie', style: TextStyle(color: Colors.white)),
              value: selectedTypeObject,
              isExpanded: true,
              dropdownColor: Color(0xFF8BE7FC),
              style: TextStyle(color: Colors.white),
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsPage(
                      selectedGare: selectedGare,
                      selectedTypeObject: selectedTypeObject,
                    ),
                  ),
                );
              },
              child: Text('Rechercher'),
            ),
          ],
        ),
      ),
    );
  }
}
