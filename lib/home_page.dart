import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'results_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  String? selectedGare;
  String? selectedTypeObject;
  DateTime? startDate;
  DateTime? endDate;
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
      gares = ['Toutes les gares', ...fetchedGares];
    });
  }

  Future<void> loadTypeObject() async {
    final fetchedTypeObjects = await apiService.fetchAllTypeObject();
    setState(() {
      typeObjects = ['Toutes les catégories', ...fetchedTypeObjects];
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
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
              'Retrouvez vos objets perdus en fonction de votre gare, de la catégorie de votre objet et de la date',
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF8BE7FC),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _selectStartDate(context),
                  child: Text(
                    startDate != null
                        ? 'Date début: ${DateFormat('dd MMM yyyy').format(startDate!)}'
                        : 'Sélectionnez la date de début',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF8BE7FC),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _selectEndDate(context),
                  child: Text(
                    endDate != null
                        ? 'Date fin: ${DateFormat('dd MMM yyyy').format(endDate!)}'
                        : 'Sélectionnez la date de fin',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
            ElevatedButton(
              onPressed: (selectedGare != null && selectedTypeObject != null)
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsPage(
                      selectedGare: selectedGare == 'Toutes les gares' ? null : selectedGare,
                      selectedTypeObject: selectedTypeObject == 'Toutes les catégories' ? null : selectedTypeObject,
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  ),
                );
              }
                  : null,
              child: Text('Rechercher'),
            ),
          ],
        ),
      ),
    );
  }
}


